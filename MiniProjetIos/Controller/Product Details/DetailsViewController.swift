//
//  DetailsViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 09/12/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import CoreData
import Cosmos

class DetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    var images : [UIImage] = []
    var id : Int?
    var product : NSArray = []
    var dateFinAuction : String?
    var boucle : Bool = true
    let BaseUrl = Common.Global.LOCAL + "/"
    var AuctionTimer: Timer!
    var similarArray : NSArray = []

    @IBOutlet weak var rateCosmos: CosmosView!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var sellerImageView: UIImageView!
    
    @IBOutlet weak var similarCollectionView: UICollectionView!
    @IBOutlet weak var typeSellLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var subCategoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productDescriptionTextView: UITextView!
    @IBOutlet weak var timeLeftForAuction: UILabel!
    @IBOutlet weak var newAcutionTextField: UITextField!
    @IBOutlet weak var echerieLabel: UILabel!
    
    

   
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        rateCosmos.settings.updateOnTouch = false
        sellerImageView.layer.cornerRadius = 22.5
        sellerImageView.clipsToBounds = true

        getImages()
        getData()
        buttonOutlet.layer.cornerRadius = 5
        echerieLabel.isHidden = true
        newAcutionTextField.isHidden = true
        timeLeftForAuction.isHidden = true
        self.newAcutionTextField.keyboardType = UIKeyboardType.decimalPad
        AuctionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getDate), userInfo: nil, repeats: true)
      
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.similarCollectionView){
            return similarArray.count
        }
        pageControl.numberOfPages = images.count
        pageControl.isHidden = !(images.count > 1)
        return images.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.similarCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "similarProductCell", for: indexPath)
            let similarProduct  = similarArray[indexPath.item] as! Dictionary<String,Any>
            let imageUrl = similarProduct["first_image_path"] as! String
            
            let image = cell.viewWithTag(2) as! UIImageView
            
            image.af_setImage(withURL: URL(string: imageUrl)!)
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        
        let image = cell.viewWithTag(1) as! UIImageView

        
        image.image = images[indexPath.item]
        
        return cell
    
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == self.similarCollectionView){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
            let similarProduct  = similarArray[indexPath.item] as! Dictionary<String,Any>
            vc.id = similarProduct["Id"] as? Int
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
   
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int ,Int, Int, Int) {
        return (seconds / 86400,(seconds % 86400) / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    
    @objc func getDate(){
        Alamofire.request(BaseUrl + "getproduct/" + String(id!)).responseJSON{
            response in
            self.product = response.result.value as! NSArray
            let singleProduct = self.product[0] as! Dictionary<String,Any>
                self.dateFinAuction = singleProduct["DateFin"] as? String
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let yourDate = formatter.date(from: self.dateFinAuction!)
                let currentDateTime = Date()
                let diffInSeconds = Calendar.current.dateComponents([.second], from:currentDateTime , to: yourDate!).second
                let (j,h,m,s) = self.secondsToHoursMinutesSeconds(seconds: diffInSeconds!)
                self.timeLeftForAuction.text = "\(j) Jour(s):\(h) H:\(m) M:\(s) S"
                self.timeLeftForAuction.isHidden = false
                self.priceLabel.text = String(singleProduct["PrixEnchere"] as! Double) + " DT"
                if(diffInSeconds! <= 0){
                    self.buttonOutlet.setTitle("Enchère terminé", for: .normal)
                    self.buttonOutlet.isEnabled = false
                    self.timeLeftForAuction.isHidden = true
                    self.newAcutionTextField.isEnabled = false
            }
        }
    }
   
    

     func getData(){
        
        Alamofire.request(BaseUrl + "getproduct/" + String(id!)).responseJSON{
            response in
            self.product = response.result.value as! NSArray
            let singleProduct = self.product[0] as! Dictionary<String,Any>
            self.nameLabel.text = singleProduct["Name"] as? String
            self.title = singleProduct["Name"] as? String
            let id_Seller = singleProduct["Id_user"] as! String
            Alamofire.request(Common.Global.LOCAL  + "/getuser/" + id_Seller).responseJSON(completionHandler: { response in
                let responseJson = JSON(response.result.value)
                let pathPicture = responseJson[0]["profile_image_path"].stringValue
                let nameSeller = responseJson[0]["FirstName"].stringValue + " " + responseJson[0]["LastName"].stringValue
                self.sellerImageView.af_setImage(withURL: URL(string: pathPicture)!)
                self.sellerNameLabel.text = nameSeller
            })
            if((id_Seller) == UserDefaults.standard.string(forKey: "idUser")){
                self.buttonOutlet.isHidden = true
                
            }
            self.subCategoryLabel.text = (singleProduct["Sub_category"] as! String)
            let url = Common.Global.LOCAL + "/getsimilarproduct/" + self.subCategoryLabel.text! + "/" + String(self.id!)
            let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            print(urlString!)
            Alamofire.request(urlString!, method: .get).responseJSON{ response in
                self.similarArray = response.result.value as! NSArray
                print("le contenu du tableau est :",self.similarArray)
                self.similarCollectionView.reloadData()
            }
            self.productDescriptionTextView.text = singleProduct["Description"] as? String
            if(singleProduct["Type_vente"] as! Int == 1){
                self.buttonOutlet.setTitle("Contacter Vendeur", for: .normal)
                self.priceLabel.text = String(singleProduct["PrixFixe"] as! Double) + " DT"
                self.typeSellLabel.text = "Prix de vente:"
            } else {
                self.echerieLabel.isHidden = false
                self.newAcutionTextField.isHidden = false
                self.buttonOutlet.setTitle("Enchérir", for: .normal)
                self.dateFinAuction = singleProduct["DateFin"] as? String
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                let yourDate = formatter.date(from: self.dateFinAuction!)
                print(self.dateFinAuction!)
                print("DateFin: ",yourDate!)
                let currentDateTime = Date()
                print("currentDate:",currentDateTime)
                
                    let diffInSeconds = Calendar.current.dateComponents([.second], from:currentDateTime , to: yourDate!).second
                let (j,h,m,s) = self.secondsToHoursMinutesSeconds(seconds: diffInSeconds!)
                self.timeLeftForAuction.text = "\(j) Jour(s):\(h) H:\(m) M:\(s) S"
                self.timeLeftForAuction.isHidden = false
                
                self.priceLabel.text = String(singleProduct["PrixEnchere"] as! Double) + " DT"
            }
        }
    }
    
    @IBAction func validateTapped(_ sender: Any) {
        
        
        
        Alamofire.request(BaseUrl + "getproduct/" + String(id!)).responseJSON{
            response in
            self.product = response.result.value as! NSArray
            let singleProduct = self.product[0] as! Dictionary<String,Any>
                let lastAuction = singleProduct["PrixEnchere"] as! Double
            
                var newAuction = self.convert(string: self.newAcutionTextField.text!)
                
                if(self.newAcutionTextField.text == ""){
                    newAuction = 0
                    let alert = UIAlertController(title: "Erreur", message: "Champs vide", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    
                    alert.addAction(action)
                    
                    
                    self.present(alert , animated: true, completion: nil)
                }
                
                if(((lastAuction * 0.01) <= newAuction) && (newAuction <= (lastAuction * 0.1))) {
                    newAuction = lastAuction + newAuction
                    print(self.BaseUrl + "updateAuction/\(self.id!)/" + self.newAcutionTextField.text!)
                    Alamofire.request(self.BaseUrl + "updateAuction/\(self.id!)/" + String(newAuction))
                    Alamofire.request(self.BaseUrl + "addtransaction/" + String(self.id!) + "/" + UserDefaults.standard.string(forKey: "idUser")! + "/" + String(newAuction), method: .post)
                    self.newAcutionTextField.text = ""
                    Alamofire.request(self.BaseUrl + "getbestauction/\(self.id!)").responseJSON(completionHandler: { response in
                        let responseJson = JSON(response.result.value)
                        let id = responseJson[0]["Id_user"].stringValue
                        Alamofire.request(Common.Global.LOCAL + "/sendnotif/" + id + "/\(self.id!)")
                    })
                } else  {
                    let a = String(format:"%.02f", lastAuction * 0.01)
                    let b = String(format:"%.02f", lastAuction * 0.1)
                    let alert = UIAlertController(title: "Nouvelle enchère invalide", message: "Votre enchère doit etre comprise entre " + a + " et " + b, preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    
                    alert.addAction(action)
                    
                    self.present(alert , animated: true, completion: nil)
                    
        }
        
        
    
    
    }
        
        

}
    func getImages(){
        print(String(self.id!))
        Alamofire.request(Common.Global.LOCAL + "/getimages/" + String(id!), method: .get).responseJSON { response in
            
            let jsonResult = JSON(response.result.value!)
            for i in 0...jsonResult.count - 1{
                print(jsonResult[i]["image_url"])
                Alamofire.request(jsonResult[i]["image_url"].stringValue).responseImage{response in
                    if let image = response.result.value {
                        print("image downloaded: \(image)")
                        self.images.append(image)
                        self.collectionView.reloadData()
                    }
                    
                }
                
            }
        }
        
    }
    
    func convert (string: String) -> Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = "."
        if let result =  numberFormatter.number(from: string) {
            return Double(truncating: result)
        } else {
            numberFormatter.decimalSeparator = ","
            if let result = numberFormatter.number(from: string) {
                return Double(truncating: result)
            }
        }
        return 0
    }
    
    
    @IBAction func addToFavorite(_ sender: Any) {
        
    }
    
    
}

//extension DetailsViewController : UICollectionViewDelegateFlowLayout
//{
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
//    {
//        
//        let layout = collectionViewLayout as! UICollectionViewFlowLayout
//        layout.minimumLineSpacing = 5.0
//        layout.minimumInteritemSpacing = 2.5
//        let itemWidth = (collectionView.bounds.width - 5.0) / 2.0
//        return CGSize(width: itemWidth, height: itemWidth)
//    }
//}
