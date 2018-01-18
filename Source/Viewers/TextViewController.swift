import UIKit

extension UIAlertController {
    
    /// Add a textViewer
    ///
    /// - Parameters:
    ///   - mode: date picker mode
    
    func addTextViewer(config: TextViewerViewController.Config? = nil, action: TextViewerViewController.Action? = nil) {
        let textViewer = TextViewerViewController(config: config, action: action)
        set(vc: textViewer)
    }
}

final class TextViewerViewController: UIViewController {
    
    public typealias Config = (UITextView) -> Swift.Void
    public typealias Action = (String?) -> Swift.Void
    
    fileprivate lazy var textView: UITextView = UITextView()
    fileprivate var action: Action?
    
    struct ui {
        static let height: CGFloat = UIScreen.main.bounds.height * 0.8
        static let vInset: CGFloat = 16
    }
    
    
    init(config configuration: Config? = nil, action: Action? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        configuration?(textView)
        preferredContentSize.height = ui.height
        
        textView.textContainerInset = UIEdgeInsetsMake(12, 16, 12, 16)
        //textView.becomeFirstResponder()
        //textView.selectedTextRange = textView.textRangeFromPosition(textView.beginningOfDocument, toPosition: textView.beginningOfDocument)
        //self.automaticallyAdjustsScrollViewInsets = false
        //textView.contentInsetAdjustmentBehavior = .never
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
        
    }
}

var returnPolicy: String {
    return "Standard Return Policy.\nThere are a few important things to keep in mind when returning a product you purchased online from Apple:\nYou have 14 calendar days to return an item from the date you received it.\nOnly items that have been purchased directly from Apple, either online or at an Apple Retail Store, can be returned to Apple. Apple products purchased through other retailers must be returned in accordance with their respective returns and refunds policy.\nPlease ensure that the item you're returning is repackaged with all the cords, adapters and documentation that were included when you received it.\nThere are some items, however, that are ineligible for return, including:\nOpened software*\nElectronic Software Downloads\nSoftware Up-to-Date Program Products (software upgrades)\nApple Store Gift Cards\nApple Developer products (membership, technical support incidents, WWDC tickets)\nApple Print Products\n*You can return software, provided that it has not been installed on any computer. Software that contains a printed software license may not be returned if the seal or sticker on the software media packaging is broken.\n\niPhone and iPad Returns — Wireless Service Cancellation\nWireless carriers have different service-cancellation policies. Returning your iPhone or iPad may not automatically cancel or reset your wireless account; you are responsible for your wireless service agreement and for any applicable fees associated with your wireless account. Please contact your provider for more information."
}
