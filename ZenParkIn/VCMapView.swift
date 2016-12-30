//
//  VCMapView.swift
//  ZenParkIn
//
//  Created by Amrita Srivastava on 7/18/16.
//  Copyright © 2016 ZenParkIn. All rights reserved.
//

import Foundation
import MapKit

extension ViewController: MKMapViewDelegate {
    
    // 1
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let annotation = annotation as? Parking {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            view.canShowCallout = true
            view.pinTintColor = annotation.pinColor()
            
            let smallSquare = CGSize(width: 60, height: 60)
            let button = UIButton(frame: CGRect(origin: CGPoint.zero, size: smallSquare))
            button.setBackgroundImage(UIImage(named: "Car"), for: UIControlState())
            //button.addTarget(self, action: #selector(self.getDirections), forControlEvents: .TouchUpInside)
            view.leftCalloutAccessoryView = button
            return view
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        print("Opening Maps")
        let location = view.annotation as! Parking
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }
 
}
