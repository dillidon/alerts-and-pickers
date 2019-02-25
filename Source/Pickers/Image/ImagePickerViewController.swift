import UIKit

extension UIAlertController {
    
    /// Add Image Picker
    ///
    /// - Parameters:
    ///   - flow: scroll direction
    ///   - pagging: pagging
    ///   - images: for content to select
    ///   - selection: type and action for selection of image/images
    
    func addImagePicker(flow: UICollectionView.ScrollDirection, paging: Bool, images: [UIImage], selection: ImagePickerViewController.SelectionType? = nil) {
        let vc = ImagePickerViewController(flow: flow, paging: paging, images: images, selection: selection)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.preferredContentSize.height = vc.preferredSize.height * 0.9
            vc.preferredContentSize.width = vc.preferredSize.width * 0.9
        } else {
            vc.preferredContentSize.height = vc.preferredSize.height
        }

        set(vc: vc)
    }
}

final class ImagePickerViewController: UIViewController {
    
    public typealias SingleSelection = (UIImage?) -> Swift.Void
    public typealias MultipleSelection = ([UIImage]) -> Swift.Void
    
    public enum SelectionType {
        case single(action: SingleSelection?)
        case multiple(action: MultipleSelection?)
    }

    // MARK: UI Metrics
    
    struct UI {
        static let itemHeight: CGFloat = UIScreen.main.bounds.width
    }
    
    var preferredSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    var columns: CGFloat {
        switch layout.scrollDirection {
        case .vertical: return UIDevice.current.userInterfaceIdiom == .pad ? 3 : 2
        case .horizontal: return 1
        }
    }
    
    var itemSize: CGSize {
        switch layout.scrollDirection {
        case .vertical:
            return CGSize(width: view.bounds.width / columns, height: view.bounds.width / columns)
        case .horizontal:
            return CGSize(width: view.bounds.width, height: view.bounds.height / columns)
        }
    }
    
    // MARK: Properties
    
    fileprivate lazy var collectionView: UICollectionView = { [unowned self] in
        $0.dataSource = self
        $0.delegate = self
        $0.register(ItemWithImage.self, forCellWithReuseIdentifier: ItemWithImage.identifier)
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.decelerationRate = UIScrollView.DecelerationRate.fast
        $0.contentInsetAdjustmentBehavior = .never
        $0.bounces = false
        $0.backgroundColor = .clear
        $0.maskToBounds = false
        $0.clipsToBounds = false
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: layout))
    
    fileprivate lazy var layout: UICollectionViewFlowLayout = {
        $0.minimumInteritemSpacing = 0
        $0.minimumLineSpacing = 0
        $0.sectionInset = .zero
        return $0
    }(UICollectionViewFlowLayout())
    
    fileprivate var selection: SelectionType?
    fileprivate var images: [UIImage] = []
    fileprivate var selectedImages: [UIImage] = []
    
    // MARK: Initialize
    
    required init(flow: UICollectionView.ScrollDirection, paging: Bool, images: [UIImage], selection: SelectionType?) {
        super.init(nibName: nil, bundle: nil)
        self.images = images
        self.selection = selection
        self.layout.scrollDirection = flow
        
        collectionView.isPagingEnabled = paging
        
        switch selection {
        case .single(_)?: collectionView.allowsSelection = true
        case .multiple(_)?: collectionView.allowsMultipleSelection = true
        case .none: break }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override func loadView() {
        view = collectionView
    }
}

// MARK: - CollectionViewDelegate

extension ImagePickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = images[indexPath.item]
        switch selection {
            
        case .single(let action)?:
            action?(images[indexPath.row])
        
        case .multiple(let action)?:
            selectedImages.contains(image)
                ? selectedImages.remove(image)
                : selectedImages.append(image)
            action?(selectedImages)
        
        case .none: break }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let image = images[indexPath.item]
        switch selection {
        case .multiple(let action)?:
            selectedImages.contains(image)
                ? selectedImages.remove(image)
                : selectedImages.append(image)
            action?(selectedImages)
        default: break }
    }
}

// MARK: - CollectionViewDataSource

extension ImagePickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: ItemWithImage.identifier, for: indexPath) as? ItemWithImage else { return UICollectionViewCell() }
        item.imageView.image = images[indexPath.row]
        return item
    }
}

// MARK: - CollectionViewDelegateFlowLayout

extension ImagePickerViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        Log("view size = \(view.bounds), collectionView = \(collectionView.size), itemSize = \(itemSize)")
        return itemSize
    }
}
