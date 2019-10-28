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
        initializeCommonRoutes(app: self)
        initializeProblemFeedRoutes(app: self)
        initializeUpdateHistoryRoutes(app: self)
        // initializeMultipleResponseProblemRoutes(app: self)

        KituraOpenAPI.addEndpoints(to: router)

        router.get("/") { request, response, next in
            response.send("index of ac-content-feed-server")
            next()
        }
    }

    public func run() throws {
        try postInit()
        Kitura.addHTTPServer(onPort: 7001, with: router)
        Kitura.run()
    }

    func execute(_ block: (() -> Void)) {
        workerQueue.sync {
            block()
        }
    }
}