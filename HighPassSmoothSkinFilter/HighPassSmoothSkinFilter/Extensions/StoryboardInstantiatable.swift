import UIKit

extension UIViewController {
    static func className() -> String {
        return String(describing: self)
    }
}

protocol StoryboardInstantiatable {}

extension UIViewController: StoryboardInstantiatable {}

extension StoryboardInstantiatable where Self: UIViewController {
    
    static func instantiateFromStoryboard(_ storyboard: UIStoryboard) -> Self {
        let vcIdentifier = self.className()
        let vc = storyboard.instantiateViewController(withIdentifier: vcIdentifier)
        return vc as! Self
    }
    
    static func instantiateInitial(from storyboard: UIStoryboard) -> Self {
        let vc = storyboard.instantiateInitialViewController()
        return vc as! Self
    }
}
