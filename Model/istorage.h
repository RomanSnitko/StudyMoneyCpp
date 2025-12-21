#pragma once

#include <QString>
#include <QList>
#include <QVariant>
#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDate>

struct ExpenseData {
    QString date;
    double amount;
    QString category;
};

struct GoalData {
    int id;
    QString name;
    double target;
    double current;

    QVariantMap toMap() const {
        double progress = (target > 0) ? (current / target) : 0;
        if (progress > 1.0) progress = 1.0;

        return {
            { "id", id },
            { "name", name },
            { "target", target },
            { "current", current },
            { "progress", progress }
        };
    }
};

class IStorage {
public:
    virtual ~IStorage() {}
    virtual bool connect() = 0;
    virtual bool loginUser(const QString &login, const QString &passHash, int &outId, double &outBudget, double &outSpent) = 0;
    virtual bool registerUser(const QString &login, const QString &passHash, const QString &email) = 0;

    virtual void addExpense(int userId, double amount, const QString &category, double &newTotalSpent) = 0;
    virtual void addIncome(int userId, double amount, double &newTotalBudget) = 0;

    virtual QList<QVariantMap> getLastOperations(int userId, int limit) = 0;
    virtual QList<QVariantMap> getWeeklyExpenses(int userId) = 0;
    virtual QList<QVariantMap> getAnalytics(int userId) = 0;

    virtual void addGoal(int userId, const QString &name, double target) = 0;
    virtual QList<GoalData> getGoals(int userId) = 0;
    virtual void addMoneyToGoal(int goalId, double amount) = 0;

    virtual QList<QVariantMap> getIncomeHistory(int userId) = 0;
    virtual void addIncomeTransaction(int userId, double amount, const QString &source) = 0;

    virtual QString lastError() const = 0;

    virtual QMap<QString, double> getCategoryTotalsForMonth(int userId) = 0;
};
