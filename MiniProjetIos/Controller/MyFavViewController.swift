//
//  MyFavViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 14/01/2019.
//  Copyright © 2019 Tarek El Ghoul. All rights reserved.
//

import UIKit
import CoreData
import AlamofireImage

class MyFavViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var productArray: [NSManagedObject] = []

  
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        getCoreData()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = productArray[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "FavProduct", for: indexPath)
        let content = cell.viewWithTag(0)
        
        let productImageView = content?.viewWithTag(1) as! UIImageView
        let productNameLabel = content?.viewWithTag(2) as! UILabel
        let productSellType = content?.viewWithTag(3)  as! UILabel
        
        productNameLabel.text = product.value(forKey: "name") as? String
        let productImagePath = product.value(forKey: "firstImagePath") as! String
        productImageView.af_setImage(withURL: URL(string: productImagePath)!)
        
        if(product.value(forKey: "typevente") as! Int == 1){
            productSellType.text = "Achat Immédiat"
        } else {
            productSellType.text = "Enchère"
        }
        
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = productArray[indexPath.row]
        if(product.value(forKey: "typevente") as! Int == 1){
            performSegue(withIdentifier: "toDirectSell", sender: indexPath)
        } else {
            performSegue(withIdentifier: "toDetails", sender: indexPath)
        }

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = sender as? NSIndexPath
        
        let product = productArray[index!.item]
        
        let productId = product.value(forKey: "id") as! Int
        
        
        if segue.identifier == "toDetails"{
            
            
            if let destinationVC =  segue.destination as? DetailsViewController{
                
                destinationVC.id = productId
            }
            
        }
        if segue.identifier == "toDirectSell"{
            
            
            if let destinationVC =  segue.destination as? DetailsDirectSellViewController{
                
                destinationVC.id = productId
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let productToDelete =  productArray[indexPath.row]
            context.delete(productToDelete)
            
            do{
                try context.save()
                productArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                //tableView.reloadData()
            }catch{
                print("Error")
            }
            
            
            
        }
    }
    
    
    
    func getCoreData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSManagedObject> (entityName: "Produit")
        
        do {
            productArray = try context.fetch(request)
            tableView.reloadData()
        } catch  {
            print ("Error!")
        }
    }
    

    
}
