import KituraContracts

func initializeCodableRoutes(app: App) {
    // Register routes here
    app.router.post("/codable", handler: app.postHandler)
    app.router.get("/codable", handler: app.getAllHandler)
    app.router.get("/codable", handler: app.getOneHandler)
}
extension App {
    static var codableStore = [Book]()
    // Write handlers here

    func postHandler(book: Book, completion: (Book?, RequestError?) -> Void) {
        print(book)
        execute {
            App.codableStore.append(book)
        }
        completion(book, nil)
    }

    func getAllHandler(completion: ([Book]?, RequestError?) -> Void) {
        execute {
            completion(App.codableStore, nil)
        }
    }

    func getOneHandler(id: Int, completion: (Book?, RequestError?) -> Void) {
        execute {
            guard id < App.codableStore.count, id >= 0 else {
                return completion(nil, .notFound)
            }
            completion(App.codableStore[id], nil)
        }
    }
}
