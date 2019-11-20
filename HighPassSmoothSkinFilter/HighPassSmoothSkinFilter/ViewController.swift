//
//  ViewController.swift
//  HighPassSmoothSkinFilter
//
//  Created by Taras Chernyshenko on 7/25/19.
//  Copyright © 2019 Taras Chernyshenko. All rights reserved.
//

import UIKit
import GPUImage
import Photos

final class ImageLUTFilter: LookupFilter {
    init(named: String) {
        super.init()
        self.lookupImage = PictureInput(imageName: named)
    }
}


class ViewController: UIViewController {
    @IBOutlet private weak var slider: UISlider!
    private var renderView: RenderView = RenderView(frame: .zero)
    private let skinSmoothFilter = HighPassSkinSmoothingFilter()
    private let lookup = ImageLUTFilter(named: "lookup")
    private var pictureInput: PictureInput!
   
    @IBAction func didchange(_ sender: UISlider) {
        self.skinSmoothFilter.amount = sender.value
        self.skinSmoothFilter.radius = HighPassSkinSmoothingRadius(pixels: sender.value * 16)
        self.pictureInput.processImage()
    }
    
    var asset: PHAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.insertSubviewWithConstraints(view: self.renderView)
        self.view.bringSubviewToFront(self.slider)
        guard let asset = self.asset else {
            return
        }
        self.requestImage(with: asset, size: PHImageManagerMaximumSize) { (image) in
            self.pictureInput = PictureInput(image: image!)
            self.pictureInput.processImage()
            
            self.pictureInput --> self.lookup --> self.skinSmoothFilter --> self.renderView
        }
    }
    
    func requestImage(with asset: PHAsset, size: CGSize,
        completion: @escaping (UIImage?) -> ()) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .default, options: options) { (image, _) in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
