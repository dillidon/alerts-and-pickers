import UIKit

protocol PhotoLayoutDelegate: class {
    
    func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize
}


class PhotoLayout: UICollectionViewLayout {
    
    weak var delegate: PhotoLayoutDelegate!
    
    public var lineSpacing: CGFloat = 6
    
    fileprivate var previousAttributes = [UICollectionViewLayoutAttributes]()
    fileprivate var currentAttributes = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentSize: CGSize = .zero
    public var selectedCellIndexPath: IndexPath?
    
    override var collectionViewContentSize: CGSize {
        return contentSize
    }
    
    override public var collectionView: UICollectionView {
        return super.collectionView!
    }
    
    private var inset: UIEdgeInsets {
        return collectionView.contentInset
    }
    
    private var numberOfSections: Int {
        return collectionView.numberOfSections
    }
    
    private func numberOfItems(inSection section: Int) -> Int {
        return collectionView.numberOfItems(inSection: section)
    }
    
    override public func invalidateLayout() {
        super.invalidateLayout()
    }
    
    override func prepare() {
        super.prepare()
        previousAttributes = currentAttributes
        
        contentSize = .zero
        currentAttributes = []
        
        var xOffset: CGFloat = 0
        let yOffset: CGFloat = 0
        
        let height: CGFloat = collectionView.bounds.height - (inset.top + inset.bottom)
        
        for item in 0 ..< numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let photoWidth: CGFloat = delegate.collectionView(collectionView, sizeForPhotoAtIndexPath: indexPath).width
            
            let width: CGFloat = photoWidth
            
            let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            currentAttributes.append(attributes)
            
            contentSize.width = max(contentSize.width, frame.maxX)
            xOffset += width + lineSpacing
        }
        
        contentSize.height = height
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return previousAttributes[itemIndexPath.item]
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return currentAttributes[indexPath.item]
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return currentAttributes.filter { rect.intersects($0.frame) }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView.bounds
        if !oldBounds.size.equalTo(newBounds.size) {
            return true
        }
        return false
    }
    
    
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        Log(selectedCellIndexPath)
        guard let selectedCellIndexPath = selectedCellIndexPath else { return proposedContentOffset }
        Log(selectedCellIndexPath)
        var finalContentOffset = proposedContentOffset
        
        if let itemFrame = layoutAttributesForItem(at: selectedCellIndexPath)?.frame {
            let width = collectionView.bounds.size.width
            
            let contentLeft = proposedContentOffset.x
            let contentRight = contentLeft + width
            
            let itemLeft = itemFrame.origin.x
            let itemRight = itemLeft + itemFrame.size.width
            
            if itemRight > contentRight {
                finalContentOffset = CGPoint(x: contentLeft + (itemRight - contentRight) + lineSpacing, y: -inset.top)
            } else if itemLeft < contentLeft {
                finalContentOffset = CGPoint(x: contentLeft - (contentLeft - itemLeft) - lineSpacing, y: -inset.top)
            }
            Log(finalContentOffset)
        }
        return finalContentOffset
    }
}

