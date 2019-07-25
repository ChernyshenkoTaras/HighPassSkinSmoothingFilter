import UIKit

protocol NibInstantiatable {}

extension UIView: NibInstantiatable {}

extension NibInstantiatable where Self: UIView {
    static func instantiate() -> Self {
        return self.nib.instantiate(withOwner: nil, options: nil).first as! Self
    }
}
