//
//  CreateNewTicketViewController.swift
//  PetAlert
//
//  Created by Claudia on 10.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class CreateNewTicketViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var pets:[Pet]? = []
    
    
    
    // inputs from storyboard
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var breedInput: UITextField!
    @IBOutlet weak var colorInput: UITextField!
    @IBOutlet weak var imageCtr: UIImageView!
    
    // status choice from picker
    @IBOutlet weak var statusInput: UITextField!
    let statuses = ["Found", "Searching"]
    var selectedStatus:String = ""

    
    // Google maps
    @IBOutlet weak var lastSeenPlaceLbl: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var street:String = ""
    var city:String = ""
    var finalLongitude:Double = 0.0
    var finalLatitude:Double = 0.0
    
    // Date Time picker
    @IBOutlet weak var lastSeenDateInput: UITextField!
    var fullDateTimeValue:String = ""
    let picker = UIDatePicker()
    
    // Photo
    var imageData:NSData! = NSData()

    
    
    // ************** Choose photo
    
    @IBAction func selectImageFromLibrary(_ sender: UITapGestureRecognizer) {
        
        let alertController = UIAlertController(title: "Choose photo", message: "Message choose photo", preferredStyle: .actionSheet)
        
        // TODO: add icons for the choices
        //let imageCamera = UIImage(named: "icon_camera")
        
        let choiceCamera = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.showPicker(sourceType: .camera)
        })
        let choiceAlbum = UIAlertAction(title: "Album", style: .default, handler: { (action) in
            self.showPicker(sourceType: .photoLibrary)
        })
        let choiceCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        //choiceCamera.setValue(imageCamera, forKey: "imageCamera")
        
        alertController.addAction(choiceCamera)
        alertController.addAction(choiceAlbum)
        alertController.addAction(choiceCancel)
        present(alertController, animated: true, completion: nil)
    }
    
    // Show image picker
    func showPicker (sourceType: UIImagePickerControllerSourceType){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        self.present(picker, animated: true, completion: nil)
    }

    // Cancel the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Chosen image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageCtr.image = selectedPhoto
        imageData = UIImagePNGRepresentation(selectedPhoto)! as NSData
        //let compressedImage = UIImage(data: imageData!)
        //UIImageWriteToSavedPhotosAlbum(selectedPhoto, nil, nil, nil)
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // ************** Last date time picker

    func createDatePicker() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        lastSeenDateInput.inputAccessoryView = toolbar
        lastSeenDateInput.inputView = picker
        
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

        lastSeenDateInput.text = "\(dateString)"
        fullDateTimeValue = dateString
        
        self.view.endEditing(true)
    }
    
    
    // ************** Google Maps

    func initializeTheLocationManager()
    {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locationManager.location?.coordinate
        let coordinate = CLLocationCoordinate2DMake(Double((location?.latitude)!), Double((location?.longitude)!))
        let marker = GMSMarker(position: coordinate)
        marker.isDraggable = true
        marker.map = self.mapView
        self.mapView.animate(toLocation: coordinate)

        
        let geocoder = GMSGeocoder()
        
        cameraMoveToLocation(toLocation: location)
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let location = response?.firstResult() {
                let marker = GMSMarker(position: coordinate)
                marker.isDraggable = true
                let lines = location.lines! as [String]
                let value = lines.joined(separator: "\n")
                self.street = lines[0]
                self.city = lines[1].components(separatedBy: ",")[0]
                
                // show marker
                marker.userData = value
                marker.title = value
                marker.infoWindowAnchor = CGPoint(x: 0.5, y: -0.25)
                marker.accessibilityLabel = "current"
                marker.map = self.mapView
                
                self.mapView.animate(toLocation: coordinate)
                self.mapView.selectedMarker = marker
                
                self.lastSeenPlaceLbl.text = value
                self.finalLongitude = coordinate.longitude
                self.finalLatitude = coordinate.latitude
            }
        }
    }

    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("Drag")
    }
    
    func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
        print("Old Coordinate - \(marker.position)")
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("New Coordinate - \(marker.position)")
    }
    
   
    
    
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        if toLocation != nil {
            mapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: 15)
        }
    }
    
    
    // ************** Status picker
    
    func createStatusPicker(){
        let statusPicker = UIPickerView()
        statusPicker.delegate = self
        statusInput.inputView = statusPicker
        statusPicker.backgroundColor = .white
    }
    
    func createToolbar(){
        let toolbarStatus = UIToolbar()
        toolbarStatus.sizeToFit()
        
        // done button for toolbar
        let doneStatus = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dissmissKeyboard))
        toolbarStatus.setItems([doneStatus], animated: false)
        toolbarStatus.isUserInteractionEnabled = true
        statusInput.inputAccessoryView = toolbarStatus
    }
    
    @objc func dissmissKeyboard(){
        view.endEditing(true)
        if (selectedStatus == ""){
            selectedStatus = statuses[0]
        }
        statusInput.text = selectedStatus
    }
    
    // Status picker components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Status picker rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statuses.count
    }
    
    // Status picker displayed values
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statuses[row]
    }
    
    // Status picker selection action
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStatus = statuses[row]
        statusInput.text = selectedStatus
    }
    

    // ************** Save button and main object creation

    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let loggedUserID = UserDefaults.standard.value(forKey: "logged_user_ID")
        let imageNameStr:String = ""
        //URL to web service
        let URL_SAVE_TEAM = "https://serwer1878270.home.pl/WebService/api/createpet.php"
        
