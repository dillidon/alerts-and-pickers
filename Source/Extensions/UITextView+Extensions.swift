import UIKit

// MARK: - Methods
public extension UITextView {
	
	/// Scroll to the bottom of text view
	public func scrollToBottom() {
		let range = NSMakeRange((text as NSString).length - 1, 1)
		scrollRangeToVisible(range)
	}
	
	/// Scroll to the top of text view
	public func scrollToTop() {
		let range = NSMakeRange(0, 1)
		scrollRangeToVisible(range)
	}
}
