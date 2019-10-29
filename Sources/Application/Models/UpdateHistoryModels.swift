import Kitura
import KituraOpenAPI
import KituraContracts

struct UpdateProblemHistoryParams: Codable {
    let set_name: String
    let problem_type: String
    let problem_id: String
    let answer_status: String // suceeded, failed, gaveup
    
    // If MRP
    var perplexion_problem_id: String?
    var perplexion_question: String? // duplicate though
}

struct ProblemHistory: Codable { // Once written, never updated
    // User identifier
    var user_id: String?

    // Problem identifier
    var set_name: String
    var problem_id: String

    var answer_status: String
    var created_at: String
}

struct PerplexionHistory: Codable { // Once written, never updated
    // User identifier
    var user_id: String?

    // Problem identifier
    var set_name: String
    var problem_id: String
    var perplexion_problem_id: String
    var perplexion_question: String

    var created_at: String
}