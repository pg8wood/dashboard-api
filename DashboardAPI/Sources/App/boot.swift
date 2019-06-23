import Vapor

/// Called after your application has initialized.
public func boot(_ app: Application) throws {
    // Your code here
    ServiceMonitor(eventLoop: app.eventLoop).monitorAllServices()
    
    
}
