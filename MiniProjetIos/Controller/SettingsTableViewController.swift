//
//  SettingsTableViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 14/01/2019.
//  Copyright © 2019 Tarek El Ghoul. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    
    var idUser : String?
    override func viewDidLoad() {
        super.viewDidLoad()

        logoImageView.layer.cornerRadius = 75.0
        logoImageView.clipsToBounds = true
        idUser = UserDefaults.standard.string(forKey: "idUser")
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        } else if(section == 1){
            return 1
        } else if(section == 2){
            return 1
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath == [0,0]){
            performSegue(withIdentifier: "toMyProducts", sender: nil)
        } else if(indexPath == [0,1]) {
            performSegue(withIdentifier: "toMyFav", sender: nil)
        } else if(indexPath == [1,0]) {
            performSegue(withIdentifier: "toMyProfile", sender: nil)
        } else if(indexPath == [2,0]){
            print("conditions")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toMyProducts"){
            if let destinationVC =  segue.destination as? ProfileSellerViewController {
                destinationVC.idUserSeller = self.idUser
            }
        }
    }


}
