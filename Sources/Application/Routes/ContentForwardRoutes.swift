import KituraContracts
import MongoKitten
import LoggerAPI
import Foundation

func getCurrentDateString() -> String {
    let now = Date()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = formatter.string(from: now)
    return dateString
}

func initializeContentForwardRoutes(app: App) {
    app.router.get("/getContent", handler: app.getContentHandler)
    app.router.post("/insertContent", handler: app.insertContentHandler)
    app.router.post("/updateContent", handler: app.updateContentHandler)
    // app.router.put("/updateContentRank", handler: app.updateContentRankHandler)
}

extension App {
    static let database = try! Database.synchronousConnect("mongodb://mongo:27017/adaptive_cram")
    static var codableStoreBookDocument = [BookDocument]()

    func getContentHandler(completion: @escaping (Content?, RequestError?) -> Void) {
        // Check if collections exist
        let collection = App.database["contents"]

        // Algorithm
        do {
            // Sample from latest error set (Top N)
            let contents = try collection
                // .find([
                //     "set_name": "commercial_law"
                // ])
                .find()
                .sort([
                    "last_succeeded_at": .ascending,
                    "last_failed_at" : .descending,
                    "created_at": .descending,
                ])
                .decode(Content.self)
                .getAllResults()
                .wait() 
            print(contents)

            // Sample from the rest
            // let contentsNormal = try collection.find({"latest error": {"$lt": "....", "max": 100}})
            //         .decode(BookDocument.self)
            //         .getAllResults()
            //         .wait() 
            // // Concatenate two sets
            // let contentsCandidates = contentsWrong + contentsNormal 
            // // Random selection from Dirichlet distribution with rank as alphas
            let content = contents[0]
            // content = Dirichlet(contentsCandidates)

            // Send respoese
            completion(content, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    // Insert content defined by user into database
    func insertContentHandler(content: Content, completion: @escaping (Document?, RequestError?) -> Void) {
        // Check if collections exist
        let collection = App.database["contents"]
        
        // Insert Document
        do {
            var content = content
            content.created_at = getCurrentDateString()
            content.count_succeeded = 0
            content.count_failed = 0
            content.count_gaveup = 0

            let document: Document = try BSONEncoder().encode(content)
            print(document)
            collection.insert(document)
            completion(document, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    // Update content itself
    func updateContentHandler(content: Content, completion: @escaping (Document?, RequestError?) -> Void) {
        // Check if collections exist
        let collection = App.database["contents"]

        do {
            let document: Document = try BSONEncoder().encode(content)

            let objectId = try ObjectId(content._id!)
            var updateSetting: [String: String] = [:]
            
            if content.last_failed_at != nil {
                updateSetting["last_failed_at"] = content.last_failed_at!
                // updateSetting["count_failed"]
            } else if content.last_succeeded_at != nil {
                updateSetting["last_succeeded_at"] = content.last_succeeded_at!
            }

            // update document
            let result = try collection.update(
                where: "_id" == objectId, 
                setting: updateSetting
            ).wait()

            print(result)
            // RETURN TYPE WILL BE CHANGED TO MEET HTTP REQUEST-RESPONSE SPEC
            completion(document, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    // Update content rank
    // func updateContentRankHandler(content: ContentDocument, completion: @escaping (BookDocument?, RequestError?) -> Void) {
    //     // Check if collections exist
    //     let collection = App.database["mottemotte"]
        
    //     // Update rank
    //     let rank = algorithm.updateRank(content)
    //     content.rank 

    //     do {
    //         let encoder = BSONEncoder()
    //         let encodedDocument: Document = try encoder.encode(book)
            
            
    //         collection.update(encodedDocument)
    //         completion(encodedContent, nil)
    //     } catch let error {
    //         Log.error(error.localizedDescription)
    //         return completion(nil, .internalServerError)
    //     }
    // }
}