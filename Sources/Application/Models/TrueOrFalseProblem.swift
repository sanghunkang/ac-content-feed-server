import Kitura
import KituraOpenAPI
import KituraContracts

struct Content: Codable { // struct TrueOrFalseProblemToInsert: Codable {
    // Identifiers for database
    let _id: String?
    var _rev: String?

    // Identifiers for set
    var content_id: String?
    var set_name: String
    
    // Unique content
    var question: String
    var answer: Bool
    var solution: String

    // Automatically computed by service. Ordinary users wouldn't have access to manipulate these
    let rank: Int?
    var created_at: String?
}

struct TrueOrFalseProblemToServe: Codable {
    // Identifiers for set
    var content_id: String?
    var set_name: String
    
    // Unique content
    var question: String
    var answer: Bool
    var solution: String
}



struct UpdateProblemHistoryParams: Codable {
    var set_name: String
    var problem_id: String
    var answer_status: String
}

struct UpdateUserHistoriesParam: Codable {
    
}