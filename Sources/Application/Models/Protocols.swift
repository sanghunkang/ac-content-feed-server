import Kitura
import KituraOpenAPI
import KituraContracts

struct UpdateContentParams: Codable {
    let _id: String
    let set_name: String
    let answer_status: String // suceeded, failed, gaveup
}

// struct GetContentParams: Codable {
//     let set_name: String
// }

struct GetContentParams: QueryParams {
    let set_name: String
}

struct Response: Codable {
    let message: String

    init(message: String) {
        self.message = message
    }
}
