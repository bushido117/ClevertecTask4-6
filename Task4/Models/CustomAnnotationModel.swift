//
//  CustomAnnotationModel.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import MapKit
import UIKit

enum ElementType: Hashable {
    case atm
    case infobox
    case filial

    var typeLetter: String {
        switch self {
        case .atm:
            return "Б"
        case .infobox:
            return "И"
        case .filial:
            return "Ф"
        }
    }
}

final class CustomAnnotation: NSObject, MKAnnotation {
    
    let placeName: String
    let workTime: String
    var currency: String?
    var cashIn: String?
    var id: String
    var address: String?
    var phoneNumber: String?
    let coordinate: CLLocationCoordinate2D
    let type: ElementType

    init(placeName: String,
         workTime: String,
         currency: String?,
         cashIn: String?,
         id: String,
         coordinate: CLLocationCoordinate2D,
         type: ElementType) {
        self.placeName = placeName
        self.workTime = workTime
        self.currency = currency
        self.cashIn = cashIn
        self.id = id
        self.coordinate = coordinate
        self.type = type
    }
    
    init(placeName: String,
         workTime: String,
         address: String,
         phoneNumber: String,
         id: String,
         coordinate: CLLocationCoordinate2D,
         type: ElementType) {
        self.placeName = placeName
        self.workTime = workTime
        self.address = address
        self.phoneNumber = phoneNumber
        self.id = id
        self.coordinate = coordinate
        self.type = type
    }
}
