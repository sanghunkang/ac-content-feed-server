import Kitura
import KituraOpenAPI
import KituraContracts

struct GetContentParams: QueryParams { // struct GetProblemParams: QueryParams {
    let set_name: String
}

struct GetContentsParams: QueryParams { // struct GetProblemsParams: QueryParams {
    let set_name: String
    let num_contents: Int
}

struct GetProblemParams: QueryParams {
    let set_name: String
}

struct GetProblemsParams: QueryParams {
    let set_name: String
    let num_contents: Int
}

struct UpdateContentParams: Codable { // struct UpdateProblemParams: Codable {
    let _id: String
    let set_name: String
    // let problem_id: String
    let answer_status: String // suceeded, failed, gaveup
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





struct SetName: Codable {
    var set_name: String
    var problem_type: String? // true_or_false, multiple_response

    init(set_name: String) {
        self.set_name = set_name
    }
}


struct ResponseMessage: Codable {
    let message: String

    init(message: String) {
        self.message = message
    }
}