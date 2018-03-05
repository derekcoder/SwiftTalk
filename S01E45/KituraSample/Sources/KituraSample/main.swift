import Foundation
import Kitura
import LoggerAPI
import HeliumLogger
import Application

let router = Router()

router.get("/") { req, res, next in
    res.send("Homepage")
    next()
}

router.get("/test") { req, res, next in
    res.send("Test page")
    next()
}

router.get("/users/:id") { req, res, next in
    let id = req.parameters["id"] ?? "Invalid id"
    res.send("User profile: \(id)")
    next()
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()
