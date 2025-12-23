#include "sqlstorage.h"

SqlStorage::SqlStorage() {}

SqlStorage::~SqlStorage() {
    if (m_db.isOpen()) m_db.close();
}

bool SqlStorage::connect() {
    if (m_db.isOpen()) return true;
    m_db = QSqlDatabase::addDatabase("QPSQL");
    m_db.setHostName("127.0.0.1");
    m_db.setPort(5432);
    m_db.setDatabaseName("db");
    m_db.setUserName("postgres");
    m_db.setPassword("31072007");

    if (!m_db.open()) {
        m_error = m_db.lastError().text();
        return false;
    }
    return true;
}

bool SqlStorage::loginUser(const QString &login, const QString &passHash, int &outId, double &outBudget, double &outSpent) {
    if (!connect()) return false;
    QSqlQuery query;
    query.prepare("SELECT id, budget, spent, password_hash FROM users WHERE login = :l");
    query.bindValue(":l", login);

    if (query.exec() && query.next()) {
        QString dbHash = query.value("password_hash").toString();
        if (dbHash == passHash) {
            outId = query.value("id").toInt();
            outBudget = query.value("budget").toDouble();
            outSpent = query.value("spent").toDouble();
            return true;
        } else {
            m_error = "Неверный пароль";
            return false;
        }
    }
    m_error = "Пользователь не найден";
    return false;
}

bool SqlStorage::registerUser(const QString &login, const QString &passHash, const QString &email) {
    if (!connect()) return false;
    QSqlQuery query;
    query.prepare("INSERT INTO users (login, email, password_hash, budget, spent) VALUES (:l, :e, :p, 0, 0)");
    query.bindValue(":l", login);
    query.bindValue(":e", email);
    query.bindValue(":p", passHash);

    if (query.exec()) return true;
    m_error = query.lastError().text();
    return false;
}

void SqlStorage::addExpense(int userId, double amount, const QString &category, double &newTotalSpent) {
    if (!connect()) return;
    QSqlQuery qGet;
    qGet.prepare("SELECT spent FROM users WHERE id = :id");
    qGet.bindValue(":id", userId);
    if(qGet.exec() && qGet.next()) {
        newTotalSpent = qGet.value(0).toDouble() + amount;
        QSqlQuery qUpd;
        qUpd.prepare("UPDATE users SET spent = :s WHERE id = :id");
        qUpd.bindValue(":s", newTotalSpent);
        qUpd.bindValue(":id", userId);
        qUpd.exec();
    }
    QSqlQuery qIns;
    qIns.prepare("INSERT INTO expenses (user_id, amount, category, date_added) VALUES (:uid, :amt, :cat, CURRENT_DATE)");
    qIns.bindValue(":uid", userId);
    qIns.bindValue(":amt", amount);
    qIns.bindValue(":cat", category);
    qIns.exec();
}

void SqlStorage::addIncome(int userId, double amount, double &newTotalBudget) {
    if (!connect()) return;
    QSqlQuery qGet;
    qGet.prepare("SELECT budget FROM users WHERE id = :id");
    qGet.bindValue(":id", userId);
    if(qGet.exec() && qGet.next()) {
        newTotalBudget = qGet.value(0).toDouble() + amount;
        QSqlQuery qUpd;
        qUpd.prepare("UPDATE users SET budget = :b WHERE id = :id");
        qUpd.bindValue(":b", newTotalBudget);
        qUpd.bindValue(":id", userId);
        qUpd.exec();
    }
}

QList<QVariantMap> SqlStorage::getLastOperations(int userId, int limit) {
    QList<QVariantMap> result;
    if (!connect()) return result;

    QSqlQuery query;

    QString sql = R"(
        SELECT amount, category, date_added as op_date, 0 as type
        FROM expenses WHERE user_id = :uid
        UNION ALL
        SELECT amount, source as category, date_received as op_date, 1 as type
        FROM incomes WHERE user_id = :uid
        ORDER BY op_date DESC, type ASC
        LIMIT :lim
    )";

    query.prepare(sql);
    query.bindValue(":uid", userId);
    query.bindValue(":lim", limit);

    if (query.exec()) {
        while(query.next()) {
            QVariantMap map;

            QDate date = query.value("op_date").toDate();
            map["date"] = date.toString("dd.MM");

            map["amount"] = query.value("amount").toDouble();
            map["category"] = query.value("category").toString();
            map["type"] = query.value("type").toInt();
            result.append(map);
        }
    } else {
        qDebug() << "getLastOperations ERROR:" << query.lastError().text();
    }
    return result;
}

