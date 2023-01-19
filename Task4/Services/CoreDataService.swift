//
//  CoreDataService.swift
//  Task4
//
//  Created by Вадим Сайко on 18.01.23.
//

import Foundation
import CoreData
import UIKit

class CoreDataService {
    
    static let shared = CoreDataService()
    private init() {}
    
    private let container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    private let atmsFetchRequest = NSFetchRequest<ATMElementEntity>(entityName: "ATMElementEntity")
    private let infoboxesFetchRequest = NSFetchRequest<InfoboxElementEntity>(entityName: "InfoboxElementEntity")
    private let filialsFetchRequest = NSFetchRequest<FilialElementEntity>(entityName: "FilialElementEntity")
    
    func saveATMs(atms: [ATMElement]) {
        container?.performBackgroundTask({ [weak self] context in
            self?.deleteATMsFromCoreData(context: context)
            self?.saveATMsToCoreData(atms: atms, context: context)
        })
    }
    
    func saveInfoboxes(infoboxes: [InfoboxElement]) {
        container?.performBackgroundTask({ [weak self] context in
            self?.deleteInfoboxesFromCoreData(context: context)
            self?.saveInfoboxessToCoreData(infoboxes: infoboxes, context: context)
        })
    }
    
    func saveFilials(filials: [FilialElement]) {
        container?.performBackgroundTask({ [weak self] context in
            self?.deleteFilialsFromCoreData(context: context)
            self?.saveFilialsToCoreData(filials: filials, context: context)
        })
    }
    
    func readATMs() -> [ATMElementEntity] {
        do {
            guard let atms = try (container?.viewContext.fetch(atmsFetchRequest)) else { return [] }
            return atms
        } catch {
            print("Reading error")
            container?.viewContext.rollback()
            return []
        }
    }
    
    func readInfoboxes() -> [InfoboxElementEntity] {
        do {
            guard let infoboxes = try (container?.viewContext.fetch(infoboxesFetchRequest)) else { return [] }
            return infoboxes
        } catch {
            print("Reading error")
            container?.viewContext.rollback()
            return []
        }
    }
    
    func readFilials() -> [FilialElementEntity] {
        do {
            guard let filials = try (container?.viewContext.fetch(filialsFetchRequest)) else { return [] }
            return filials
        } catch {
            print("Reading error")
            container?.viewContext.rollback()
            return []
        }
    }
    
    private func saveATMsToCoreData(atms: [ATMElement], context: NSManagedObjectContext) {
        context.perform {
            for atm in atms {
                let atmEntity = ATMElementEntity(context: context)
                atmEntity.id = atm.id
                atmEntity.area = atm.area
                atmEntity.cityType = atm.cityType
                atmEntity.city = atm.city
                atmEntity.addressType = atm.addressType
                atmEntity.address = atm.address
                atmEntity.house = atm.house
                atmEntity.cashIn = atm.cashIn
                atmEntity.installPlace = atm.installPlace
                atmEntity.workTime = atm.workTime
                atmEntity.currency = atm.currency
                atmEntity.gpsX = atm.gpsX
                atmEntity.gpsY = atm.gpsY
                atmEntity.installPlaceFull = atm.installPlaceFull
                atmEntity.workTimeFull = atm.workTimeFull
                atmEntity.atmType = atm.atmType
                atmEntity.atmError = atm.atmError
                atmEntity.atmPrinter = atm.atmPrinter
            }
            do {
                try context.save()
            } catch {
                print("Saving error")
            }
        }
    }
    
    private func saveInfoboxessToCoreData(infoboxes: [InfoboxElement], context: NSManagedObjectContext) {
        context.perform {
            for infobox in infoboxes {
                let infoboxEntity = InfoboxElementEntity(context: context)
                infoboxEntity.id = String(infobox.id)
                infoboxEntity.area = infobox.area
                infoboxEntity.cityType = infobox.cityType
                infoboxEntity.city = infobox.city
                infoboxEntity.addressType = infobox.addressType
                infoboxEntity.address = infobox.address
                infoboxEntity.house = infobox.house
                infoboxEntity.locationNameDescription = infobox.locationNameDescription
                infoboxEntity.installPlace = infobox.installPlace
                infoboxEntity.currency = infobox.currency
                infoboxEntity.cashIn = infobox.cashIn
                infoboxEntity.workTime = infobox.workTime
                infoboxEntity.timeLong = infobox.timeLong
                infoboxEntity.gpsX = infobox.gpsX
                infoboxEntity.gpsY = infobox.gpsY
                infoboxEntity.infType = infobox.infType
                infoboxEntity.cashInError = infobox.cashInError
                infoboxEntity.infStatus = infobox.infStatus
                infoboxEntity.typeCashIn = infobox.typeCashIn
                infoboxEntity.infPrinter = infobox.infPrinter
                infoboxEntity.regionPayment = infobox.regionPayment
                infoboxEntity.rechargePayment = infobox.rechargePayment
            }
            do {
                try context.save()
            } catch {
                print("Saving error")
            }
        }
    }
    
    private func saveFilialsToCoreData(filials: [FilialElement], context: NSManagedObjectContext) {
        context.perform {
            for filial in filials {
                let filialEntity = FilialElementEntity(context: context)
                filialEntity.id = filial.id
                filialEntity.sapID = filial.sapID
                filialEntity.installPlace = filial.installPlace
                filialEntity.phoneNumber = filial.phoneNumber
                filialEntity.cityType = filial.cityType
                filialEntity.city = filial.city
                filialEntity.addressType = filial.addressType
                filialEntity.address = filial.address
                filialEntity.house = filial.house
                filialEntity.temporaryCityType = filial.temporaryCityType
                filialEntity.temporaryCity = filial.temporaryCity
                filialEntity.bik = filial.bik
                filialEntity.unp = filial.unp
                filialEntity.temporaryAddressType = filial.temporaryAddressType
                filialEntity.temporaryAddress = filial.temporaryAddress
                filialEntity.temporaryHouse = filial.temporaryHouse
                filialEntity.additionalInfo = filial.additionalInfo
                filialEntity.workTime = filial.workTime
                filialEntity.gpsX = filial.gpsX
                filialEntity.gpsY = filial.gpsY
                filialEntity.belCheckingAccountNumber = filial.belCheckingAccountNumber
                filialEntity.foreignCheckingAccountNumber = filial.foreignCheckingAccountNumber
                filialEntity.filialNumber = filial.filialNumber
                filialEntity.cbuNumber = filial.cbuNumber
                filialEntity.otdNumber = filial.otdNumber
                filialEntity.dopNumber = filial.dopNumber
            }
            do {
                try context.save()
            } catch {
                print("Saving error")
            }
        }
    }
    
    private func deleteATMsFromCoreData(context: NSManagedObjectContext) {
        do {
            let objects = try context.fetch(atmsFetchRequest)
            _ = objects.map({context.delete($0)})
            try context.save()
        } catch {
            print("Deleting error")
        }
    }
    
    private func deleteInfoboxesFromCoreData(context: NSManagedObjectContext) {
        do {
            let objects = try context.fetch(infoboxesFetchRequest)
            _ = objects.map({context.delete($0)})
            try context.save()
        } catch {
            print("Deleting error")
        }
    }
    
    private func deleteFilialsFromCoreData(context: NSManagedObjectContext) {
        do {
            let objects = try context.fetch(filialsFetchRequest)
            _ = objects.map({context.delete($0)})
            try context.save()
        } catch {
            print("Deleting error")
        }
    }
}
