//
//  SearchViewController.swift
//  MiniProjetIos
//
//  Created by Tarek El Ghoul on 20/12/2018.
//  Copyright © 2018 Tarek El Ghoul. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import AlamofireImage
import SwiftyJSON

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
   
    
    let baseUrl = "http://192.168.0.111:3000/"
    var productsArray : NSArray = []
    var currentArray = [Product]()
    var products = [Product]()
    
    @IBOutlet weak var searchBar: UITableView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        getData()

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("la taille du tableau recherche est: ",currentArray.count)
        return currentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath)
        
        let content = cell.viewWithTag(0)
        let imageProduct = content?.viewWithTag(1) as! UIImageView
        let nameProduct = content?.viewWithTag(2) as! UILabel
        
        let urlImage = currentArray[indexPath.row].image
        imageProduct.af_setImage(withURL: URL(string: urlImage)!)
        nameProduct.text = currentArray[indexPath.row].name
        
        return cell
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            currentArray = products
            tableView.reloadData()
            return
        }
        currentArray =  products.filter({ product -> Bool in
            return product.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    
    func getData() {
        Alamofire.request(self.baseUrl + "getproducts").responseJSON { response in
            self.productsArray = response.result.value as! NSArray
            let productJson = JSON(self.productsArray)
            for index in 0...self.productsArray.count - 1{
                self.products.append(Product.init(id: productJson[index]["Id"].intValue, name: productJson[index]["Name"].stringValue, image: productJson[index]["first_image_path"].stringValue))
                
                self.currentArray = self.products

                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toDetails", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = sender as? NSIndexPath
        
        let product = currentArray[index!.item]
        
        let productId = product.id
        
        
        if segue.identifier == "toDetails"{
            
            
            if let destinationVC =  segue.destination as? DetailsViewController{
                
                destinationVC.id = productId
            }
        }
        
    }
  
}

class Product {
    let id: Int
    let name: String
    let image: String
    
    init(id: Int, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
}
