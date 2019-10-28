import KituraContracts
import KituraSession
import MongoKitten
import LoggerAPI

func initializeCommonRoutes(app: App) {
    app.router.get("/getSetNames", handler: app.getSetNamesHandler)
}

extension App {
    static let database = try! Database.synchronousConnect("mongodb://mongo:27017/adaptive_cram")
    // static let database = try! Database.synchronousConnect("mongodb://localhost/adaptive_cram")

    func getSetNamesHandler(session: CheckoutSession, completion: @escaping ([SetName]?, RequestError?) -> Void) {
        let collection = App.database["problems"]

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
}