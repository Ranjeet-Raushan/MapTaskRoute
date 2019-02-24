//  MapVC.swift
//  MapTaskRoute
//  Created by vaayoo on 29/07/18.
//  Copyright © 2018 vaayoo. All rights reserved.

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftyJSON
import Alamofire
protocol MapVC_Delegate
{
    func getJioPoints(Latitude:String, Longitude:String, text:String,buttonNo: Int)
}
class MapVC:UIViewController,CLLocationManagerDelegate {

    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var marker: GMSMarker? = nil
    @IBOutlet weak var mapCenterPinImage: UIImageView!
    
    @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
    
    var Map_Delegate : MapVC_Delegate?//important
    var controllerName: String?
    var lat: String?
    var long: String?
    var text: String?
    
    var buttonNO:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        
        
        // 2. search related code from google
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        // put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        searchController?.searchBar.placeholder = "Search Location"
        setTextFieldTintColor(to: UIColor.red, for: (searchController?.searchBar)!)
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        
        
        
        // 3.create done button and place on nav bar
        let done = UIButton.init(type: .custom)
        done.frame = CGRect.init(x: 0, y: 0, width: 50, height: 30)
        done.setTitle("Done", for: .normal)
        done.setTitleColor(UIColor.red, for: .normal)
        done.addTarget(self, action: #selector(onDoneClick(_:)), for: .touchUpInside)
        done.transform = CGAffineTransform(translationX: 0, y: 5)
        let view = UIView.init(frame: done.frame)
        view.addSubview(done)
        let item1 = UIBarButtonItem.init(customView: view)
        self.navigationItem.rightBarButtonItem = item1
        
        //4.
        mapView.delegate = self
        self.mapView?.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
        self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)// 60 to show mycurrent location button little above than the bottom label
      self.pinImageVerticalConstraint.constant -= (60-18)// 60 is height from bottom and 18 is half height of marker image
        
        
        // User Location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude,
                                              longitude: userLocation!.coordinate.longitude, zoom: 15.0)
        self.mapView.camera = camera
        locationManager.stopUpdatingLocation()
        
    }
    //helper method
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                let lines1 = address.lines!
                print("New Address after dragging = \(lines1)")
                let lines = address.lines!
                self.addressLabel.text = lines.joined(separator: "\n")
                self.lat = String(coordinate.latitude)
                self.long = String(coordinate.longitude)
                self.text = String(describing: address.locality)
                
            }
        }
    }
    @IBAction func onDoneClick(_ sender: UIBarButtonItem) {
        print("Done click")
        if addressLabel.text != "Address" {
            
            if let del = self.Map_Delegate
            {
                //del.getJioPoints(Latitude: lat!, Longitude: long!, text: text!)
                del.getJioPoints(Latitude: lat!, Longitude: long!, text: addressLabel.text!,buttonNo: self.buttonNO!)
            }
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    // for customizing TextFied cursor color
    func setTextFieldTintColor(to color: UIColor, for view: UIView) {
        if view is UITextField {
            view.tintColor = color
        }
        for subview in view.subviews {
            setTextFieldTintColor(to: color, for: subview)
        }
    }
}
//Autoplace Google API's delegates . Handle the user's selection of auto place dropdown
extension MapVC: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress ?? "")")
        // adjust map to selected location
        let camera = GMSCameraPosition.camera(withLatitude: (place.coordinate.latitude), longitude: (place.coordinate.longitude), zoom: 15.0)
        self.mapView?.animate(to: camera)
        let centerLoc: CLLocationCoordinate2D = mapView.camera.target
        
        print("CenterLat = \(centerLoc.latitude) and CenterLong = \(centerLoc.longitude)")
        lat = String(centerLoc.latitude)
        long = String(centerLoc.longitude)
        text = String(describing: place.name)
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                           didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
//Google map deligate
//MARK: - GMSMapViewDelegate (called when map is moved)
extension MapVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        reverseGeocodeCoordinate(coordinate: position.target)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        // addressLabel.lock()
    }
}
