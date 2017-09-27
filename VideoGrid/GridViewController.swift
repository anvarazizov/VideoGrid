//
//  ViewController.swift
//  VideoGrid
//
//  Created by Anvar Azizov on 26.09.17.
//  Copyright © 2017 Anvar Azizov. All rights reserved.
//

import UIKit
import Photos

class GridViewController: UICollectionViewController {

    fileprivate let cellIdentifier = "videoCell"
    fileprivate let detailViewControllerID = "detailVC"
    fileprivate let sectionInsets = UIEdgeInsets(top:2.0, left: 10.0, bottom: 2.0, right: 10.0)
    fileprivate let itemsPerRow = 3
    fileprivate var thumbnailSize: CGSize!
    fileprivate var fetchResult: PHFetchResult<PHAsset>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
        
        PHPhotoLibrary.shared().register(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let scale = UIScreen.main.scale
        let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - UICollectionView Delegate and DataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = fetchResult.object(at: indexPath.item)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! GridCell
        cell.assetID = asset.localIdentifier
        cell.delegate = self
        PHImageManager.default().requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, info) in
            if cell.assetID == asset.localIdentifier {
                if let image = image {
                    DispatchQueue.main.async {
                        cell.thumbnailImage = image
                    }
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: detailViewControllerID) as? DetailViewController {
            detailVC.asset = fetchResult.object(at: indexPath.item)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

extension GridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / CGFloat(itemsPerRow)
        let availaibleHeight = view.frame.height - paddingSpace
        let heightPerItem = availaibleHeight / CGFloat(itemsPerRow)
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}

extension GridViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: fetchResult) {
                fetchResult = changeDetails.fetchResultAfterChanges
                collectionView?.reloadData()
            }
        }
    }
}

extension GridViewController: GridCellDelegate {
    private func deleteAsset(asset: PHAsset) {
        PHPhotoLibrary.shared().performChanges({
            let assetToDelete = PHAsset.fetchAssets(withLocalIdentifiers: [asset.localIdentifier], options: nil)
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
    
    func deleteButtonPressed(cell: GridCell) {
        if let indexPath = collectionView?.indexPathForItem(at: cell.center) {
            deleteAsset(asset: fetchResult[indexPath.item])
        }
    }
    
}

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

