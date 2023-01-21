//
//  FilialModel.swift
//  Task4
//
//  Created by Вадим Сайко on 10.01.23.
//

import CoreData
import MapKit

struct FilialElement: Codable, Hashable, BelarusbankElement {
    
    let id, sapID, installPlace: String
    let phoneNumber: String?
    let cityType, city, addressType, address, house: String
    let temporaryCityType, temporaryCity, bik, unp: String?
    let temporaryAddressType, temporaryAddress, temporaryHouse: String
    let additionalInfo, workTime: String
    let gpsX, gpsY, belCheckingAccountNumber, foreignCheckingAccountNumber: String
    let filialNumber, cbuNumber, otdNumber, dopNumber: String

    enum CodingKeys: String, CodingKey {
        case id = "filial_id"
        case sapID = "sap_id"
        case installPlace = "filial_name"
        case cityType = "name_type"
        case city = "name"
        case addressType = "street_type"
        case address = "street"
        case house = "home_number"
        case temporaryCityType = "name_type_prev"
        case temporaryCity = "name_prev"
        case temporaryAddressType = "street_type_prev"
        case temporaryAddress = "street_prev"
        case temporaryHouse = "home_number_prev"
        case additionalInfo = "info_text"
        case workTime = "info_worktime"
        case bik = "info_bank_bik"
        case unp = "info_bank_unp"
        case gpsX = "GPS_X"
        case gpsY = "GPS_Y"
        case belCheckingAccountNumber = "bel_number_schet"
        case foreignCheckingAccountNumber = "foreign_number_schet"
        case phoneNumber = "phone_info"
        case dopNumber = "dop_num"
        case filialNumber = "filial_num"
        case cbuNumber = "cbu_num"
        case otdNumber = "otd_num"
    }
}

extension FilialElement {
    func createAnnotation() -> CustomAnnotation {
        let filialFullAdress = self.cityType + self.city + self.addressType + self.address + self.house
        let coordinates = CLLocationCoordinate2D(
            latitude: (Double(self.gpsX) ?? 0) as CLLocationDegrees,
            longitude: (Double(self.gpsY) ?? 0) as CLLocationDegrees)
        let annotation = CustomAnnotation(
            placeName: self.installPlace,
            workTime: self.workTime,
            address: filialFullAdress,
            phoneNumber: self.phoneNumber ?? "",
            id: self.id,
            coordinate: coordinates,
            type: .filial)
        return annotation
    }
}
