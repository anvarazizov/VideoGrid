//
//  GridCell.swift
//  VideoGrid
//
//  Created by Anvar Azizov on 27.09.17.
//  Copyright © 2017 Anvar Azizov. All rights reserved.
//

import UIKit

protocol GridCellDelegate: class {
    func deleteButtonPressed(cell: GridCell)
}

class GridCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    weak var delegate: GridCellDelegate?
    
    var assetID: String!
    
    var thumbnailImage: UIImage! {
        didSet {
            thumbnailImageView.image = thumbnailImage
        }
    }
    
    @IBAction func deleteAction(_ sender: GridCell) {
        if let d = delegate {
            d.deleteButtonPressed(cell: self)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }
}
