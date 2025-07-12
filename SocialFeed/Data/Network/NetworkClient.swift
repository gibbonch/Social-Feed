import Foundation
import Alamofire

/// Протокол сетевого клиента для выполнения API-запросов.
protocol NetworkClientProtocol {
    
    /// Выполняет сетевой запрос к заданному endpoint.
    ///
    /// - Parameters:
    ///   - endpoint: Объект, соответствующий протоколу `Endpoint`, описывающий параметры запроса.
    ///   - responseType: Тип ожидаемой модели, соответствующий `Decodable`.
    ///   - completion: Замыкание, вызываемое по завершении запроса с результатом:
    ///     - `success`: Успешно декодированная модель типа `T`.
    ///     - `failure`: Ошибка `NetworkError`.
    func request<T: Decodable>(
        _ endpoint: Endpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    )
}

/// Класс сетевого клиента, реализующий `NetworkClientProtocol`.
///
/// Отвечает за выполнение реальных или мок-запросов в зависимости от окружения.
final class NetworkClient {
    
    /// Экземпляр Alamofire `Session`.
    private let session: Session
    
    /// Текущее сетевое окружение (`production`, `development`, `mock`).
    private let environment: Environment
    
    /// Инициализирует сетевой клиент с заданным окружением и конфигурацией сессии.
    ///
    /// - Parameters:
    ///   - environment: Окружение API (по умолчанию — `.development`).
    ///   - configuration: Конфигурация `URLSession` для Alamofire.
    init(environment: Environment = .development, configuration: URLSessionConfiguration) {
        self.environment = environment
        self.session = Session(configuration: configuration)
    }
}

extension NetworkClient: NetworkClientProtocol {
    
    func request<T>(
        _ endpoint: any Endpoint,
        responseType: T.Type,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) where T : Decodable {
        
        // Если выбрано mock-окружение — возвращается заранее определённый ответ.
        if environment == .mock {
            let mockResponse = MockResponseManager.shared.mockResponse(for: endpoint, type: responseType)
            // Симмуляция сетевого запроса
            DispatchQueue.global(qos: .utility).async {
                usleep(UInt32.random(in: 500_000...2_000_000))
                completion(mockResponse)
            }
            return
        }
        
        let fullURL = environment.baseURL + endpoint.path
        
        session.request(
            fullURL,
            method: endpoint.method,
            parameters: endpoint.parameters,
            headers: endpoint.headers
        )
        .validate()
        .responseDecodable(of: responseType) { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure:
                completion(.failure(.unknownError))
            }
        }
    }
}

