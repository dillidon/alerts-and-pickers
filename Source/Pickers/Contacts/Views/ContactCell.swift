import UIKit

final class ContactTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    static let identifier = String(describing: ContactTableViewCell.self)
    static let size: CGSize = CGSize(width: 80, height: 80)
    
    var contact: Contact?
    
    // MARK: Initialize
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = nil
        contentView.backgroundColor = nil
        imageView?.maskToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let value: CGFloat = self.contentView.height - 8
        imageView?.size = CGSize(width: value, height: value)
        imageView?.circleCorner = true
    }
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
    
    func configure(with contact: Contact) {
        self.contact = contact
        DispatchQueue.main.async {
            self.update()
        }
    }
    
    func update() {
        guard let contact = contact else { return }
        
        if let ava = contact.image {
            imageView?.image = ava
        } else {
            imageView?.setImageForName(string: contact.displayName, circular: true, gradient: true)
        }
        
        textLabel?.text = contact.displayName
        
        if contact.phones.count >= 1  {
            detailTextLabel?.text = "\(contact.phones[0].number)"
        } else {
            detailTextLabel?.text = "No phone numbers available"
        }
    }
}
