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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var names = ["Leon", "Ares", "Hektor", "Eden", "Drops", "Zora", "Koda", "Amber", "Atan", "Natan", "Piorun", "Paco", "Rox", "Fafik", "Bąbel", "Bambi", "Amor", "Baks", "Coco", "Micka"]
        var latitude = [50.09000833, 50.10635068, 50.15258778, 50.0406191, 50.05985175, 50.07332046, 50.14757413, 50.15044122, 50.10997714, 50.0558049, 50.088566, 50.13715946, 50.0990909, 50.05216344, 49.99223714, 50.10933517, 49.98568133, 50.01387256, 50.07015543, 50.14930141]
        var longitude = [20.01274005, 20.0681771, 19.95851556, 19.91279338, 19.81823311, 19.93518523, 19.9667472, 19.92463495, 19.85944606, 19.87102005, 19.75631217, 19.96753202, 20.12630022, 20.13657324, 20.06941245, 20.06932906, 20.05847755, 19.99495258, 19.97558074, 19.93061267]
        
        var petsArray = [Pet]()
        let lat = 50.09000833
        let long = 20.01274005
        
        for i in 0...names.count-1 {
            let pet = Pet()
            pet.Name = names[i]
            pet.Longitude = longitude[i]
            pet.Latitude = latitude[i]
            petsArray.append(pet)
        }
        
        for pet in petsArray {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: pet.Latitude, longitude: pet.Longitude)
            marker.title = pet.Name
            marker.snippet = "Hey, this is \(pet.Name ?? "")"
            marker.map = mapView
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 10.0)
        let map = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        
        self.mapView.camera = camera;
        self.mapView = map
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


