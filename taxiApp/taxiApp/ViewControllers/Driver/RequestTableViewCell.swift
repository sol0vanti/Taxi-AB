//
//  RequestTableViewCell.swift
//  taxiApp
//
//  Created by Alex on 02.08.2023.
//

import UIKit

class RequestTableViewCell: UITableViewCell {
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var journeyDistanceLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var distanceToCustomerLabel: UILabel!
    @IBOutlet weak var salaryLabel: UILabel!
    @IBOutlet weak var pickButton: UIButton!
}