//        var addedPet:Pet = Pet(ID: 0, Name: nameInput.text, Breed: breedInput.text, Color: colorInput.text, City: city, Street: street, PetType: "1", Description: "", LastDate: lastSeenDateInput.text, Longitude: finalLongitude, Latitude: finalLatitude, Status: selectedStatus, Image: imageNameStr, ImageData: UIImage(), UserID: loggedUserID as? Int, UUID: UUID().uuidString, DateTimeModification: NSDate())
        
        
        //created NSURL
        let requestURL = NSURL(string: URL_SAVE_TEAM)
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        //setting the method to post
        request.httpMethod = "POST"
        
        //getting values from text fields
        let name = nameInput.text
        let breed = breedInput.text
        let color = colorInput.text
        let city = self.city
        let street = self.street
        let petType = "1"
        let description = ""
        let lastDate = picker.date
        let longitude = finalLongitude
        let latitude = finalLatitude
        var status = selectedStatus
        let image = imageNameStr
        //let imageData = UIImage()
        let userID = "\(loggedUserID ?? "0")"
        let uuid = UUID().uuidString
        let dateTimeModification = NSDate()
        
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateTimeModificationString = formatter.string(from: dateTimeModification as Date)
        let lastDateString = formatter.string(from: lastDate as Date)

        if (status == "Searching"){
            status = "1"
        } else if (status == "Spotted"){
            status = "2"
        } else if (status == "Found"){
            status = "3"
        } else {
            status = "0"
        }
        
        //creating the post parameter by concatenating the keys and values from text field
        var postParameters = "name="+name!
        postParameters+="&breed="+breed!
        postParameters+="&color="+color!
        postParameters+="&city="+city
        postParameters+="&street="+street
        postParameters+="&petType="+petType
        postParameters+="&description="+description
        postParameters+="&lastDate="+String(lastDateString)
        postParameters+="&longitude="+String(longitude)
        postParameters+="&latitude="+String(latitude)
        postParameters+="&status="+status
        postParameters+="&image="+image
        postParameters+="&userID="+userID
        postParameters+="&uuid="+uuid
        postParameters+="&dateTimeModification="+dateTimeModificationString
        //adding the parameters to request body
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        
        
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            if error != nil{
                print("error is \(String(describing: error))")
                return;
            }
            
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
        
        
        
        
        
        
        
        print("Dodano")
//        pets = CoreDataHelper.fetchObject()
        
        let alert = UIAlertController(title: "Saved", message: "Your ticket has been saved", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//            let vc = storyboard.instantiateViewController(withIdentifier: "NewView")
//
//            self.navigationController?.pushViewController(vc, animated: true)

            
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "TicketsViewController")
            let navController = UINavigationController(rootViewController: VC1)
            self.present(navController, animated:true, completion: nil)

//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let rootVC = storyboard.instantiateViewController(withIdentifier: "AddTicketViewController") as! UINavigationController
//            let playVC = storyboard.instantiateViewController(withIdentifier: "TicketsViewController")
//            window?.rootViewController?.presentViewController(rootVC, animated: true, completion: { () -> Void in
//                rootVC.pushViewController(playVC, animated: true)
//            })
            
            //let viewControllerYouWantToPresent = self.storyboard?.instantiateViewController(withIdentifier: "TicketsViewController")
            //self.present(viewControllerYouWantToPresent!, animated: true, completion: nil)
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)

    }
    
    // ************** ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        createDatePicker()
        createStatusPicker()
        createToolbar()
        initializeTheLocationManager()
        self.mapView.isMyLocationEnabled = true
    }

}



