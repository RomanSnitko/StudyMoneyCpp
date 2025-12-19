#include "maincontroller.h"
#include <QCryptographicHash>
#include <QTimer>

MainController::MainController(QObject *parent) : QObject(parent) {
    m_storage = new SqlStorage();
    m_storage->connect();
}

MainController::~MainController() {
    delete m_storage;
}

QVariantList MainController::lastExpenses() const {
    if (!m_authorized) return {};

    QList<QVariantMap> raw = m_storage->getLastOperations(m_currentUserId, 7);

    QVariantList list;
    for (const auto &item : raw) {
        list.append(item);
    }
    return list;
}

QVariantList MainController::weeklyExpenses() const {
    if (!m_authorized) return {};
    QList<QVariantMap> raw = m_storage->getWeeklyExpenses(m_currentUserId);
    QVariantList list;
    for(const auto &m : raw) list.append(m);
    return list;
}

QVariantList MainController::analyticsData() const {
    if (!m_authorized) return {};
    QList<QVariantMap> raw = m_storage->getAnalytics(m_currentUserId);
    QVariantList list;
    for(const auto &m : raw) list.append(m);
    return list;
}

QVariantList MainController::goalsModel() const {
    if (!m_authorized) return {};
    QList<GoalData> goals = m_storage->getGoals(m_currentUserId);
    QVariantList list;
    for (const auto &g : goals) {
        QVariantMap map;
        map["id"] = g.id;
        map["name"] = g.name;
        map["target"] = g.target;
        map["current"] = g.current;
        double progress = (g.target > 0) ? (g.current / g.target) : 0;
        if (progress > 1.0) progress = 1.0;
        map["progress"] = progress;
        list.append(map);
    }
    return list;
}

QVariantList MainController::incomeHistoryModel() const {
    if (!m_authorized) return {};
    QList<QVariantMap> raw = m_storage->getIncomeHistory(m_currentUserId);
    QVariantList list;
    for(const auto &m : raw) list.append(m);
    return list;
}

void MainController::refreshData() {
    emit weeklyExpensesChanged();
    emit analyticsDataChanged();
    emit goalsModelChanged();
    emit incomeHistoryModelChanged();
    emit lastExpensesChanged();
}

void MainController::login(const QString &login, const QString &password) {
    m_loading = true; emit loadingChanged(); m_authError = ""; emit authErrorChanged();
    QTimer::singleShot(300, this, [=]() {
        QByteArray hash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256).toHex();
        if (m_storage->loginUser(login, QString(hash), m_currentUserId, m_budget, m_spent)) {
            m_authorized = true;

            emit budgetChanged(); emit spentChanged(); emit remainingAmountChanged();
            emit lastExpensesChanged(); emit authorizedChanged();
            refreshData();
        } else {
            m_authError = m_storage->lastError(); emit authErrorChanged();
        }
        m_loading = false; emit loadingChanged();
    });
}

void MainController::registerUser(const QString &login, const QString &password, const QString &email) {
    m_loading = true; emit loadingChanged();
    QTimer::singleShot(300, this, [=]() {
        QByteArray hash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha256).toHex();
        if (m_storage->registerUser(login, QString(hash), email)) m_authError = "Регистрация успешна!";
        else m_authError = m_storage->lastError();
        emit authErrorChanged(); m_loading = false; emit loadingChanged();
    });
}

void MainController::addExpense(double amount, const QString &category) {
    m_storage->addExpense(m_currentUserId, amount, category, m_spent);

    emit spentChanged(); emit remainingAmountChanged();
    emit lastExpensesChanged();
    refreshData();
}

void MainController::addIncome(double amount, const QString &source) {
    m_storage->addIncome(m_currentUserId, amount, m_budget);
    QString finalSource = source.isEmpty() ? "Пополнение" : source;
    m_storage->addIncomeTransaction(m_currentUserId, amount, finalSource);

    emit budgetChanged(); emit remainingAmountChanged();
    emit lastExpensesChanged();
    refreshData();
}

void MainController::createGoal(const QString &name, double target) {
    if (!m_authorized) return;
    m_storage->addGoal(m_currentUserId, name, target);
    emit goalsModelChanged();
}

void MainController::topUpGoal(int goalId, double amount) {
    if (!m_authorized) return;
    m_storage->addMoneyToGoal(goalId, amount);
    m_budget -= amount;
    emit budgetChanged(); emit remainingAmountChanged(); emit goalsModelChanged();
}

void MainController::logout() {
    m_authorized = false; m_currentUserId = -1;
    emit authorizedChanged();
}


void MainController::generateAnalyticsReport() {
    if (!m_authorized) return;

    m_loading = true; emit loadingChanged();

    QTimer::singleShot(500, this, [=]() {
        QMap<QString, double> totals = m_storage->getCategoryTotalsForMonth(m_currentUserId);

        m_recommendations.clear();
        m_recChartData.clear();
        double totalSpent = 0;

        for (auto it = totals.begin(); it != totals.end(); ++it) {
            totalSpent += it.value();
        }
        for (auto it = totals.begin(); it != totals.end(); ++it) {
            QVariantMap map;
            map["category"] = it.key();
            map["amount"] = it.value();
            map["percent"] = (totalSpent > 0) ? (it.value() / totalSpent) : 0;
            m_recChartData.append(map);
        }

        double foodSpent = totals.value("Еда", 0);
        if (foodSpent > 400) {
            m_recommendations.append("🍎 <b>Питание:</b> Вы потратили " + QString::number(foodSpent) + " Br на еду. Это выше нормы. Рекомендуем составить рацион питания на неделю и готовить дома, чтобы сократить расходы.");
        } else if (foodSpent > 0) {
            m_recommendations.append("✅ <b>Питание:</b> Расходы на еду в пределах нормы.");
        }

        double housingSpent = totals.value("Жилье", 0);
        if (housingSpent > 600) {
            m_recommendations.append("🏠 <b>Жилье:</b> Расходы на жилье (" + QString::number(housingSpent) + " Br) превышают среднюю стоимость по рынку (600 Br). Рекомендуем рассмотреть варианты аренды в другом районе или поиск соседа.");
        }

        double funSpent = totals.value("Развлечения", 0);
        if (funSpent > 150) {
            m_recommendations.append("🎉 <b>Развлечения:</b> Вы потратили " + QString::number(funSpent) + " Br на досуг. Попробуйте найти бесплатные мероприятия или ограничить походы в кафе.");
        }

        if (m_recommendations.isEmpty() && totalSpent == 0) {
            m_recommendations.append("ℹ️ Пока недостаточно данных для анализа. Добавьте свои расходы.");
        }

        m_loading = false; emit loadingChanged();

        emit recommendationTextChanged();
        emit recommendationChartChanged();
    });
}
