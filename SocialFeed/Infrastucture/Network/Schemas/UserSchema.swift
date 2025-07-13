/// Ответ сервера на запрос пользователя.
struct UserSchema: Codable {
    let id: String
    let username: String
    let avatar: String?
}
