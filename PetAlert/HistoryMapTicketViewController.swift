//
//  HistoryMapTicketViewController.swift
//  PetAlert
//
//  Created by Claudia on 06.02.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit
import GoogleMaps

class HistoryMapTicketViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    //Web service url
    let URL_GET_PETS_HST_LOC_STR = "https://serwer1878270.home.pl/WebService/api/gethistoryticketlocations.php?uuid="
    var sentPetToViewHistory = Pet()
    var sentStatus = ""
    var petsLoc:[Pet]? = []
    var locationManager = CLLocationManager()
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    var bounds = GMSCoordinateBounds()
    var chosenMarkerID: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        let uuid = sentPetToViewHistory.UUID
        connectToJson(link: URL_GET_PETS_HST_LOC_STR + "\(uuid ?? "")", mainFunctionName: mainHistoryMapTicketsFunction)

        mapView.delegate = self

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        let coordinateValues = locationManager.location?.coordinate
        
        initGoogleMaps(lat: (coordinateValues?.latitude)!, long: (coordinateValues?.longitude)!)
        customMarkerPreviewView=CustomMarkerPreviewView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width-100, height: 190))

        // Do any additional setup after loading the view.
    }
    
    func initGoogleMaps(lat: Double, long: Double) {
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 10.0)
        self.mapView.camera = camera
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
    }

    func mainHistoryMapTicketsFunction (passedJsonArray: [[String: Any]]) {
        // return to main array for this controller results from choped json into single objects in array
        self.petsLoc = JsonToArray(inputJsonArray: passedJsonArray, downloadThumbnail: true)
        
        //let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 10.0)
        
        showHistMarkers()
        
        self.mapView.settings.compassButton = true
        self.mapView.settings.myLocationButton = true
        self.mapView.settings.scrollGestures = true
        self.mapView.settings.zoomGestures = true
        
        //self.mapView.camera = camera;
        
        // dostosowanie zooma automatycznie do wyswietlanych markerów
        self.mapView.animate(with: GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(50.0 , 50.0 ,50.0 ,50.0)))

    }
    
    func showHistMarkers() {
        self.mapView?.clear()

        for (index, pet) in self.petsLoc!.enumerated() {
            let marker=GMSMarker()
            var color = UIColor()
            if (pet.StatusLoc == 1){
                color = UIColor.red
            } else {
                color = UIColor.darkGray
            }
            let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: pet.ImageData ?? UIImage(), borderColor: color, tag: index)
            marker.iconView=customMarker
            marker.position = CLLocationCoordinate2D(latitude: pet.Latitude, longitude: pet.Longitude)
            marker.map = self.mapView
            
            // dostosowanie zooma automatycznie do wyswietlanych markerów
            bounds = bounds.includingCoordinate(marker.position)
            

        }
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
        let data = self.petsLoc![customMarkerView.tag]
        customMarkerPreviewView.setData(title: data.LastDate!, img: data.ImageData ?? UIImage(), breed: data.Street!)
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
    
    var customMarkerPreviewView: CustomMarkerPreviewView = {
        let v=CustomMarkerPreviewView()
        return v
    }()
    
    @objc func markerTapped(tag: Int) {
        self.performSegue(withIdentifier: "showTicketDetailsFromMarker", sender: self)
        
    }

}
