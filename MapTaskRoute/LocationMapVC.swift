//  LocationMapVC.swift
//  MapTaskRoute
//  Created by vaayoo on 30/07/18.
//  Copyright © 2018 vaayoo. All rights reserved.

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire

class LocationMapVC: UIViewController,CLLocationManagerDelegate,SendAllLatLong{
    var firstMarker: GMSMarker!
    var secondMarker: GMSMarker!
    var thirdMarker: GMSMarker!
    var fourthMarker: GMSMarker!
    // location 1 // source 1
    var lat1: String?
    var long1:String?
    // location 2 // source 2
    var lat2: String?
    var long2:String?
    // location 3  //source 3
    var lat3: String?
    var long3:String?
    // location 4 // Destination
    var lat4: String?
    var long4:String?

    var directionMode: String!

    var varDistance: Int = 0//Global Variable
    var varDuration: Int = 0//Global Variable

    func sendAllLatLong(lat1: String, long1: String, lat2: String, long2: String, lat3: String, long3: String, lat4: String, long4: String) {
        self.lat1 = lat1
        self.long1 = long1
        self.lat2 = lat2
        self.long2 = long2
        self.lat3 = lat3
        self.long3 = long3
        self.lat4 = lat4
        self.long4 = long4
    }
    
    @IBAction func createRoute(_ sender: UIButton) {
       createrouteOnMap()
    }
    private func createrouteOnMap() {
        self.varDistance = 0
        self.varDuration = 0
        
        hitMapServer(sourceLat: self.lat1! ,sourceLong: self.long1! ,destinationLat: self.lat2!,destinationLong: self.long2!)
        hitMapServer(sourceLat: self.lat2! ,sourceLong: self.long2! ,destinationLat:self.lat3!,destinationLong: self.long3!)
        hitMapServer(sourceLat: self.lat3!,sourceLong: self.long3! ,destinationLat:self.lat4! ,destinationLong: self.long4!)
     
        
        //firstMarker
        firstMarker = GMSMarker()
        firstMarker.position = CLLocationCoordinate2D(latitude: Double(self.lat1!)! , longitude: Double(self.long1!)!)
        firstMarker.icon = #imageLiteral(resourceName: "icons")
        firstMarker.groundAnchor = CGPoint(x: 0.5 , y: 0.5)
        self.firstMarker.map = mappView
        
        
        //secondMarker
        secondMarker = GMSMarker()
        secondMarker.position = CLLocationCoordinate2D(latitude: Double(self.lat2!)! , longitude: Double(self.long2!)!)
        secondMarker.icon = #imageLiteral(resourceName: "icons")
        secondMarker.groundAnchor = CGPoint(x: 0.5 , y: 0.5)
        self.secondMarker.map = mappView
        
        //thirdMarker
        thirdMarker = GMSMarker()
        thirdMarker.position = CLLocationCoordinate2D(latitude: Double(self.lat3!)!  , longitude: Double(self.long3!)!)
        thirdMarker.icon = #imageLiteral(resourceName: "icons")
        thirdMarker.groundAnchor = CGPoint(x: 0.5 , y: 0.5)
        self.thirdMarker.map = mappView
        
        //fourthMarker
        fourthMarker = GMSMarker()
        fourthMarker.position = CLLocationCoordinate2D(latitude: Double(self.lat4!)! , longitude: Double(self.long4!)!)
        fourthMarker.icon = #imageLiteral(resourceName: "icons")
        fourthMarker.groundAnchor = CGPoint(x: 0.5 , y: 0.5)
        self.fourthMarker.map = mappView
 
        // show all 4 markers within visible map bound
        let path = GMSMutablePath()
        path.add(self.firstMarker.position)
        path.add(self.secondMarker.position)
        path.add(self.thirdMarker.position)
        path.add(self.fourthMarker.position)
        let bounds = GMSCoordinateBounds(path: path)
        self.mappView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30))
    }
    @IBOutlet weak var mappView: GMSMapView!
    var locationManager = CLLocationManager()
    @IBAction func walkk_btn(_ sender: UIButton) {
        btnWalkk.isSelected = true
        btnCyclee.isSelected = false
        btnCarr.isSelected = false
        directionMode = "walking"
        mappView.clear()
        createrouteOnMap()
    }
    @IBAction func cyclee_btn(_ sender: UIButton) {
        btnWalkk.isSelected = false
        btnCyclee.isSelected = true
        btnCarr.isSelected = false
        directionMode = "bicycling"
        mappView.clear()
        createrouteOnMap()
    }
    @IBAction func carr_btn(_ sender: UIButton) {
        btnWalkk.isSelected = false
        btnCyclee.isSelected = false
        btnCarr.isSelected = true
        directionMode = "driving"
        mappView.clear()
        createrouteOnMap()
    }
    @IBOutlet weak var btnWalkk: UIButton!
    @IBOutlet weak var btnCyclee: UIButton!
    @IBOutlet weak var btnCarr: UIButton!
    @IBOutlet weak var tdtt: UILabel!
    @IBOutlet weak var etaa: UILabel!
    var controllerName: String?
    var lat: String?
    var long: String?
    var text: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mappView?.isMyLocationEnabled = true
        self.mappView.settings.myLocationButton = true
        self.mappView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)// 60 to show mycurrent location button little above than the bottom label
        // User Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
         directionMode = "walking"
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 15.0)
        self.mappView.camera = camera
        locationManager.stopUpdatingLocation()
    }
    @IBAction func getPickUps(_ sender: Any){
        let AdDrEsSePickUps = self.storyboard?.instantiateViewController(withIdentifier: "addressepickups") as? AddressePickUps
         AdDrEsSePickUps?.mydelegate = self
        self.present(AdDrEsSePickUps!, animated: true, completion: nil)
    }

    @objc func showActionSheet() {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        let hybrid = UIAlertAction(title: "Hybrid", style: .default) { action in
            self.mappView.mapType = .hybrid
        }
        
        let normal = UIAlertAction(title: "Normal", style: .default) { action in
            self.mappView.mapType = .normal
        }
        
        let satellite = UIAlertAction(title: "Satellite", style: .default) { action in
            self.mappView.mapType = .satellite
        }
        let terrain = UIAlertAction(title: "Terrain", style: .default) { action in
            self.mappView.mapType = .terrain
        }
        let none = UIAlertAction(title: "None", style: .default) { action in
            self.mappView.mapType = .none
        }
    
        actionSheet.addAction(hybrid)
        actionSheet.addAction(normal)
        actionSheet.addAction(satellite)
        actionSheet.addAction(terrain)
        actionSheet.addAction(none)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func mapType(_ sender: Any){
        showActionSheet()
    }
   
    func hitMapServer(sourceLat: String,sourceLong: String,destinationLat:String,destinationLong:String)
    {
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(sourceLat),\(sourceLong)&destination=\(destinationLat),\(destinationLong)&sensor=false&mode=\(self.directionMode!)"
        Alamofire.request( url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { response in
 
            print(response.result.value as Any)   // result of response serialization
            let json = JSON(response.data as Any)
            let routes = json["routes"].arrayValue
            print("All routes = \(routes)")
            if routes.count > 0 {
            let route = routes[0]
                let routeOverviewPolyLine = route["overview_polyline"].dictionary
                let points = routeOverviewPolyLine!["points"]?.stringValue
                self.varDistance +=  route["legs"][0]["distance"]["value"].int!
                self.varDuration +=  route["legs"][0]["duration"]["value"].int!
                
                let Path = GMSPath.init(fromEncodedPath: points!)
                let polyLine = GMSPolyline.init(path: Path)
                polyLine.strokeWidth = 4.0
                polyLine.strokeColor = UIColor.blue
                polyLine.map = self.mappView
               
                self.tdtt.text = "\(self.varDistance/1000) kms"
                self.etaa.text = "\(self.varDuration/60) mins"
                
            }
        }
    }
}
