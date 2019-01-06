//
//  CommentaryDetailsViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 28/12/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import PKHUD

class CommentaryDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var commentariesArray : NSArray = []
    var idSender : String?
    var AuctionTimer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        configureTableView()
        tableView.reloadData()
        scrollToBottom()
        AuctionTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getData), userInfo: nil, repeats: true)

    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("taille du tableau: ",commentariesArray.count)
        return commentariesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let commentary = commentariesArray[indexPath.row] as! Dictionary<String,Any>
    
        if(commentary["Id_sender"] as? String == UserDefaults.standard.string(forKey: "idUser")){
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath)
            let content = cell.viewWithTag(0)
            let senderLabel = content?.viewWithTag(2) as! UILabel
            let senderView = content?.viewWithTag(4)
            senderView!.layer.cornerRadius = 8.0
            senderView!.clipsToBounds = true
            senderLabel.text = commentary["text"] as? String
        return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath)
            let content = cell.viewWithTag(0)
            let receiverLabel = content?.viewWithTag(1) as! UILabel
            let receiverView = content?.viewWithTag(3)
            receiverView!.layer.cornerRadius = 8.0
            receiverView!.clipsToBounds = true
            receiverLabel.text = commentary["text"] as? String
            return cell
        }
    }
    
    @objc func getData(){
        print(UserDefaults.standard.string(forKey: "idUser")!)
        Alamofire.request(Common.Global.LOCAL + "/getcommentariessender/" + idSender! + "/" + UserDefaults.standard.string(forKey: "idUser")!).responseJSON { response in
            self.commentariesArray = response.result.value as! NSArray
            self.tableView.reloadData()
        }
        tableView.reloadData()
    }
    
    
    @IBAction func sendTapped(_ sender: Any) {
        if(messageTextField.text == "") {
            let alert = UIAlertController(title: "Champs vide", message: "veuillez remplir le champs vide", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
        } else {
            let message = messageTextField.text
            let myId = UserDefaults.standard.string(forKey: "idUser")
            let finalRequest = Common.Global.LOCAL + "/addcommentary/" + myId! + "/" + idSender! + "/" + message!
            let finalUrl = finalRequest.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            Alamofire.request(finalUrl!)
            messageTextField.text = ""
            HUD.flash(.success , delay: 1.0)
            getData()
            tableView.reloadData()
            scrollToBottom()
        }
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50.0
    }
    
    func scrollToBottom(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(row: self.commentariesArray.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
