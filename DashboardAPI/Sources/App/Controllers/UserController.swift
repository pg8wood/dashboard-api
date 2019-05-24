import Vapor

final class UserController {
    
    func createHandler(_ req: Request) throws -> Future<User> {
        return try req.content.decode(User.self).flatMap { (user) in
            return user.save(on: req)
        }
    }
    
    func getOneHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
}

extension UserController: RouteCollection {
    func boot(router: Router) throws {
        let pushRoute = router.grouped("dashboard", "users")
        pushRoute.post(use: createHandler)
        pushRoute.get(User.parameter, use: getOneHandler)
    }
}
