import KituraContracts
import KituraSession
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


func initializeContentFeedRoutes(app: App) {
    app.router.get("/getSetNames", handler: app.getSetNamesHandler)
    app.router.get("/getContent", handler: app.getContentHandler)
    app.router.get("/getContents", handler: app.getContentsHandler)
    app.router.post("/applyResult", handler: app.applyResultHandler)
    // app.router.get("/applyResults", handler: app.applyResultsHandler)
}

extension App {
    static let database = try! Database.synchronousConnect("mongodb://mongo:27017/adaptive_cram")
    // static let database = try! Database.synchronousConnect("mongodb://localhost/adaptive_cram")

    func getSetNamesHandler(session: CheckoutSession, completion: @escaping ([SetName]?, RequestError?) -> Void) {
        let collection = App.database["contents"]

        do {
            let setNames = try collection.distinct(onKey: "set_name").wait().map { document in
                return SetName(set_name: document as! String)
            }
            
            for setName in setNames { //setName in 
                session.setNames.append(setName)
            }
            print(setNames)

            completion(session.setNames, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    func getContentHandler(session: CheckoutSession, query: GetContentParams, completion: @escaping (Content?, RequestError?) -> Void) {
        // Check if collections exist
        let collection = App.database["contents"]
        print(query.set_name)
        
        do {
            // Sort by rank
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

            // TODO: raise error if length is less than 0
            let content = contents[0]

            // Send response
            completion(content, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    func getContentsHandler(session: CheckoutSession, query: GetContentsParams, completion: @escaping ([Content]?, RequestError?) -> Void) {
        let collection = App.database["contents"]
        print(query.set_name)
        // Algorithm
        do {
            // Sort by rank
            let contents = try collection
                .find([
                    "set_name": query.set_name,
                    "limitedTo": query.num_contents,
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

            // TODO: raise error if length is less than N

            // Send top N as response
            // let contentsToReturn = contents[...query.num_contents] as! [Content]
            // completion(contentsToReturn, nil)
            completion(contents, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    func applyResultHandler(session: CheckoutSession, params: UpdateContentParams, completion: @escaping (ResponseMessage?, RequestError?) -> Void) {
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


            // Prepare response
            let responseMessage = ResponseMessage(message: "succesfully updated content")
            completion(responseMessage, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    // func applyResultsHandler(session: CheckoutSession, params: [UpdateContentParams], completion: @escaping (ResponseMessage?, RequestError?) -> Void) {
    //     do {
    //         let responseMessage = ResponseMessage(message: "API not yet implemented")
    //         completion(responseMessage, nil)
    //     } catch let error {
    //         Log.error(error.localizedDescription)
    //         return completion(nil, .internalServerError)
    //     }
    // }
}