import UIKit

extension UITableViewCell {
    
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}
