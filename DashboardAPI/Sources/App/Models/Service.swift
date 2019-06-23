import Vapor
import FluentSQLite

final class Service: Codable {
    var id: Int?
    var name: String
    var url: String
    var isOnline: Bool
    
    init(name: String, url: String, isOnline: Bool = true) {
        self.name = name
        self.url = url
        self.isOnline = isOnline
    }
}

extension Service: SQLiteModel { }
extension Service: Migration { }
extension Service: Content { }
extension Service: Parameter { }
