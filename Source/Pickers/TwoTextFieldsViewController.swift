import UIKit

extension UIAlertController {
    
    /// Add two textField
    ///
    /// - Parameters:
    ///   - height: textField height
    ///   - hInset: right and left margins to AlertController border
    ///   - vInset: bottom margin to button
    ///   - textFieldOne: first textField
    ///   - textFieldTwo: second textField
    
    public func addTwoTextFields(height: CGFloat = 58, hInset: CGFloat = 0, vInset: CGFloat = 0, textFieldOne: TextField.Config?, textFieldTwo: TextField.Config?) {
        let textField = TwoTextFieldsViewController(height: height, hInset: hInset, vInset: vInset, textFieldOne: textFieldOne, textFieldTwo: textFieldTwo)
        set(vc: textField, height: height * 2 + 2 * vInset)
    }
}

final public class TwoTextFieldsViewController: UIViewController {
    
    fileprivate lazy var textFieldView: UIView = UIView()
    fileprivate lazy var textFieldOne: TextField = TextField()
    fileprivate lazy var textFieldTwo: TextField = TextField()
    
    fileprivate var height: CGFloat
    fileprivate var hInset: CGFloat
    fileprivate var vInset: CGFloat
    
    public init(height: CGFloat, hInset: CGFloat, vInset: CGFloat, textFieldOne configurationOneFor: TextField.Config?, textFieldTwo configurationTwoFor: TextField.Config?) {
        self.height = height
        self.hInset = hInset
        self.vInset = vInset
        super.init(nibName: nil, bundle: nil)
        view.addSubview(textFieldView)
        
        textFieldView.addSubview(textFieldOne)
        textFieldView.addSubview(textFieldTwo)
        
        textFieldView.width = view.width
        textFieldView.height = height * 2
        textFieldView.maskToBounds = true
        textFieldView.borderWidth = 1
        textFieldView.borderColor = UIColor.lightGray
        textFieldView.cornerRadius = 8
        
        configurationOneFor?(textFieldOne)
        configurationTwoFor?(textFieldTwo)
        
        //preferredContentSize.height = height * 2 + vInset
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textFieldView.width = view.width - hInset * 2
        textFieldView.height = height * 2
        textFieldView.center.x = view.center.x
        textFieldView.center.y = view.center.y
        
        textFieldOne.width = textFieldView.width
        textFieldOne.height = textFieldView.height / 2
        textFieldOne.center.x = textFieldView.width / 2
        textFieldOne.center.y = textFieldView.height / 4
        
        textFieldTwo.width = textFieldView.width
        textFieldTwo.height = textFieldView.height / 2
        textFieldTwo.center.x = textFieldView.width / 2
        textFieldTwo.center.y = textFieldView.height - textFieldView.height / 4
    }
}

