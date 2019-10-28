import KituraContracts
import KituraSession
import MongoKitten
import LoggerAPI


func initializeUpdateHistoryRoutes(app: App) {
    app.router.post("/updateProblemHistory", handler: app.updateProblemHistoryHandler)
    // app.router.post("/updateProblemHistories", handler: app.updateProblemHistoriesHandler)
}

extension App {
    func updateProblemHistoryHandler(session: CheckoutSession, params: UpdateProblemHistoryParams, completion: @escaping (ResponseMessage?, RequestError?) -> Void) {
        // Check if collections exist 
        // let problemCollection = App.database["problems"]
        let problemHistoryCollection = App.database["problem_history"]
        let perplexionCollection = App.database["perplexions"]

        // do {
            // let objectId = try ObjectId(params._id)           

            // var multipleResponseProblemHistory = 
            //     "$set": [String: String],
            //     "$inc": [String: Int],
            // ]
            
            var problemHistory: Document = []

            switch params.answer_status {
            case "correct_answer":
                print("Correct answer")
                problemHistory["$set"]["last_succeeded_at"] = getCurrentDateString()
                problemHistory["$inc"]["count_succeeded"] = 1
            case "wrong_answer":
                print("Wrong answer")
                problemHistory["$set"]["last_failed_at"] = getCurrentDateString()
                problemHistory["$inc"]["count_failed"] = 1              
            default:
                print("Neither correct or wrong answer")
                problemHistory["$set"]["last_gaveup_at"] = getCurrentDateString()
                problemHistory["$inc"]["count_gaveup"] = 1
            }

            // TODO: Need to be something of upsert
            // let document: Document = try BSONEncoder().encode(multipleResponseProblemHistory)
            problemHistoryCollection.update(
                where: [
                    "set_name": params.set_name,
                    "problem_id": params.problem_id,
                ],
                to: problemHistory
                // to: document
            )


            // If MRP
            if params.problem_type == "multiple_response" && params.answer_status == "wrong_answer" {
                var perplexion: Document = []
                perplexion["$set"]["last_perplexed_at"] = getCurrentDateString()

                perplexionCollection.update(
                    where: [
                        "set_name": params.set_name,
                        "label_problem_id": params.problem_id,
                        "perplexion_problem_id": params.perplexion_problem_id,
                        "perplexion_question": params.perplexion_question,
                    ],
                    to: perplexion
                )
            }



            // Prepare response
            let responseMessage = ResponseMessage(message: "succesfully updated content")
            completion(responseMessage, nil)
        // } catch let error {
        //     Log.error(error.localizedDescription)
        //     return completion(nil, .internalServerError)
        // }
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