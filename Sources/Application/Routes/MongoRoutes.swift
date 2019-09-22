import KituraContracts
import MongoKitten
import LoggerAPI

func initializeMongoRoutes(app: App) {
    app.router.post("/mongo", handler: app.mongoSaveHandler)
    app.router.get("/mongo", handler: app.mongoFindAllHandler)
}

extension App {
    // Define ConnectionProperties and mongoDBClient here
    static let properties = ConnectionProperties(
        host: "127.0.0.1",              // http address
        port: 5984,                     // http port
        secured: false,                 // https or http
        username: "<mongoDB-username>", // admin username
        password: "<mongoDB-password>"  // admin password
    )
    let mongoDBClient = try MongoClient("mongodb://localhost:27017")
    static let mongoDBClient = mongoDBClient(connectionProperties: properties)

    let db = client.db("myDB")
    let collection = try db.createCollection("myCollection")


    func mongoSaveHandler(book: BookDocument, completion: @escaping (BookDocument?, RequestError?) -> Void) {
        // Save book here
        // App.mongoDBClient.retrieveDB("bookstore") { (database, error) in
        //     guard let database = database  else {
        //         return completion(nil, .internalServerError)
        //     }
        //     // Initialize document here
        // }

        // Save book here
        App.mongoDBClient.db("bookstore") { (database, error) in
            guard let database = database  else {
                return completion(nil, .internalServerError)
            }
            // Initialize document here
        }
    }

    func mongoFindAllHandler(completion: @escaping ([BookDocument]?, RequestError?) -> Void) {
        // Get all books here
    }
}