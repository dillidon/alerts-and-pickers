import UIKit

extension UIAlertController {
    
    /// Add Image Picker
    ///
    /// - Parameters:
    ///   - flow: scroll direction
    ///   - pagging: pagging
    ///   - height: height of picker's view controller
    ///   - images: for content to select
    ///   - selection: type and action for selection of image/images
    
    public func addImagePicker(flow: UICollectionViewScrollDirection, paging: Bool, height: CGFloat? = nil, images: [UIImage], selection: ImagePickerViewController.SelectionType? = nil) {
        let imagePicker = ImagePickerViewController(flow: flow, paging: paging, data: images, selection: selection)
        if let height = height {
            imagePicker.preferredContentSize.height = height
        } else {
            imagePicker.preferredContentSize.height = imagePicker.preferredHeight
        }
        set(vc: imagePicker)
    }
}

final public class ImagePickerViewController: UIViewController {
    
    public typealias SingleAction = (UIImage?) -> Swift.Void
    public typealias MultiAction = ([UIImage]) -> Swift.Void
    
    public enum SelectionType {
        case single(action: SingleAction?)
        case multiple(action: MultiAction?)
    }
    
    typealias CellConfig = (ItemWithImage?) -> Swift.Void
    
    struct CellData {
        var config: CellConfig?
        var action: CellConfig?
    }
    
    // MARK: UI Metrics
    
    struct UI {
        static let itemHeight: CGFloat = UIScreen.main.bounds.width
    }
    
    var preferredHeight: CGFloat {
        switch layout.scrollDirection {
        case .vertical: return UIScreen.main.bounds.height
        case .horizontal: return UIScreen.main.bounds.width * 1.5
        }
    }
    
    var columns: CGFloat {
        switch layout.scrollDirection {
        case .vertical: return 2
        case .horizontal: return 1
        }
    }
    
    var itemSize: CGSize {
        switch layout.scrollDirection {
        case .vertical:
            return CGSize(width: collectionView.bounds.width / columns, height: collectionView.bounds.width / columns)
        case .horizontal:
            return collectionView.bounds.size
        }
    }
    
    // MARK: Properties
    
    fileprivate lazy var collectionView: UICollectionView = {
        $0.dataSource = self
        $0.delegate = self
        $0.register(ItemWithImage.self, forCellWithReuseIdentifier: String(describing: ItemWithImage.self))
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.decelerationRate = UIScrollViewDecelerationRateFast
        if #available(iOS 11.0, *) {
            $0.contentInsetAdjustmentBehavior = .never
        }
        $0.bounces = false
        $0.backgroundColor = .clear
        $0.maskToBounds = false
        $0.clipsToBounds = false
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()))
    
    fileprivate var layout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        $0.color = .lightGray
        return $0
    }(UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge))
    
    fileprivate var data: [UIImage]
    fileprivate var selection: SelectionType?
    fileprivate var dataSource: [CellData] = []
    
    fileprivate lazy var selectedImages: [UIImage] = []
    
    // MARK: Initialize
    
    required public init(flow: UICollectionViewScrollDirection, paging: Bool, data: [UIImage], selection: SelectionType?) {
        self.data = data
        self.selection = selection
        super.init(nibName: nil, bundle: nil)
        
        self.layout.scrollDirection = flow
        
        collectionView.isPagingEnabled = paging
        
        switch selection {
        case .single(_)?:
            collectionView.allowsSelection = true
        case .multiple(_)?:
            collectionView.allowsMultipleSelection = true
        case .none: break }
        //layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override public func loadView() {
        view = collectionView
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(indicatorView)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDataSource()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        indicatorView.center = view.center
    }
    
    func updateDataSource() {
        self.indicatorView.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            self.reloadDataSource()
            DispatchQueue.main.async {
                self.indicatorView.stopAnimating()
                self.collectionView.reloadData()
            }
        }
    }
    
    func reloadDataSource() {
        dataSource = data.map { image in
            let config: CellConfig = { cell in
                cell?.imageView.image = image
            }
            let action: CellConfig = { [unowned self] cell in
                switch self.selection {
                case .single(let action)?:
                    action?(image)
                case .multiple(let action)?:
                    if self.selectedImages.contains(image) {
                        self.selectedImages.remove(image)
                    } else {
                        self.selectedImages.append(image)
                    }
                    action?(self.selectedImages)
                case .none: break }
            }
            return CellData(config: config, action: action)
        }
    }
}

