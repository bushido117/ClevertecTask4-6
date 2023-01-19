//
//  BelarusbankElement.swift
//  Task4
//
//  Created by Вадим Сайко on 16.01.23.
//

import Foundation

protocol BelarusbankElement: Hashable {
    var gpsX: String { get }
    var gpsY: String { get }
    var workTime: String { get }
    var installPlace: String { get }
    var currency: String? { get }
    var cashIn: String? { get }
    var phoneNumber: String? { get }
    var cityType: String { get }
    var city: String { get }
    var addressType: String { get }
    var address: String { get }
    var house: String { get }
}

extension BelarusbankElement {
    var currency: String? { return nil }
    var cashIn: String? { return nil }
    var phoneNumber: String? { return nil }
//    var workTime: String? { return nil }
}
