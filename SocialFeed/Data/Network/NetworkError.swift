import Foundation
import Alamofire

enum NetworkError: Error {
    
    case invalidURL
    case noData
    case decodingError
    case mockFileNotFound
    case unknownError
}
