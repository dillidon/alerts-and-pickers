import UIKit

final class SegmentedControl: UISegmentedControl {
    
    public typealias Action = (Int) -> Swift.Void
    
    fileprivate var action: Action?
    
    func action(new: Action?) {
        if action == nil {
            addTarget(self, action: #selector(segmentedControlValueChanged(segment:)), for: .valueChanged)
        }
        action = new
    }
    
    @objc func segmentedControlValueChanged(segment: UISegmentedControl) {
        action?(segment.selectedSegmentIndex)
    }
}
