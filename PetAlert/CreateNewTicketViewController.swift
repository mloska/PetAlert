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

    var pets:[PetEntity]? = nil
    
    // inputs from storyboard
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var breedInput: UITextField!
    @IBOutlet weak var colorInput: UITextField!
    @IBOutlet weak var imageCtr: UIImageView!
    
    // status
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
        
        CoreDataHelper.saveObject(
            name: nameInput.text!,
            breed: breedInput.text!,
            color: colorInput.text!,
            status: selectedStatus,
            image: "",
            city: city,
            street: street,
            longitude: finalLongitude,
            latitude: finalLatitude,
            lastdate: lastSeenDateInput.text!,
            uuid: UUID().uuidString,
            dateTimeModification: NSDate(),
            imageBinary: imageData,
            petType: "Dog",
            userID: 21
            
        )
        
        print("Dodano")
        pets = CoreDataHelper.fetchObject()
        print(print(pets?.count ?? 0))
        
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



