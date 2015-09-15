#ifndef RELAY_H
#define RELAY_H

#include <QObject>
#include <QTimer>
#include <QTime>
#include <src/sysfsGpio/gpio-sysfs.h>
#include <memory>

class Relay : public QObject
{
    Q_OBJECT

public:
    explicit Relay(int index, int pinNumber, QObject *parent = 0);
    ~Relay();

    void start();
    void stop();

    void pause();
    void resume();

    unsigned int interval() const { return interval_/1000; }
    void setInterval(const int seconds);
    void setEnabled(const bool state) { enabled_ = state; }

    bool enabled() const { return enabled_; }
    bool running() const { return ticker_->isActive(); }

private:

    bool enabled_=true;
    
    QTime start_time_ = QTime::currentTime();
    unsigned long interval_ = 1000; // new timer interval in ms
    unsigned long current_interval_; // current timer interval in ms

    int relayIndex_;
    int pinNumber_;

    QTimer *ticker_ = new QTimer(this);

signals:
    void relayComplete(const unsigned int index);
    void progressChanged(const double progress);

public slots:
    void timeout();

};

#endif // RELAY_H
