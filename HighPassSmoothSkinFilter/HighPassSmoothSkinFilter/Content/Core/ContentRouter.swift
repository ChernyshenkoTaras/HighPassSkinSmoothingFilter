import UIKit

protocol ContentRouterInput {
    func showEditing(asset: Asset)
    func dismiss()
}

final class ContentRouter: ContentRouterInput {
    private weak var controller: UIViewController?
    init(controller: UIViewController) {
        self.controller = controller
    }
    func showEditing(asset: Asset) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        controller.asset = asset
        self.controller?.present(controller, animated: true)
    }
    func dismiss() {
        self.controller?.tabBarController?.selectedIndex = 0
        self.controller?.dismiss(animated: true)
    }
}
