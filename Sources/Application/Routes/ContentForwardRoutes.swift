import KituraContracts
import MongoKitten
import LoggerAPI

func initializeContentForwardRoutes(app: App) {
    app.router.get("/getContent", handler: app.getContentHandler)
    app.router.post("/insertContent", handler: app.insertContentHandler)
    // app.router.put("/updateContent", handler: app.updateContentHandler)
    // app.router.put("/updateContentRank", handler: app.updateContentRankHandler)
}

extension App {
    // static var codableStoreBookDocument = [BookDocument]()

    func getContentHandler(completion: @escaping ([Content]?, RequestError?) -> Void) {
        // Check if collections exist
        let collection = App.mongoDBClient["mottemotte"]

        // Algorithm
        do {
            // Sample from latest error set (Top N)
            let contents = try collection.find("answer" != nil)
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
            // content = Dirichlet(contentsCandidates)

            // Send respoese
            completion(contents, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    // Insert content defined by user into database
    func insertContentHandler(content: Content, completion: @escaping (Document?, RequestError?) -> Void) {
        // Check if collections exist
        let collection = App.mongoDBClient["mottemotte"]
        
        // Insert Document
        do {
            print(content)
            let encoder = BSONEncoder()
            let encodedDocument: Document = try encoder.encode(content)
            // print(encodedDocument)
            // let myUser: Document = ["username": "kitty", "password": "meow"]


            collection.insert(encodedDocument)
            completion(encodedDocument, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    // Update content itself
    // func updateContentHandler(content: ContentDocument, completion: @escaping (BookDocument?, RequestError?) -> Void) {
    //     // Check if collections exist
    //     let collection = App.mongoDBClient["mottemotte"]

    //     do {

    //     } catch let error {
    //         Log.error(error.localizedDescription)
    //         return completion(nil, .internalServerError)
    //     }
    // }

    // Update content rank
    // func updateContentRankHandler(content: ContentDocument, completion: @escaping (BookDocument?, RequestError?) -> Void) {
    //     // Check if collections exist
    //     let collection = App.mongoDBClient["mottemotte"]
        
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