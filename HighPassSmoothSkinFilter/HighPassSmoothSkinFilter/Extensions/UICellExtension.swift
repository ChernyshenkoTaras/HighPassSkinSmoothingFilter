import UIKit

protocol ReusableViewType: class {
    static var reuseIdentifier: String { get }
}

extension ReusableViewType where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewCell: ReusableViewType { }
extension UICollectionViewCell: ReusableViewType { }
extension UITableViewHeaderFooterView: ReusableViewType { }
