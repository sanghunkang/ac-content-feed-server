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

func initializeCommonRoutes(app: App) {
    app.router.get("/getSetNames", handler: app.getSetNamesHandler)
    app.router.post("/updateProblemHistory", handler: app.updateProblemHistoryHandler)
    app.router.post("/updateProblemHistories", handler: app.updateProblemHistoriesHandler)
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

    func updateProblemHistoryHandler(session: CheckoutSession, params: UpdateProblemHistoryParams, completion: @escaping (ResponseMessage?, RequestError?) -> Void) {
        // Check if collections exist
        let collection = App.database["contents"]
        let collectionUserAnswerHistory =  App.database["user_answer_history"]

        do {
            let objectId = try ObjectId(params._id)           

            var multipleResponseProblemHistory: MultipleResponseProblemHistory = [
                "$set": [... ]// append to perplexion
            ]
            
            switch params.answer_status {
            case "correct_answer":
                print("Correct answer")
                multipleResponseProblemHistory["$set"]["last_succeeded_at"] = getCurrentDateString()
                multipleResponseProblemHistory["$inc"]["count_succeeded"] = 1
            case "wrong_answer":
                print("Wrong answer")
                multipleResponseProblemHistory["$set"]["last_failed_at"] = getCurrentDateString()
                multipleResponseProblemHistory["$inc"]["count_failed"] = 1
            default:
                print("Neither correct or wrong answer")
                multipleResponseProblemHistory["$set"]["last_gaveup_at"] = getCurrentDateString()
                multipleResponseProblemHistory["$inc"]["count_gaveup"] = 1
            }
            



            let collectionUserAnswerHistory.upsert(
                where: [
                    "set_name": UpdateContentParams.set_name,
                    "problem_id": UpdateContentParams.problem_id,
                ],
                to: multipleResponseProblemHistory
            )


            // var updateDocument: Document = [
            //     "$set": ["last_served_at": getCurrentDateString()]
            // ]

            // TO CHANGE WHEN PARAMETER CHANGES
            // switch params.answer_status {
            // case "correct_answer":
            //     print("Correct answer")
            //     updateDocument["$set"]["last_succeeded_at"] = getCurrentDateString()
            //     updateDocument["$inc"]["count_succeeded"] = 1
            // case "wrong_answer":
            //     print("Wrong answer")
            //     updateDocument["$set"]["last_failed_at"] = getCurrentDateString()
            //     updateDocument["$inc"]["count_failed"] = 1
            // default:
            //     print("Neither correct or wrong answer")
            //     updateDocument["$set"]["last_gaveup_at"] = getCurrentDateString()
            //     updateDocument["$inc"]["count_gaveup"] = 1
            // }

            // // update document
            // let result = try collection.update(
            //     where: "_id" == objectId, 
            //     to: updateDocument
            // ).wait()

            // try collectionUserAnswerHistory.update(
            //     where: "_id" == objectId, 
            //     to: updateDocument
            // ).wait()

            // print(result)




            


            // Prepare response
            let responseMessage = ResponseMessage(message: "succesfully updated content")
            completion(responseMessage, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    // func updateProblemHistoriesHandler(session: CheckoutSession, params: [UpdateProblemHistoryParams], completion: @escaping (ResponseMessage?, RequestError?) -> Void) {
    //     do {
    //         let responseMessage = ResponseMessage(message: "API not yet implemented")
    //         completion(responseMessage, nil)
    //     } catch let error {
    //         Log.error(error.localizedDescription)
    //         return completion(nil, .internalServerError)
    //     }
    // }

}