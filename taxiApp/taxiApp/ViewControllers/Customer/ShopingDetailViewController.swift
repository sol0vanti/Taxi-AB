import UIKit
import CoreLocation
import Firebase
import FirebaseFirestore

class ShopingDetailViewController: UIViewController {
    @IBOutlet var tip: UILabel!
    @IBOutlet var billAmount: UILabel!
    @IBOutlet var timeInfoButton: UIButton!
    @IBOutlet var requestRideButton: UIButton!
    @IBOutlet var userNickname: UITextField!
    @IBOutlet var tippingSlider: UISlider!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var errorLabel: UILabel!
    
    private var taxiTarif = 47
    public var distance: Int = 0
    public var distanceToCustomer: Int = 0
    private var price: Int?
    private var totalPrice: Int?
    private var additionPrice: Int?
    public var from: String?
    public var to: String?
    public var userCoordinates: CLLocationCoordinate2D?
    public var destinationCoordinates: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.systemPink
        
        title = "Shoping Detail"

        calculateDistance()
        calculatePrice()
        setUpTippingSlider()
        calculateAdditionalPrice()
    }
    
    func calculateDistance() {
        distance = distance/1000
        distanceToCustomer = distanceToCustomer/1000
        distanceLabel.text = "\(distance)km"
    }
    
    func calculatePrice() {
        price = (distance * taxiTarif)
        billAmount.text = "\(price!)₴"
    }
    
    func setUpTippingSlider() {
        tippingSlider.value = Float(price!)
        tippingSlider.minimumValue = Float(price!) * 0.1
        tippingSlider.maximumValue = Float(price!) * 0.2
    }
    
    func calculateAdditionalPrice() {
        additionPrice = Int(tippingSlider.value)
        tip.text = "\(additionPrice!)₴"
        
        totalPrice = additionPrice! + price!
        totalPriceLabel.text = "\(totalPrice!)₴"
    }
    
    @IBAction func tippingSliderHasChanged(_ sender: UISlider) {
        calculateAdditionalPrice()
    }
    @IBAction func requestRideButtonClicked(_ sender: UIButton) {
        if  userNickname.text!.count < 2 {
            userNickname.layer.borderColor = UIColor.systemPink.cgColor
            userNickname.layer.borderWidth = 1.5
            errorLabel.isHidden = false
        } else {
            let database = Firestore.firestore()
            database.collection("drive-requests").addDocument(data: [
                "userNickname": userNickname.text!,
                "distanceJourney": distance,
                "distanceToCustomer": distanceToCustomer,
                "moneyPaid": Int(tippingSlider.value),
                "from": from!,
                "to": to!,
                "userLongitude": userCoordinates?.longitude as Any,
                "userLatitude": userCoordinates?.latitude as Any,
                "destinationLongitude":destinationCoordinates?.longitude as Any,
                "destinationLatitude": destinationCoordinates?.latitude as Any
            ]) { (error) in
                if error != nil {
                    print(String(describing: error))
                } else {
                    let ac = UIAlertController(title: "Success", message: "Your ride was successfuly requested. We will let drivers see your request", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                    self.present(ac, animated: true)
                }
            }
        }
    }
    
    @IBAction func timeInfoButtonClicked(_ sender: UIButton) {
        let ac = UIAlertController(title: "Attend time info", message: "Your current distance from the taxi driver is \(distanceToCustomer)km.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
