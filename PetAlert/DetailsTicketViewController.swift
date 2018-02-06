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
    
    var destPet = Pet()
    let URL_PHOTOS_MAIN_STR = "https://serwer1878270.home.pl/Images/User_"
    let thumbnailString = ""
    
    // within segue check what invoked the action, what button as they do the same with small logic changes
    var buttonStatusTapped: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavBar()
        
        nameLbl.text = destPet.Name
        breedLbl.text = destPet.Breed
        colorLbl.text = destPet.Color
        lastSeenDateLbl.text = destPet.LastDate
        lastSeenPlaceLbl.text = "\(destPet.Street ?? "")" + ", " + "\(destPet.City ?? "")"
        let imgURL = "\(URL_PHOTOS_MAIN_STR)" + "\(destPet.UserID ?? 0 )" + "/" + "\(thumbnailString)" + "\(destPet.UUID ?? "" )" + ".jpg"

        // download full resolution of the image, not the thumbnail
        let url = URL(string:imgURL)
        if let data = try? Data(contentsOf: url!)
        {
            imageCtr.image = UIImage(data: data)
        }
        else {
            imageCtr.image = destPet.ImageData
        }
        

        let lat = destPet.Latitude
        let long = destPet.Longitude 
        
        
        // Create a GMSCameraPosition that tells the map to display the
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 16.0)
        let map = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        marker.title = "\(destPet.Name ?? "")"
        marker.snippet = "\(destPet.Color ?? "")" + " " + "\(destPet.Breed ?? "")"
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

    func setUpNavBar () {
        let found = UIBarButtonItem(title: "Found", style: .plain, target: self, action: #selector(foundTapped))
        let spotted = UIBarButtonItem(title: "Spotted", style: .plain, target: self, action: #selector(spottedTapped))
        let mapHistory = UIBarButtonItem(image: #imageLiteral(resourceName: "map_Pin"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(mapTapped))

        self.navigationItem.rightBarButtonItems = [found, spotted, mapHistory]

    }
    
    @objc func foundTapped (){
        print ("foundTapped")
        buttonStatusTapped = "found"
        performSegue(withIdentifier: "changeStatusTicketSegue", sender: self)

    }
    
    @objc func spottedTapped(){
        print ("spottedTapped")
        buttonStatusTapped = "spotted"
        performSegue(withIdentifier: "changeStatusTicketSegue", sender: self)

    }
    
    @objc func mapTapped(){
        print ("mapTapped")
        buttonStatusTapped = "map"
        performSegue(withIdentifier: "mapHistoryTicketSegue", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChangeStatusViewController {
            destination.sentPetToChange = destPet
            destination.sentStatus = buttonStatusTapped
        }
        if let destination = segue.destination as? HistoryMapTicketViewController {
            destination.sentPetToViewHistory = destPet
            destination.sentStatus = buttonStatusTapped
        }
        
        
    }


}
