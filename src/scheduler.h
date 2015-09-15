#ifndef SCHEDULER_H
#define SCHEDULER_H

#include <QObject>
#include <QTimer>
#include <QDateTime>
#include <memory>

class Scheduler : public QObject
{
    Q_OBJECT

public:
    explicit Scheduler(QObject *parent = 0);

    void start();
    void stop();

    void updateSchedule(const int startHour, const int dayInterval);

    QDateTime runDateTime() const { return runDateTime_; }

private:
    QDateTime runDateTime_ = QDateTime::currentDateTime();
    QDateTime startDateTime_ = QDateTime::currentDateTime();

    int startHour_ = 8;
    int dayInterval_ = 1;

    QTimer *timer_ = new QTimer(this);

signals:
    void scheduledRun();

public slots:
    void timeout();

};

#endif // SCHEDULER_H
