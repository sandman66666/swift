import Foundation

enum ApiError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case serverError(Int)
    case decodingError
    case unauthorized
    case serverUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request. Please try again."
        case .networkError:
            return "Network error. Please check your connection."
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
        case .decodingError:
            return "Error processing data. Please try again."
        case .unauthorized:
            return "Please sign in again."
        case .serverUnavailable:
            return "Service temporarily unavailable. Please try again later."
        }
    }
}
