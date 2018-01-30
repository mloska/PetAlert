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
        //let coordinateValues = locationManager.location?.coordinate
        //let radiusKM = currentValue
        //mapView?.clear()
        //drawCircle(coordinate: (coordinateValues)!, radius: Double(radiusKM))
        //reloadDataOnMap(lat: (coordinateValues?.latitude)!, long: (coordinateValues?.longitude)!, rad: Double(radiusKM))
    }
    
    //Web service url
    var URL_GET_PETS_RADIUS_STR = "https://serwer1878270.home.pl/WebService/api/getallpetsforselectedradius.php"
    var petsArrayMap:[Pet]? = []
    var locationManager = CLLocationManager()
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    var chosenMarkerID: Int = 0
    
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
        print("lat: ", coordinateValues?.latitude ?? 0)
        print("long: ", coordinateValues?.longitude ?? 0)
        
        customMarkerPreviewView=CustomMarkerPreviewView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width-100, height: 190))
        drawCircle(coordinate: (coordinateValues)!, radius: radiusKM)

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
        
        showMarkers()
        
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
    
    
    // MARK: GOOGLE MAP DELEGATE
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return false }
        let img = customMarkerView.img!
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: img, borderColor: UIColor.white, tag: customMarkerView.tag)
        
        marker.iconView = customMarker
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return nil }
        let data = self.petsArrayMap![customMarkerView.tag]
        customMarkerPreviewView.setData(title: data.Name!, img: data.ImageData ?? UIImage(), breed: data.Breed!)
        return customMarkerPreviewView
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return }
        chosenMarkerID = customMarkerView.tag
        markerTapped(tag: chosenMarkerID)
    }
    
    func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        guard let customMarkerView = marker.iconView as? CustomMarkerView else { return }
        let img = customMarkerView.img!
        let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: img, borderColor: UIColor.darkGray, tag: customMarkerView.tag)
        marker.iconView = customMarker
    }
    
    func showMarkers() {
        //mapView.clear()
        for (index, pet) in self.petsArrayMap!.enumerated() {
            let marker=GMSMarker()
            let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: pet.ImageData ?? UIImage(), borderColor: UIColor.darkGray, tag: index)
            marker.iconView=customMarker
            marker.position = CLLocationCoordinate2D(latitude: pet.Latitude, longitude: pet.Longitude)
            marker.map = self.mapView
        }
    }
    
    @objc func markerTapped(tag: Int) {
        self.performSegue(withIdentifier: "showTicketDetailsFromMarker", sender: self)

    }
    
    var customMarkerPreviewView: CustomMarkerPreviewView = {
        let v=CustomMarkerPreviewView()
        return v
    }()

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailsTicketViewController {
            let arrayIndex = chosenMarkerID
            let petObject = petsArrayMap![arrayIndex]
            destination.destPet = petObject
        }
    }

}



