import Vapor

public func routes(_ router: Router) throws {
    try router.register(collection: ServiceController())
    try router.register(collection: UserController())

    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }
}
