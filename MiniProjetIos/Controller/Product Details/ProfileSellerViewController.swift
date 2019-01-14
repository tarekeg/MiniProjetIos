//
//  ProfileSellerViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 13/01/2019.
//  Copyright © 2019 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import Cosmos

class ProfileSellerViewController: UIViewController,UITableViewDataSource, UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource {
    
    

    @IBOutlet weak var addRatingButton: UIButton!
    @IBOutlet weak var cosmosRate: CosmosView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    @IBOutlet weak var userImageViw: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userFirstNameLabel: UILabel!
    @IBOutlet weak var userAdressLabel: UILabel!
    
    var idUserSeller : String?
    var data: [JSON] = []
    var id : Int?
    var userProductArray : NSArray = []
    var rateArray : NSArray = []
    var rateAvgArray : NSArray = []
    let user = UserDefaults.standard.string(forKey: "idUser")

    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    
    override func viewDidLoad() {
        print("tesssssssst",idUserSeller)
        super.viewDidLoad()
        tableView.isHidden = true
        getData()
        userImageViw.layer.cornerRadius = 50.0
        userImageViw.clipsToBounds = true
        cosmosRate.settings.updateOnTouch = false
        cosmosRate.settings.fillMode = .precise

    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return userProductArray.count
        return userProductArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userProductCell", for: indexPath)
        let product = userProductArray[indexPath.row] as! Dictionary<String,Any>
        let imageProductView = cell.viewWithTag(1) as! UIImageView
        let pathImage = product["first_image_path"] as! String
        print(pathImage)
        imageProductView.af_setImage(withURL: URL(string: pathImage)!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return rateArray.count
        return rateArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rateCellDetails", for: indexPath)
        
        let rating  = rateArray[indexPath.row] as! Dictionary<String,Any>
        
        let content = cell.viewWithTag(0)
        let imageProfileView = content?.viewWithTag(1) as! UIImageView
        let rateValue = content?.viewWithTag(2) as! CosmosView
        var commentaryLabel = content?.viewWithTag(3) as! UILabel
        var nameRaterLabel = content?.viewWithTag(4) as! UILabel
        
        imageProfileView.layer.cornerRadius = 20.0
        imageProfileView.clipsToBounds = true
        
        
        rateValue.rating = rating["Value"] as! Double
        commentaryLabel.text = rating["Commentaire"] as! String
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        nameRaterLabel.text = self.data[indexPath.row]["FirstName"].stringValue
        let imagePath = self.data[indexPath.row]["profile_image_path"].stringValue
            imageProfileView.af_setImage(withURL: URL(string: imagePath)!)

        }
        
        return cell
    }
    
    @IBAction func changeViewSegmented(_ sender: UISegmentedControl) {
        switch segmentedControlOutlet.selectedSegmentIndex {
        case 0:
            tableView.isHidden = true
            collectionView.isHidden = false
        case 1:
            tableView.isHidden = false
            collectionView.isHidden = true
        default:
            break;
        }
    }
    func getData() {
        self.data = []
            if(self.user == self.idUserSeller!){
                self.addRatingButton.isHidden = true
            }
            Alamofire.request(Common.Global.LOCAL + "/getaveragevalue/" + idUserSeller!).responseJSON(completionHandler: { responseAvg in
                
                self.rateAvgArray = responseAvg.result.value as! NSArray
                
                if let rate = self.rateAvgArray[0] as? Dictionary<String,Any> {
                    
                    if let rateAvg =  rate["AverageValue"] as? Double {
                        
                        self.cosmosRate.rating = rateAvg
                        
                    } else {
                        
                        self.cosmosRate.rating = 0.0
                        
                    }
                    
                }
                
                
            })
            Alamofire.request(Common.Global.LOCAL + "/getuser/" + self.idUserSeller!).responseJSON{ responseUser in
                let responseJsonUser = JSON(responseUser.result.value)
                print(responseJsonUser)
                self.userNameLabel.text = responseJsonUser[0]["LastName"].stringValue
                self.userFirstNameLabel.text = responseJsonUser[0]["FirstName"].stringValue
                self.userAdressLabel.text = "champs vide"
                let pathPicture = responseJsonUser[0]["profile_image_path"].stringValue
                self.userImageViw.af_setImage(withURL: URL(string: pathPicture)!)
            }
            
            Alamofire.request(Common.Global.LOCAL + "/getproductuser/" + idUserSeller!).responseJSON { response in
                self.userProductArray = response.result.value as! NSArray
                self.collectionView.reloadData()
                
            }
      
            Alamofire.request(Common.Global.LOCAL + "/getuserrate/" + idUserSeller!).responseJSON { responseRating in
                self.rateArray = responseRating.result.value as! NSArray
                let responseRatingJson = JSON(responseRating.result.value)
                if(self.rateArray.count != 0){
                    for index in 0...self.rateArray.count - 1{
                        let id_validateur = responseRatingJson[index]["Id_validateur"].stringValue
                        Alamofire.request(Common.Global.LOCAL + "/getuser/" + id_validateur).responseJSON { responseUserJSON in
                            self.data = self.data + JSON(responseUserJSON.result.value!).arrayValue
                            print(self.data.count)
                            self.tableView.reloadData()
                        }
                    }
            }
            
        }
    }
    
    
    @IBAction func addRateTapped(_ sender: Any) {
        performSegue(withIdentifier: "toRate", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRate" {
            if let destinationVC =  segue.destination as? UINavigationController {
                if let childVC = destinationVC.topViewController as? AddRateViewController {
                    childVC.id = id
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileSellerViewController") as! ProfileSellerViewController
        let seller  =   self.data[indexPath.row]["Id"].stringValue
        vc.idUserSeller = seller
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let productUser  = userProductArray[indexPath.item] as! Dictionary<String,Any>
        if(productUser["Type_vente"] as? Int == 1){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DirectBuyViewController") as! DetailsDirectSellViewController
            vc.id = productUser["Id"] as? Int
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        vc.id = productUser["Id"] as? Int
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
    
    
}
