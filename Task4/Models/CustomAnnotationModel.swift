//
//  CustomAnnotationModel.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import MapKit

final class CustomAnnotation: NSObject, MKAnnotation {
    let placeName: String
    let workTime: String
    let currency: String
    let cashIn: String
    let id: String
    let coordinate: CLLocationCoordinate2D
    
    init(placeName: String,
         workTime: String,
         currency: String,
         cashIn: String,
         id: String,
         coordinate: CLLocationCoordinate2D) {
        self.placeName = placeName
        self.workTime = workTime
        self.currency = currency
        self.cashIn = cashIn
        self.id = id
        self.coordinate = coordinate
    }
}
