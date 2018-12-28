//
//  PhotoCell.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 07/12/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit

protocol PhotoCellDelegate: class {
    func delete(cell: PhotoCell)
}

class PhotoCell: UICollectionViewCell {
    
    weak var delegate: PhotoCellDelegate?
    
    @IBOutlet weak var imageCell: UIImageView!
    
    @IBOutlet weak var backgroundDeleteView: UIView!
    
    
   
    @IBAction func deleteButtonDidTap(_ sender: Any) {
        delegate?.delete(cell: self)
    }
}
