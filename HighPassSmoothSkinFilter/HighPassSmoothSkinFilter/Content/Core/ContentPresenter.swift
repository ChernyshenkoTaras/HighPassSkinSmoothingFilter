import Foundation

final class ContentPresenter {
    enum Mode {
        case preview, standard
    }
    private weak var controller: ContentViewControllerInput?
    private let router: ContentRouterInput
    var mode: Mode = .standard
    init(controller: ContentViewControllerInput, router: ContentRouterInput) {
        self.controller = controller
        self.router = router
    }
}

extension ContentPresenter: ContentViewControllerOutput {
    func handleDismiss() {
        
    }
    
    func handleViewDidLoad() {
        if self.mode == .preview {
            self.controller?.setCancelButtonHidden(false)
        }
    }
    func handleViewWillAppear() {}
    func handleAssetSelect(_ asset: Asset) {
        self.router.showEditing(asset: asset)
    }
}
