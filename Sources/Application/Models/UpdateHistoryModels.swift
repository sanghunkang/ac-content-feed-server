import Kitura
import KituraOpenAPI
import KituraContracts

struct UpdateProblemHistoryParams: Codable { // struct UpdateProblemParams: Codable {
    let _id: String
    let set_name: String
    let problem_type: String
    let problem_id: String
    let answer_status: String // suceeded, failed, gaveup
    
    var perplexion_problem_id: String
    var perplexion_question: String // duplicate though
}

struct ProblemHistory: Codable {
    let _id: String?
    var _rev: String?

    // User identifier
    var user_type: String
    var user_id: String

    // Problem identifier
    var set_name: String
    var content_id: String

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