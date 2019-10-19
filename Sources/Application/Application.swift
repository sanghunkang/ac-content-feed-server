import Kitura
import KituraOpenAPI
import LoggerAPI
import Dispatch

public class App {

    let router = Router()
    let workerQueue = DispatchQueue(label: "worker")

    public init() throws {
        Log.info("Hello World")
    }

    func postInit() throws {
        initializeContentFeedRoutes(app: self)

        KituraOpenAPI.addEndpoints(to: router)

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
        Kitura.addHTTPServer(onPort: 8080, with: router)
        Kitura.run()
    }

    func execute(_ block: (() -> Void)) {
        workerQueue.sync {
            block()
        }
    }
}