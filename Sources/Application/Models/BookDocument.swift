import MongoKitten

// struct BookDocument: Document {
struct BookDocument: Codable {
    let _id: String?
    var _rev: String?
    let title: String
    let price: Double
    let genre: String
}