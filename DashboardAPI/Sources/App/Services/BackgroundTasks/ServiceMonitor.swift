//
//  ServiceMonitor.swift
//  App
//
//  Created by Patrick Gatewood on 6/23/19.
//

import Vapor

class ServiceMonitor: Vapor.Service {
    private let pingInterval: TimeAmount = TimeAmount.seconds(1)
    
    private let eventLoop: EventLoop
    
    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }
    
    func monitorAllServices() {
        eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(0), delay: pingInterval) { repeatedTask -> EventLoopFuture<Void> in
            PingService.fetchServerStatus(url: "http://patrickgatewood.com", eventLoop: self.eventLoop).futureResult.do { result in
                print("pingservice: \(result)")
                }.catch { error in
                    print("pingserviceerror: \(error)") // A Swift Error
            }
            return self.eventLoop.future() // no force
        }
    }
}
