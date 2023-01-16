//
//  InfoboxModel.swift
//  Task4
//
//  Created by Вадим Сайко on 10.01.23.
//

struct InfoboxElement: Codable, Hashable, Coordinate {
    
    let id: Int
    let area, cityType, city, addressType: String
    let currency, cashIn: String?
    let address, house, locationNameDescription, installPlace: String
    let workTime, timeLong, gpsX, gpsY: String
    let infType, cashInError, infStatus: String
    let typeCashIn, infPrinter, regionPayment, rechargePayment: String

    enum CodingKeys: String, CodingKey {
        case id = "info_id"
        case area
        case cityType = "city_type"
        case city
        case addressType = "address_type"
        case address, house
        case installPlace = "install_place"
        case locationNameDescription = "location_name_desc"
        case workTime = "work_time"
        case timeLong = "time_long"
        case gpsX = "gps_x"
        case gpsY = "gps_y"
        case currency
        case infType = "inf_type"
        case cashIn = "cash_in_exist"
        case cashInError = "cash_in"
        case typeCashIn = "type_cash_in"
        case infPrinter = "inf_printer"
        case regionPayment = "region_platej"
        case rechargePayment = "popolnenie_platej"
        case infStatus = "inf_status"
    }
}
