#include "scheduler.h"
#include <iostream>

Scheduler::Scheduler(QObject *parent) : QObject(parent)
{
    // Update schedule
    updateSchedule(startHour_, dayInterval_);

    // Configure the timer
    timer_->setSingleShot(false);
    connect(timer_, SIGNAL(timeout()), this, SLOT(timeout()));

    // Signal to trigger the scheduled run
    connect(this, SIGNAL(scheduledRun()), parent, SLOT(onScheduledRun()));
}

void Scheduler::start(){
    startDateTime_ = QDateTime::currentDateTime();
    timer_->start();
}

void Scheduler::stop(){
    timer_->stop();
}

void Scheduler::timeout(){
    startDateTime_ = QDateTime::currentDateTime();
    updateSchedule(startHour_, dayInterval_);
    emit scheduledRun();
}

void Scheduler::updateSchedule(const int startHour, const int dayInterval){
    startHour_ = startHour;
    dayInterval_ = dayInterval;

    runDateTime_ = QDateTime::currentDateTime().addDays( dayInterval );
    runDateTime_.setTime( QTime(startHour, 0) );

    int seconds = QDateTime::currentDateTime().secsTo(runDateTime_);

    timer_->setInterval( seconds*1000 );
}
