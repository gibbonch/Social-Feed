import Foundation

final class MockResponseManager {
    
    static let shared = MockResponseManager()
    
    private init() {}
    
    func mockResponse<T: Decodable>(for endpoint: Endpoint, type: T.Type) -> Result<T, NetworkError> {
        guard let fileName = endpoint.mockResponseFileName,
              let data = loadMockData(from: fileName)else {
            return .failure(.mockFileNotFound)
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let result = try decoder.decode(T.self, from: data)
            return .success(result)
        } catch {
            print(error.localizedDescription)
            return .failure(.decodingError)
        }
    }
    
    private func loadMockData(from fileName: String) -> Data? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Mock file not found: \(fileName)")
            return nil
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Error loading mock data: \(error)")
            return nil
        }
    }
}
