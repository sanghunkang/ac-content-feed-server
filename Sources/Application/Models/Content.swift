// import MongoKitten

struct Content: Codable {
    let _id: String?
    var _rev: String?
    var type: String?

    // Field values which users must provide. Error will be raised when absent
    var content_id: String?
    var set_name: String
    var question: String
    var answer: Bool
    var solution: String

    // Automatically computed by service. Ordinary users wouldn't have access to manipulate these
    let rank: Int?
    var created_at: String?
    var last_served_at: String?
    var last_succeeded_at: String?
    var last_failed_at: String?
    var last_gaveup_at: String?
    var count_failed: Int?
    var count_succeeded: Int?
    var count_gaveup: Int?
}

struct SetName: Codable {
    var set_name: String

    init(set_name: String) {
        self.set_name = set_name
    }
}