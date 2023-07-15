import UIKit
import Firebase
import FirebaseFirestore

class ShopingDetailViewController: UIViewController {
    @IBOutlet var timeInfoButton: UIButton!
    @IBOutlet var requestRideButton: UIButton!
    @IBOutlet var driverCommentTextField: UITextField!
    @IBOutlet var tippingSlider: UISlider!
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var errorLabel: UILabel!
    
    private var taxiTarif = 42
    public var distance: Int = 0
    public var distanceToDriver: Int = 0
    private var totalPrice: Int?
    private var additionPrice: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.systemPink

        calculateDistance()
        calculatePrice()
        setUpTippingSlider()
        calculateAdditionalPrice()
    }
    
    func calculateDistance() {
        distance = distance/1000
        distanceToDriver = distanceToDriver/1000
        distanceLabel.text = "\(distance)km"
    }
    
    func calculatePrice() {
        totalPrice = (distance * taxiTarif)
    }
    
    func setUpTippingSlider() {
        tippingSlider.value = Float(totalPrice!)
        tippingSlider.minimumValue = Float(totalPrice!) * 0.2
        tippingSlider.maximumValue = Float(totalPrice!) / 1.5
    }
    
    func calculateAdditionalPrice() {
        additionPrice = Int(tippingSlider.value) + totalPrice!
        totalPriceLabel.text = "\(additionPrice!)₴"
    }
    
    @IBAction func tippingSliderHasChanged(_ sender: UISlider) {
        calculateAdditionalPrice()
    }
    @IBAction func requestRideButtonClicked(_ sender: UIButton) {
        if  driverCommentTextField.text!.count < 2 {
            driverCommentTextField.layer.borderColor = UIColor.systemPink.cgColor
            driverCommentTextField.layer.borderWidth = 1.5
            errorLabel.isHidden = false
        } else {
            let db = Firestore.firestore()
            db.collection("drive-requests").addDocument(data: [
                "Comment-for-a-driver": driverCommentTextField.text!,
                "Distance-journey": distance,
                "Distance-to-driver": distanceToDriver,
                "Money-paid": Int(tippingSlider.value)
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
        let ac = UIAlertController(title: "Attend time info", message: "Your current distance from the taxi driver is \(distanceToDriver)km.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
