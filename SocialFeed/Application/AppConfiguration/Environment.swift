/// Перечисление, определяющее окружение для API.
///
/// Используется для выбора соответствующего базового URL в зависимости от конфигурации сборки:
/// - `production` - боевое окружение.
/// - `development` - среда разработки.
/// - `mock` - подставные данные для тестирования без реального API.
enum Environment {
    
    /// Боевое окружение (Production).
    case production
    
    /// Среда разработки (Development).
    case development
    
    /// Тестовое окружение с подставными данными (Mock).
    case mock
    
    /// Базовый URL для соответствующего окружения.
    ///
    /// Возвращает строку с адресом API в зависимости от текущего значения перечисления:
    /// - `production` - `https://api.example.com`
    /// - `development` - `https://dev-api.example.com`
    /// - `mock` - `mock://api`
    var baseURL: String {
        switch self {
        case .development:
            return "https://dev-api.example.com"
        case .production:
            return "https://api.example.com"
        case .mock:
            return "mock://api"
        }
    }
}
