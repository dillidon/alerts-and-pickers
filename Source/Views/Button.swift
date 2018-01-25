import UIKit

open class Button: UIButton {
    
    public typealias Action = (Button) -> Swift.Void
    
    fileprivate var actionOnTouch: Action?
    
    init() {
        super.init(frame: .zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func action(_ closure: @escaping Action) {
        if actionOnTouch == nil {
            addTarget(self, action: #selector(Button.actionOnTouchUpInside), for: .touchUpInside)
        }
        self.actionOnTouch = closure
    }
    
    @objc internal func actionOnTouchUpInside() {
        actionOnTouch?(self)
    }
}


