//
//  AddRateViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 13/01/2019.
//  Copyright © 2019 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Cosmos
import Alamofire
import SwiftyJSON
import PKHUD

class AddRateViewController: UIViewController {
    
    @IBOutlet weak var dismissBarButton: UIBarButtonItem!
    @IBOutlet weak var validateRateButton: UIButton!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var rateBar: CosmosView!
    
    var id : Int?
    var rateValue : Double?
    let idUser = UserDefaults.standard.string(forKey: "idUser")

    override func viewDidLoad() {
        super.viewDidLoad()
        testUser()
        buttonOutlet.layer.cornerRadius = 20.0
        buttonOutlet.clipsToBounds = true
        rateBar.didFinishTouchingCosmos = { rating in
        self.rateValue = rating
            self.commentTextField.layer.cornerRadius = 10.0
            self.commentTextField.layer.masksToBounds = true
        let myColor = UIColor(red: 0.04, green: 0.52, blue: 0.89, alpha: 1.0)
            self.commentTextField.layer.borderColor = myColor.cgColor
            self.commentTextField.layer.borderWidth = 1.0
            
        }

    }
    


    @IBAction func validateTapped(_ sender: Any) {
        if((commentTextField.text == "") || rateBar.rating == 0.0){
            let alert = UIAlertController(title: "Champ vide", message: "Vous ne pouvez pas envoyer un commentaire vide", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
            alert.addAction(action)
            
            
            self.present(alert , animated: true, completion: nil)
            
        } else if(validateRateButton.title(for: .normal) == "Modifier votre avis"){
            HUD.flash(.success , delay: 1.0)
            Alamofire.request(Common.Global.LOCAL + "/getproduct/" + String(id!)).responseJSON { response in
                let responseJson = JSON(response.result.value)
                let idSeller = responseJson[0]["Id_user"].stringValue
                
                let firstPart = Common.Global.LOCAL + "/updateratevalue/"
                let secondPart = self.idUser! + "/" + idSeller
                let thirdPart = "/" + String(self.rateValue!) + "/" + self.commentTextField.text!
                
                let requestFinal =  firstPart + secondPart + thirdPart
                let urlString = requestFinal.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                print(urlString)
                Alamofire.request(urlString!)
                self.dismiss(animated: true, completion: nil)
            }
        } else {
        print(rateValue)
        HUD.flash(.success , delay: 1.0)
        Alamofire.request(Common.Global.LOCAL + "/getproduct/" + String(id!)).responseJSON { response in
            let responseJson = JSON(response.result.value)
            let idSeller = responseJson[0]["Id_user"].stringValue
            
            let firstPart = Common.Global.LOCAL + "/addraiting/"
            let secondPart = self.idUser! + "/" + idSeller
            let thirdPart = "/" + String(self.rateValue!) + "/" + self.commentTextField.text!
            
            let requestFinal =  firstPart + secondPart + thirdPart
            let urlString = requestFinal.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            print(urlString)
            Alamofire.request(urlString!)
            self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func testUser() {
        Alamofire.request(Common.Global.LOCAL + "/getproduct/" + String(id!)).responseJSON { response in
            let responseJson = JSON(response.result.value)
            let idSeller = responseJson[0]["Id_user"].stringValue
            Alamofire.request(Common.Global.LOCAL + "/getcountrating/" + self.idUser! + "/" + idSeller).responseJSON{ responseRate in
                let responseRateJson = JSON(responseRate.result.value)
                let countRate = responseRateJson[0]["ratingCount"].intValue
                if(countRate == 1){
                    Alamofire.request(Common.Global.LOCAL + "/getratevalue/" + self.idUser! + "/" + idSeller).responseJSON(completionHandler: { responseData in
                        let responseDataJson = JSON(responseData.result.value)
                        self.rateBar.rating = responseDataJson[0]["Value"].doubleValue
                        self.commentTextField.text = responseDataJson[0]["Commentaire"].stringValue
                    })
                    
                    self.validateRateButton.setTitle("Modifier votre avis", for: .normal)
                }
            }
        }
    }
    
    
  
    @IBAction func dismissBarButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
