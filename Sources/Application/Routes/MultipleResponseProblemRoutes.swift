import KituraContracts
import KituraSession
import MongoKitten
import LoggerAPI
import Foundation

func initializeMultipleResponseProblemRoutes(app: App) {
    app.router.get("/getMultipleResponseProblem", handler: app.getMultipleResponseProblemHandler)
    app.router.get("/getMultipleResponseProblems", handler: app.getMultipleResponseProblemsHandler)
}


extension App {
    func getMultipleResponseProblemHandler(session: CheckoutSession, query: GetContentParams, completion: @escaping (MultipleResponseProblemToFeed?, RequestError?) -> Void) {
        // Check if collections exist
        let collection = App.database["contents"]
        let perplexionCollection = App.database["perplexions"]
        print(query.set_name)
        
        do {
            // Sort by rank
            var multipleResponseProblems = try collection
                .find([
                    "set_name": query.set_name, // we skip querying set_type
                    "limitedTo": 1,
                ])
                .sort(["rank": .descending])
                .decode(MultipleResponseProblem.self)
                .getAllResults()
                .wait() 
            // TODO: raise error if length is less than 0
            var problem = multipleResponseProblems[0]
            var multipleResponseProblemToFeed = MultipleResponseProblemToFeed(
                content_id: problem.problem_id,
                set_name: problem.set_name,
                answer: problem.answer
            )

            // Build MRP set for all questions
            let perplexions = try perplexionCollection
                .find([
                    "set_name": query.set_name,
                    "problem_id": problem.problem_id,
                ])
                .sort(["rank": .descending,])
                .getAllResults()
                .wait() 

            

            let numResponses = 5
            if (numResponses < perplexions.count + 1) { // Using purely perplexions
                // multipleResponseProblemToFeed.choices // TODO: Add choices
            } else { // Using problem from others
                let perplexionsAdditional = try collection 
                    .find([
                        "set_name": query.set_name,
                        "limitedTo": numResponses - perplexions.count - 1
                    ])
                    .sort([
                        "rank": .descending,
                    ])
                    .decode(MultipleResponseProblem.self) // NOTE: Is it safe?
                    .getAllResults()
                    .wait()

                // multipleResponseProblemToFeed.choices // TODO: Add choices
            }


            // Send response
            completion(multipleResponseProblemToFeed, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    func getMultipleResponseProblemsHandler(session: CheckoutSession, query: GetProblemsParams, completion: @escaping ([MultipleResponseProblemToFeed]?, RequestError?) -> Void) {
        do {

            let multipleResponseProblemsToFeed: [MultipleResponseProblemToFeed]
            // Send response
            completion(multipleResponseProblemsToFeed, nil)
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }

    }
}
