import UIKit

extension UIAlertController {
    
    /// Add a Text Viewer
    ///
    /// - Parameters:
    ///   - text: text kind
    
    func addTextViewer(text: TextViewerViewController.Kind) {
        let textViewer = TextViewerViewController(text: text)
        set(vc: textViewer)
    }
}

final class TextViewerViewController: UIViewController {
    
    enum Kind {
        
        case text(String?)
        case attributedText([AttributedText])
    }
    
    public enum AttributedText {
        
        case header1(String)
        case header2(String)
        case normal(String)
        case list(String)
        
        var text: NSMutableAttributedString {
            let attributedString: NSMutableAttributedString
            switch self {
            case .header1(let value):
                let attributes: [NSAttributedStringKey: Any] = [.font: UIFont.boldSystemFont(ofSize: 20), .foregroundColor: UIColor.black]
                attributedString = NSMutableAttributedString(string: value, attributes: attributes)
            case .header2(let value):
                let attributes: [NSAttributedStringKey: Any] = [.font: UIFont.boldSystemFont(ofSize: 18), .foregroundColor: UIColor.black]
                attributedString = NSMutableAttributedString(string: value, attributes: attributes)
            case .normal(let value):
                let attributes: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black]
                attributedString = NSMutableAttributedString(string: value, attributes: attributes)
            case .list(let value):
                let attributes: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black]
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
    
    fileprivate var text: [AttributedText] = []
    
    fileprivate lazy var textView: UITextView = {
        $0.isEditable = false
        $0.isSelectable = true
        $0.backgroundColor = nil
        return $0
    }(UITextView())
    
    struct UI {
        static let height: CGFloat = UIScreen.main.bounds.height * 0.8
        static let vInset: CGFloat = 16
        static let hInset: CGFloat = 16
    }
    
    
    init(text kind: Kind) {
        super.init(nibName: nil, bundle: nil)
        
        switch kind {
        case .text(let text):
            textView.text = text
        case .attributedText(let text):
            textView.attributedText = text.map { $0.text }.joined(separator: "\n")
        }
        textView.textContainerInset = UIEdgeInsetsMake(UI.hInset, UI.vInset, UI.hInset, UI.vInset)
        //preferredContentSize.height = self.textView.contentSize.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override func loadView() {
        view = textView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            preferredContentSize.width = UIScreen.main.bounds.width * 0.618
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.scrollToTop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize.height = textView.contentSize.height
        
    }
}
