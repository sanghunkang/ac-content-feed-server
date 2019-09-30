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
        // Check if collections exist
        let collection = App.mongoDBClient["mottemotte"]
        
        // Insert Document
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


        // Retrieve Documents
        do {
            let bookDocuments = try collection.find()
                .decode(BookDocument.self)
                .getAllResults()
                .wait() 
            print(bookDocuments)
            // completion(bookDocuments, nil)
        } catch let error{
            Log.error(error.localizedDescription)
            completion(nil, .internalServerError)
        }
    }
}