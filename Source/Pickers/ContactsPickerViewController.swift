import UIKit
import ContactsUI

extension UIAlertController {
    
    /// Add Contacts Picker
    ///
    /// - Parameters:
    ///   - selection: type and action for selection of contact
    
    func addContactsPicker(selection: ContactsPickerViewController.SelectionType) {
        let vc = ContactsPickerViewController(selection: selection)
        vc.alertController = self
        set(vc: vc)
    }
}

final class ContactsPickerViewController: UIViewController {
    
    // MARK: UI Metrics
    
    struct UI {
        static let rowHeight: CGFloat = 58
        static let separatorColor: UIColor = UIColor.lightGray.withAlphaComponent(0.4)
    }
    
    // MARK: Properties
    
    var alertController: UIAlertController?
    
    public enum SelectionType {
        
        case single(action: (Contact) -> ())
        case multiple(action: ([Contact]) -> ())
        case showOrCall
    }
    
    fileprivate var selection: SelectionType {
        didSet {
            switch selection {
            case .single(_), .showOrCall: tableView.allowsMultipleSelection = false
            case .multiple(_): tableView.allowsMultipleSelection = true
            }
        }
    }
    
    //Contacts ordered in dicitonary alphabetically
    var orderedContacts = [String: [CNContact]]()
    var sortedContactKeys = [String]()
    
    var selectedContacts: [Contact] = []
    var filteredContacts: [CNContact] = []
    
    fileprivate lazy var resultSearchController: UISearchController = {
        $0.searchResultsUpdater = self
        $0.searchBar.delegate = self
        $0.dimsBackgroundDuringPresentation = false
        $0.hidesNavigationBarDuringPresentation = false
        //$0.view.backgroundColor = .clear
        //$0.searchBar.showsScopeBar = false
        //$0.searchBar.backgroundImage = UIImage()
        //$0.searchBar.isTranslucent = true
        //$0.searchBar.tintColor = .black
        //$0.searchBar.backgroundColor = .clear
        //$0.searchBar.barStyle = .default
        $0.searchBar.searchBarStyle = .minimal
        $0.searchBar.textField?.textColor = .black
        $0.searchBar.textField?.clearButtonMode = .whileEditing
        //$0.searchBar.textField?.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        return $0
    }(UISearchController(searchResultsController: nil))
    
    fileprivate lazy var tableView: UITableView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        $0.separatorColor = UI.separatorColor
        $0.bounces = true
        $0.rowHeight = UI.rowHeight
        $0.backgroundColor = nil
        $0.tableFooterView = UIView()
        $0.register(ContactTableViewCell.self,
                    forCellReuseIdentifier: ContactTableViewCell.identifier)
        return $0
        }(UITableView(frame: .zero, style: .plain))
    
    fileprivate lazy var searchView: UIView = UIView()
    
    // MARK: Initialize
    
    required init(selection: SelectionType) {
        self.selection = selection
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            preferredContentSize.width = UIScreen.main.bounds.width / 2
        }
        
        searchView.addSubview(resultSearchController.searchBar)
        tableView.tableHeaderView = searchView

        extendedLayoutIncludesOpaqueBars = true
        edgesForExtendedLayout = .bottom
        definesPresentationContext = true

        updateContacts()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableView.tableHeaderView?.height = 57
        resultSearchController.searchBar.sizeToFit()
        resultSearchController.searchBar.frame.size.width = searchView.frame.size.width
        resultSearchController.searchBar.frame.size.height = searchView.frame.size.height
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        preferredContentSize.height = tableView.contentSize.height
    }
    
    func updateContacts() {
        checkStatus { [unowned self] orderedContacts in
            
            self.orderedContacts = orderedContacts
            self.sortedContactKeys = Array(self.orderedContacts.keys).sorted(by: <)
            
            if self.sortedContactKeys.first == "#" {
                self.sortedContactKeys.removeFirst()
                self.sortedContactKeys.append("#")
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func checkStatus(completionHandler: @escaping ([String: [CNContact]]) -> ()) {
        Log("status = \(CNContactStore.authorizationStatus(for: .contacts))")
        switch CNContactStore.authorizationStatus(for: .contacts) {
            
        case .notDetermined:
            /// This case means the user is prompted for the first time for allowing contacts
            Contacts.requestAccess { [unowned self] bool, error in
                self.checkStatus(completionHandler: completionHandler)
            }
            
        case .authorized:
            /// Authorization granted by user for this app.
            DispatchQueue.main.async {
                self.fetchContacts(completionHandler: completionHandler)
            }

        case .denied, .restricted:
            /// User has denied the current app to access the contacts.
            let productName = Bundle.main.infoDictionary!["CFBundleName"]!
            let alert = UIAlertController(style: .alert, title: "Permission denied", message: "\(productName) does not have access to contacts. Please, allow the application to access to your contacts.")
            alert.addAction(title: "Settings", style: .destructive) { action in
                if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(settingsURL)
                }
            }
            alert.addAction(title: "OK", style: .cancel) { [unowned self] action in
                self.alertController?.dismiss(animated: true)
            }
            alert.show()
        }
    }
    
    func fetchContacts(completionHandler: @escaping ([String: [CNContact]]) -> ()) {
        Contacts.fetchContactsGroupedByAlphabets { [unowned self] result in
            switch result {
                
            case .success(let orderedContacts):
                completionHandler(orderedContacts)
                
            case .error(let error):
                Log("------ error")
                let alert = UIAlertController(style: .alert, title: "Error", message: error.localizedDescription)
                alert.addAction(title: "OK") { [unowned self] action in
                    self.alertController?.dismiss(animated: true)
                }
                alert.show()
            }
        }
    }
    
    func show(contact: CNContact) {
        var contact = contact
        let keys: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor,
            CNContactViewController.descriptorForRequiredKeys()
        ]
        if !contact.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            do {
                contact = try CNContactStore().unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            }
            catch { }
        }
        
        let vc = CNContactViewController(for: contact)
        vc.delegate = self
        vc.contactStore = CNContactStore()
        vc.allowsActions = true
        vc.allowsEditing = false
        vc.displayedPropertyKeys = keys
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.modalPresentationStyle = UIModalPresentationStyle.currentContext
        self.present(navigationVC, animated: true)
    }
}

