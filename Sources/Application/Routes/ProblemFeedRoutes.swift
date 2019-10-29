import KituraContracts
import KituraSession
import MongoKitten
import LoggerAPI
import Foundation

func initializeProblemFeedRoutes(app: App) {
    app.router.get("/getProblem", handler: app.getProblemHandler)
    app.router.get("/getProblems", handler: app.getProblemsHandler)
}

extension App {
    func getProblemHandler(session: CheckoutSession, query: GetProblemParams, completion: @escaping (ProblemFeed?, RequestError?) -> Void) {
        // Check if problemCollections exist
        let problemCollection = App.database["problems"]
        print(query.set_name)
        
        do {
            // Sort by rank
            let problems = try problemCollection
                .find([
                    "set_name": query.set_name
                    // "limitedTo": 1,
                ])
                .sort([
                    // "rank": .descending
                    "last_served_at": .ascending,
                    "last_succeeded_at": .ascending,
                    "last_failed_at" : .descending,
                    "created_at": .descending,
                ])
                .decode(Problem.self)
                .getAllResults()
                .wait() 

            // Send response
            if 0 == problems.count {
                completion(nil, .noContent)
            } else {
                // TODO: raise error if length is less than 0
                let problem = problems[0]
                var problemFeed = ProblemFeed(
                    set_name: problem.set_name,
                    problem_id: problem.problem_id,
                    problem_type: problem.problem_type,
                    question: problem.question,
                    answer: problem.answer
                )

                if problem.problem_type == "mutliple_response" {
                    problemFeed.choices = findPerplexions(
                        setName: query.set_name, 
                        problemId: problem.problem_id
                    )

                    // if problemFeed.choices.count < 5 {
                    //     problemFeed.choices.append()
                    // }
                }

                completion(problemFeed, nil)
            }

        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    func getProblemsHandler(session: CheckoutSession, query: GetProblemsParams, completion: @escaping ([ProblemFeed]?, RequestError?) -> Void) {
        let problemCollection = App.database["problems"]
        print(query.set_name)
        print(query.num_problems)
        // Algorithm
        do {
            // Sort by rank
            var problems = try problemCollection
                .find([
                    "set_name": query.set_name,
                    // "limitedTo": query.num_problems, // TO DO: Find way to filter when querying
                ])
                .sort([
                    // "rank": .descending,
                    "last_served_at": .ascending,
                    "last_succeeded_at": .ascending,
                    "last_failed_at" : .descending,
                    "created_at": .descending,
                ])
                .decode(Problem.self)
                .getAllResults()
                .wait() 


            // if 0 == problems.count {
            //     completion([], .noContent)
            // } 
            guard 0 < problems.count else {
                return completion([], .noContent)
            }
            
            problems = Array(problems[..<query.num_problems]) // Send top N as response
            let problemFeeds: [ProblemFeed] = problems.map { problem in
                var problemFeed = ProblemFeed(
                    set_name: problem.set_name,
                    problem_id: problem.problem_id,
                    problem_type: problem.problem_type,
                    question: problem.question,
                    answer: problem.answer
                )

                if problem.problem_type == "mutliple_response" {
                    problemFeed.choices = findPerplexions(
                        setName: query.set_name, 
                        problemId: problem.problem_id
                    )

                    // if problemFeed.choices.count < 5 {
                    //     problemFeed.choices.append()
                    // }
                }
                return problemFeed  
            }
            completion(problemFeeds, nil)

        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }


    private func findPerplexions(setName: String, problemId: String) -> [String: String] {
        let perplexionCollection = App.database["perplexions"]
        
        do {
            let numResponses = 5
            var perplexions = try perplexionCollection
                .find([
                    "set_name": setName,
                    "label_problem_id": problemId,
                ])
                .sort(["rank": .descending,])
                .decode(Perplexion.self)
                .getAllResults()
                .wait() 
            perplexions = Array(perplexions[..<numResponses])
            
            let choices = perplexions.reduce([String: String]()) {(choices, choice) -> [String: String] in
                var choices = choices
                choices[choice.perplexion_problem_id] = choice.perplexion_question
                return choices
            }
            return choices

        } catch let error {
            Log.error(error.localizedDescription)
            return [:]
        }
    }
}