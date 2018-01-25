import UIKit.UITableViewCell

public typealias CellConfig = (UITableViewCell?) -> Swift.Void

public struct CellData {
    public var config: CellConfig?
    public var action: CellConfig?
}
