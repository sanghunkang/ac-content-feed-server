import KituraContracts
import MongoKitten
import LoggerAPI

func initializeMongoRoutes(app: App) {
    app.router.post("/mongo", handler: app.mongoSaveHandler)
    app.router.get("/mongo", handler: app.mongoFindAllHandler)
}

extension App {
    // Define ConnectionProperties and mongoDBClient here
    // static let properties = ConnectionProperties(
    //     host: "127.0.0.1",              // http address
    //     port: 27017,                     // http port
    //     secured: false,                 // https or http
    //     username: "<mongoDB-username>", // admin username
    //     password: "<mongoDB-password>"  // admin password
    // )
    // let mongoDBClient = try MongoClient("mongodb://localhost:27017")
    static let mongoDBClient = try! Database.synchronousConnect("mongodb://localhost/test")


    func mongoSaveHandler(book: BookDocument, completion: @escaping (BookDocument?, RequestError?) -> Void) {
        // Save book here
        print("mongo triggered")
        print(book)
        print(App.mongoDBClient["mottemotte"])  
        
        let items = App.mongoDBClient["mottemotte"]

        let encoder = BSONEncoder()
        do {
            let encodedDocument: Document = try encoder.encode(book)
            items.insert(encodedDocument)
            print("Inserted!")
        } catch let error {
            print(error)
        }
    }

    func mongoFindAllHandler(completion: @escaping ([BookDocument]?, RequestError?) -> Void) {
        // Get all books here
    }
}