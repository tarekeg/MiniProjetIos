import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import CoreData
import Cosmos

class DetailsDirectSellViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var images: [UIImage] = []
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var id : Int?
    var product : NSArray = []
    var boucle : Bool = true
    let BaseUrl = Common.Global.LOCAL + "/"
    var similarArray : NSArray = []
    var rateAvgArray : NSArray = []
    var idUser : String?


    
    
    @IBOutlet weak var addToFav: UIBarButtonItem!
    @IBOutlet weak var rateCosmos: CosmosView!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var sellerImageView: UIImageView!
    
    @IBOutlet weak var similarCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var buttonOutlet: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subCategoryLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var productDescriptionTextView: UITextView!
    
//    
//    override func viewWillAppear(_ animated: Bool) {
//        getData()
//    }
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //getDate()
        getImages()
        getData()
        getSellerId()

        rateCosmos.settings.updateOnTouch = false
        rateCosmos.settings.fillMode = .precise
        sellerImageView.layer.cornerRadius = 22.5
        sellerImageView.clipsToBounds = true
        buttonOutlet.layer.cornerRadius = 20.0
        buttonOutlet.clipsToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(nameSellerTapped))
        sellerNameLabel.isUserInteractionEnabled = true
        sellerImageView.isUserInteractionEnabled = true
        sellerNameLabel.addGestureRecognizer(tap)
        sellerImageView.addGestureRecognizer(tap)
        
        
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.similarCollectionView){
            return similarArray.count
        }
        print(images.count)
        pageControl.numberOfPages = images.count
        pageControl.isHidden = !(images.count > 1)
        return images.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (collectionView == self.similarCollectionView){
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "similarProductCell", for: indexPath)
            let similarProduct  = similarArray[indexPath.item] as! Dictionary<String,Any>
            let imageUrl = similarProduct["first_image_path"] as! String
            
            let image = cell.viewWithTag(2) as! UIImageView
            
            image.af_setImage(withURL: URL(string: imageUrl)!)
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        
        let image = cell.viewWithTag(1) as! UIImageView
        
        image.image = images[indexPath.item]
        
        return cell
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(collectionView == self.similarCollectionView){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
            let similarProduct  = similarArray[indexPath.item] as! Dictionary<String,Any>
            vc.id = similarProduct["Id"] as? Int
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: self.collectionView.contentOffset, size: self.collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = self.collectionView.indexPathForItem(at: visiblePoint) {
            self.pageControl.currentPage = visibleIndexPath.row
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    
    
    
    
  
    

    
    
    
    func getData(){
        
        Alamofire.request(BaseUrl + "getproduct/" + String(id!)).responseJSON{
            response in
            self.buttonOutlet.setTitle("Contacter Vendeur", for: .normal)
            self.product = response.result.value as! NSArray
            let singleProduct = self.product[0] as! Dictionary<String,Any>
            let id_Seller = singleProduct["Id_user"] as! String
            if(id_Seller == UserDefaults.standard.string(forKey: "idUser")){
                self.buttonOutlet.setTitle("Modifier État Produit", for: .normal)
                self.addToFav.isEnabled = false
            }
            Alamofire.request(Common.Global.LOCAL + "/getaveragevalue/" + id_Seller).responseJSON(completionHandler: { responseAvg in
                
                self.rateAvgArray = responseAvg.result.value as! NSArray
                
                if let rate = self.rateAvgArray[0] as? Dictionary<String,Any> {
                    
                    if let rateAvg =  rate["AverageValue"] as? Double {
                        
                        self.rateCosmos.rating = rateAvg
                        
                    } else {
                        
                        self.rateCosmos.rating = 0.0
                        
                    }
                    
                }
                
            })
            Alamofire.request(Common.Global.LOCAL  + "/getuser/" + id_Seller).responseJSON(completionHandler: { response in
                let responseJson = JSON(response.result.value)
                let pathPicture = responseJson[0]["profile_image_path"].stringValue
                let nameSeller = responseJson[0]["FirstName"].stringValue + " " + responseJson[0]["LastName"].stringValue
                self.sellerImageView.af_setImage(withURL: URL(string: pathPicture)!)
                self.sellerNameLabel.text = nameSeller
            })
            self.nameLabel.text = singleProduct["Name"] as? String
            self.title = singleProduct["Name"] as? String
            self.subCategoryLabel.text = (singleProduct["Sub_category"] as! String)
            let url = Common.Global.LOCAL + "/getsimilarproduct/" + self.subCategoryLabel.text! + "/" + String(self.id!)
            let urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            print(urlString!)
            Alamofire.request(urlString!, method: .get).responseJSON{ response in
                self.similarArray = response.result.value as! NSArray
                print("le contenu du tableau est :",self.similarArray)
                self.similarCollectionView.reloadData()
            }
            self.productDescriptionTextView.text = singleProduct["Description"] as? String
                self.priceLabel.text = String(singleProduct["PrixFixe"] as! Double) + " DT"
            
        }
        
        
    }
    
    @IBAction func validateTapped(_ sender: Any) {
        
        
        
        Alamofire.request(BaseUrl + "getproduct/" + String(id!)).responseJSON{
            response in
            self.product = response.result.value as! NSArray
            let singleProduct = self.product[0] as! Dictionary<String,Any>
                
                let userid = singleProduct["Id_user"] as! String
                
                Alamofire.request(self.BaseUrl + "getphone/" + userid).responseJSON{ response in
                    let resultJson = JSON(response.result.value)
                    let phoneNumber = resultJson[0]["PhoneNumber"].stringValue
                    
                    let alert = UIAlertController(title: "Contacter", message: "", preferredStyle: .alert)
                    
                    let action = UIAlertAction(title: "Appeler", style: .default, handler: { (UIAlertAction) in
                        guard let number = URL(string: "tel://" + phoneNumber) else { return }
                        UIApplication.shared.open(number)
                    })
                    let actionComentaire = UIAlertAction(title: "Commentaire", style: .default, handler: { (UIAlertAction) in
                        self.performSegue(withIdentifier: "toCommentary", sender: nil)
                    })
                    let actionCancel = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
                    
                    alert.addAction(action)
                    alert.addAction(actionComentaire)
                    alert.addAction(actionCancel)
                    
                    self.present(alert , animated: true, completion: nil)
                    
                }
                
                
            }
             
            }
            
    
    func getImages(){
        Alamofire.request(Common.Global.LOCAL + "/getimages/" + String(id!), method: .get).responseJSON { response in
         let jsonResult = JSON(response.result.value!)
            for i in 0...jsonResult.count - 1{
                Alamofire.request(jsonResult[i]["image_url"].stringValue).responseImage{response in
                    if let image = response.result.value {
                        self.images.append(image)
                        self.collectionView.reloadData()
                    }
                    
                }
                
            }
        }
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCommentary" {
            if let destinationVC =  segue.destination as? UINavigationController {
                if let childVC = destinationVC.topViewController as? CommentaryViewController {
                    childVC.id = id
                }
            }
        }
        if segue.identifier == "toProfileSeller" {
            
            if let destinationVC =  segue.destination as? ProfileSellerViewController {
                destinationVC.idUserSeller = self.idUser
                destinationVC.id = id
            }
        }
    }

    func getSellerId(){
        Alamofire.request(Common.Global.LOCAL + "/getproduct/" + String(self.id!)).responseJSON { response in
            let responseJson = JSON(response.result.value)
            self.idUser = responseJson[0]["Id_user"].stringValue
        }
        
    }
    
    

    
    func convert (string: String) -> Double {
        let numberFormatter = NumberFormatter()
        numberFormatter.decimalSeparator = "."
        if let result =  numberFormatter.number(from: string) {
            return Double(truncating: result)
        } else {
            numberFormatter.decimalSeparator = ","
            if let result = numberFormatter.number(from: string) {
                return Double(truncating: result)
            }
        }
        return 0
}
    @objc func nameSellerTapped(){
        performSegue(withIdentifier: "toProfileSeller", sender: nil)
    }
 


}
