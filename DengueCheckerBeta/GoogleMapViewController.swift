//
//  GoogleMapViewController.swift
//  placeAutocomplete
//
//  Created by Indresh Arora on 06/11/18
//  Modified by Jun Jia on 04/03/20
//  Copyright © 2018 Indresh Arora. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
import SwiftSoup

class GoogleMapViewController: UIViewController {
    
    // create global marker (only marker to be drawn on map)
    var onlyMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    
    // can be commented out
    func locateWithLong(lon: String, andLatitude lat: String, andAddress address: String) {
        DispatchQueue.main.async {
            
            let latDouble = Double(lat)
            let lonDouble = Double(lon)
            self.mapView.clear()
            let position = CLLocationCoordinate2D(latitude: latDouble ?? 20.0, longitude: lonDouble ?? 10.0)
            let marker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: latDouble ?? 20.0, longitude: lonDouble ?? 10.0, zoom: 14)
            self.mapView.camera = camera
            self.searchButton.setTitle(address, for: .normal)
            self.mapView.settings.myLocationButton = true
            
            marker.map = self.mapView
        }
    }
    
    //location manager for accessing current location of the device
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var mapView: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func jsonToNSData(json: JSON) -> NSData?{
            do {
                return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData
            } catch let myJSONError {
                print(myJSONError)
            }
            return nil;
        }
        Alamofire.request("https://data.gov.sg/api/action/resource_show?id=8af18201-f3b0-4a9c-924e-f0bd8dda7bf6").validate().responseJSON { response in
            switch response.result {
            case .success:
                print("1st Validation Successful)")
                
                if let json = response.data {
                    do{
                        let data = try JSON(data: json)
                        let geojsonURL = (data["result"]["url"]).description
                        Alamofire.request(geojsonURL).validate().responseJSON { response in
                            switch response.result {
                            case .success:
                                print("2nd Validation Successful)")
                                
                                if let json = response.data {
                                    do{
                                        let geoJsonParser = GMUGeoJSONParser(data: json as Data)
                                        geoJsonParser.parse()
                                        
                                        let red_style = GMUStyle(styleID: "red", stroke: UIColor.red, fill: UIColor.red.withAlphaComponent(0.5), width: 2, scale: 1, heading: 0, anchor: CGPoint(x: 0, y: 0), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)
                                        
                                        let yellow_style=GMUStyle(styleID: "yellow", stroke: UIColor.yellow, fill: UIColor.yellow.withAlphaComponent(0.5), width: 2, scale: 1, heading: 0, anchor: CGPoint(x: 0, y: 0), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)
                                        
                                        let orange_style=GMUStyle(styleID: "orange", stroke: UIColor.orange, fill: UIColor.orange.withAlphaComponent(0.5), width: 2, scale: 1, heading: 0, anchor: CGPoint(x: 0, y: 0), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)
                                        
                                        var styleDict = [Int: Int]()
                                        let localGeoJSON = try JSON(data: json);
                                        for i in 0..<localGeoJSON["features"].count{
                                            do { let html = localGeoJSON["features"][i]["properties"]["Description"].string
                                                
                                                let doc: Document = try SwiftSoup.parse(html!)
                                                let a = try doc.getElementsByTag("td").get(1).text()
                                                styleDict[i] = Int(a)!
                                            }
                                            catch{
                                                print("Parsing Error")
                                            }
                                        }
                                        
                                        //                                        for i in range(len(dengue_dict["features"])){
                                        //                                            kmlDict[i] = int(dengue_dict["features"][i]['properties']['Description'].split('<th>CASE_SIZE</th> <td>')[1].split('</td')[0])}
                                        
                                        //                                        let dictionary = [0: 45, 1: 8, 2: 2, 3: 2, 4: 2, 5: 3, 6: 3, 7: 2, 8: 8, 9: 3, 10: 3, 11: 3, 12: 3, 13: 38, 14: 2, 15: 3, 16: 3, 17: 2, 18: 3, 19: 99, 20: 65, 21: 2, 22: 2, 23: 28, 24: 4, 25: 17, 26: 7, 27: 4, 28: 3, 29: 3, 30: 3, 31: 6, 32: 110, 33: 10, 34: 6, 35: 6, 36: 12, 37: 34, 38: 7, 39: 178, 40: 3, 41: 3, 42: 13, 43: 5, 44: 2, 45: 2, 46: 2, 47: 18, 48: 2, 49: 5, 50: 3, 51: 2, 52: 4, 53: 4, 54: 6, 55: 4, 56: 3, 57: 6, 58: 3, 59: 3, 60: 2, 61: 2, 62: 4, 63: 4, 64: 25, 65: 2, 66: 2, 67: 11, 68: 8, 69: 6, 70: 3, 71: 3, 72: 4, 73: 3, 74: 15, 75: 4, 76: 4, 77: 106, 78: 9, 79: 7, 80: 2, 81: 2, 82: 3, 83: 4, 84: 23, 85: 3, 86: 4, 87: 5, 88: 3, 89: 2, 90: 3, 91: 23, 92: 2, 93: 11, 94: 3, 95: 3, 96: 22, 97: 21, 98: 5, 99: 4, 100: 4, 101: 4, 102: 24, 103: 6, 104: 7, 105: 18, 106: 41, 107: 5, 108: 9, 109: 3, 110: 3, 111: 3, 112: 2, 113: 2, 114: 23, 115: 36]
                                        
                                        for i in 0..<geoJsonParser.features.count {
                                            if styleDict[i]! > 50  {
                                                geoJsonParser.features[i].style = red_style
                                            }
                                            else if styleDict[i]! > 10  {
                                                geoJsonParser.features[i].style = orange_style
                                            }
                                            else{
                                                geoJsonParser.features[i].style = yellow_style
                                            }
                                        }
                                        let renderer = GMUGeometryRenderer(map: self.mapView, geometries: geoJsonParser.features)
                                        renderer.render()
                                    }
                                    catch{
                                        print("2nd JSON Error")
                                    }
                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                    catch{
                        print("1st JSON Error")
                    }
                    
                }
            case .failure(let error):
                print(error)
            }
        }
        
        // Do any additional setup after loading the view.
        //         GEOJSON Parsing
        //        let path = Bundle.main.path(forResource: "dengue", ofType: "geojson")
        //        let url = URL(fileURLWithPath: path!)
        //        let geoJsonParser = GMUGeoJSONParser(data: <#T##Data#>)
        //        geoJsonParser.parse()
        //
        //        let red_style = GMUStyle(styleID: "red", stroke: UIColor.red, fill: UIColor.red.withAlphaComponent(0.5), width: 2, scale: 1, heading: 0, anchor: CGPoint(x: 0, y: 0), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)
        //
        //        let yellow_style=GMUStyle(styleID: "yellow", stroke: UIColor.yellow, fill: UIColor.orange.withAlphaComponent(0.5), width: 2, scale: 1, heading: 0, anchor: CGPoint(x: 0, y: 0), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)
        //
        //        let dictionary = [0: 45, 1: 8, 2: 2, 3: 2, 4: 2, 5: 3, 6: 3, 7: 2, 8: 8, 9: 3, 10: 3, 11: 3, 12: 3, 13: 38, 14: 2, 15: 3, 16: 3, 17: 2, 18: 3, 19: 99, 20: 65, 21: 2, 22: 2, 23: 28, 24: 4, 25: 17, 26: 7, 27: 4, 28: 3, 29: 3, 30: 3, 31: 6, 32: 110, 33: 10, 34: 6, 35: 6, 36: 12, 37: 34, 38: 7, 39: 178, 40: 3, 41: 3, 42: 13, 43: 5, 44: 2, 45: 2, 46: 2, 47: 18, 48: 2, 49: 5, 50: 3, 51: 2, 52: 4, 53: 4, 54: 6, 55: 4, 56: 3, 57: 6, 58: 3, 59: 3, 60: 2, 61: 2, 62: 4, 63: 4, 64: 25, 65: 2, 66: 2, 67: 11, 68: 8, 69: 6, 70: 3, 71: 3, 72: 4, 73: 3, 74: 15, 75: 4, 76: 4, 77: 106, 78: 9, 79: 7, 80: 2, 81: 2, 82: 3, 83: 4, 84: 23, 85: 3, 86: 4, 87: 5, 88: 3, 89: 2, 90: 3, 91: 23, 92: 2, 93: 11, 94: 3, 95: 3, 96: 22, 97: 21, 98: 5, 99: 4, 100: 4, 101: 4, 102: 24, 103: 6, 104: 7, 105: 18, 106: 41, 107: 5, 108: 9, 109: 3, 110: 3, 111: 3, 112: 2, 113: 2, 114: 23, 115: 36]
        //
        //        for i in 0..<geoJsonParser.features.count {
        //            if dictionary[i]! > 10  {
        //                geoJsonParser.features[i].style = red_style
        //            }
        //            else{
        //                geoJsonParser.features[i].style = yellow_style
        //            }
        //        }
        //
        //        let renderer = GMUGeometryRenderer(map: mapView, geometries: geoJsonParser.features)
        //        renderer.render()
        
        // KML METHOD
        //        let path = Bundle.main.path(forResource: "Dengue", ofType: "kml")
        //        let url = URL(fileURLWithPath: path!)
        //        let kmlParser = GMUKMLParser(url: url)
        //        kmlParser.parse()
        //        let renderer = GMUGeometryRenderer(map: self.self.mapView,
        //                                           geometries: kmlParser.placemarks,
        //                                           styles: kmlParser.styles)
        //        renderer.render()
        //
        
        //initializing CLLocationManager
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        //searchButton ui implementations
        self.searchButton.layer.cornerRadius = 14.5
        
        //        if g_lat != nil {
        //            print("1st function: ")
        //            locateWithLong(lon: g_lat, andLatitude: g_long, andAddress: g_address)
        //        }
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        if g_lat != nil {
    //            print("2nd function")
    //            locateWithLong(lon: g_lat, andLatitude: g_long, andAddress: g_address)
    //        }
    //    }
    
    // Present the Autocomplete view controller when the button is pressed.
    @objc func autocompleteClicked(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        if #available(iOS 13.0, *) {
            if UIScreen.main.traitCollection.userInterfaceStyle == UIUserInterfaceStyle.dark
            {
                autocompleteController.primaryTextColor = UIColor.white
                autocompleteController.secondaryTextColor = UIColor.lightGray
                autocompleteController.tableCellSeparatorColor = UIColor.lightGray
                autocompleteController.tableCellBackgroundColor = UIColor.darkGray
            } else {
                autocompleteController.primaryTextColor = UIColor.black
                autocompleteController.secondaryTextColor = UIColor.lightGray
                autocompleteController.tableCellSeparatorColor = UIColor.lightGray
                autocompleteController.tableCellBackgroundColor = UIColor.white
            }
        }
        autocompleteController.delegate = self as GMSAutocompleteViewControllerDelegate
        
        // Specify the place data types to return.
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
            UInt(GMSPlaceField.placeID.rawValue) | UInt(GMSPlaceField.coordinate.rawValue))!
        autocompleteController.placeFields = fields
        
        // Specify a filter.
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.country = "SG"
        autocompleteController.autocompleteFilter = filter
        
        // Display the autocomplete view controller.
        present(autocompleteController, animated: true, completion: nil)
    }
}

//implementing extension from CLLocationManagerDelegate
extension GoogleMapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        guard status == .authorizedWhenInUse else {
            return
        }
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.first else {
            return
        }
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 14.5, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
}

extension GoogleMapViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name ?? "Unknown Location")")
        print("Place ID: \(place.placeID ?? "Unknown Location")")
        print("Place attributions: \(String(describing: place.attributions))")
        dismiss(animated: true, completion: nil)
        
        // animate camera  to searched location
        let cameraPosition = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 14.5)
        mapView.animate(to: cameraPosition)
        
        // place marker on searched location
        let markerPosition = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        onlyMarker.position = markerPosition
        onlyMarker.title = place.name
        onlyMarker.map = mapView
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
