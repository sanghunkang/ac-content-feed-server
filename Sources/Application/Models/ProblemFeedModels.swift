import Kitura
import KituraOpenAPI
import KituraContracts

struct GetProblemParams: QueryParams {
    let set_name: String
}

struct GetProblemsParams: QueryParams {
    let set_name: String
    let num_problems: Int
}

struct Problem: Codable {
    // Identifiers for database
    let _id: String?
    var _rev: String?

    // Identifiers for set
    var set_name: String
    var problem_id: String
    var problem_type: String
    
    // Unique content
    var question: String
    var answer: String             
    var solution: String?           // only required for TF question (possibly for MRP?)

    // Automatically computed by service. Ordinary users wouldn't have access to manipulate these
    let rank: Int?
    var created_at: String?
}

struct ProblemFeed: Codable {
    // Identifiers for set
    var set_name: String
    var problem_id: String
    var problem_type: String
    
    // Unique content
    var question: String
    var answer: String
    var solution: String?           // only required for TF question (possibly for MRP?)
    var choices: [String: String]?  // only required for MRP

    init(set_name: String, problem_id: String, problem_type: String, question: String, answer: String) {
        self.problem_id = problem_id;
        self.problem_type = problem_type;
        self.set_name = set_name;
        self.question = question;
        self.answer = answer;
   }
}

struct Perplexion: Codable {
    // User identifier
    var user_id: String?

    // Problem identifiers
    var set_name: String
    var label_problem_id: String
    var perplexion_problem_id: String
    var perplexion_question: String     // duplicate, but will allow to skip one query per problem

    // Unique contents with algorithm keys
    var rank: Int
}