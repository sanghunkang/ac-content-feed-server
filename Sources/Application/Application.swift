import Kitura
import LoggerAPI
import Dispatch

public class App {

    let router = Router()
    let workerQueue = DispatchQueue(label: "worker")

    public init() throws {
        Log.info("Hello World")
    }

    func postInit() throws {
        initializeCodableRoutes(app: self)
        initializeRawRoutes(app: self)

        router.get("/") { request, response, next in
            response.send("Hello from the 1st route!")
            next()
        }

        router.get("/") { request, response, next in
            response.send("Hello from the 2nd route!")
            next()
        }
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: 8000, with: router)
        Kitura.run()
    }

    func execute(_ block: (() -> Void)) {
        workerQueue.sync {
            block()
        }
    }
}