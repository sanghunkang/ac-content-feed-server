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
        print(App.mongoDBClient["mottemotte"])  
        
        let items = App.mongoDBClient["mottemotte"]

        let encoder = BSONEncoder()
        do {
            let encodedDocument: Document = try encoder.encode(book)
            items.insert(encodedDocument)
            print("Inserted!")
            print(encodedDocument)

            execute {
                App.codableStoreBookDocument.append(book)
            }
            completion(book, nil)
        } catch let error {
            print(error)
        }
    }

    func mongoFindAllHandler(completion: @escaping ([BookDocument]?, RequestError?) -> Void) {
        print("GET: mongo triggered")
        // Check if collections exist
        let database = App.mongoDBClient["mottemotte"]
        // guard let database = App.mongoDBClient["mottemotte"]  else {
        //     return completion(nil, .internalServerError)
        // }


        // Send query to collection
        let books = database.find()
            // .map { document in return document["username"] as? String } 
            .forEach { (book: Document) in print(book) }
        print(books)
        // completion(books, nil)

        books.whenSuccess { _ in
            print("Inserted!")
            // completion(aa, nil)
        }

        books.whenFailure { error in
            print("Insertion failed", error)
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