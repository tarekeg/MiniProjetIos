//
//  CommentaryViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 24/12/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD

class CommentaryViewController: UIViewController {
    
    @IBOutlet weak var nameReceiver: UILabel!
    @IBOutlet weak var nameProduct: UILabel!
    
    @IBOutlet weak var commentaryTextView: UITextView!
    var id : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        print(id!)
        UpdateData()
        

    }
    
    func UpdateData(){
        Alamofire.request(Common.Global.LOCAL + "/getproduct/" + String(id!)).responseJSON { response in
            let responseJson = JSON(response.result.value)
            self.nameProduct.text = "Produit: " + responseJson[0]["Name"].stringValue
            UserDefaults.standard.setValue(responseJson[0]["Id_user"].stringValue, forKey: "idReceiver")
            Alamofire.request(Common.Global.LOCAL + "/getuser/" + responseJson[0]["Id_user"].stringValue).responseJSON(completionHandler: { responseUser in
                print(responseUser.result.value)
                let responseUserJson = JSON(responseUser.result.value)
                self.nameReceiver.text = "Vendeur: " + responseUserJson[0]["FirstName"].stringValue + " " + responseUserJson[0]["LastName"].stringValue
            })
            
        }
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        
        if(commentaryTextView.text == ""){
            
            let alert = UIAlertController(title: "Champ vide", message: "Vous ne pouvez pas envoyer un commentaire vide", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
            alert.addAction(action)
            
            
            self.present(alert , animated: true, completion: nil)
            
        } else {
           
            HUD.flash(.success , delay: 1.0)

            let idSender = UserDefaults.standard.string(forKey: "idUser")
            let idReceiver = UserDefaults.standard.string(forKey: "idReceiver")
            print("idSender = ",idSender!)
            print("idReceiver = ",idReceiver!)
            let url = Common.Global.LOCAL + "/addcommentary/" + idSender! + "/" + idReceiver! + "/" + String(id!) + "/" + commentaryTextView.text
            
            let finalUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            print(finalUrl!)
            Alamofire.request(finalUrl!)
            dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    

}
