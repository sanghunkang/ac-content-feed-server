// import MongoKitten

struct Content: Codable {
    let _id: String?
    var _rev: String?
    let question: String
    let answer: Bool
    let description: String
    let rank: Int?
    let last_answered_wrong: String?
}