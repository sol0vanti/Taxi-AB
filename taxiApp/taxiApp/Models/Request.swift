//
//  Request.swift
//  taxiApp
//
//  Created by Alex on 02.08.2023.
//

import Foundation

struct Request: Identifiable {
    var id: String
    var userNickname: String
    var distanceJourney: Int
    var distanceToCustomer: Int
    var moneyPaid: Int
    var from: String
    var to: String
}
