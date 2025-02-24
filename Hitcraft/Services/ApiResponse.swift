struct ApiResponse<T: Codable>: Codable {
    let data: T
    let status: Int
    let message: String?
    let errors: [String]?
    
    enum CodingKeys: String, CodingKey {
        case data
        case status
        case message
        case errors
    }
}
