import KituraContracts
import KituraSession
import MongoKitten
import LoggerAPI
import Foundation



func initializeTrueOrFalseProblemRoutes(app: App) {
    app.router.get("/getContent", handler: app.getContentHandler)
    app.router.get("/getContents", handler: app.getContentsHandler)
}

extension App {
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

            // Send response
            if 0 == contents.count {
                completion(nil, .noContent)
            } else {
                completion(contents[0], nil)
            }

        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }

    func getContentsHandler(session: CheckoutSession, query: GetContentsParams, completion: @escaping ([Content]?, RequestError?) -> Void) {
        let collection = App.database["contents"]
        print(query.set_name)
        print(query.num_contents)
        // Algorithm
        do {
            // Sort by rank
            var contents = try collection
                .find([
                    "set_name": query.set_name,
                    // "limitedTo": query.num_contents, // TO DO: Find way to filter when querying
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

            
            if 0 == contents.count {
                completion([], .noContent)
            } else {
                contents = Array(contents[..<query.num_contents]) // Send top N as response
                completion(contents, nil)
            }
        } catch let error {
            Log.error(error.localizedDescription)
            return completion(nil, .internalServerError)
        }
    }    
}