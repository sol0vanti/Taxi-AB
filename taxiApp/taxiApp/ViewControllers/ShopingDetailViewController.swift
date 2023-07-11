import UIKit

class ShopingDetailViewController: ViewController {
    @IBOutlet var sectionDetailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let economyTarifButton = TarifButtonWithImage(frame: CGRect(x: 0, y: 0, width: 220, height: 55))
        view.addSubview(economyTarifButton)
        economyTarifButton.center = view.center
        economyTarifButton.configure(with: TarifButtonWithImageViewModel(tarifCost: "4.2", tarifType: "Economy", tarifImage: "$"))
        
        let tarifButton = TarifButtonWithImage(frame: CGRect(x: 0, y: 40, width: 220, height: 55))
        view.addSubview(tarifButton)
        tarifButton.center = view.center
        tarifButton.configure(with: TarifButtonWithImageViewModel(tarifCost: "6.7", tarifType: "Middle Class", tarifImage: "$$"))
    }
}
