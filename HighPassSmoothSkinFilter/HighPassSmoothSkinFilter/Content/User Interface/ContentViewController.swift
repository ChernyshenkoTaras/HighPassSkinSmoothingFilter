import UIKit
import Photos

typealias Asset = PHAsset

final class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .lightGray
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.timeLabel.text = nil
    }
}

protocol ContentViewControllerInput: class {
    func setCancelButtonHidden(_ isHidden: Bool)
}

protocol ContentViewControllerOutput: class {
    func handleViewDidLoad()
    func handleViewWillAppear()
    func handleDismiss()
    func handleAssetSelect(_ asset: Asset)
}

class ContentViewController: UIViewController, ContentViewControllerInput {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBAction private func selectButtonPressed(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    
    private var imagesCount: Int = 0
    private var result: PHFetchResult<PHAsset>!
    private var cachingImageManager = PHCachingImageManager()
    private var imageManager = PHImageManager.default()
    private var requestsIDs: [IndexPath : PHImageRequestID] = [:]
    private let targetSize = CGSize(width: 150, height: 150)
    private var refreshControl = UIRefreshControl()
    var output: ContentViewControllerOutput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.refreshControl = self.refreshControl
        self.refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.output?.handleViewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 44))
        let stackView = UIStackView(frame: containerView.frame)
        containerView.addSubview(stackView)
        let label = UILabel()
        label.text = "Select"
        let imageView = UIImageView(image: UIImage(named: "icon_show_more"))
        imageView.contentMode = .scaleAspectFit
        stackView.insertArrangedSubview(label, at: 0)
        stackView.insertArrangedSubview(imageView, at: 1)
        let button = UIButton(frame: containerView.frame)
        button.addTarget(self, action: #selector(selectButtonPressed(_:)), for: .touchUpInside)
        containerView.addSubview(button)
        self.navigationItem.titleView = containerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.refresh()
        self.output?.handleViewWillAppear()
    }
    
    @objc private func cancel() {
        self.output?.handleDismiss()
    }
    
    @objc private func refresh() {
        let fetchResult = PHAssetCollection.fetchAssetCollections(with:.smartAlbum, subtype:.smartAlbumUserLibrary, options: nil)
        self.imagesCount = 0
        if let assetCollection = fetchResult.firstObject {
            let allPhotos = PHAsset.fetchAssets(in: assetCollection, options: nil)
            allPhotos.enumerateObjects { (asset, index, pointer) in
                self.imagesCount += 1
            }
            self.result = allPhotos
            self.refreshControl.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    func setCancelButtonHidden(_ isHidden: Bool) {
        if isHidden {
            self.navigationItem.leftBarButtonItem = nil
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        }
    }
    
    func assetAtIndex(index: Int) -> PHAsset {
        // Return results in reverse order
        return self.result[self.result.count - index - 1]
    }
    
    private func request(asset: PHAsset, at indexPath: IndexPath, completion: @escaping (UIImage?) -> ()) {
        let options = PHImageRequestOptions()
        options.deliveryMode = .fastFormat
        options.isSynchronous = false
        options.isNetworkAccessAllowed = true
        let imageRequestID = self.imageManager.requestImage(for: asset, targetSize: self.targetSize, contentMode: .aspectFill, options: options, resultHandler: {(result, info) -> Void in
            completion(result)
        })
        self.requestsIDs[indexPath] = imageRequestID
    }
    
    private func requestVideoThumbnail(asset: PHAsset, at indexPath: IndexPath, completion: @escaping (AVAsset, UIImage?) -> ()) {
        let options = PHVideoRequestOptions()
        options.deliveryMode = .mediumQualityFormat
        options.version = .original
        options.isNetworkAccessAllowed = true
        let imageRequestID = self.imageManager.requestAVAsset(forVideo: asset, options: options) { (video, audioMix, info) in
            if let video = video {
                let imageGenerator = AVAssetImageGenerator(asset: video)
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
        self.requestsIDs[indexPath] = imageRequestID
    }
}

extension ContentViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as? ImageCollectionViewCell else {
            assertionFailure("cell can't be nil")
            return UICollectionViewCell()
        }
        let asset = self.assetAtIndex(index: indexPath.row)
        switch asset.mediaType {
        case .image:
            self.request(asset: asset, at: indexPath) { image in
                if let _ = self.requestsIDs[indexPath] {
                    cell.imageView.image = image
                    cell.timeLabel.text = ""
                }
            }
        case .video:
            self.requestVideoThumbnail(asset: asset, at: indexPath) { (video, image) in
                if let _ = self.requestsIDs[indexPath] {
                    cell.imageView.image = image
                    cell.timeLabel.text = video.duration.durationText
                }
            }
        default: break
        }
        
        cell.imageView.contentMode = .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let requestID = self.requestsIDs[indexPath] {
            self.imageManager.cancelImageRequest(requestID)
            self.requestsIDs[indexPath] = nil
        }
    }
}

extension ContentViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 4 - 1
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = self.assetAtIndex(index: indexPath.row)
        self.output?.handleAssetSelect(asset)
    }
}

extension ContentViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            let option = PHImageRequestOptions()
            option.deliveryMode = .highQualityFormat
            self.cachingImageManager.startCachingImages(for: indexPaths.map{ self.result.object(at: $0.item) }, targetSize: self.targetSize, contentMode: .aspectFill, options: option)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            let option = PHImageRequestOptions()
            option.deliveryMode = .highQualityFormat
            self.cachingImageManager.stopCachingImages(for: indexPaths.map{ self.result.object(at: $0.item) }, targetSize: self.targetSize, contentMode: .aspectFill, options: option)
        }
    }
}

extension ContentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            picker.dismiss(animated: false) {
                self.output?.handleAssetSelect(asset)
            }
        }
    }
}
