import UIKit

final class LikeButtonCell: UITableViewCell {
    
    // MARK: Properties
    
    static let identifier = String(describing: LikeButtonCell.self)
    
    
    // MARK: Initialize
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = nil
        contentView.backgroundColor = nil
        textLabel?.textColor = UIColor(hex: 0x007AFF)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.textAlignment = .center
    }
}
