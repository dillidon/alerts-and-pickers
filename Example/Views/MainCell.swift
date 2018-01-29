import UIKit

final class MainTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    static let identifier = String(describing: MainTableViewCell.self)
    
    fileprivate lazy var backView: UIView = {
        $0.backgroundColor = .white
        return $0
    }(UIView())
    
    fileprivate var inset: CGFloat {
        return 20 + layoutMargins.right + layoutMargins.left
    }
    
    fileprivate var originalWidth: CGFloat?
    
    // MARK: Initialize
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.insertSubview(backView, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if originalWidth == nil { originalWidth = size.width }
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: (originalWidth ?? size.width) - inset, height: size.height)
        super.layoutSubviews()
        //Log("layoutMargins = \(layoutMargins)")
        //Log("styling ")
        let margin: CGFloat = 1.5 * (layoutMargins.left + layoutMargins.right)
        backView.frame = CGRect(
            x: bounds.origin.x + (UIDevice.current.userInterfaceIdiom == .pad ? margin : 0),
            y: bounds.origin.y,
            width: bounds.width - (UIDevice.current.userInterfaceIdiom == .pad ? 2 * margin : 0),
            height: bounds.height)
        style(view: backView)
    }
    
    func style(view: UIView) {
        view.maskToBounds = false
        view.backgroundColor = .white
        view.cornerRadius = 12
        view.shadowColor = .black
        view.shadowOffset = CGSize(width: 2, height: 4)
        view.shadowRadius = 8
        view.shadowOpacity = 0.2
        view.shadowPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 12, height: 12)).cgPath
        view.shadowShouldRasterize = true
        view.shadowRasterizationScale = UIScreen.main.scale
    }
}
