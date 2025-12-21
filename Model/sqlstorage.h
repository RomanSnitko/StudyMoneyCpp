#pragma once

#include "istorage.h"
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDate>
#include <QDebug>

class SqlStorage final : public IStorage {
public:
    SqlStorage();
    ~SqlStorage() override;

    bool connect() override;
    bool loginUser(const QString &login, const QString &passHash, int &outId, double &outBudget, double &outSpent) override;
    bool registerUser(const QString &login, const QString &passHash, const QString &email) override;

    void addExpense(int userId, double amount, const QString &category, double &newTotalSpent) override;
    void addIncome(int userId, double amount, double &newTotalBudget) override;

    QList<QVariantMap> getLastOperations(int userId, int limit) override;
    QList<QVariantMap> getWeeklyExpenses(int userId) override;
    QList<QVariantMap> getAnalytics(int userId) override;

    void addGoal(int userId, const QString &name, double target) override;
    QList<GoalData> getGoals(int userId) override;
    void addMoneyToGoal(int goalId, double amount) override;

    QList<QVariantMap> getIncomeHistory(int userId) override;
    void addIncomeTransaction(int userId, double amount, const QString &source) override;

    QMap<QString, double> getCategoryTotalsForMonth(int userId) override;

    QString lastError() const override { return m_error; }

private:
    QSqlDatabase m_db;
    QString m_error;
};