extension ContactsPickerViewController: CNContactViewControllerDelegate {
    /*!
     * @abstract    Called when the user selects a single property.
     * @discussion  Return @c NO if you do not want anything to be done or if you are handling the actions yourself.
     * @return      @c YES if you want the default action performed for the property otherwise return @c NO.
     */
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        return true
    }
    
    
    /*!
     * @abstract    Called when the view has completed.
     * @discussion  If creating a new contact, the new contact added to the contacts list will be passed.
     *              If adding to an existing contact, the existing contact will be passed.
     * @note        It is up to the delegate to dismiss the view controller.
     */
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        
    }
}

extension ContactsPickerViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = resultSearchController.searchBar.text, searchController.isActive else { return }
        Contacts.searchContact(searchString: searchText) { [unowned self] result in
            switch result {
            case .success(let contacts):
                self.filteredContacts = contacts
                self.tableView.reloadData()
            case .error(let error):
                Log(error.localizedDescription)
            }
        }
    }
}

extension ContactsPickerViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - TableViewDelegate

extension ContactsPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ContactTableViewCell
        guard let selectedContact = cell.contact else { return }
        switch selection {
            
        case .single(let action):
            resultSearchController.isActive = false
            DispatchQueue.main.async {
                action(selectedContact)
            }
            
        case .multiple(let action):
            cell.isSelected
                ? selectedContacts = selectedContacts.filter { $0.id != selectedContact.id }
                : selectedContacts.append(selectedContact)
            action(selectedContacts)
            
        case .showOrCall:
            break
        }
    }
}

// MARK: - TableViewDataSource

extension ContactsPickerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if resultSearchController.isActive { return 1 }
        return sortedContactKeys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.isActive { return filteredContacts.count }
        if let contactsForSection = orderedContacts[sortedContactKeys[section]] {
            return contactsForSection.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if resultSearchController.isActive { return 0 }
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: UITableViewScrollPosition.top , animated: false)
        return sortedContactKeys.index(of: title)!
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if resultSearchController.isActive { return nil }
        return sortedContactKeys
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if resultSearchController.isActive { return nil }
        return sortedContactKeys[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.identifier) as! ContactTableViewCell
       
        /// Convert CNContact to Contact
        let contact: Contact
        
        if resultSearchController.isActive {
            contact = Contact(contact: filteredContacts[indexPath.row])
        } else {
            guard let contactsForSection = orderedContacts[sortedContactKeys[indexPath.section]] else {
                assertionFailure()
                return UITableViewCell()
            }
            contact = Contact(contact: contactsForSection[indexPath.row])
        }
        
        switch selection {
        case .multiple(_):
            if selectedContacts.contains(where: { $0.id == contact.id }) {
                cell.accessoryType = .checkmark
            }
        case .showOrCall:
            let button: Button = Button()
            button.size = CGSize(width: 40, height: 40)
            button.setImage(#imageLiteral(resourceName: "user"), for: .normal)
            button.action { [unowned self] button in
                self.show(contact: contact.value)
            }
            cell.accessoryView = button
        default: break }
        
        cell.configure(with: contact)
        return cell
    }
}

final class ContactTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    static let identifier = String(describing: ContactTableViewCell.self)
    static let size: CGSize = CGSize(width: 80, height: 80)
    
    var contact: Contact?
    
    // MARK: Initialize
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
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
