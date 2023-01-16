//
//  DetailsModel.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import Foundation

enum CellsNameForATMAndInfobox: String, CaseIterable {
    case id = "ID"
    case area = "Область"
    case city = "Населенный пункт"
    case address = "Адрес"
    case installPlace = "Место установки"
    case workTime = "Время работы"
    case coordinates = "Географические координаты"
    case workTimeFull = "Подробное время работы"
    case type = "Тип"
    case error = "Исправность"
    case currency = "Доступная валюта"
    case cashIn = "Прием наличных"
    case printer = "Наличие принтера"
}

enum CellsNameForFilial: String, CaseIterable {
    case id = "ID"
    case sapID = "SAP ID"
    case filialNumber = "Номер филиала структурного подразделения"
    case cbuNumber = "Номер ЦБУ структурного подразделения"
    case city = "Населенный пункт"
    case address = "Адрес"
    case installPlace = "Место установки"
    case workTimeFull = "Подробное время работы"
    case coordinates = "Географические координаты"
    case phoneNumber = "Номер телефона"
    case belCheckingAccountNumber = "Номер рассчетного счета в белорусских рублях"
    case foreignCheckingAccountNumber = "Номер рассчетного счета в иностранной валюте"
    case additionalInfo = "Дополнительная информация"
}
