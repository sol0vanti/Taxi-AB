//
//  RequestsViewController.swift
//  taxiApp
//
//  Created by Alex on 02.08.2023.
//

import UIKit
import Firebase

class RequestsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var table: UITableView!
    var requests: [Request]!
    var indexPath: IndexPath!

    override func viewDidLoad() {
        super.viewDidLoad()

        table.dataSource = self
        table.delegate = self
        getData()
        
    }
    
    func getData() {
        let db = Firestore.firestore()
        db.collection("drive-requests").getDocuments { snapshot, error in
            if error != nil {
                print(String(describing: error))
            } else {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        self.requests = snapshot.documents.map { d in
                            Request(id: d.documentID,
                                    userNickname: d["userNickname"] as? String ?? "",
                                    distanceJourney: d["distanceJourney"] as? Int ?? 0,
                                    distanceToCustomer: d["distanceToCustomer"] as? Int ?? 0,
                                    moneyPaid: d["moneyPaid"] as? Int ?? 0,
                                    from: d["from"] as? String ?? "",
                                    to: d["to"] as? String ?? "",
                                    userLongitude: d["userLongtitude"] as? Double ?? 0.00,
                                    userLatitude: d["userLatitude"] as? Double ?? 0.00,
                                    destinationLongitude: d["destinationLatitude"] as? Double ?? 0.00,
                                    destinationLatitude: d["destinationLongtitude"] as? Double ?? 0.00
                                    )
                        }
                        self.table.reloadData()
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if requests == nil {
            return 0
        } else {
            return requests.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var followButtonClicked: (() -> Void)?
        
        let request = requests[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RequestTableViewCell
        cell.distanceToCustomerLabel.text! += " " + "\(request.distanceToCustomer)km"
        cell.fromLabel.text = "From: " + "\(request.from)"
        cell.toLabel.text = "To: " + "\(request.to)"
        cell.journeyDistanceLabel.text! += " \(request.distanceJourney)km"
        cell.salaryLabel.text = "\(request.moneyPaid)₴"
        cell.nickname.text = request.userNickname
        cell.followButtonClicked = { [weak self] in
            self?.followButtonClicked(indexPath: indexPath)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func followButtonClicked(indexPath: IndexPath) {
        let request = requests[indexPath.row]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RequestMapViewController") as? RequestMapViewController
        vc!.userNickname = request.userNickname
        vc!.userLongitude = request.userLongitude
        vc!.userLatitude = request.userLatitude
        vc!.destinationLongitude = request.destinationLongitude
        vc!.destinationLatitude = request.destinationLatitude
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
