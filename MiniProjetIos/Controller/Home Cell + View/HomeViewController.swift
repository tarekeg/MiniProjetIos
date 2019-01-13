//
//  HomeViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 08/12/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
  
    var productsArrayImmo : NSArray = []
    var productsArrayInfo : NSArray = []
    var productsArrayVeh : NSArray = []
    var productsArrayMaison : NSArray = []
    var productsArrayBienEtre : NSArray = []
    var productsArrayAutres : NSArray = []
    var productsArrayLoisirs : NSArray = []
    var products : NSArray = []
    var productId : Int?
    var productImages : [UIImage] = []
    let group = DispatchGroup()


    let baseUrl = Common.Global.LOCAL

    @IBOutlet weak var tableView: UITableView!
    
    
    
    
    let categoriesArray = ["Immobilier","Véhicules","Pour la Maison et Jardin","Loisirs et Divertissement","Informatique et Multimédia","Habillement et Bien Etre","Autres"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = "Acceuil"
        tableView.reloadData()
        updatedevicetoken()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.categoryLabel.text = categoriesArray[indexPath.section]
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? CategoryCell {
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.tag = indexPath.section
            cell.collectionView.reloadData()
            
            
            if(cell.collectionView.tag == 0){
                Alamofire.request(baseUrl+"/getproductsimmo").responseJSON{
                    response in
                    if let result = response.result.value as? NSArray {
                        self.productsArrayImmo = result
                        cell.collectionView.reloadData()
                    }
                         else {
                            print("empty array")
                    }
                }
            }
            if(cell.collectionView.tag == 1){
                Alamofire.request(baseUrl+"/getproductsvehicules").responseJSON{
                    response in
                    if let result = response.result.value as? NSArray {
                        self.productsArrayVeh = result
                        cell.collectionView.reloadData()
                    }
                    else {
                        print("empty array")
                    }
                }
            }
            if(cell.collectionView.tag == 2){
                Alamofire.request(baseUrl+"/getproductsmaison").responseJSON{
                    response in
                    if let result = response.result.value as? NSArray {
                        self.productsArrayMaison = result
                        cell.collectionView.reloadData()
                    }
                    else {
                        print("empty array")
                    }
                }
            }
            if(cell.collectionView.tag == 3){
                Alamofire.request(baseUrl+"/getproductsloisirs").responseJSON{
                    response in
                    if let result = response.result.value as? NSArray {
                        self.productsArrayLoisirs = result
                        cell.collectionView.reloadData()
                    }
                    else {
                        print("empty array")
                    }
                }
            }
            if(cell.collectionView.tag == 4){
                Alamofire.request(baseUrl+"/getproductsinfo").responseJSON{
                    response in
                    if let result = response.result.value as? NSArray {
                        self.productsArrayInfo = result
                        cell.collectionView.reloadData()
                    }
                    else {
                        print("empty array")
                    }
                }
            }
            if(cell.collectionView.tag == 5){
                Alamofire.request(baseUrl+"/getproductsbienetre").responseJSON{
                    response in
                    if let result = response.result.value as? NSArray {
                        self.productsArrayBienEtre = result
                        cell.collectionView.reloadData()
                    }
                    else {
                        print("empty array")
                    }
                }
            }
            if(cell.collectionView.tag == 6){
                Alamofire.request(baseUrl+"/getproductsautres").responseJSON{
                    response in
                    if let result = response.result.value as? NSArray {
                        self.productsArrayAutres = result
                        cell.collectionView.reloadData()
                    }
                    else {
                        print("empty array")
                    }
                }
            }
            
            cell.collectionView.reloadData()

        }
    }
    
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView.tag == 0){
            return self.productsArrayImmo.count
        }
        if(collectionView.tag == 1){
            return self.productsArrayVeh.count
        }
        if(collectionView.tag == 2){
            return self.productsArrayMaison.count
        }
        if(collectionView.tag == 3){
            return self.productsArrayLoisirs.count
        }
        if(collectionView.tag == 4){
            return self.productsArrayInfo.count
        }
        if(collectionView.tag == 5){
            return self.productsArrayBienEtre.count
        }
        if(collectionView.tag == 6){
            return self.productsArrayAutres.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        
        if(collectionView.tag == 0){
            let immo  = productsArrayImmo[indexPath.item] as! Dictionary<String,Any>
            cell.productNameLabel.text = immo["Name"] as? String
            let urlImage = immo["first_image_path"] as? String
            cell.imageProduct.af_setImage(withURL: URL(string: urlImage!)!)
            cell.imageProduct.layer.cornerRadius = 20.0
            cell.imageProduct.clipsToBounds = true
            if(immo["Type_vente"] as! Int == 1){
                let prix = immo["PrixFixe"] as! Double
                cell.priceLabel.text = "\(prix) DT"
                cell.typeVenteLabel.text = "Achat immédiat"
            } else {
                let prix = immo["PrixEnchere"] as! Double
                cell.priceLabel.text = "\(prix) DT"
                cell.typeVenteLabel.text = "Enchère"
                
            }
            return cell
        }
        
        if(collectionView.tag == 1){
            let veh  = productsArrayVeh[indexPath.item] as! Dictionary<String,Any>
            cell.productNameLabel.text = veh["Name"] as? String
            let urlImage = veh["first_image_path"] as? String
            cell.imageProduct.af_setImage(withURL: URL(string: urlImage!)!)
            cell.imageProduct.layer.cornerRadius = 20.0
            cell.imageProduct.clipsToBounds = true
            if(veh["Type_vente"] as! Int == 1){
                let prix = veh["PrixFixe"] as! Double
                cell.priceLabel.text = "\(prix) DT"
                cell.typeVenteLabel.text = "Achat immédiat"
            } else {
                let prix = veh["PrixEnchere"] as! Double
                cell.priceLabel.text = "\(prix) DT"
                cell.typeVenteLabel.text = "Enchère"
                
            }
            return cell

        }
        if(collectionView.tag == 2){
            let maison  = productsArrayMaison[indexPath.item] as! Dictionary<String,Any>
            cell.productNameLabel.text = maison["Name"] as? String
            let urlImage = maison["first_image_path"] as? String
            cell.imageProduct.af_setImage(withURL: URL(string: urlImage!)!)
            cell.imageProduct.layer.cornerRadius = 20.0
            cell.imageProduct.clipsToBounds = true
            if(maison["Type_vente"] as! Int == 1){
                let prix = maison["PrixFixe"] as! Double
                cell.priceLabel.text = "\(prix) DT"
                cell.typeVenteLabel.text = "Achat immédiat"
            } else {
                let prix = maison["PrixEnchere"] as! Double
                cell.typeVenteLabel.text = "Enchère"
                cell.priceLabel.text = "\(prix) DT"
                
            }
            return cell
            
        }
        if(collectionView.tag == 3){
            let loisir  = productsArrayLoisirs[indexPath.item] as! Dictionary<String,Any>
            cell.productNameLabel.text = loisir["Name"] as? String
            let urlImage = loisir["first_image_path"] as? String
            cell.imageProduct.af_setImage(withURL: URL(string: urlImage!)!)
            cell.imageProduct.layer.cornerRadius = 20.0
            cell.imageProduct.clipsToBounds = true
            if(loisir["Type_vente"] as! Int == 1){
                let prix = loisir["PrixFixe"] as! Double
                cell.priceLabel.text = "\(prix) DT"
                cell.typeVenteLabel.text = "Achat immédiat"
            } else {
                let prix = loisir["PrixEnchere"] as! Double
                cell.priceLabel.text = "\(prix) DT"
                cell.typeVenteLabel.text = "Enchère"
                
            }
            return cell


        }
        if(collectionView.tag == 4){
            let info  = productsArrayInfo[indexPath.item] as! Dictionary<String,Any>
            cell.productNameLabel.text = info["Name"] as? String
            let urlImage = info["first_image_path"] as? String
            cell.imageProduct.af_setImage(withURL: URL(string: urlImage!)!)
            cell.imageProduct.layer.cornerRadius = 20.0
            cell.imageProduct.clipsToBounds = true
            if(info["Type_vente"] as! Int == 1){
                let prix = info["PrixFixe"] as! Double
                cell.priceLabel.text = "\(prix) DT"
                cell.typeVenteLabel.text = "Achat immédiat"
            } else {
                let prix = info["PrixEnchere"] as! Double
                cell.priceLabel.text = "\(prix) DT"
                cell.typeVenteLabel.text = "Enchère"
                
            }
            return cell

            
        }
        if(collectionView.tag == 5){
            let bienEtre  = productsArrayBienEtre[indexPath.item] as! Dictionary<String,Any>
            cell.productNameLabel.text = bienEtre["Name"] as? String
            let urlImage = bienEtre["first_image_path"] as? String
            cell.imageProduct.af_setImage(withURL: URL(string: urlImage!)!)
            cell.imageProduct.layer.cornerRadius = 20.0
            cell.imageProduct.clipsToBounds = true
            if(bienEtre["Type_vente"] as! Int == 1){
                let prix = bienEtre["PrixFixe"] as! Double
                cell.priceLabel.text = "\(prix) DT"
                cell.typeVenteLabel.text = "Achat immédiat"
            } else {
                let prix = bienEtre["PrixEnchere"] as! Double
                cell.priceLabel.text = "\(prix) DT"
                cell.typeVenteLabel.text = "Enchère"
                
            }
            return cell

            
        }
        if(collectionView.tag == 6){
            let autre  = productsArrayAutres[indexPath.item] as! Dictionary<String,Any>
            cell.productNameLabel.text = autre["Name"] as? String
            let urlImage = autre["first_image_path"] as? String
            cell.imageProduct.af_setImage(withURL: URL(string: urlImage!)!)
            cell.imageProduct.layer.cornerRadius = 20.0
            cell.imageProduct.clipsToBounds = true
            if(autre["Type_vente"] as! Int == 1){
                let prix = autre["PrixFixe"] as! Double
                cell.priceLabel.text = String(prix)
                cell.typeVenteLabel.text = "Achat immédiat"
            } else {
                let prix = autre["PrixEnchere"] as! Double
                cell.priceLabel.text = String(prix) + "DT"
                cell.typeVenteLabel.text = "Enchère"
                cell.priceLabel.text = String(prix)
                
            }
            return cell
   
        }
  
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView.tag == 0){
            products = productsArrayImmo

        }
        if(collectionView.tag == 1){
            products = productsArrayVeh
            
        }
        if(collectionView.tag == 2){
            products = productsArrayMaison
            
        }
        if(collectionView.tag == 3){
            products = productsArrayLoisirs
            
        }
        if(collectionView.tag == 4){
            products = productsArrayInfo

        }
        if(collectionView.tag == 5){
            products = productsArrayBienEtre
            
        }
        if(collectionView.tag == 6){
            products = productsArrayAutres
            
        }
        
        let product = products[indexPath.item] as! Dictionary<String,Any>
        
        if(product["Type_vente"] as? Int == 1){
            print("toAchatImmediat")
            self.performSegue(withIdentifier: "toDirectSell", sender: indexPath)
        } else {
            print("toAuction")
            self.performSegue(withIdentifier: "toDetails", sender: indexPath)

        }
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let index = sender as? NSIndexPath
    
       

        

        
        if segue.identifier == "toDetails"{
            
            let product = products[index!.item] as! Dictionary<String,Any>
            productId = product["Id"] as? Int
            
            if let destinationVC =  segue.destination as? DetailsViewController{
                destinationVC.id = productId!

            }
        }
        if segue.identifier == "toDirectSell"{
            
            let product = products[index!.item] as! Dictionary<String,Any>
            productId = product["Id"] as? Int
            
            if let destinationVC =  segue.destination as? DetailsDirectSellViewController{
                destinationVC.id = productId!
              
                }
            }
            
        }
    func updatedevicetoken(){
        if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") {
            let id = UserDefaults.standard.string(forKey: "idUser")
            print(deviceToken)
            print(id!)
           Alamofire.request(Common.Global.LOCAL + "/updatedevicetoken/" + deviceToken + "/" + id! ,method : .post)
        } else {
            print("devicetoken nil")
        }
        
    }

}

    
//    func getImages(id: Int, completionHandler:@escaping ([UIImage ]?, Error?) -> Void){
//        print(String(id))
//        Alamofire.request("http://192.168.0.111:3000/getimages/" + String(id)).responseJSON { response in
//            let jsonResult = JSON(response.result.value!)
//            for i in 0...jsonResult.count - 1{
//                let remoteImageURL = URL(string:jsonResult[i]["image_url"].stringValue )!
//                Alamofire.request(remoteImageURL).responseData { response in
//
//                    print(response.result)
//                    if let data = response.data {
//                        do {
//                            //                            self.downloadImage.image = UIImage(data:data)
//                            self.productImages.append(UIImage(data:data)!)
//                            print(self.productImages.count)
//                            completionHandler(self.productImages, nil)
//                        } catch {
//                            completionHandler(nil,error)
//                        }
//                    }
//                }
//            }
//
//        }
//        }









