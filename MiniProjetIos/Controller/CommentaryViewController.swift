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

class CommentaryViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var nameReceiver: UILabel!
    @IBOutlet weak var nameProduct: UILabel!
    
    @IBOutlet weak var commentaryTextView: UITextView!
    var placeholderLabel : UILabel!
    var id : Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        commentaryTextView.delegate = self
        placeholderLabel = UILabel()
        placeholderLabel.text = "Entrer votre commentaire"
        placeholderLabel.font = UIFont.italicSystemFont(ofSize: (commentaryTextView.font?.pointSize)!)
        placeholderLabel.sizeToFit()
        commentaryTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: (commentaryTextView.font?.pointSize)! / 2)
        placeholderLabel.textColor = UIColor(red:0.00, green:0.52, blue:1.00, alpha:1.0)
        placeholderLabel.isHidden = !commentaryTextView.text.isEmpty
        UpdateData()
        
        

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
            let url = Common.Global.LOCAL + "/addcommentary/" + idSender! + "/" + idReceiver! + "/" + commentaryTextView.text
            
            let finalUrl = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            Alamofire.request(finalUrl!)
            dismiss(animated: true, completion: nil)
            
        }
        
        
    }
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    @IBAction func backToHome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
