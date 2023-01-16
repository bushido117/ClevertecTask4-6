//
//  FilialModel.swift
//  Task4
//
//  Created by Вадим Сайко on 10.01.23.
//

struct FilialElement: Codable, Hashable, Coordinate {
    
    let id, sapID, installPlace: String
    let phoneNumber: String?
    let cityType, city, addressType, address, house: String
    let temporaryCityType, temporaryCity, bik, unp: String?
    let temporaryAddressType, temporaryAddress, temporaryHouse: String
    let additionalInfo, workTime: String
    let gpsX, gpsY, belCheckingAccountNumber, foreignCheckingAccountNumber: String
    let infoWeekend1Day, infoWeekend2Day, infoWeekend3Day, infoWeekend4Day: String
    let infoWeekend5Day, infoWeekend6Day, infoWeekend7Day, infoWeekend1Time: String
    let infoWeekend2Time, infoWeekend3Time, infoWeekend4Time, infoWeekend5Time: String
    let infoWeekend6Time, infoWeekend7Time: String
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
        case infoWeekend1Day = "info_weekend1_day"
        case infoWeekend2Day = "info_weekend2_day"
        case infoWeekend3Day = "info_weekend3_day"
        case infoWeekend4Day = "info_weekend4_day"
        case infoWeekend5Day = "info_weekend5_day"
        case infoWeekend6Day = "info_weekend6_day"
        case infoWeekend7Day = "info_weekend7_day"
        case infoWeekend1Time = "info_weekend1_time"
        case infoWeekend2Time = "info_weekend2_time"
        case infoWeekend3Time = "info_weekend3_time"
        case infoWeekend4Time = "info_weekend4_time"
        case infoWeekend5Time = "info_weekend5_time"
        case infoWeekend6Time = "info_weekend6_time"
        case infoWeekend7Time = "info_weekend7_time"
        case dopNumber = "dop_num"
        case filialNumber = "filial_num"
        case cbuNumber = "cbu_num"
        case otdNumber = "otd_num"
    }
}
