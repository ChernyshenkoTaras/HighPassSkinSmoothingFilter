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
    private var movieFile: MovieInput!
    
    @IBAction func didchange(_ sender: UISlider) {
        self.skinSmoothFilter.amount = sender.value
        self.skinSmoothFilter.radius = HighPassSkinSmoothingRadius(pixels: sender.value * 20)
    }
    var asset: PHAsset?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.insertSubviewWithConstraints(view: self.renderView)
        self.view.bringSubviewToFront(self.slider)
        guard let asset = self.asset else {
            return
        }
        self.requestVideo(with: asset) { (asset, _) in
            let urlAsset = asset as! AVURLAsset
            self.movieFile = try! MovieInput(url: urlAsset.url, playAtActualSpeed: true, loop: true)
            
            self.movieFile --> self.lookup --> self.skinSmoothFilter --> self.renderView
            
            self.skinSmoothFilter.amount = 0.7
            self.renderView.fillMode = .preserveAspectRatio
            self.renderView.orientation = .landscapeLeft
            self.movieFile?.start()
        }
        
        
        
    }
    
    func requestVideo(with asset: PHAsset, completion: @escaping (AVAsset, UIImage) -> ()) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.version = .original
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (video, audioMix, info) in
            if let video = video {
                let imageGenerator = AVAssetImageGenerator(asset: video)
                imageGenerator.maximumSize = CGSize(width: 80, height: 80)
                imageGenerator.appliesPreferredTrackTransform = true
                let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 1)
                var actualTime : CMTime = CMTimeMake(value: 0, timescale: 0)
                let image = try? imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
                if let image = image {
                    DispatchQueue.main.async {
                        completion(video, UIImage(cgImage: image))
                    }
                }
            }
        }
    }
}
