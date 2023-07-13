import UIKit

class WhatsNewViewController: UIViewController {
    @IBOutlet var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func continueButtonClicked(_ sender: UIButton) {
        let ac = UIAlertController(title: "Chose User", message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "Taxi Driver", style: .default) { _ in
            let driverViewController = self.storyboard?.instantiateViewController(withIdentifier: "TaxiDriverViewController") as? TaxiDriverViewController
            self.navigationController?.pushViewController(driverViewController!, animated: true)
        })
        ac.addAction(UIAlertAction(title: "Customer", style: .default) { _ in
            let customerViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
            self.navigationController?.pushViewController(customerViewController!, animated: true)
        })
        
        present(ac, animated: true)
    }
}
