//
//  MapViewController.swift
//  PetAlert
//
//  Created by Claudia on 07.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!

    //Web service url
    var URL_GET_PETS_RADIUS_STR = "https://serwer1878270.home.pl/WebService/api/getallpetsforselectedradius.php"
    
    var petsArrayMap:[Pet]? = []
    let lat = 50.09000833
    let long = 20.01274005
    var locationManager = CLLocationManager()
    let myCircle = GMSCircle()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTheLocationManager()
        mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        //drawCircle(coordinate: (locationManager.location?.coordinate)!)
        //https:serwer1878270.home.pl/WebService/api/getallpetsforselectedradius.php?centerLatitude=50.020049&centerLongitude=19.906647&radiusKM=5
        
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        let radiusKM:Double = 10
        
        let circleCenter = CLLocationCoordinate2D(latitude: (latitude)!, longitude: (longitude)!)
        let circ = GMSCircle(position: circleCenter, radius: 1000*radiusKM) //radius is in meters
        circ.fillColor = UIColor(red: 0.09, green: 0.6, blue: 0.41, alpha: 0.5)
        circ.strokeColor = .black
        circ.strokeWidth = 1
        circ.map = mapView
        URL_GET_PETS_RADIUS_STR = "\(URL_GET_PETS_RADIUS_STR)" + "?centerLatitude=" + "\(latitude ?? 0)" + "&centerLongitude=" + "\(longitude ?? 0)" + "&radiusKM=" + "\(radiusKM*0.621371192)"
        
        connectToJson(link: URL_GET_PETS_RADIUS_STR, mainFunctionName: mainMapFunction)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func drawCircle (coordinate: CLLocationCoordinate2D){
        let circle = GMSCircle()
        circle.radius = 3500 // Meters
        circle.fillColor = UIColor(red: 0.09, green: 0.6, blue: 0.41, alpha: 0.5)
        circle.position = (coordinate) // Your CLLocationCoordinate2D  position
        circle.strokeWidth = 1;
        circle.strokeColor = UIColor.black
        circle.map = mapView; // Add it to the map
    }
    
    func mainMapFunction (passedJsonArray: [[String: Any]]) {
        self.petsArrayMap = JsonToArray(inputJsonArray: passedJsonArray, downloadThumbnail: true)
        
        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 10.0)
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
    
    
    func initializeTheLocationManager()
    {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    

}



