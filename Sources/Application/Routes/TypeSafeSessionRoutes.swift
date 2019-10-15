import KituraContracts
import KituraSession

func initializeTypeSafeSessionRoutes(app: App) {
    app.router.post("/cart", handler: app.postSessionHandler)
    app.router.get("/cart", handler: app.getSessionHandler)
}

extension App {
    // Define handlers here

    func postSessionHandler(session: CheckoutSession, book: Book, completion: (Book?, RequestError?) -> Void) {
        session.books.append(book)
        session.save()
        completion(book, nil)
    }

    func getSessionHandler(session: CheckoutSession, completion: ([Book]?, RequestError?) -> Void) -> Void {
        completion(session.books, nil)
    }
}