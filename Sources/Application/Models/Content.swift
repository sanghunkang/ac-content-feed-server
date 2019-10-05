import MongoKitten

struct Content: Codable {
    let _id: String?
    var _rev: String?
    let question: String
    let answer: Bool
    let description: String
    let rank: Int?
    var created_at: String?
    var last_succeeded_at: String?
    var last_failed_at: String?

    init(question: String, answer: Bool, description: String) {
        self._id = ""
        self._rev = ""
        self.question = question
        self.answer = answer
        self.description = description
        self.rank = 0
        
    }
}