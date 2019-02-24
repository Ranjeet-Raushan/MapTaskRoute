//  AddressePickUps.swift
//  MapTaskRoute
//  Created by vaayoo on 30/07/18.
//  Copyright © 2018 vaayoo. All rights reserved.

import UIKit
protocol SendAllLatLong {
    func sendAllLatLong(lat1: String,long1: String,lat2: String,long2: String,lat3: String,long3: String,lat4: String,long4: String)
}

class AddressePickUps: UIViewController,MapVC_Delegate{
   
    @IBOutlet weak var firstTV: UITextView!{
        didSet{
            firstTV.isEditable = false
            firstTV.isSelectable = false
        }
    }
    @IBOutlet weak var secondTV: UITextView!
    {
        didSet{
            secondTV.isEditable = false
            secondTV.isSelectable = false
        }
    }
    @IBOutlet weak var thirdTV: UITextView!
    {
        didSet{
            thirdTV.isEditable = false
            thirdTV.isSelectable = false
        }
    }
    @IBOutlet weak var fourthTV: UITextView!
    {
        didSet{
            fourthTV.isEditable = false
            fourthTV.isSelectable = false
        }
    }
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
    
    var mydelegate: SendAllLatLong?
    override func viewDidLoad() {
        super.viewDidLoad()
        firstTV.text = ""
        secondTV.text = ""
        thirdTV.text = ""
        fourthTV.text = ""
    }
    
    @IBAction func onFirstButtonClick(_ sender: UIButton) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapvc") as! MapVC
        vc.Map_Delegate = self
        vc.buttonNO = sender.tag
        let nav = UINavigationController.init(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
        
    }
    func getJioPoints(Latitude:String, Longitude:String, text:String,buttonNo: Int) {
        if buttonNo == 1{
            print("Latitude = \(Latitude)")
            print("Longitude = \(Longitude)")
            print("Address = \(text)")
            firstTV.text = text
            lat1 = Latitude
            long1 = Longitude
        }
        if buttonNo == 2 {
            print("Latitude = \(Latitude)")
            print("Longitude = \(Longitude)")
            print("Address = \(text)")
            secondTV.text = text
            lat2 = Latitude
            long2 = Longitude
        }
        if buttonNo == 3 {
            print("Latitude = \(Latitude)")
            print("Longitude = \(Longitude)")
            print("Address = \(text)")
            thirdTV.text = text
            lat3 = Latitude
            long3 = Longitude
        }
        if buttonNo == 4 {
            print("Latitude = \(Latitude)")
            print("Longitude = \(Longitude)")
            print("Address = \(text)")
            fourthTV.text = text
            lat4 = Latitude
            long4 = Longitude
        }
    }
    @IBAction func submitt(_ sender: Any){
        
        if let del = mydelegate {
            del.sendAllLatLong(lat1: lat1!,long1: long1!,lat2: lat2!,long2: long2!,lat3: lat3!,long3: long3!,lat4: lat4!,long4: long4!)
        }
          self.dismiss(animated: true, completion: nil)
    }

}
