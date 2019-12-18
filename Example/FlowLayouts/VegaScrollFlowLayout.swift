//guard let layout = collectionView.collectionViewLayout as? VegaScrollFlowLayout else { return }
//layout.minimumLineSpacing = lineSpacing
//layout.sectionInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
//let itemWidth = UIScreen.main.bounds.width - 2 * xInset
//layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
//collectionView.collectionViewLayout.invalidateLayout()

//https://github.com/ApplikeySolutions/VegaScroll

import UIKit

open class VerticalScrollFlowLayout: UICollectionViewFlowLayout {
    
    open var springHardness: CGFloat = 15
    open var isPagingEnabled: Bool = true
    
    private var dynamicAnimator: UIDynamicAnimator!
    private var visibleIndexPaths = Set<IndexPath>()
    private var latestDelta: CGFloat = 0
    
    private let transformIdentity = CATransform3D(
        m11: 1, m12: 0, m13: 0, m14: 0,
        m21: 0, m22: 1, m23: 0, m24: 0,
        m31: 0, m32: 0, m33: 1, m34: 0,
        m41: 0, m42: 0, m43: 0, m44: 1)
    
    // MARK: - Initialization
    
    override public init() {
        super.init()
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        dynamicAnimator = UIDynamicAnimator(collectionViewLayout: self)
    }
    
    // MARK: - Public
    
    open func resetLayout() {
        dynamicAnimator.removeAllBehaviors()
        prepare()
    }
    
    // MARK: - Overrides
    
    override open func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
		
		// expand the visible rect slightly to avoid flickering when scrolling quickly
		let expandBy: CGFloat = -100
        let visibleRect = CGRect(origin: collectionView.bounds.origin,
                                 size: collectionView.frame.size).insetBy(dx: 0, dy: expandBy)
        
        guard let visibleItems = super.layoutAttributesForElements(in: visibleRect) else { return }
        let indexPathsInVisibleRect = Set(visibleItems.map{ $0.indexPath })
        
        removeNoLongerVisibleBehaviors(indexPathsInVisibleRect: indexPathsInVisibleRect)
        
        let newlyVisibleItems = visibleItems.filter { item in
            return !visibleIndexPaths.contains(item.indexPath)
        }
        