QList<QVariantMap> SqlStorage::getWeeklyExpenses(int userId) {
    QList<QVariantMap> list;
    if (!connect()) return list;
    QSqlQuery query;
    query.prepare("SELECT amount, category, to_char(date_added, 'DD.MM') as d_str FROM expenses WHERE user_id = :uid AND date_added >= CURRENT_DATE - 7 ORDER BY date_added DESC, id DESC");
    query.bindValue(":uid", userId);
    if (query.exec()) {
        while (query.next()) {
            QVariantMap map;
            map["amount"] = query.value("amount").toDouble();
            map["category"] = query.value("category").toString();
            map["date"] = query.value("d_str").toString();
            list.append(map);
        }
    }
    return list;
}

QList<QVariantMap> SqlStorage::getAnalytics(int userId) {
    QList<QVariantMap> list;
    if (!connect()) return list;
    QSqlQuery query;
    query.prepare("SELECT category, SUM(amount) as total FROM expenses WHERE user_id = "
                  ":uid GROUP BY category ORDER BY total DESC");
    query.bindValue(":uid", userId);

    double totalSum = 0;
    struct Temp { QString c; double v; };
    QList<Temp> tmp;

    if (query.exec()) {
        while (query.next()) {
            double v = query.value("total").toDouble();
            tmp.append({query.value("category").toString(), v});
            totalSum += v;
        }
    }
    for (const auto &item : tmp) {
        QVariantMap map;
        map["category"] = item.c;
        map["amount"] = item.v;
        map["percent"] = (totalSum > 0) ? (item.v / totalSum) : 0;
        list.append(map);
    }
    return list;
}

void SqlStorage::addGoal(int userId, const QString &name, double target) {
    if (!connect()) return;
    QSqlQuery query;
    query.prepare("INSERT INTO goals (user_id, name, target_amount, current_amount) VALUES (:uid, :n, :t, 0)");
    query.bindValue(":uid", userId);
    query.bindValue(":n", name);
    query.bindValue(":t", target);
    query.exec();
}

QList<GoalData> SqlStorage::getGoals(int userId) {
    QList<GoalData> list;
    if (!connect()) return list;
    QSqlQuery query;
    query.prepare("SELECT id, name, target_amount, current_amount FROM goals WHERE user_id = :uid");
    query.bindValue(":uid", userId);
    if (query.exec()) {
        while(query.next()) {
            list.append({
                query.value("id").toInt(),
                query.value("name").toString(),
                query.value("target_amount").toDouble(),
                query.value("current_amount").toDouble()
            });
        }
    }
    return list;
}

void SqlStorage::addMoneyToGoal(int goalId, double amount) {
    if (!connect()) return;
    QSqlQuery qUser;
    qUser.prepare("SELECT user_id FROM goals WHERE id = :gid");
    qUser.bindValue(":gid", goalId);
    if(qUser.exec() && qUser.next()) {
        int userId = qUser.value(0).toInt();
        QSqlQuery qUpdUser;
        qUpdUser.prepare("UPDATE users SET budget = budget - :amt WHERE id = :uid");
        qUpdUser.bindValue(":amt", amount);
        qUpdUser.bindValue(":uid", userId);
        qUpdUser.exec();
        QSqlQuery qUpdGoal;
        qUpdGoal.prepare("UPDATE goals SET current_amount = current_amount + :amt WHERE id = :gid");
        qUpdGoal.bindValue(":amt", amount);
        qUpdGoal.bindValue(":gid", goalId);
        qUpdGoal.exec();
    }
}

QList<QVariantMap> SqlStorage::getIncomeHistory(int userId) {
    QList<QVariantMap> list;
    if (!connect()) return list;
    QSqlQuery query;
    query.prepare("SELECT amount, source, to_char(date_received, 'DD.MM') as d_str FROM incomes WHERE user_id = :uid ORDER BY date_received DESC, id DESC");
    query.bindValue(":uid", userId);
    if (query.exec()) {
        while (query.next()) {
            QVariantMap map;
            map["amount"] = query.value("amount").toDouble();
            map["source"] = query.value("source").toString();
            map["date"] = query.value("d_str").toString();
            list.append(map);
        }
    }
    return list;
}

void SqlStorage::addIncomeTransaction(int userId, double amount, const QString &source) {
    if (!connect()) return;
    QSqlQuery query;
    query.prepare("INSERT INTO incomes (user_id, amount, source, date_received) VALUES (:uid, :amt, :src, CURRENT_DATE)");
    query.bindValue(":uid", userId);
    query.bindValue(":amt", amount);
    query.bindValue(":src", source);
    query.exec();
}

QMap<QString, double> SqlStorage::getCategoryTotalsForMonth(int userId) {
    QMap<QString, double> result;
    if (!connect()) return result;

    QSqlQuery query;

    query.prepare("SELECT category, SUM(amount) as total "
                  "FROM expenses "
                  "WHERE user_id = :uid AND date_added >= CURRENT_DATE - 30 "
                  "GROUP BY category");
    query.bindValue(":uid", userId);

    if (query.exec()) {
        while (query.next()) {
            result.insert(query.value("category").toString(), query.value("total").toDouble());
        }
    }
    return result;
}

