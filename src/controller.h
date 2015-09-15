#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QObject>
#include <QDate>
#include "scheduler.h"
#include "relay.h"

const int PIN_NUMBERS[] = {21,20,26,16,19,13,12,6,5,7,8,11,25,9,10,24,23,22,27,18,17,15,14,4,3,2};

class Controller : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int relayCount READ relayCount NOTIFY relayCountChanged)

    // Process properties
    Q_PROPERTY(bool running READ running NOTIFY runningChanged)
    Q_PROPERTY(bool paused READ paused NOTIFY pausedChanged)
    Q_PROPERTY(int currentRelay READ currentRelay NOTIFY currentRelayChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(double totalProgress READ totalProgress NOTIFY totalProgressChanged)
    Q_PROPERTY(int totalInterval READ totalInterval NOTIFY totalIntervalChanged)

    // Schedule properties
    Q_PROPERTY(bool scheduled READ scheduled NOTIFY scheduledChanged)
    Q_PROPERTY(QDateTime runDateTime READ runDateTime NOTIFY runDateTimeChanged)

public:
    explicit Controller(QObject *parent = 0);

    int relayCount() const { return relayCount_; }

    // Process
    bool running() const { return running_; }
    bool paused() const { return paused_; }
    int currentRelay() const { return currentRelay_; }

    // Progress
    double progress() const { return progress_; }
    double totalProgress() const { return totalProgress_; }
    int totalInterval() const { return totalInterval_; }

    // Schedule
    bool scheduled() const { return scheduled_; }
    QDateTime runDateTime() const { return scheduler_->runDateTime(); }

    void addRelay(int pinNumber);

    // Process functions
    Q_INVOKABLE void startProcess();
    Q_INVOKABLE void stopProcess();
    Q_INVOKABLE void pauseProcess();
    Q_INVOKABLE void resumeProcess();
    Q_INVOKABLE void skipRelay();
    Q_INVOKABLE void startNextRelay();

    // Relay functions
    Q_INVOKABLE void startRelay(const unsigned int index);
    Q_INVOKABLE void stopRelay(const unsigned int index);
    Q_INVOKABLE void setRelayEnabled(const unsigned int index, const bool state);
    Q_INVOKABLE void setRelayInterval(const unsigned int index, const int seconds);
    Q_INVOKABLE bool relayState(const unsigned int index);

    // Schedule functions
    Q_INVOKABLE void updateSchedule(const int startHour, const int dayInterval);
    Q_INVOKABLE void enableSchedule(const bool state);

private:
    int relayCount_=0;
    bool running_=false; // true when process is running (relays are turing on in sequence)
    bool paused_=false;
    int currentRelay_=-1;
    double progress_=0;
    double totalProgress_=0;
    int totalInterval_=0;
    bool scheduled_=false; // true when scheduler is on

    // Manages when the next run will start
    Scheduler *scheduler_ = new Scheduler(this);

    // Contains all of the relays
    std::vector<Relay*> relays_;

signals:
    void relayCountChanged();
    void runningChanged();
    void pausedChanged();
    void currentRelayChanged();
    void runDateTimeChanged();
    void scheduledChanged();
    void progressChanged();
    void totalProgressChanged();
    void totalIntervalChanged();

public slots:
    void onScheduledRun();
    void onRelayComplete(const unsigned int index);
    void onProgressChanged(const double progress);
};

#endif // CONTROLLER_H
