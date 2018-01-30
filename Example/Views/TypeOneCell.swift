import UIKit

class TypeOneCell: UICollectionViewCell {
    
    static let identifier = String(describing: TypeOneCell.self)
    
    public lazy var imageView: UIImageView = {
        $0.contentMode = .center
        return $0
    }(UIImageView())
    
    public lazy var title: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 20 : 17)
        $0.textColor = .black
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    public lazy var subtitle: UILabel = {
        $0.font = .systemFont(ofSize: UIDevice.current.userInterfaceIdiom == .pad ? 15 : 13)
        $0.textColor = .gray
        $0.numberOfLines = 1
        return $0
    }(UILabel())
    
    fileprivate let textView = UIView()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    fileprivate func setup() {
        backgroundColor = .white
        contentView.addSubview(imageView)
        contentView.addSubview(textView)
        textView.addSubview(title)
        textView.addSubview(subtitle)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        //Log("layoutMargins = \(layoutMargins), contentView = \(contentView.bounds)")
        layout()
    }
    
    func layout() {
        let vTextInset: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
        let hTextInset: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 12 : 8
        let imageViewHeight: CGFloat = contentView.height - (layoutMargins.top + layoutMargins.bottom)
        imageView.frame = CGRect(x: layoutMargins.left + 4, y: layoutMargins.top, width: imageViewHeight, height: imageViewHeight)
        let textViewWidth: CGFloat = contentView.width - imageView.frame.maxX - 2 * hTextInset
        let titleSize = title.sizeThatFits(CGSize(width: textViewWidth, height: contentView.height))
        let subtitleSize = subtitle.sizeThatFits(CGSize(width: textViewWidth, height: contentView.height))
        title.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: textViewWidth, height: titleSize.height))
        subtitle.frame = CGRect(origin: CGPoint(x: 0, y: title.frame.maxY + vTextInset), size: CGSize(width: textViewWidth, height: subtitleSize.height))
        textView.size = CGSize(width: textViewWidth, height: subtitle.frame.maxY)
        textView.frame.origin.x = imageView.frame.maxX + hTextInset
        textView.center.y = imageView.center.y
        //textRect(forBounds: CGRect(x: 0, y: 0, width: Int.max, height: 30), limitedToNumberOfLines: 1).width
        
        style(view: contentView)
    }
    
    func style(view: UIView) {
        view.maskToBounds = false
        view.backgroundColor = .white
        view.cornerRadius = 14
        view.shadowColor = .black
        view.shadowOffset = CGSize(width: 1, height: 5)
        view.shadowRadius = 8
        view.shadowOpacity = 0.2
        view.shadowPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 14, height: 14)).cgPath
        view.shadowShouldRasterize = true
        view.shadowRasterizationScale = UIScreen.main.scale
    }
}
