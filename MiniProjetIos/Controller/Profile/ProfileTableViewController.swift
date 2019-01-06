//
//  ProfileTableViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 16/12/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Alamofire
import SwiftyJSON
import AlamofireImage
import PKHUD

class ProfileTableViewController: UITableViewController,  FBSDKLoginButtonDelegate, GIDSignInUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    
    
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var updateBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var changeProfilePicture: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var googleSignOutButton: UIButton!
    @IBOutlet weak var logOutButton: FBSDKLoginButton!
    
    let imagePicker = UIImagePickerController()
    var userArray : NSArray = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        self.hideKeyboardWhenTappedAround()
        cancelBarButtonItem.isEnabled = false
        cancelBarButtonItem.title = ""
        changeProfilePicture.isHidden = true
        logOutButton.isHidden = true
        googleSignOutButton.isHidden = true
        self.logOutButton.delegate = self
        imagePicker.delegate = self
        let urlPath = UserDefaults.standard.string(forKey: "profileImg")
        getData()
        profileImageView.layer.cornerRadius = 52.5
        profileImageView.clipsToBounds = true
        if(urlPath == nil){
        if let url = URL(string: urlPath!) {
            downloadImage(from: url)
        }
    }
        tableView.reloadData()
    }
    
    var picker_image : UIImage? {
        didSet {
            guard let image = picker_image else { return }
            self.profileImageView.image = image
            self.tableView.reloadData()
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 5
        } else if(section == 1){
            return 1
        }
        return 0
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("ok")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func googleSignOutTapped(_ sender: Any) {
//        GIDSignIn.sharedInstance().hasAuthInKeychain() = false
        GIDSignIn.sharedInstance()?.disconnect()
        HUD.show(.progress)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            HUD.hide()

        }
    }
    
    func getData() {
        let defaults = UserDefaults.standard
        if let idValue = defaults.string(forKey: "idUser"){
            print(idValue)
            let url = Common.Global.LOCAL + "/getuser/"+idValue
            print(url)
            Alamofire.request(url, method: .get).responseJSON{
                response in
                self.userArray = response.result.value as! NSArray
                let user = self.userArray[0] as! Dictionary<String,Any>
                
//                if user["profile_image_path"] == nil {
                    let pathPicture = user["profile_image_path"] as! String
                    self.profileImageView.af_setImage(withURL: URL(string: pathPicture)!)
//                } else {
//                    let urlPath = UserDefaults.standard.string(forKey: "profileImg")
//                    let url = URL(string: urlPath!)
//                    self.downloadImage(from: url!)
//
//                    }
                
                let userFirstName = user["FirstName"] as! String
                let userLastName = user["LastName"] as! String
                let userPhoneNumber = user["PhoneNumber"] as! String
                let userEmail = user["Email"] as! String
                self.addressTextField.text = user["Adresse"] as? String ?? "champs vide"
                self.nameTextField.text = userFirstName
                self.lastNameTextField.text = userLastName
                self.phoneNumberTextField.text = userPhoneNumber
                self.emailTextField.text = userEmail
                
                if(user["type_connexion"] as! Int == 1){
                    self.logOutButton.isHidden = false
                } else {
                    self.googleSignOutButton.isHidden = false
                }
            }

        }
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                self.profileImageView.image = UIImage(data: data)
            }
        }
    }
    @IBAction func changeProfileImageTapped(_ sender: Any) {
        
        let sheet = UIAlertController(title: "Ajouter une photo", message: "Choisssez votre source", preferredStyle: .actionSheet)
        
        let actionSheetLibrary = UIAlertAction(title: "Photo library", style: .default) { (UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let actionSheetCamera = UIAlertAction(title: "Camera", style: .default) { (UIAlertAction) in
            self.imagePicker.sourceType = .camera
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let actionSheetCancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        sheet.addAction(actionSheetLibrary)
        sheet.addAction(actionSheetCamera)
        sheet.addAction(actionSheetCancel)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.picker_image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.picker_image = originalImage
            
        }
        let imageData = self.picker_image!.jpegData(compressionQuality: 0.5)
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            MultipartFormData.append(imageData!, withName: "myImage", fileName: "image.jpeg", mimeType: "image/jpeg")
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to:Common.Global.LOCAL + "/uploadprofilepic/"+UserDefaults.standard.string(forKey: "idUser")!, method: .post, headers: nil) { (result: SessionManager.MultipartFormDataEncodingResult) in
            switch result {
            case .failure(let error):
                print(error)
            case . success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                upload.uploadProgress(closure: { (progress) in
                    print(progress)
                }
                    
                )}
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    @IBAction func updateProfileTapped(_ sender: Any) {
        
        if(updateBarButtonItem.title == "Modifier"){
        cancelBarButtonItem.title = "Annuler"
        cancelBarButtonItem.isEnabled = true
        updateBarButtonItem.title = "OK"
        tableView.allowsSelection = true
        nameTextField.isUserInteractionEnabled = true
        lastNameTextField.isUserInteractionEnabled = true
        emailTextField.isUserInteractionEnabled = true
        phoneNumberTextField.isUserInteractionEnabled = true
        addressTextField.isUserInteractionEnabled = true
        changeProfilePicture.isHidden = false

            
        } else if (updateBarButtonItem.title == "OK"){
            let firstName = nameTextField.text
            let lastName = lastNameTextField.text
            let email = emailTextField.text
            let phoneNumber = phoneNumberTextField.text
            let address = addressTextField.text
            let defaults = UserDefaults.standard
            if let idValue = defaults.string(forKey: "idUser"){
                let url = Common.Global.LOCAL + "/updateuserprofile/"+idValue+"/"+firstName!+"/"+lastName!+"/"+email!+"/"+phoneNumber!+"/"+address!
                let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                print(urlString!)
                Alamofire.request(urlString!, method: .post)
            }
            tableView.allowsSelection = false
            cancelBarButtonItem.title = ""
            cancelBarButtonItem.isEnabled = false
            updateBarButtonItem.title = "Modifier"
            nameTextField.isUserInteractionEnabled = false
            lastNameTextField.isUserInteractionEnabled = false
            emailTextField.isUserInteractionEnabled = false
            phoneNumberTextField.isUserInteractionEnabled = false
            addressTextField.isUserInteractionEnabled = false
            changeProfilePicture.isHidden = true
            

        }
        
        
    }
    @IBAction func cancelUpdateProfileTapped(_ sender: Any) {
        
        
        updateBarButtonItem.title = "Modifier"
        cancelBarButtonItem.isEnabled = false
        cancelBarButtonItem.title = ""
        nameTextField.isUserInteractionEnabled = false
        lastNameTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        phoneNumberTextField.isUserInteractionEnabled = false
        addressTextField.isUserInteractionEnabled = false
        changeProfilePicture.isHidden = true
        
        
        
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
    

