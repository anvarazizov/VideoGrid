//
//  DetailViewController.swift
//  VideoGrid
//
//  Created by Anvar Azizov on 26.09.17.
//  Copyright © 2017 Anvar Azizov. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class DetailViewController: UIViewController {

    var asset: PHAsset!
    fileprivate var playerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let deleteBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(DetailViewController.deleteAsset))
        navigationItem.rightBarButtonItem = deleteBarButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        
        // This thumbnail will be used only for the deletion dialog
        let targetSize = CGSize(width: view.bounds.width / 2, height: view.bounds.height / 2)
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { image, _ in
            if image != nil {
                self.play()
            }
        })
    }
    
    func play() {
        if playerLayer != nil {
            playerLayer.player!.play()
        } else {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            options.deliveryMode = .automatic
            
            PHImageManager.default().requestPlayerItem(forVideo: asset, options: options, resultHandler: { playerItem, info in
                DispatchQueue.main.sync {
                    guard self.playerLayer == nil else { return }
                
                    let player = AVPlayer(playerItem: playerItem)
                    let playerLayer = AVPlayerLayer(player: player)
                    
                    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
                    playerLayer.frame = self.view.layer.bounds
                    self.view.layer.addSublayer(playerLayer)
                    
                    player.play()
                    
                    self.playerLayer = playerLayer
                }
            })
        }
    }
    
    @objc private func deleteAsset() {
        PHPhotoLibrary.shared().performChanges({
            let assetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: [self.asset.localIdentifier], options: nil)
            PHAssetChangeRequest.deleteAssets(assetToDelete)
        }) { (success, error) in
            if error != nil {
                print(error?.localizedDescription ?? "undefined error")
            } else {
                if success {
                    print("video succesfully deleted")
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    print("video not deleted")
                }
            }
        }
    }
}
