struct Book: Codable {
    let id: Int
    let title: String
    let price: Double
    let genre: String

    init(id: Int, title: String, price: Double, genre: String) {
        self.id = id
        self.title = title
        self.price = price
        self.genre = genre
    }
}