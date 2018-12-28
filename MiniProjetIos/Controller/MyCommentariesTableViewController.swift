//
//  MyCommentariesTableViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 24/12/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MyCommentariesTableViewController: UITableViewController {
    
    var commentariesArray : NSArray = []
    var productData: [JSON] = []
    var userData: [JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        tableView.reloadData()

    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(commentariesArray.count)
        return commentariesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentaryCell", for: indexPath)
        
        
        let content = cell.viewWithTag(0)
        
        let nameSender = content?.viewWithTag(1) as! UILabel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            nameSender.text = (self.userData[indexPath.row]["FirstName"].stringValue + " " + self.userData[indexPath.row]["LastName"].stringValue + " vous a envoyé un commentaire")

        }
        return cell
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toComments", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = sender as? NSIndexPath

        if segue.identifier == "toComments"{
            
            let commentaire = commentariesArray[index!.item] as! Dictionary<String,Any>
            let idCommentary = commentaire["Id"] as? Int
            print(idCommentary)
            if let destinationVC =  segue.destination as? CommentaryDetailsViewController{
                destinationVC.idCommentary = idCommentary!
                
            }
        }
    }
    
    func getData(){
         self.productData = []
         self.userData = []
        Alamofire.request(Common.Global.LOCAL + "/getcommentaries/" + UserDefaults.standard.string(forKey: "idUser")!).responseJSON { response in
            self.commentariesArray = response.result.value as! NSArray
            let responseJson = JSON(response.result.value!)
            if(self.commentariesArray.count != 0){
                for index in 0...self.commentariesArray.count - 1{
                    Alamofire.request(Common.Global.LOCAL + "/getuser/" + responseJson[index]["Id_sender"].stringValue).responseJSON{ responseUser in
                        print(responseUser.result.value!)
                        self.userData = self.userData + JSON(responseUser.result.value!).arrayValue
                        print(self.userData.count)
                        self.tableView.reloadData()
                    }
                }
            }
            
        }
        
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
  

}
