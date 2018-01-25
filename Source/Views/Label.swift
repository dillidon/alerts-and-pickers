import UIKit

open class Label: UILabel {
    
    public typealias Action = (Label) -> Swift.Void
    
    fileprivate var actionOnTouch: Action?
    
    open var insets: UIEdgeInsets = .zero
    
    override open func drawText(in rect: CGRect) {
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    // Override -intrinsicContentSize: for Auto layout code
    override open var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += insets.top + insets.bottom
        contentSize.width += insets.left + insets.right
        return contentSize
    }
    
    // Override -sizeThatFits: for Springs & Struts code
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var contentSize = super.sizeThatFits(size)
        contentSize.height += insets.top + insets.bottom
        contentSize.width += insets.left + insets.right
        return contentSize
    }
    
    public func action(_ closure: @escaping Action) {
        Log("action did set")
        if actionOnTouch == nil {
            let gesture = UITapGestureRecognizer(
                target: self,
                action: #selector(Label.actionOnTouchUpInside))
            gesture.numberOfTapsRequired = 1
            gesture.numberOfTouchesRequired = 1
            self.addGestureRecognizer(gesture)
            self.isUserInteractionEnabled = true
        }
        self.actionOnTouch = closure
    }
    
    @objc internal func actionOnTouchUpInside() {
        actionOnTouch?(self)
    }
}
