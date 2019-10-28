import Kitura
import KituraOpenAPI
import KituraContracts

struct GetSetNameParams: QueryParams {
    // User identifiers
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