        addBehaviors(for: newlyVisibleItems)
    }
    
    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        guard isPagingEnabled else {
            return latestOffset
        }
		
        let row = ((proposedContentOffset.y) / (itemSize.height + minimumLineSpacing)).rounded()
        
        let calculatedOffset = row * itemSize.height + row * minimumLineSpacing
        let targetOffset = CGPoint(x: latestOffset.x, y: calculatedOffset)
        return targetOffset
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let dynamicItems = dynamicAnimator.items(in: rect) as? [UICollectionViewLayoutAttributes]
        dynamicItems?.forEach { item in
			let convertedY = item.center.y - collectionView.contentOffset.y	- sectionInset.top
			item.zIndex = item.indexPath.row
			transformItemIfNeeded(y: convertedY, item: item)
        }
        return dynamicItems
    }
	
	private func transformItemIfNeeded(y: CGFloat, item: UICollectionViewLayoutAttributes) {
		guard itemSize.height > 0, y < itemSize.height * 0.5 else {
			return
		}
		
		let scaleFactor: CGFloat = scaleDistributor(x: y)
		
		let yDelta = getYDelta(y: y)
		
		item.transform3D = CATransform3DTranslate(transformIdentity, 0, yDelta, 0)
		item.transform3D = CATransform3DScale(item.transform3D, scaleFactor, scaleFactor, scaleFactor)
		item.alpha = alphaDistributor(x: y)
	
	}
	
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return dynamicAnimator.layoutAttributesForCell(at: indexPath)!
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let scrollView = self.collectionView!
        let delta = newBounds.origin.y - scrollView.bounds.origin.y
        latestDelta = delta
        
        let touchLocation = collectionView!.panGestureRecognizer.location(in: collectionView)
        
        dynamicAnimator.behaviors.compactMap { $0 as? UIAttachmentBehavior }.forEach { behavior in
            let attrs = behavior.items.first as! UICollectionViewLayoutAttributes
            attrs.center = getUpdatedBehaviorItemCenter(behavior: behavior, touchLocation: touchLocation)
            self.dynamicAnimator.updateItem(usingCurrentState: attrs)
        }
        return false
    }
    
    // MARK: - Utils
    
    private func removeNoLongerVisibleBehaviors(indexPathsInVisibleRect indexPaths: Set<IndexPath>) {
        //get no longer visible behaviors
        let noLongerVisibleBehaviours = dynamicAnimator.behaviors.filter { behavior in
            guard let behavior = behavior as? UIAttachmentBehavior,
                let item = behavior.items.first as? UICollectionViewLayoutAttributes else { return false }
            return !indexPaths.contains(item.indexPath)
        }
        
        //remove no longer visible behaviors
        noLongerVisibleBehaviours.forEach { behavior in
            guard let behavior = behavior as? UIAttachmentBehavior,
                let item = behavior.items.first as? UICollectionViewLayoutAttributes else { return }
            self.dynamicAnimator.removeBehavior(behavior)
            self.visibleIndexPaths.remove(item.indexPath)
        }
    }
    
    private func addBehaviors(for items: [UICollectionViewLayoutAttributes]) {
        guard let collectionView = collectionView else { return }
        let touchLocation = collectionView.panGestureRecognizer.location(in: collectionView)
        
        items.forEach { item in
            let springBehaviour = UIAttachmentBehavior(item: item, attachedToAnchor: item.center)
            
            springBehaviour.length = 0.0
            //springBehaviour.damping = 0.8
            //springBehaviour.frequency = 1.0
            
            if !CGPoint.zero.equalTo(touchLocation) {
                item.center = getUpdatedBehaviorItemCenter(behavior: springBehaviour, touchLocation: touchLocation)
            }
            
            self.dynamicAnimator.addBehavior(springBehaviour)
            self.visibleIndexPaths.insert(item.indexPath)
        }
    }
    
    private func getUpdatedBehaviorItemCenter(behavior: UIAttachmentBehavior,touchLocation: CGPoint) -> CGPoint {
        let yDistanceFromTouch = abs(touchLocation.y - behavior.anchorPoint.y)
        let xDistanceFromTouch = abs(touchLocation.x - behavior.anchorPoint.x)
        let scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / (springHardness * 100)
        
        let attrs = behavior.items.first as! UICollectionViewLayoutAttributes
        var center = attrs.center
        if latestDelta < 0 {
            center.y += max(latestDelta, latestDelta * scrollResistance)
        } else {
            center.y += min(latestDelta, latestDelta * scrollResistance)
        }
        return center
    }
    
    // MARK: - Distribution functions
    
    /**
     Distribution function that start as a square root function and levels off when reaches y = 1.
     - parameter x: X parameter of the function. Current layout implementation uses center.y coordinate of collectionView cells.
     - parameter threshold: The x coordinate where function gets value 1.
     - parameter xOrigin: x coordinate of the function origin.
     */
    private func distributor(x: CGFloat, threshold: CGFloat, xOrigin: CGFloat) -> CGFloat {
		guard threshold > xOrigin else {
			return 1
		}
        var arg = (x - xOrigin)/(threshold - xOrigin)
        arg = arg <= 0 ? 0 : arg
        let y = sqrt(arg)
        return y > 1 ? 1 : y
    }
	
	private func scaleDistributor(x: CGFloat) -> CGFloat {
		return distributor(x: x, threshold: itemSize.height * 0.5, xOrigin: -itemSize.height * 5)
    }
    
    private func alphaDistributor(x: CGFloat) -> CGFloat {
		return distributor(x: x, threshold: itemSize.height * 0.5, xOrigin: -itemSize.height)
    }
	
	private func getYDelta(y: CGFloat) -> CGFloat {
		return itemSize.height * 0.5 - y
	}
}
