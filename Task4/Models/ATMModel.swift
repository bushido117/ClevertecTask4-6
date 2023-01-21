//
//  ATMModel.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

//import CoreData
import MapKit

struct ATMElement: Codable, Hashable, BelarusbankElement {
    
    let id, area, cityType, city: String
    let addressType, address, house, installPlace: String
    let currency, cashIn: String?
    let workTime: String
    let gpsX, gpsY, installPlaceFull: String
    let workTimeFull, atmType, atmError, atmPrinter: String

    enum CodingKeys: String, CodingKey {
        case id, area
        case cityType = "city_type"
        case city
        case addressType = "address_type"
        case address, house
        case installPlace = "install_place"
        case workTime = "work_time"
        case gpsX = "gps_x"
        case gpsY = "gps_y"
        case installPlaceFull = "install_place_full"
        case workTimeFull = "work_time_full"
        case atmType = "ATM_type"
        case atmError = "ATM_error"
        case currency
        case cashIn = "cash_in"
        case atmPrinter = "ATM_printer"
    }
}

extension ATMElement {
    func createAnnotation() -> CustomAnnotation {
        let coordinates = CLLocationCoordinate2D(
            latitude: (Double(self.gpsX) ?? 0) as CLLocationDegrees,
            longitude: (Double(self.gpsY) ?? 0) as CLLocationDegrees)
        let annotation = CustomAnnotation(
            placeName: self.installPlace,
            workTime: self.workTime,
            currency: self.currency,
            cashIn: self.cashIn,
            id: self.id,
            coordinate: coordinates,
            type: .atm)
        return annotation
    }
}
