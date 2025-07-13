import Foundation

extension Date {
    var formatDate: String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute], from: self, to: now)
        
        if let days = components.day, days > 0 {
            return "\(days) дн. назад"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours) ч. назад"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes) мин. назад"
        } else {
            return "Только что"
        }
    }
}