// MARK: - TableViewDelegate

extension ImagePickerViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataSource[indexPath.item].action?(collectionView.cellForItem(at: indexPath) as? ItemWithImage)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        switch selection {
        case .multiple(_)?:
            dataSource[indexPath.item].action?(collectionView.cellForItem(at: indexPath) as? ItemWithImage)
        default: break }
    }
}

// MARK: - TableViewDataSource

extension ImagePickerViewController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ItemWithImage.self), for: indexPath) as? ItemWithImage else { return UICollectionViewCell() }
        dataSource[indexPath.item].config?(item)
        return item
    }
}

/// UICollectionViewDelegateFlowLayout
extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch layout.scrollDirection {
        case .vertical:
            return CGSize(width: collectionView.bounds.width / columns, height: collectionView.bounds.width / columns)
        case .horizontal:
            return collectionView.bounds.size
        }
    }
}

class ItemWithImage: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.maskToBounds = true
        return $0
    }(UIImageView())
    
    lazy var unselectedCircle: UIView = {
        $0.backgroundColor = .clear
        $0.borderWidth = 2
        $0.borderColor = .white
        $0.maskToBounds = false
        return $0
    }(UIView())
    
    lazy var selectedCircle: UIView = {
        $0.backgroundColor = .clear
        $0.borderWidth = 2
        $0.borderColor = .white
        $0.maskToBounds = false
        return $0
    }(UIView())
    
    lazy var selectedPoint: UIView = {
        $0.backgroundColor = UIColor(hex: 0x007AFF)
        return $0
    }(UIView())
    
    fileprivate let inset: CGFloat = 8
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public func setup() {
        backgroundColor = .clear
        //contentView.backgroundColor = .clear
        //contentView.addSubview(imageView)
        
        
        
        let unselected: UIView = UIView()
        unselected.addSubview(imageView)
        unselected.addSubview(unselectedCircle)
        backgroundView = unselected
        
        let selected: UIView = UIView()
        selected.addSubview(selectedCircle)
        selected.addSubview(selectedPoint)
        selectedBackgroundView = selected
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    func layout() {
        imageView.frame = contentView.frame
        updateAppearance(forCircle: unselectedCircle)
        updateAppearance(forCircle: selectedCircle)
        updateAppearance(forPoint: selectedPoint)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.size = size
        layout()
        return size
    }
    
    func updateAppearance(forCircle view: UIView) {
        view.frame.size = CGSize(width: 28, height: 28)
        view.frame.origin.x = imageView.bounds.width - unselectedCircle.bounds.width - inset
        view.frame.origin.y = inset
        view.circleCorner = true
        view.shadowColor = UIColor.black.withAlphaComponent(0.4)
        view.shadowOffset = .zero
        view.shadowRadius = 4
        view.shadowOpacity = 0.2
        view.shadowPath = UIBezierPath(roundedRect: unselectedCircle.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: unselectedCircle.bounds.width / 2, height: unselectedCircle.bounds.width / 2)).cgPath
        view.shadowShouldRasterize = true
        view.shadowRasterizationScale = UIScreen.main.scale
    }
    
    func updateAppearance(forPoint view: UIView) {
        view.frame.size = CGSize(width: unselectedCircle.width - unselectedCircle.borderWidth * 2, height: unselectedCircle.height - unselectedCircle.borderWidth * 2)
        view.center = selectedCircle.center
        view.circleCorner = true
    }
}
