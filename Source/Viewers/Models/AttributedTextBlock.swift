import UIKit

public enum AttributedTextBlock {
    
    case header1(String)
    case header2(String)
    case normal(String)
    case list(String)
    
    var text: NSMutableAttributedString {
        let attributedString: NSMutableAttributedString
        switch self {
        case .header1(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 20), .foregroundColor: UIColor.black]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .header2(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 18), .foregroundColor: UIColor.black]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .normal(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black]
            attributedString = NSMutableAttributedString(string: value, attributes: attributes)
        case .list(let value):
            let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black]
            attributedString = NSMutableAttributedString(string: "∙ " + value, attributes: attributes)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1
        paragraphStyle.paragraphSpacing = 10
        
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range:NSMakeRange(0, attributedString.length))
        return attributedString
    }
}
