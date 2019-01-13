//
//  AuctionSellViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 02/12/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FBSDKLoginKit
import PKHUD

class AuctionSellViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    
    
    let categoriesArray = ["Immobilier","Véhicules","Pour la Maison et Jardin","Loisirs et Divertissement","Informatique et Multimédia","Habillement et Bien Etre","Autres"]
    
    var subCategoriesImmoArray = ["Appartements","Maisons et Villas","Location et Vacances","Bureaux","Magasin, Commerces et Locaux industriels","Terrains nus","Fermes","Colocation","Autres"]
    
    var subCategoriesVehiculesArray = ["Voitures","Motos","Pièces et Accessoires","Bateaux","Camions","Engins Agricole","Autres"]
    
    var subCategoriesMaisonJardinArray = ["Electroménager et Vaisselles","Meubles et Décoration","Jardin et Outils de bricolage"]
    
    var subCategoriesLoisirDivertissementArray = ["Vélos","Sports et Loisirs","Animaux","Films, Livres, Magazines","Voyages et Billetteries","Art et Collections","Instrument de Musique","Autres"]
    
    var subCategoriesInfoMultimediaArray = ["Téléphones","Image & Son","Ordinateurs fixes et Portables","Accessoires Informatique et Gadget","Jeux vidéo et Consoles","Appareils Photos et Caméras","Tablettes","Télévision"]
    
    var subCategoriesHabillementBienEtreArray = ["Vêtements","Chaussures","Montres et Bijoux","Sac et Accessoires","Vêtements pour enfant et bébé","Equipement pour enfant et bébé","Produits de beauté"]
    
    var subCategoriesAutresArray = ["Autres"]
    
    var dureeEncherePicker = ["3 jours","5 jours","7 jours","10 jours"]
    
    var Images : [UIImage]?
    
    let baseUrl = Common.Global.LOCAL + "/"
    var picker : UIPickerView!
    var activeTextField = 0
    var activeTF : UITextField!
    var activeValue = ""
    var Duration : String = ""
    let currentDate = Date()
    var auctionSeconds : Int?
 
    @IBOutlet weak var warnLabelName: UILabel!
    @IBOutlet weak var warnLabelCategory: UILabel!
    @IBOutlet weak var warnLabelSubCategory: UILabel!
    @IBOutlet weak var warnDurationLabel: UILabel!
    @IBOutlet weak var warnPriceLabel: UILabel!
    
    
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productCategoryTextField: UITextField!
    @IBOutlet weak var productSubCategoryTextField: UITextField!
    @IBOutlet weak var productDescriptionTextView: UITextView!
    @IBOutlet weak var productPriceTextField: UITextField!
    @IBOutlet weak var productAuctionDurationTextField: UITextField!
    @IBOutlet weak var productMinimumPriceTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Enchères"
        self.hideKeyboardWhenTappedAround()
        productCategoryTextField.delegate = self
        productSubCategoryTextField.delegate = self
        productAuctionDurationTextField.delegate = self
        warnLabelName.isHidden = true
        warnPriceLabel.isHidden = true
        warnLabelCategory.isHidden = true
        warnLabelSubCategory.isHidden = true
        warnDurationLabel.isHidden = true
        productDescriptionTextView.layer.borderWidth = 1.0
        self.productPriceTextField.keyboardType = UIKeyboardType.decimalPad
        self.productMinimumPriceTextField.keyboardType = UIKeyboardType.decimalPad

        

    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch activeTextField {
        case 1:
            return categoriesArray.count
        case 2:
            if(productCategoryTextField.text == "Immobilier"){
                return subCategoriesImmoArray.count
            }
            if(productCategoryTextField.text == "Véhicules"){
                return subCategoriesVehiculesArray.count
            }
            if(productCategoryTextField.text == "Pour la Maison et Jardin"){
                return subCategoriesMaisonJardinArray.count
            }
            if(productCategoryTextField.text == "Loisirs et Divertissement"){
                return subCategoriesLoisirDivertissementArray.count
            }
            if(productCategoryTextField.text == "Informatique et Multimédia"){
                return subCategoriesInfoMultimediaArray.count
            }
            if(productCategoryTextField.text == "Habillement et Bien Etre"){
                return subCategoriesHabillementBienEtreArray.count
            }
            if(productCategoryTextField.text == "Autres"){
                return subCategoriesAutresArray.count
            }
            return 0
        case 3:
            return dureeEncherePicker.count
            
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        // return correct content for picekr view
        switch activeTextField {
        case 1:
            return categoriesArray[row]
        case 2:
            if(productCategoryTextField.text == "Immobilier"){
                return subCategoriesImmoArray[row]
            }
            if(productCategoryTextField.text == "Véhicules"){
                return subCategoriesVehiculesArray[row]
            }
            if(productCategoryTextField.text == "Pour la Maison et Jardin"){
                return subCategoriesMaisonJardinArray[row]
            }
            if(productCategoryTextField.text == "Loisirs et Divertissement"){
                return subCategoriesLoisirDivertissementArray[row]
            }
            if(productCategoryTextField.text == "Informatique et Multimédia"){
                return subCategoriesInfoMultimediaArray[row]
            }
            if(productCategoryTextField.text == "Habillement et Bien Etre"){
                return subCategoriesHabillementBienEtreArray[row]
            }
            if(productCategoryTextField.text == "Autres"){
                return subCategoriesAutresArray[row]
            }
            return ""
        case 3:
            return dureeEncherePicker[row]
        default:
            return ""
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // set currect active value based on picker view
        switch activeTextField {
        case 1:
            activeValue = categoriesArray[row]
        case 2:
            if(productCategoryTextField.text == "Immobilier"){
                activeValue = subCategoriesImmoArray[row]
            }
            if(productCategoryTextField.text == "Véhicules"){
                activeValue = subCategoriesVehiculesArray[row]
            }
            if(productCategoryTextField.text == "Pour la Maison et Jardin"){
                activeValue = subCategoriesMaisonJardinArray[row]
            }
            if(productCategoryTextField.text == "Loisirs et Divertissement"){
                activeValue = subCategoriesLoisirDivertissementArray[row]
            }
            if(productCategoryTextField.text == "Informatique et Multimédia"){
                activeValue = subCategoriesInfoMultimediaArray[row]
            }
            if(productCategoryTextField.text == "Habillement et Bien Etre"){
                activeValue = subCategoriesHabillementBienEtreArray[row]
            }
            if(productCategoryTextField.text == "Autres"){
                activeValue = subCategoriesAutresArray[row]
            }
        case 3:
            activeValue = dureeEncherePicker[row]
            
        default:
            activeValue = ""
        }
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // set up correct active textField (no)
        switch textField {
        case productCategoryTextField:
            activeTextField = 1
            productSubCategoryTextField.text = ""
        case productSubCategoryTextField:
            activeTextField = 2
        case productAuctionDurationTextField:
            activeTextField = 3
        default:
            activeTextField = 0
        }
        
        // set active Text Field
        activeTF = textField
        
        self.pickUpValue(textField: textField)
        
    }
    
    func pickUpValue(textField: UITextField) {
        
        // create frame and size of picker view
        picker = UIPickerView(frame:CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.frame.size.width, height: 216)))
        
        // deletates
        picker.delegate = self
        picker.dataSource = self
        
        // if there is a value in current text field, try to find it existing list
        if let currentValue = textField.text {
            
            var row : Int?
            
            // look in correct array
            switch activeTextField {
            case 1:
                row = categoriesArray.index(of: currentValue)
            case 2:
                if(productCategoryTextField.text == "Immobilier"){
                    row = subCategoriesImmoArray.index(of: currentValue)
                }
                if(productCategoryTextField.text == "Véhicules"){
                    row = subCategoriesVehiculesArray.index(of: currentValue)
                }
                if(productCategoryTextField.text == "Pour la Maison et Jardin"){
                    row = subCategoriesMaisonJardinArray.index(of: currentValue)
                }
                if(productCategoryTextField.text == "Loisirs et Divertissement"){
                    row = subCategoriesLoisirDivertissementArray.index(of: currentValue)
                }
                if(productCategoryTextField.text == "Informatique et Multimédia"){
                    row = subCategoriesInfoMultimediaArray.index(of: currentValue)
                }
                if(productCategoryTextField.text == "Habillement et Bien Etre"){
                    row = subCategoriesHabillementBienEtreArray.index(of: currentValue)
                }
                if(productCategoryTextField.text == "Autres"){
                    row = subCategoriesAutresArray.index(of: currentValue)
                }
            case 3:
                row = dureeEncherePicker.index(of: currentValue)
                
            default:
                row = nil
            }
            
            // we got it, let's set select it
            if row != nil {
                picker.selectRow(row!, inComponent: 0, animated: true)
            }
        }
        
        picker.backgroundColor = UIColor.white
        textField.inputView = self.picker
        
        // toolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        //        toolBar.barTintColor = UIColor.darkGray
        toolBar.sizeToFit()
        
        // buttons for toolBar
        let doneButton = UIBarButtonItem(title: "Choisir", style: .plain, target: self, action: #selector(doneClick))
        doneButton.tintColor = UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Annuler", style: .plain, target: self, action: #selector(cancelClick))
        cancelButton.tintColor = UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        switch activeTextField {
        case 1:
            let titleData = categoriesArray[row]
            let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)])
            
            return myTitle
        case 2:
            if(productCategoryTextField.text == "Immobilier"){
                let titleData = subCategoriesImmoArray[row]
                let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)])
                
                return myTitle
            }
            if(productCategoryTextField.text == "Véhicules"){
                let titleData = subCategoriesVehiculesArray[row]
                let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)])
                
                return myTitle
            }
            if(productCategoryTextField.text == "Pour la Maison et Jardin"){
                let titleData = subCategoriesMaisonJardinArray[row]
                let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)])
                
                return myTitle
            }
            if(productCategoryTextField.text == "Loisirs et Divertissement"){
                let titleData = subCategoriesLoisirDivertissementArray[row]
                let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)])
                
                return myTitle
            }
            if(productCategoryTextField.text == "Informatique et Multimédia"){
                let titleData = subCategoriesInfoMultimediaArray[row]
                let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)])
                
                return myTitle
            }
            if(productCategoryTextField.text == "Habillement et Bien Etre"){
                let titleData = subCategoriesHabillementBienEtreArray[row]
                let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)])
                
                return myTitle
            }
            if(productCategoryTextField.text == "Autres"){
                let titleData = subCategoriesAutresArray[row]
                let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)])
                
                return myTitle
            }
        case 3:
            let titleData = dureeEncherePicker[row]
            let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)])
            return myTitle
            
        default:
            let titleData = ""
            let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)])
            
            return myTitle
        }
        let titleData = ""
        let myTitle = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.13, green: 0.33, blue: 0.56, alpha: 1.0)])
        
        return myTitle
    }
    
   
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == productCategoryTextField){
            return false
        }
        if(textField == productSubCategoryTextField){
            return false
        }
        if(textField == productAuctionDurationTextField){
            return false
        }
        
        return true
    }
    
    // done
    @objc func doneClick() {
        activeTF.text = activeValue
        activeTF.resignFirstResponder()
        
    }
    
    // cancel
    @objc func cancelClick() {
        activeTF.resignFirstResponder()
    }
    
    
    @IBAction func validateTapped(_ sender: Any) {
        
        Duration = productAuctionDurationTextField.text!
        
        if(Duration == "10 jours"){
            auctionSeconds = 864000
        }
        if(Duration == "7 jours"){
            auctionSeconds = 604800
                  }
        if(Duration == "5 jours"){
            auctionSeconds = 432000
                    }
        if(Duration == "3 jours"){
          
            auctionSeconds =  259200
                   }
        
        let textPrice = productPriceTextField.text
        let letterCharacters = NSCharacterSet.letters
        
        
        
        if(textPrice?.rangeOfCharacter(from: letterCharacters) != nil) || (productNameTextField.text == "") || (productCategoryTextField.text == "") || (productSubCategoryTextField.text == "") || (productPriceTextField.text == "") || (productAuctionDurationTextField.text == ""){
            
            let alert = UIAlertController(title: "Champ incorrect", message: "Vérifier les champs saisis", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
            alert.addAction(action)
            
            
            self.present(alert , animated: true, completion: nil)
            
            if(textPrice?.rangeOfCharacter(from: letterCharacters) != nil || productPriceTextField.text == ""){
                
                warnPriceLabel.isHidden = false
                
            } else {
                
                warnPriceLabel.isHidden = true
                
            }
            
            if(productNameTextField.text == ""){
                
                warnLabelName.isHidden = false
                
            } else {
                
                warnLabelName.isHidden = true
                
            }
            
            if(productCategoryTextField.text == ""){
                
                warnLabelCategory.isHidden = false
                
            } else {
                
                warnLabelCategory.isHidden = true
                
            }
            
            if(productSubCategoryTextField.text == ""){
                
                warnLabelSubCategory.isHidden = false
                
            } else {
                
                warnLabelSubCategory.isHidden = true
                
            }
            if(productAuctionDurationTextField.text == ""){
                
                warnDurationLabel.isHidden = false
        
            } else {
                
                warnDurationLabel.isHidden = true
                
            }
            
            if(self.productDescriptionTextView.text == ""){
                
                self.productDescriptionTextView.text = "champ vide"
            }
            if(self.productMinimumPriceTextField.text == ""){
                self.productMinimumPriceTextField.text = "-1"
            }
            
        }
        else {
            
            warnLabelName.isHidden = true
            warnLabelCategory.isHidden = true
            warnLabelSubCategory.isHidden = true
            warnPriceLabel.isHidden = true
            
                let idValue = UserDefaults.standard.string(forKey: "idUser")
            
                let nameProduct = self.productNameTextField.text
                
                let category = self.productCategoryTextField.text
                
                let subCategory = self.productSubCategoryTextField.text
                
                let productPrice = self.productPriceTextField.text
                
                
            var description = self.productDescriptionTextView.text
                
            var minEnchere = self.productMinimumPriceTextField.text
            
            if((minEnchere?.isEmpty)!){
                minEnchere = "0"
            }
            if((description?.isEmpty)!){
                description = "Champs vide"
            }
        
                
                let requestFinal = self.baseUrl + "addproductauction/" + idValue! + "/" + nameProduct! + "/" + category! + "/" + subCategory! + "/" + productPrice! + "/" + minEnchere! + "/" + String(self.auctionSeconds!) + "/2/" + description!
                
                
                let urlString = requestFinal.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                print(urlString!)
            
            print("l url auction add product = " + urlString!)
                
                Alamofire.request(urlString!)
                
                
                
                let j = (self.Images?.count)!
                for index in 0...j - 1 {
                    print("premiere image : ",index)
                    let imageData = self.Images![index].jpegData(compressionQuality: 0.5)
                    Alamofire.upload(multipartFormData: { (MultipartFormData) in
                        MultipartFormData.append(imageData!, withName: "myImage", fileName: "image.jpeg", mimeType: "image/jpeg")
                    }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to:self.baseUrl + "upload", method: .post, headers: nil) { (result: SessionManager.MultipartFormDataEncodingResult) in
                        switch result {
                        case .failure(let error):
                            print(error)
                        case . success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                            upload.uploadProgress(closure: { (progress) in
                                print(progress)
                            }
                                
                            )}
                    }
                
     
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                self.present(vc, animated: true, completion: nil)
        }
            HUD.show(.progress)
        
        }

    }
    
    
    
}


