//
//  ServiceMonitor.swift
//  App
//
//  Created by Patrick Gatewood on 6/23/19.
//

import Vapor

class ServiceMonitor: Vapor.Service {
    private let pingInterval: TimeAmount = TimeAmount.seconds(1)
    
    private let app: Application
    private var eventLoop: EventLoop {
        return app.eventLoop
    }
    
    init(app: Application) {
        self.app = app
    }
    
    func monitorAllServices() {
        app.eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(0), delay: pingInterval) { repeatedTask -> EventLoopFuture<Void> in
            let request = Request(using: self.app)
            let allServices = Service.query(on: request).decode(Service.self).all()
            
            allServices.do { services in
                services.forEach { service in
                    self.monitorService(service)
                }
            }.catch { error in
                print("Monitoring service failed: \(error)")
            }
            
            return self.eventLoop.future()
        }
    }
    
    func monitorService(_ service: Service) -> Future<Void> {
        PingService.fetchServerStatus(url: service.url, eventLoop: self.eventLoop).futureResult.do { result in
            print("pinging service: \(service.url) | result: \(result)")
        }.catch { error in
            print("Ping Service error: \(error)")
        }
        
        return self.eventLoop.future()
    }
}
