import UIKit

extension String {
    
    /// Возвращает подстроку, которая умещается в заданное количество строк, с учётом шрифта и ширины.
    /// Добавляет "…" в конец, если строка была обрезана.
    func fittingSubstring(font: UIFont, width: CGFloat, maxLines: Int) -> String {
        let ending = "…"
        let characters = Array(self)
        
        let fullTextHeight = self.height(withConstrainedWidth: width, font: font)
        let maxHeight = round(CGFloat(maxLines) * font.lineHeight)

        if fullTextHeight <= maxHeight {
            return self
        }
        
        var fittingSubstring = ""
        for i in 1...characters.count {
            let candidate = String(characters.prefix(i)) + ending
            let height = candidate.height(withConstrainedWidth: width, font: font)
            
            if height <= maxHeight {
                fittingSubstring = String(characters.prefix(i))
            } else {
                break
            }
        }
        
        return fittingSubstring.count < self.count ? fittingSubstring + ending : fittingSubstring
    }
    
    /// Вычисляет высоту строки с заданной шириной и шрифтом.
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let boundingRect = (self as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font, .paragraphStyle: paragraphStyle],
            context: nil
        )
        
        return ceil(boundingRect.height)
    }
}
