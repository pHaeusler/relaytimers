#include "controller.h"
#include <iostream>

using namespace std;

Controller::Controller(QObject *parent) : QObject(parent)
{
    // Add the default relays
    for (auto i : PIN_NUMBERS){
        addRelay(i);
    }
}

void Controller::addRelay(int pinNumber){
    relays_.push_back( new Relay(relayCount_, pinNumber, this) );
    relayCount_++;
    emit relayCountChanged();
}

void Controller::startProcess(){
    stopProcess();
    running_ = true;
    emit runningChanged();
    paused_ = false;
    emit pausedChanged();
    progress_ = 0;
    emit progressChanged();
    totalProgress_ = 0;
    emit totalProgressChanged();

    // Start the first enabled relay
    startNextRelay();
}

void Controller::stopProcess(){
    running_ = false;
    emit runningChanged();
    paused_ = false;
    emit pausedChanged();
    progress_ = 0;
    emit progressChanged();
    totalProgress_ = 0;
    emit totalProgressChanged();
    currentRelay_ = -1;
    emit currentRelayChanged();

    // Stop all of the relays
    for( Relay *relay : relays_ ){
        relay->stop();
    }
}

void Controller::pauseProcess(){
    if ( ! paused_ ){
        if( currentRelay_ < (int)relays_.size() ){
            relays_.at(currentRelay_)->pause();
            paused_ = true;
            emit pausedChanged();
        }
    }
}

void Controller::resumeProcess(){
    if ( paused_ ){
        if( currentRelay_ < (int)relays_.size() ){
            relays_.at(currentRelay_)->resume();
            paused_ = false;
            emit pausedChanged();
        }
    }
}

void Controller::skipRelay(){
    if ( running_ ){
        if( currentRelay_ < (int)relays_.size() ){
            stopRelay(currentRelay_);
            startNextRelay();
        }
    }
}

void Controller::startNextRelay(){
    do{
        if ( currentRelay_ + 1 < (int)relays_.size() ){
            currentRelay_++;
            emit currentRelayChanged();
        }
        else {
            stopProcess();
            return;
        }
    } while ( ! relays_.at(currentRelay_)->enabled() );

    relays_.at(currentRelay_)->start();
}

void Controller::startRelay(const unsigned int index) {
    // Can only start single relay when process is not currently running
    if ( ! running_ ){
        if ( index < relays_.size() ){
            relays_.at(index)->start();
            currentRelay_ = index;
            emit currentRelayChanged();
            progress_ = 0;
            emit progressChanged();
            totalProgress_ = 0;
            emit totalProgressChanged();
            paused_ = false;
            emit pausedChanged();
        }
    }
}

void Controller::stopRelay(const unsigned int index) {
    if ( index < relays_.size() ){
        relays_.at(index)->stop();
        progress_ = 0;
        emit progressChanged();
        totalProgress_ = 0;
        emit totalProgressChanged();
        paused_ = false;
        emit pausedChanged();

        if ( ! running_ ){
            currentRelay_ = -1;
            emit currentRelayChanged();
        }
    }
}

void Controller::setRelayEnabled(const unsigned int index, const bool state) {
    if ( index < relays_.size() ){
        relays_.at(index)->setEnabled(state);
    }
}

void Controller::setRelayInterval(const unsigned int index, const int seconds) {
    if ( index < relays_.size() ){
        relays_.at(index)->setInterval(seconds);
    }
}

void Controller::updateSchedule(const int startHour, const int dayInterval) {
    scheduler_->updateSchedule(startHour, dayInterval);
    emit scheduledChanged();
}

bool Controller::relayState(const unsigned int index){
    if ( index < relays_.size() ){
        return relays_.at(index)->running();
    }
    return false;
}

void Controller::enableSchedule(const bool state){
    if ( state ){
        scheduler_->start();
        scheduled_ = true;
        emit scheduledChanged();
    } else {
        scheduler_->stop();
        scheduled_ = false;
        emit scheduledChanged();
    }
}

void Controller::onScheduledRun(){
    if ( !running_ ){
        cout << "Starting scheduled run at: " << QDateTime::currentDateTime().toString(Qt::LocalDate).toStdString() << endl;
        startProcess();
    } else {
        cout << "Trying to start a scheduled run but its already running..." << endl;
    }
}

void Controller::onRelayComplete(const unsigned int) {
    // Check in process (otherwise testing)
    if( running_ ){
        // Check for last relay
        if(currentRelay_ + 1 >= (int)relays_.size() ) {
            currentRelay_ = -1;
            emit currentRelayChanged();
            running_ = false;
            emit runningChanged();
        }
        else if( running_ ){
            startNextRelay();
        }
    }
    // Just finished a test
    else {
        currentRelay_ = -1;
        emit currentRelayChanged();
    }

    progress_ = 0;
    emit progressChanged();
    paused_ = false;
    emit pausedChanged();
}

void Controller::onProgressChanged(const double progress){
    if ( running_ && currentRelay_ < (int)relays_.size() && currentRelay_ >= 0){
        // Calculate the total interval
        int totalInterval = 0;
        for( Relay *relay : relays_ ){
            if (relay->enabled()){
                totalInterval += relay->interval();
            }
        }
        totalInterval_ = totalInterval;
        emit totalIntervalChanged();

        int elapsed = 0;
        if ( currentRelay_ > 0){
            for( int i=0; i<currentRelay_; ++i){
                if (relays_[i]->enabled()){
                    elapsed += relays_[i]->interval();
                    std::cout << "Int: " << relays_[i]->interval() << ", of relay: " << i << std::endl;
                }
            }
        }
        elapsed += progress*relays_[currentRelay_]->interval();

        // Calculate total progress
        totalProgress_ = double(elapsed) / double(totalInterval);
        emit totalProgressChanged();
    }

    progress_ = progress;
    emit progressChanged();
}
