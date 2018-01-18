//
//  DetailsTicketViewController.swift
//  PetAlert
//
//  Created by Claudia on 09.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit
import GoogleMaps

class DetailsTicketViewController: UIViewController {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var breedLbl: UILabel!
    @IBOutlet weak var colorLbl: UILabel!
    @IBOutlet weak var lastSeenDateLbl: UILabel!
    @IBOutlet weak var lastSeenPlaceLbl: UILabel!
    @IBOutlet weak var imageCtr: UIImageView!
    @IBOutlet weak var mapView: GMSMapView!
    
    var destPet:PetEntity? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLbl.text = destPet?.name
        breedLbl.text = destPet?.breed
        colorLbl.text = destPet?.color
        lastSeenDateLbl.text = destPet?.lastdate
        lastSeenPlaceLbl.text = "\(destPet?.street ?? "")" + ", " + "\(destPet?.city ?? "")"
        imageCtr.image = UIImage(data: (destPet?.imageBinary ?? Data())!)
        
        //imageCtr.image = UIImage(named: (destPet?.image)!)
        let lat = destPet?.latitude
        let long = destPet?.longitude
        
        
        // Create a GMSCameraPosition that tells the map to display the
        let camera = GMSCameraPosition.camera(withLatitude: lat!, longitude: long!, zoom: 16.0)
        let map = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: long!)
        marker.title = "\(destPet?.name ?? "")"
        marker.snippet = "\(destPet?.color ?? "")" + " " + "\(destPet?.breed ?? "")"
        marker.map = self.mapView
        
        self.mapView.camera = camera;
        self.mapView = map
        
        //self.mapView.isMyLocationEnabled = true;
        
    }
    
    @IBAction func selectImageToBeFullscreenGesture(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }



}
