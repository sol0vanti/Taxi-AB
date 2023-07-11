import UIKit

class ShopingDetailViewController: UIViewController {
    @IBOutlet var totalPriceLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    private let taxiTarif = 47
    public var distance: Int = 0
    private var totalPrice: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateDistance()
        calculatePrice()
    }
    
    func calculatePrice() {
        totalPrice = distance * taxiTarif
        totalPriceLabel.text = "\(totalPrice ?? 0)₴"
    }
    
    func calculateDistance() {
        distance = distance/1000
        distanceLabel.text = "\(distance)km"
    }
}
