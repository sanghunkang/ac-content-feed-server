// Struct to store in database
struct MultipleResponseProblem: Codable {
    // Identifiers for database
    let _id: String?
    var _rev: String?

    // Identifiers for set
    var problem_id: String?
    var set_name: String
    
    // Intrinsic content
    var question: String
    var answer: String

    // Automatically computed by service. Ordinary users wouldn't have access to manipulate these
    let rank: Int?
    var created_at: String?
}


// Struct to feed to user
struct MultipleResponseProblemToFeed: Codable {
    // Identifiers for set
    var content_id: String
    var set_name: String
    
    // Intrinsic content
    var choices: [String: String]
    var answer: String

    init(content_id: String, set_name: String, answer: String) {
        self.content_id = content_id
        self.set_name = set_name
        self.answer = answer
   }
}

struct Perplexion: Codable {
    // Database collection identifiers
    let _id: String?
    var _rev: String?

    // User identifier
    var user_type: String
    var user_id: String

    // Problem identifiers
    var set_name: String
    var problem_id: String

    // Unique contents with algorithm keys
    var perplexions: [String: Int]
}