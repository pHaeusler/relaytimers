#include "relay.h"
#include <iostream>

Relay::Relay(int index, int pinNumber, QObject *parent)
    : QObject(parent),
      relayIndex_(index),
      pinNumber_(pinNumber)
{
    //Configure pin as output
    gpio_export(pinNumber_);
    gpio_set_dir(pinNumber_, 1);
    gpio_set_value(pinNumber_, 0);

    // Configure the timer
    ticker_->setSingleShot(false);
    ticker_->setInterval(50);
    connect(ticker_, SIGNAL(timeout()), this, SLOT(timeout()));

    // Signal to notify relay has completed
    connect(this,
            SIGNAL(relayComplete(const unsigned int)),
            parent,
            SLOT(onRelayComplete(const unsigned int)));
    
    // Signal to update progress
    connect(this,
            SIGNAL(progressChanged(const double)),
            parent,
            SLOT(onProgressChanged(const double)));
}

Relay::~Relay(){
    gpio_unexport(pinNumber_);
}

void Relay::start(){
    gpio_set_value(pinNumber_, 1);
    start_time_ = QTime::currentTime();
    current_interval_ = interval_;
    ticker_->start();
}

void Relay::stop(){
    gpio_set_value(pinNumber_, 0);
    ticker_->stop();
}

void Relay::pause(){
    if ( ticker_->isActive() ){
        gpio_set_value(pinNumber_, 0);
        ticker_->stop();
        current_interval_ = QTime::currentTime().msecsTo( start_time_.addMSecs( current_interval_ ) );
    }
}

void Relay::resume(){
    if ( !ticker_->isActive() ){
        gpio_set_value(pinNumber_, 1);
        start_time_ = QTime::currentTime();
        ticker_->start();
    }
}

void Relay::setInterval(const int seconds){
    interval_ = seconds*1000;
    current_interval_ = interval_;
}

void Relay::timeout(){
    // Milliseconds remaining
    int remaining_ms = QTime::currentTime().msecsTo( start_time_.addMSecs( current_interval_ ) );

    // Check if expired or has been switched off
    if ( remaining_ms < 0 || !enabled_ ){
        // Complete
        stop();
        emit relayComplete( relayIndex_ );
    }
    else {
        // Calculate Progress
        double elapsed_ms = double(interval_) - double(remaining_ms);
        double progress = elapsed_ms / double(interval_);
        emit progressChanged( progress );
    } 
}
