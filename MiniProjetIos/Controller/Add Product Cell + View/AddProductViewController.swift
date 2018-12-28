//
//  AddProductViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 30/11/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class AddProductViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
    @IBOutlet weak var validateButton: UIButton!
    
    fileprivate let cellIdentifier = "PhotoCell"
 
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    
    
    
    let imagePicker = UIImagePickerController()
    
    var imageArray : [UIImage] = []
    
    var picker_image : UIImage? {
        didSet {
            guard let image = picker_image else { return }
            self.imageArray.append(image)
            self.collectionView.reloadData()
                                    
        }
    }
                
    
            
    @IBOutlet weak var segmentedControlSellType: UISegmentedControl!
    @IBOutlet weak var imageToAdd: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
             
   
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tapGesture1))
        imageToAdd.addGestureRecognizer(tap1)
        imageToAdd.isUserInteractionEnabled = true
        imagePicker.delegate = self
    }
    @objc func tapGesture1() {
        if(imageArray.count ==  10){
            let alert = UIAlertController(title: "Maximum d'image atteint", message: "Vous atteint le nombre maximum d'images tolérées", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
            alert.addAction(action)
            
            
            self.present(alert , animated: true, completion: nil)
        } else {
        let sheet = UIAlertController(title: "Ajouter une photo", message: "Choisssez votre source", preferredStyle: .actionSheet)
        
        let actionSheetLibrary = UIAlertAction(title: "Photo library", style: .default) { (UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let actionSheetCamera = UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let actionSheetCancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        sheet.addAction(actionSheetLibrary)
        sheet.addAction(actionSheetCamera)
        sheet.addAction(actionSheetCancel)
        self.present(sheet, animated: true, completion: nil)
    }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.picker_image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.picker_image = originalImage
            
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier , for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        
        cell.imageCell.image = imageArray[indexPath.row]
        
        cell.delegate = self as PhotoCellDelegate
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth = UIScreen.main.bounds.width
        let width = (screenWidth - 10)/3
        
        return CGSize.init(width: width, height: width)
        
    }
    
  
    
    
    @IBAction func applyTapped(_ sender: Any) {
        if(imageArray.count == 0){
            let alert = UIAlertController(title: "Aucune image ajoutée", message: "Vous devez ajouter au moins une image", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
            alert.addAction(action)
            
            
            self.present(alert , animated: true, completion: nil)
            
        } else {
        if segmentedControlSellType.selectedSegmentIndex == 0 {
            performSegue(withIdentifier: "toDirectSell", sender: nil)
        } else {
            performSegue(withIdentifier: "toAuctionSell", sender: nil)
        }
    }
    
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDirectSell"{
            
            
            
            let destinationVC = segue.destination as? DirectSellViewController
            
            destinationVC?.Images = imageArray
            
        }
        if segue.identifier == "toAuctionSell"{
            
            
            
            let destinationVC = segue.destination as? AuctionSellViewController
            
            destinationVC?.Images = imageArray
            
        }
    }
}
    

extension AddProductViewController : PhotoCellDelegate {
    
    func delete(cell: PhotoCell) {
        if let indexPath = collectionView?.indexPath(for: cell) {
            
            imageArray.remove(at: indexPath.item)
            collectionView?.deleteItems(at: [indexPath])
            
        }
    }
    
    }
    

