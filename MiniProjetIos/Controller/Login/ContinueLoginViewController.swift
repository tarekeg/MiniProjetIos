//
//  ContinueLoginViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 14/12/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Alamofire

class ContinueLoginViewController: UIViewController {
    
    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneNumberTextField.keyboardType = UIKeyboardType.decimalPad

        
    }
    
    func updataUserData() {
        let phoneNumber = phoneNumberTextField.text
        let trimmedPhoneNumber = phoneNumber!.trimmingCharacters(in: .whitespacesAndNewlines)
        let defaults = UserDefaults.standard
        if let idValue = defaults.string(forKey: "idUser"){
            let url = Common.Global.LOCAL + "/addphonenumber/"+idValue+"/"+trimmedPhoneNumber
        
            Alamofire.request(url, method: .post)
            
            
        }
        
        
    }
    
    @IBAction func validateTapped(_ sender: Any) {
        if(phoneNumberTextField.text == ""){
            
            let alert = UIAlertController(title: "Champ vide", message: "Le champ ne doit pas rester vide", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            
            alert.addAction(action)
            
            
            self.present(alert , animated: true, completion: nil)
            
        } else {
        updataUserData()
            self.phoneNumberTextField.text = ""
                self.performSegue(withIdentifier: "toHome", sender: nil)

        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
