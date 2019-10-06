import MongoKitten

struct Content: Codable {
    let _id: String?
    var _rev: String?
    let question: String
    let answer: Bool
    let solution: String
    let rank: Int?
    var created_at: String?
    var last_succeeded_at: String?
    var last_failed_at: String?
    var last_gaveup_at: String?
    var count_failed: Int?
    var count_succeeded: Int?
    var count_gaveup: Int?

    init(question: String, answer: Bool, solution: String) {
        self._id = ""
        self._rev = ""
        self.question = question
        self.answer = answer
        self.solution = solution
        self.rank = 0
        
    }
}