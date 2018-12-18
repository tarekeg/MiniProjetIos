//
//  ViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 27/11/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import AlamofireImage
import Alamofire
import SwiftyJSON
import GoogleSignIn

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    
    
    
    var signed = false
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewWillAppear(_ animated: Bool) {
//        let signIn = GIDSignIn.sharedInstance()
//        if (signIn!.hasAuthInKeychain()) {
//            self.performSegue(withIdentifier: "toHome", sender: self)
//            print("Signed in")
//        } else {
//            signIn?.signInSilently()
//            print("Not signed in")
//        }
        super.viewWillAppear(true)
        let signIn = GIDSignIn.sharedInstance()
        signIn!.scopes = ["https://www.googleapis.com/auth/plus.login","https://www.googleapis.com/auth/plus.me"]
        
        if (signIn!.hasAuthInKeychain()) {
            print("Signed in")
            signIn?.signInSilently()
        } else {
            print("Not signed in")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        let googleSignInButton = GIDSignInButton(frame: CGRect(x: screenWidth/2 - 100, y: screenHeight/2 + 100, width: 200, height: 30))
        loginButton.frame = CGRect(x: screenWidth/2 - 100, y: screenHeight/2 + 50, width: 200, height: 30)
        self.view.addSubview(googleSignInButton)
        loginButton.readPermissions = ["public_profile","email"]
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        loginButton.delegate = self
        if FBSDKAccessToken.current() != nil {
            OperationQueue.main.addOperation {
                print("ok")
                self.performSegue(withIdentifier: "toHome", sender: self)
            }
        }
        
      
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (error != nil){
            print(error.localizedDescription)
        } else  if (result.isCancelled){
                print("user cancelled login")
                return
        } else {
            
            print("loggin succeded")
            getFBUserData()
            performSegue(withIdentifier: "continueLog", sender: nil)

            //performSegue(withIdentifier: "toHome", sender: nil)
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("log out succeded")
        
        
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        
        if((GIDSignIn.sharedInstance()?.hasAuthInKeychain())!){
            performSegue(withIdentifier: "toHome", sender: nil)
        }
        
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            let userId = user.userID
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            let pictureUrl = user.profile.imageURL(withDimension: 120)
            let defaults = UserDefaults.standard
            defaults.setValue(userId!, forKey: "idUser")
            let request = "http://192.168.0.111:3000/adduser/\(userId!)/\(givenName!)/\(familyName!)/\(email!)/2"
            
            defaults.set(pictureUrl?.absoluteString, forKey: "profileImg")
            defaults.setValue("google", forKey: "typeConnexion")
            
            let urlString = request.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            Alamofire.request(urlString!,method: .post)
            
            performSegue(withIdentifier: "continueLog", sender: nil)
        }
    }
    
    
    func getFBUserData()
    {
        print("in fvuserdata")
        let parameters = ["fields":"id,email,first_name,last_name,picture.type(large)"]
   
        FBSDKGraphRequest.init(graphPath: "me", parameters: parameters)?.start { (connection, result, error) in
            
            if  error != nil{
                print("failed to strat graph",error!)
            }
            
            let resultJson = JSON(result!)
            
            print(resultJson)
            
            print()
            
            let pictureUrl = resultJson["picture"]["data"]["url"].stringValue
            
            let uid = resultJson["id"].stringValue
            
            let idValue = uid
            UserDefaults.standard.setValue(idValue, forKey: "idUser")
            UserDefaults.standard.setValue("facebook", forKey: "typeConnexion")
            UserDefaults.standard.set(pictureUrl, forKey: "profileImg")
            let firstName = resultJson["first_name"].stringValue
            
            let lastName = resultJson["last_name"].stringValue
            
            let email = resultJson["email"].stringValue
            
            Alamofire.request("http://192.168.0.111:3000/adduser/\(uid)/\(firstName)/\(lastName)/\(email)/1", method: .post)
            

            
            
            
        }
    }
            
    }






