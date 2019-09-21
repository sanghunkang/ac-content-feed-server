import KituraContracts
import MongoKitten
import LoggerAPI

func initializeCouchRoutes(app: App) {
    app.router.post("/couch", handler: app.couchSaveHandler)
    app.router.get("/couch", handler: app.couchFindAllHandler)
}
extension App {
    // Define ConnectionProperties and CouchDBClient here

    func couchSaveHandler(book: BookDocument, completion: @escaping (BookDocument?, RequestError?) -> Void) {
        // Save book here
    }

    func couchFindAllHandler(completion: @escaping ([BookDocument]?, RequestError?) -> Void) {
        // Get all books here
    }
}Copied to clipboard.