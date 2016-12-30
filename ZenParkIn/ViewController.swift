//
//  ViewController.swift
//  ZenParkIn
//
//  Created by Amrita Srivastava on 7/18/16.
//  Copyright © 2016 ZenParkIn. All rights reserved.
//

import UIKit
import MapKit

protocol HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark)
}

class ViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var parkings = [Parking]()
    let regionRadius: CLLocationDistance = 1000
    var locationManager = CLLocationManager()
    
    var resultSearchController:UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set initial location
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        mapView.delegate = self
        
        // show parking on map
        loadInitialData()
        mapView.addAnnotations(parkings)
        
        // search location
        searchLocation()
        //addBoundry(parkings)
        
    }
    
    func addBoundry(_ parkings: [Parking])
    {
        print("Inside addBoundry")
        var points = [CLLocationCoordinate2D]()
        for parkingData in parkings {
            points.append(parkingData.coordinate)
        }
        let polygon = MKPolygon(coordinates: &points, count: points.count)
        mapView.add(polygon)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.lightGray
            
            return polygonView
        
    }
    
    
    func searchLocation() {
        print("Inside searchLocation")
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = resultSearchController?.searchBar
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
    }

    func loadInitialData() {
        print("Inside loadInitialData")
        // 1
        let fileName = Bundle.main.path(forResource: "PublicParkingData", ofType: "json");
        var data: Data?
        do {
            data = try Data(contentsOf: URL(fileURLWithPath: fileName!), options: NSData.ReadingOptions(rawValue: 0))
        } catch _ {
            data = nil
        }
        
        // 2
        let jsonObject: Any!
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
        } catch _ {
            jsonObject = nil
        }
        
        // 3
        if let jsonObject = jsonObject as? [String: AnyObject],
            // 4
            let jsonData = JSONValue.fromObject(jsonObject as AnyObject)?["data"]?.array {
            for parkingJSON in jsonData {
                if let parkingJSON = parkingJSON.array,
                    // 5
                    let parking = Parking.fromJSON(parkingJSON) {
                    parkings.append(parking)
                }
            }
        }
    }
    
    // location manager to authorize user location for Maps app
    func checkLocationAuthorizationStatus() {
        print("Inside checkLocationAuthorizationStatus")
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorizationStatus()
    }

}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.006, 0.006)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}

extension ViewController: HandleMapSearch {
    func dropPinZoomIn(_ placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        //mapView.removeAnnotations(mapView.annotations)
        
        let span = MKCoordinateSpanMake(0.006, 0.006)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
        let searchParking = Parking(title: "Search Location",
                                    address: placemark.title!,
                                    primeType: "PPA",
                                    coordinate: CLLocationCoordinate2D(
                                        latitude:  placemark.coordinate.latitude,
                                        longitude: placemark.coordinate.longitude))
        self.mapView.addAnnotation(searchParking)
    }
}
