//
//  ProfileViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 30/11/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    
    @IBOutlet weak var googleSignOutTapped: UIButton!
    
    var userArray : NSArray = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.logButton.isHidden = true
        googleSignOutTapped.isHidden = true
        
        self.logButton.delegate = self
//        print(UserDefaults.standard.string(forKey: "idUser")!)
        getData()
       
    }
    

   
    @IBOutlet weak var logButton: FBSDKLoginButton!
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("ok")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func googleSignOut(_ sender: Any) {
        GIDSignIn.sharedInstance()?.disconnect()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func getData() {
        let defaults = UserDefaults.standard
        if let idValue = defaults.string(forKey: "idUser"){
            print(idValue)
            let url = "http://192.168.0.111:3000/getuser/"+idValue
            print(url)
            Alamofire.request(url, method: .get).responseJSON{
                response in
                self.userArray = response.result.value as! NSArray
                let user = self.userArray[0] as! Dictionary<String,Any>
                if(user["type_connexion"] as! Int == 1){
                    self.logButton.isHidden = false
                } else {
                    self.googleSignOutTapped.isHidden = false
                }
            }
            
            
        }
        
    }
    
    

}
