//
//  Parking.swift
//  ZenParkIn
//
//  Created by Amrita Srivastava on 7/18/16.
//  Copyright © 2016 ZenParkIn. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class Parking: NSObject, MKAnnotation {
    let title: String?
    let address: String
    let primeType: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, address: String, primeType: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.address = address
        self.primeType = primeType
        self.coordinate = coordinate
        
        super.init()
    }
    
    class func fromJSON(_ json: [JSONValue]) -> Parking? {
        // 1
        var title: String
        if let titleOrNil = json[8].string {
            title = titleOrNil
        } else {
            title = ""
        }
        let address = json[9].string
        let primeType = json[10].string
        
        // 2
        let latitude = (json[17][1]!.string! as NSString).doubleValue
        let longitude = (json[17][2]!.string! as NSString).doubleValue
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // 3
        return Parking(title: title, address: address!, primeType: primeType!, coordinate: coordinate)
    }

    var subtitle: String? {
        return address
    }
    
    // annotation callout info button opens this mapItem in Maps app
    func mapItem() -> MKMapItem {
        let addressDictionary = [String(CNPostalAddressStreetKey): self.subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        
        return mapItem
    }
    
    // pinColor for disciplines: Sculpture, Plaque, Mural, Monument, other
    func pinColor() -> UIColor  {
        switch title {
        case "Private"?:
            return UIColor.magenta
        case "Search Location"?:
            return UIColor.cyan
        default:
            return UIColor.blue
        }
    }

}

