import Foundation
import UIKit
import Photos

extension UIAlertController {
    
    /// Add PhotoLibrary Picker
    ///
    /// - Parameters:
    ///   - flow: scroll direction
    ///   - pagging: pagging
    ///   - images: for content to select
    ///   - selection: type and action for selection of image/images
    
    func addPhotoLibraryPicker(flow: UICollectionViewScrollDirection, paging: Bool, selection: PhotoLibraryPickerViewController.Selection) {
        let selection: PhotoLibraryPickerViewController.Selection = selection
        var asset: PHAsset?
        var assets: [PHAsset] = []
        
        let buttonAdd = UIAlertAction(title: "Add", style: .default) { action in
            switch selection {
                
            case .single(let action):
                action?(asset)
                
            case .multiple(let action):
                action?(assets)
            }
        }
        buttonAdd.isEnabled = false
        
        let vc = PhotoLibraryPickerViewController(flow: flow, paging: paging, selection: {
            switch selection {
            case .single(_):
                return .single(action: { new in
                    buttonAdd.isEnabled = new != nil
                    asset = new
                })
            case .multiple(_):
                return .multiple(action: { new in
                    buttonAdd.isEnabled = new.count > 0
                    assets = new
                })
            }
        }())
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.preferredContentSize.height = vc.preferredSize.height * 0.9
            vc.preferredContentSize.width = vc.preferredSize.width * 0.9
        } else {
            vc.preferredContentSize.height = vc.preferredSize.height
        }
        
        addAction(buttonAdd)
        set(vc: vc)
    }
}

final class PhotoLibraryPickerViewController: UIViewController {
    
    public typealias SingleSelection = (PHAsset?) -> Swift.Void
    public typealias MultipleSelection = ([PHAsset]) -> Swift.Void
    
    public enum Selection {
        case single(action: SingleSelection?)
        case multiple(action: MultipleSelection?)
    }
    
    // MARK: UI Metrics
    
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
        $0.register(ItemWithImage.self, forCellWithReuseIdentifier: String(describing: ItemWithImage.self))
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.decelerationRate = UIScrollViewDecelerationRateFast
        $0.contentInsetAdjustmentBehavior = .always
        $0.bounces = true
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

    fileprivate var selection: Selection?
    fileprivate var assets: [PHAsset] = []
    fileprivate var selectedAssets: [PHAsset] = []
    
    // MARK: Initialize
    
    required public init(flow: UICollectionViewScrollDirection, paging: Bool, selection: Selection) {
        super.init(nibName: nil, bundle: nil)
        
        self.selection = selection
        self.layout.scrollDirection = flow
        
        self.collectionView.isPagingEnabled = paging
        
        switch selection {
            
        case .single(_):
            collectionView.allowsSelection = true
        case .multiple(_):
            collectionView.allowsMultipleSelection = true
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePhotos()
    }
    
    func updatePhotos() {
        checkStatus { [unowned self] assets in
            self.assets.removeAll()
            self.assets.append(contentsOf: assets)
            self.collectionView.reloadData()
        }
    }
    
    func checkStatus(completionHandler: @escaping ([PHAsset]) -> ()) {
        switch PHPhotoLibrary.authorizationStatus() {
            
        case .notDetermined:
            /// This case means the user is prompted for the first time for allowing contacts
            Assets.requestAccess { [unowned self] status in
                self.checkStatus(completionHandler: completionHandler)
            }
            
        case .authorized:
            /// Authorization granted by user for this app.
            DispatchQueue.main.async {
                self.fetchPhotos(completionHandler: completionHandler)
            }
            
        case .denied, .restricted:
            /// User has denied the current app to access the contacts.
            let productName = Bundle.main.infoDictionary!["CFBundleName"]!
            let alert = UIAlertController(style: .alert, title: "Permission denied", message: "\(productName) does not have access to contacts. Please, allow the application to access to your photo library.")
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
    
    func fetchPhotos(completionHandler: @escaping ([PHAsset]) -> ()) {
        Assets.fetch { [unowned self] result in
            switch result {
                
            case .success(let assets):
                completionHandler(assets)
                
            case .error(let error):
                let alert = UIAlertController(style: .alert, title: "Error", message: error.localizedDescription)
                alert.addAction(title: "OK") { [unowned self] action in
                    self.alertController?.dismiss(animated: true)
                }
                alert.show()
            }
        }
    }
}

// MARK: - CollectionViewDelegate

extension PhotoLibraryPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        switch selection {
            
        case .single(let action)?:
            action?(asset)
            
        case .multiple(let action)?:
            selectedAssets.contains(asset)
                ? selectedAssets.remove(asset)
                : selectedAssets.append(asset)
            action?(selectedAssets)
            
        case .none: break }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let asset = assets[indexPath.item]
        switch selection {
        case .multiple(let action)?:
            selectedAssets.contains(asset)
                ? selectedAssets.remove(asset)
                : selectedAssets.append(asset)
            action?(selectedAssets)
        default: break }
    }
}

// MARK: - CollectionViewDataSource

extension PhotoLibraryPickerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ItemWithImage.self), for: indexPath) as? ItemWithImage else { return UICollectionViewCell() }
        let asset = assets[indexPath.item]
        Assets.resolve(asset: asset, size: item.bounds.size) { new in
            item.imageView.image = new
        }
        return item
    }
}

// MARK: - CollectionViewDelegateFlowLayout

extension PhotoLibraryPickerViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
}
