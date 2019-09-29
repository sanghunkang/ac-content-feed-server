import KituraContracts
import MongoKitten
import LoggerAPI

func initializeMongoRoutes(app: App) {
    app.router.post("/mongo", handler: app.mongoSaveHandler)
    app.router.get("/mongo", handler: app.mongoFindAllHandler)
}

extension App {
    // Define ConnectionProperties and mongoDBClient here
    static let mongoDBClient = try! Database.synchronousConnect("mongodb://localhost/test")
    static var codableStoreBookDocument = [BookDocument]()

    func mongoSaveHandler(book: BookDocument, completion: @escaping (BookDocument?, RequestError?) -> Void) {
        // Save book here
        print("mongo triggered")
        print(book)

        let collection = App.mongoDBClient["mottemotte"]
        
        do {
            let encoder = BSONEncoder()
            let encodedDocument: Document = try encoder.encode(book)
            collection.insert(encodedDocument)

            execute {
                App.codableStoreBookDocument.append(book)
            }
            completion(book, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    func mongoFindAllHandler(completion: @escaping ([BookDocument]?, RequestError?) -> Void) {
        print("GET: mongo triggered")
        // Check if collections exist
        let collection = App.mongoDBClient["mottemotte"]
        // guard let database = App.mongoDBClient["mottemotte"]  else {
        //     return completion(nil, .internalServerError)
        // }


        // Send query to collection
        do {
            let bookDocuments = try collection.find()
                .decode(BookDocument.self)
                .getAllResults()
                .wait() 
            completion(bookDocuments, nil)
        } catch let error{
            Log.error(error.localizedDescription)
            completion(nil, .internalServerError)
        }

        // App.couchDBClient.retrieveDB("bookstore") { (database, error) in
        //     guard let database = database  else {
        //         return completion(nil, .internalServerError)
        //     }
        //     database.retrieveAll(includeDocuments: true, callback: { (allDocuments, error) in
        //         guard let allDocuments = allDocuments else {
        //             return completion(nil, RequestError(httpCode: error?.statusCode ?? 500))
        //         }
        //         let books = allDocuments.decodeDocuments(ofType: BookDocument.self)
        //         completion(books, nil)
        //     })
        // }
    }
}