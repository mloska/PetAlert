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
    @IBOutlet weak var sliderValueLbl: UILabel!
    @IBAction func changedSlider(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        sliderValueLbl.text = "\(currentValue)"
        let coordinateValues = locationManager.location?.coordinate
        let radiusKM = currentValue
        //mapView?.clear()
        drawCircle(coordinate: (coordinateValues)!, radius: Double(radiusKM))
        //reloadDataOnMap(lat: (coordinateValues?.latitude)!, long: (coordinateValues?.longitude)!, rad: Double(radiusKM))
    }
    
    //Web service url
    var URL_GET_PETS_RADIUS_STR = "https://serwer1878270.home.pl/WebService/api/getallpetsforselectedradius.php"
    var petsArrayMap:[Pet]? = []
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeTheLocationManager()
        mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        let coordinateValues = locationManager.location?.coordinate
        let radiusKM:Double = 10
        if (sliderValueLbl.text == "Label"){
            sliderValueLbl.text = "\(radiusKM)"
        }
        //changedSlider(UISlider())
        drawCircle(coordinate: (coordinateValues)!, radius: radiusKM)
        print("lat: ", coordinateValues?.latitude ?? 0)
        print("long: ", coordinateValues?.longitude ?? 0)

        //https:serwer1878270.home.pl/WebService/api/getallpetsforselectedradius.php?centerLatitude=50.020049&centerLongitude=19.906647&radiusKM=5
        reloadDataOnMap(lat: (coordinateValues?.latitude)!, long: (coordinateValues?.longitude)!, rad: radiusKM)

    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let coordinateValues = locationManager.location?.coordinate
//        print("updated lat: ", coordinateValues?.latitude ?? 0)
//        print("updated long: ", coordinateValues?.longitude ?? 0)
//        //drawCircle(coordinate: (coordinateValues)!)
//
//    }
    
    func reloadDataOnMap(lat: CLLocationDegrees, long: CLLocationDegrees, rad: Double){
        URL_GET_PETS_RADIUS_STR = "\(URL_GET_PETS_RADIUS_STR)" + "?centerLatitude=" + "\(lat)" + "&centerLongitude=" + "\(long)" + "&radiusKM=" + "\(rad)"
        print(URL_GET_PETS_RADIUS_STR)
        connectToJson(link: URL_GET_PETS_RADIUS_STR, mainFunctionName: mainMapFunction)
    }
    
    func drawCircle (coordinate: CLLocationCoordinate2D, radius: Double){
        let circle = GMSCircle()
        circle.radius = radius * 1000 // Meters
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



