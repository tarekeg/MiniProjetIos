//
//  TransactionViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 18/12/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON

class TransactionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var testBool = false
    var productArray : NSArray = []
    var transactionArray : NSArray = []
    var data: [JSON] = []
    let baseUrl = Common.Global.LOCAL + "/"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !testBool {
        getData()
        tableView.reloadData()
        }
        testBool = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        testBool = true

    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionCell", for: indexPath)
    
        let transaction  = transactionArray[indexPath.item] as! Dictionary<String,Any>
        let content = cell.viewWithTag(0)
        let imageProduct = content?.viewWithTag(1) as! UIImageView
        let labelName = content?.viewWithTag(2) as! UILabel
        let labelMyAuction = content?.viewWithTag(3) as! UILabel
        let labelAuction = content?.viewWithTag(4) as! UILabel
        let indication = content?.viewWithTag(5) as! UILabel
        print("lindexpath est :",indexPath.row)
        
        
        print(self.data[indexPath.row]["first_image_path"].stringValue)
        let urlImage = self.data[indexPath.row]["first_image_path"].stringValue
        imageProduct.af_setImage(withURL: URL(string: urlImage)!)
        
        labelName.text = self.data[indexPath.row]["Name"].stringValue
        let myAuction = transaction["Enchere"] as! Double
        let prix = self.data[indexPath.row]["PrixEnchere"].double
        let dateFinAuction = self.data[indexPath.row]["DateFin"].string
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let yourDate = formatter.date(from: dateFinAuction!)
        let currentDateTime = Date()
        let diffInSeconds = Calendar.current.dateComponents([.second], from:currentDateTime , to: yourDate!).second
        labelAuction.text = "\(prix!) DT"
        labelMyAuction.text = "\(myAuction) DT"
        
        if (prix! > myAuction && diffInSeconds! < 0) {
            indication.text = "Vous avez perdu l'enchère"
        } else if (prix! <= myAuction && diffInSeconds! < 0){
            indication.text = "Félicatation vous avez gagné l'enchère"
        } else if (prix! > myAuction && diffInSeconds! > 0){
            indication.text = "Vous n'êtes pas le meilleur enchériesseur"
        } else if (prix! <= myAuction && diffInSeconds! > 0){
            indication.text = "Vous êtes le meilleur enchériesseur"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetails", sender: indexPath)
    }
    
    
    func getData(){
        self.data = []
        Alamofire.request(self.baseUrl + "gettransaction/" + UserDefaults.standard.string(forKey: "idUser")!).responseJSON { response in
            let resultJson = JSON(response.result.value!)
            self.transactionArray = response.result.value as! NSArray
            if self.transactionArray.count != 0{
                for index in 0...self.transactionArray.count - 1{
                    let idProduct : Int = resultJson[index]["Id_product"].intValue
                    print(idProduct)
                    Alamofire.request(self.baseUrl + "getproduct/" + String(idProduct)).responseJSON{ response in
                        self.data = self.data + JSON(response.result.value!).arrayValue
                        self.tableView.reloadData()
                        
                    }
                    
                }
            }
            
        }

        
    }
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = sender as? NSIndexPath
        
        let productId = self.data[index!.row]["Id"].intValue
            print(productId)
        
        
        if segue.identifier == "toDetails"{
            
            
            if let destinationVC =  segue.destination as? DetailsViewController{
                
                destinationVC.id = productId
            }
        }
        
    }

}
