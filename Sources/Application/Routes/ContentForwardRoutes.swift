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
    app.router.get("/getSetNames", handler: app.getSetNamesHandler)
    app.router.get("/getContent", handler: app.getContentHandler)
    app.router.post("/insertContent", handler: app.insertContentHandler)
    app.router.post("/updateContent", handler: app.updateContentHandler)
    // app.router.put("/updateContentRank", handler: app.updateContentRankHandler)
}

extension App {
    // static let database = try! Database.synchronousConnect("mongodb://mongo:27017/adaptive_cram")
    static let database = try! Database.synchronousConnect("mongodb://localhost/adaptive_cram")

    func getSetNamesHandler(completion: @escaping (Response?, RequestError?) -> Void) {
        // Check if collections exist
        let collection = App.database["contents"]

        do {
            let setNames = try collection.distinct(onKey: "set_name").wait()
            print(setNames)

            let respoese = Response(message: "succesfully updated content")
            completion(respoese, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }



    func getContentHandler(query: GetContentParams, completion: @escaping (Content?, RequestError?) -> Void) {
        // Check if collections exist
        let collection = App.database["contents"]
        print(query.set_name)
        // Algorithm
        do {
            // Sample from latest error set (Top N)
            let contents = try collection
                .find([
                    "set_name": query.set_name
                ])
                .sort([
                    "last_served_at": .ascending,
                    "last_succeeded_at": .ascending,
                    "last_failed_at" : .descending,
                    "created_at": .descending,
                ])
                .decode(Content.self)
                .getAllResults()
                .wait() 

            // Sample from the rest
            // let contentsNormal = try collection.find({"latest error": {"$lt": "....", "max": 100}})
            //         .decode(BookDocument.self)
            //         .getAllResults()
            //         .wait() 

            // // Concatenate two sets
            // let contentsCandidates = contentsWrong + contentsNormal 
            // // Random selection from Dirichlet distribution with rank as alphas
            // if contents.count == 0 {
            //     throw error
            // } else {
            let content = contents[0]
            print(content)
            // }
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
            
            content.count_succeeded = content.count_succeeded ?? 0
            content.count_failed = content.count_failed ?? 0
            content.count_gaveup = content.count_gaveup ?? 0
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
    func updateContentHandler(params: UpdateContentParams, completion: @escaping (Response?, RequestError?) -> Void) {
        // Check if collections exist
        let collection = App.database["contents"]

        do {
            let objectId = try ObjectId(params._id)           

            var updateDocument: Document = [
                "$set": ["last_served_at": getCurrentDateString()]
            ]

            // TO CHANGE WHEN PARAMETER CHANGES
            switch params.answer_status {
            case "correct_answer":
                print("Correct answer")
                updateDocument["$set"]["last_succeeded_at"] = getCurrentDateString()
                updateDocument["$inc"]["count_succeeded"] = 1
            case "wrong_answer":
                print("Wrong answer")
                updateDocument["$set"]["last_failed_at"] = getCurrentDateString()
                updateDocument["$inc"]["count_failed"] = 1
            default:
                print("Neither correct or wrong answer")
                updateDocument["$set"]["last_gaveup_at"] = getCurrentDateString()
                updateDocument["$inc"]["count_gaveup"] = 1
            }

            // update document
            let result = try collection.update(
                where: "_id" == objectId, 
                to: updateDocument
            ).wait()

            print(result)


            // RETURN TYPE WILL BE CHANGED TO MEET HTTP REQUEST-RESPONSE SPEC
            let respoese = Response(message: "succesfully updated content")
            completion(respoese, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }
}