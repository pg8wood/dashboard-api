//
//  ServiceMonitor.swift
//  App
//
//  Created by Patrick Gatewood on 6/23/19.
//

import Vapor

class ServiceMonitor: Vapor.Service {
    private let pingInterval: TimeAmount = TimeAmount.minutes(15)
    
    private let app: Application
    private var eventLoop: EventLoop {
        return app.eventLoop
    }
    private let request: Request
    
    init(app: Application) {
        self.app = app
        self.request = Request(using: app)
    }
    
    func monitorAllServices() {
        app.eventLoop.scheduleRepeatedTask(initialDelay: TimeAmount.seconds(0), delay: pingInterval) { repeatedTask -> EventLoopFuture<Void> in
            let allServicesFuture = Service.query(on: self.request).decode(Service.self).all()
            
            // TODO delete once services are associated with a particular user
            allServicesFuture.do { services in
                services.forEach { service in
                    User.query(on: self.request).decode(User.self).first().do { user in
                        guard let user = user else {
                            fatalError("Need singleton user!")
                        }
                        
                        self.monitorServiceStatus(service, owner: user)
                    }
                }
            }.catch { error in
                print("Monitoring service failed: \(error)")
            }
            
            // TODO use once services are associated with a particular user
            // TODO this will get slow very quickly in a multi-user environment! 
//            allUsersFuture.do { users in
//                users.forEach { user in
//                    user.services?.forEach { service in
//                        self.monitorServiceStatus(service, owner: user)
//                    }
//                }
//            }.catch { error in
//                print("Monitoring service failed: \(error)")
//            }
            
            return self.eventLoop.future()
        }
    }
    
    func monitorServiceStatus(_ service: Service, owner: User) {
        
        PingService.fetchServerStatus(url: service.url, eventLoop: self.eventLoop).futureResult.do { result in
            print("pinging service: \(service.url) | result: \(result)")
            service.isOnline = true
            service.save(on: self.request)
          
        }.catch { error in
            guard service.isOnline ?? true else {
                // The service hasn't come back online since we last pinged it
                print("Service \(service.name) is still offline")
                return
            }
            print("Ping Service error: \(error)")
            
            service.isOnline = false
            service.save(on: self.request)
            
            print("sending push")
            // TODO: determine if push was sent today. Don't want to spam pushes every pingInterval!
            PushHandler.sendPush(PushHandler.ServiceDown(name: service.name), to: owner.pushToken)
        }
    }
}
