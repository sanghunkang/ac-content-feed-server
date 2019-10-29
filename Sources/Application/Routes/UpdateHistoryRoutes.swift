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
        let problemHistoryCollection = App.database["problem_history"]
        let perplexionHistoryCollection = App.database["perplexion_history"]

        // do {
            // retrieve userId from session
            // let userId = session.userID ?? nil
            problemHistoryCollection.insert([
                // "user_id": usedId,
                "set_name": params.set_name,
                "problem_id": params.problem_id,
                "answer_status": params.answer_status,
                "created_at": getCurrentDateString(),
            ])

            // If MRP
            if params.problem_type == "multiple_response" && params.answer_status == "wrong_answer" {
                perplexionHistoryCollection.insert([
                    // "user_id": usedId,
                    "set_name": params.set_name,
                    "problem_id": params.problem_id,
                    "perplexion_problem_id": params.perplexion_problem_id,
                    "perplexion_question": params.perplexion_question,
                    "created_at": getCurrentDateString(),
                ])
            }

            // Prepare response
            let responseMessage = ResponseMessage(message: "succesfully updated content")
            completion(responseMessage, .created)
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