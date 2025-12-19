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

class SqlStorage : public IStorage {
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

    QString lastError() const override { return m_error; }

    QMap<QString, double> getCategoryTotalsForMonth(int userId) override;

private:
    QSqlDatabase m_db;
    QString m_error;
};
