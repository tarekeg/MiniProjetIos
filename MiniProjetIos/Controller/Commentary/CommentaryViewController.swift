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
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var commentaryTextField: UITextField!
    
    var placeholderLabel : UILabel!
    var id : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        UpdateData()
        buttonOutlet.layer.cornerRadius = 20.0
        buttonOutlet.clipsToBounds = true
        commentaryTextField.layer.cornerRadius = 10.0
        commentaryTextField.layer.masksToBounds = true
        let myColor = UIColor(red: 0.04, green: 0.52, blue: 0.89, alpha: 1.0)
        commentaryTextField.layer.borderColor = myColor.cgColor
        commentaryTextField.layer.borderWidth = 1.0

    }
    
    func UpdateData(){
        Alamofire.request(Common.Global.LOCAL + "/getproduct/" + String(id!)).responseJSON { response in
            let responseJson = JSON(response.result.value)
            self.nameProduct.text = responseJson[0]["Name"].stringValue
            UserDefaults.standard.setValue(responseJson[0]["Id_user"].stringValue, forKey: "idReceiver")
            Alamofire.request(Common.Global.LOCAL + "/getuser/" + responseJson[0]["Id_user"].stringValue).responseJSON(completionHandler: { responseUser in
                print(responseUser.result.value)
                let responseUserJson = JSON(responseUser.result.value)
                self.nameReceiver.text = responseUserJson[0]["FirstName"].stringValue + " " + responseUserJson[0]["LastName"].stringValue
            })
            
        }
    }
    
    @IBAction func sendTapped(_ sender: Any) {
        
        if(commentaryTextField.text == ""){
            
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
            
            let firstPart = Common.Global.LOCAL + "/addcommentary/" + idSender!
            let secondPart = "/" + idReceiver! + "/" + commentaryTextField.text!
            
            let url = firstPart + secondPart
            let finalUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            Alamofire.request(finalUrl!)
            Alamofire.request(Common.Global.LOCAL + "/sendnotifcomment/" + idSender! + "/" + idReceiver!)
            dismiss(animated: true, completion: nil)
            
        }
       
        
        
    }
    
    @IBAction func backToHome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
