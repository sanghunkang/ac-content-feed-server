func initializeRawRoutes(app: App) {
    // Register routes with handlers here
    app.router.post("/raw") { request, response, next in
        do {
            let book = try request.read(as: Book.self)
        } catch {
            let _ = response.send(status: .badRequest)
        }
        next()
    }

    app.router.get("/raw") { request, response, next in
        response.send(App.bookStore)
        next()
    }

    app.router.get("/raw/:id") { request, response, next in
        guard let idString = request.parameters["id"],
            let id = Int(idString),
            id >= 0,
            id < App.bookStore.count
        else {
            let _ = response.send(status: .badRequest)
            return next()
        }
        response.send(App.bookStore[id])
        next()
    }
}

extension App {
    static var bookStore = [Book]()
}