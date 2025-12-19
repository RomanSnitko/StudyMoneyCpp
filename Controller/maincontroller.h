#ifndef MAINCONTROLLER_H
#define MAINCONTROLLER_H

#include <QObject>
#include <QVariant>
#include "../Model/storage.h"

class MainController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double budget READ budget NOTIFY budgetChanged)
    Q_PROPERTY(double spent READ spent NOTIFY spentChanged)
    Q_PROPERTY(double remainingAmount READ remainingAmount NOTIFY remainingAmountChanged)

    Q_PROPERTY(QVariantList lastExpenses READ lastExpenses NOTIFY lastExpensesChanged)
    Q_PROPERTY(QVariantList weeklyExpenses READ weeklyExpenses NOTIFY weeklyExpensesChanged)
    Q_PROPERTY(QVariantList analyticsData READ analyticsData NOTIFY analyticsDataChanged)
    Q_PROPERTY(QVariantList goalsModel READ goalsModel NOTIFY goalsModelChanged)
    Q_PROPERTY(QVariantList incomeHistoryModel READ incomeHistoryModel NOTIFY incomeHistoryModelChanged)

    Q_PROPERTY(bool authorized READ authorized NOTIFY authorizedChanged)
    Q_PROPERTY(QString authError READ authError NOTIFY authErrorChanged)
    Q_PROPERTY(bool loading READ loading NOTIFY loadingChanged)

    Q_PROPERTY(QStringList recommendationText READ recommendationText NOTIFY recommendationTextChanged)
    Q_PROPERTY(QVariantList recommendationChart READ recommendationChart NOTIFY recommendationChartChanged)

public:
    explicit MainController(QObject *parent = nullptr);
    ~MainController();

    double budget() const { return m_budget; }
    double spent() const { return m_spent; }
    double remainingAmount() const { return m_budget - m_spent; }
    bool authorized() const { return m_authorized; }
    bool loading() const { return m_loading; }
    QString authError() const { return m_authError; }

    QVariantList lastExpenses() const;
    QVariantList weeklyExpenses() const;
    QVariantList analyticsData() const;
    QVariantList goalsModel() const;
    QVariantList incomeHistoryModel() const;

    QStringList recommendationText() const { return m_recommendations; }
    QVariantList recommendationChart() const { return m_recChartData; }

    Q_INVOKABLE void generateAnalyticsReport();

    Q_INVOKABLE void login(const QString &login, const QString &password);
    Q_INVOKABLE void registerUser(const QString &login, const QString &password, const QString &email);
    Q_INVOKABLE void addExpense(double amount, const QString& category);
    Q_INVOKABLE void addIncome(double amount, const QString &source);
    Q_INVOKABLE void createGoal(const QString &name, double target);
    Q_INVOKABLE void topUpGoal(int goalId, double amount);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void refreshData();

signals:
    void budgetChanged();
    void spentChanged();
    void remainingAmountChanged();
    void lastExpensesChanged();
    void weeklyExpensesChanged();
    void analyticsDataChanged();
    void goalsModelChanged();
    void incomeHistoryModelChanged();
    void authorizedChanged();
    void authErrorChanged();
    void loadingChanged();
    void recommendationTextChanged();
    void recommendationChartChanged();

private:
    IStorage* m_storage;
    double m_budget = 0;
    double m_spent = 0;

    bool m_authorized = false;
    bool m_loading = false;
    QString m_authError;
    int m_currentUserId = -1;
    QStringList m_recommendations;
    QVariantList m_recChartData;
};

#endif
