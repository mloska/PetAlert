//
//  ChangeStatusViewController.swift
//  PetAlert
//
//  Created by Claudia on 28.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit
import GoogleMaps

class ChangeStatusViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var updatedPlaceTxt: UILabel!
    
    // datetime picker
    @IBOutlet weak var lastSeenCtrl: UITextField!
    let picker = UIDatePicker()
    
    var sentPetToChange = Pet()
    var sentStatus: String = ""
    var selectedStatus: String = ""
    
    // maps
    var city: String = ""
    var street: String = ""
    var locationManager = CLLocationManager()
    var finalLongitude:Double = 0.0
    var finalLatitude:Double = 0.0
    var finalMarker:GMSMarker = GMSMarker()

    let URL_UPDATE_TICKET = "https://serwer1878270.home.pl/WebService/api/updateticket.php"

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        setUpNavBar()
        createDatePicker()
        initializeTheLocationManager()
        
        city = self.sentPetToChange.City!
        street = self.sentPetToChange.Street!
        finalLongitude = self.sentPetToChange.Longitude
        finalLatitude = self.sentPetToChange.Latitude
        
        petName.text = sentPetToChange.Name
        if (sentStatus == "spotted"){
            statusLbl.text = "Spotted on"
            selectedStatus = "2"
        } else if (sentStatus == "found"){
            statusLbl.text = "Found on"
            selectedStatus = "3"
        }
    }

    func setUpNavBar () {
        let save = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveTapped))
        self.navigationItem.rightBarButtonItems = [save]
    }
    
    @objc func saveTapped (){
        print ("saveTapped")
        
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        print("PickerDate ", picker.date)
        
        let newLastSeenDateString = formatter.string(from: picker.date as Date)
        let dateTimeModificationString = formatter.string(from: NSDate() as Date)
        
        //created NSURL
        let requestURL = NSURL(string: URL_UPDATE_TICKET)
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        //setting the method to post
        request.httpMethod = "POST"
        
        //getting values from text fields
        let city = self.city
        let street = self.street
        let longitude = finalLongitude
        let latitude = finalLatitude
        let status = selectedStatus
        let userID = UserDefaults.standard.value(forKey: "logged_user_ID")
        // cannot update userID cos I will not display owner's ticket, but we need to show tickets that new user is participating. need to be done in seperate table?
        //let userID = "\(loggedUserID ?? "0")"
        
        //creating the post parameter by concatenating the keys and values from text field
        var postParameters="city="+city
        postParameters+="&street="+street
        postParameters+="&lastDate="+String(newLastSeenDateString)
        postParameters+="&longitude="+String(longitude)
        postParameters+="&latitude="+String(latitude)
        postParameters+="&status="+status
        postParameters+="&uuid="+sentPetToChange.UUID!
        postParameters+="&dateTimeModification="+String(dateTimeModificationString)
        postParameters+="&userid="+"\(userID ?? "")"

        //adding the parameters to request body
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        print ("newLastSeenDateString: ", newLastSeenDateString)
        print (postParameters)
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            if error != nil{
                print("error is \(String(describing: error))")
                return;
            }
            
            // You can print out response object
            print("******* response = \(response ?? URLResponse())")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            
            //parsing the response
            do {
                //converting resonse to NSDictionary
                let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                //parsing the json
                if let parseJSON = myJSON {
                    
                    //creating a string
                    var msg : String!
                    
                    //getting the json response
                    msg = parseJSON["message"] as! String?
                    
                    //printing the response
                    print(msg)
                    
                }
            } catch {
                print(error)
            }
            
        }
        //executing the task
        task.resume()
        
        
        print("Zaktualizowano status i polozenie")
        
        let alert = UIAlertController(title: "Update", message: "Ticket has been updated", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "TicketsViewController")
            let navController = UINavigationController(rootViewController: VC1)
            if let tabViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainTabController") as? MainTabController {
                self.present(tabViewController, animated: true, completion: nil)
            }
            self.present(navController, animated:true, completion: nil)
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    // ************** Last date time picker
    // TODO: universilize this function so there are used in many places

    func createDatePicker() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        lastSeenCtrl.inputAccessoryView = toolbar
        lastSeenCtrl.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .dateAndTime
        picker.locale = NSLocale(localeIdentifier: "pl_PL") as Locale
    }
    
    @objc func donePressed() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        
        let dateString = formatter.string(from: picker.date)
        
        lastSeenCtrl.text = "\(dateString)"
        
        self.view.endEditing(true)
    }
    
    
    
    func initializeTheLocationManager()
    {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       // let location = locationManager.location?.coordinate
//        let coordinate = CLLocationCoordinate2DMake(Double((location?.latitude)!), Double((location?.longitude)!))
        
        //let lastPetLocation = CLLocationCoordinate2DMake(Double((sentPetToChange.Latitude)), Double((sentPetToChange.Longitude)))
        //let marker = GMSMarker(position: coordinate)
        self.mapView.clear()
        let marker = GMSMarker()
        marker.isDraggable = true
        marker.position = CLLocationCoordinate2DMake(sentPetToChange.Latitude, sentPetToChange.Longitude)
        marker.map = self.mapView
        finalMarker = marker
        self.mapView.animate(toLocation: finalMarker.position)
        
        
        cameraMoveToLocation(toLocation: finalMarker.position)
        self.finalLongitude = finalMarker.position.longitude
        self.finalLatitude = finalMarker.position.latitude
        
        getAddressBasedOnTheMarker(marker: marker) { streetVal, cityVal, placeStringVal in
            self.street = streetVal
            self.city = cityVal
            self.updatedPlaceTxt.text = placeStringVal
        }
        
    }
    
    internal func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        getAddressBasedOnTheMarker(marker: marker) { streetVal, cityVal, placeStringVal in
            self.street = streetVal
            self.city = cityVal
            self.updatedPlaceTxt.text = placeStringVal
            self.finalMarker = marker
            self.finalLongitude = self.finalMarker.position.longitude
            self.finalLatitude = self.finalMarker.position.latitude
        }
        self.mapView.animate(toLocation: self.finalMarker.position)
        self.cameraMoveToLocation(toLocation: self.finalMarker.position)
    }
    
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        if toLocation != nil {
            mapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: 15)
        }
    }
    
}
