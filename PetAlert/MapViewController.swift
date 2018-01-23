//
//  MapViewController.swift
//  PetAlert
//
//  Created by Claudia on 07.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!

    //Our web service url
    let URL_GET_PETS_STR = "https://serwer1878270.home.pl/WebService/api/getallpets.php"
    
    var petsArrayMap:[Pet]? = []
    let lat = 50.09000833
    let long = 20.01274005
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connectToJson(link: URL_GET_PETS_STR, mainFunctionName: mainMapFunction)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func mainMapFunction (passedJsonArray: [[String: Any]]) {
        self.petsArrayMap = JsonToArray(inputJsonArray: passedJsonArray)
        
        let camera = GMSCameraPosition.camera(withLatitude: self.lat, longitude: self.long, zoom: 10.0)
        let map = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        for pet in self.petsArrayMap! {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: pet.Latitude, longitude: pet.Longitude)
            marker.title = pet.Name
            marker.snippet = "Hey, this is \(pet.Name ?? "")"
            marker.map = self.mapView
        }
        
        self.mapView.settings.compassButton = true
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.scrollGestures = true
        self.mapView.settings.zoomGestures = true
        
        self.mapView.camera = camera;
        self.mapView = map
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


