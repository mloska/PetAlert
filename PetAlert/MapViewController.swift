//
//  MapViewController.swift
//  PetAlert
//
//  Created by Claudia on 07.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

struct MyPlace {
    var name: String
    var lat: Double
    var long: Double
}


class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    
    @IBAction func filterTapped(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "PopoverFilterViewController") as! PopoverFilterViewController
        vc.preferredContentSize.width = UIScreen.main.bounds.width
        vc.preferredContentSize.height = 180

        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popover = navController.popoverPresentationController
        popover?.delegate = self
        popover?.barButtonItem = sender as? UIBarButtonItem
        self.present(navController, animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        let radiusSliderValue = Shared.shared.radiusValue
        radiusFromSlider = Shared.shared.radiusValue
        breedFromInput = Shared.shared.breedChoice == "Select Breed" ? "" : Shared.shared.breedChoice

        print (breedFromInput)
//        sourceForMainMapFunction = "mainView"
        print("Wywoluje reloadDataOnMap z popoverPresentationControllerDidDismissPopover place z lat = ", drawLat, ", long = ", drawLong)
        reloadDataOnMap(lat: (drawLat), long: (drawLong), rad: Double(radiusSliderValue))
    }
    
    //Web service url
    let URL_GET_PETS_RADIUS_STR = "https://serwer1878270.home.pl/WebService/api/getallpetsforselectedradius.php"
    var petsArrayMap:[Pet]? = []
    var locationManager = CLLocationManager()
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    var chosenMarkerID: Int = 0
    var chosenPlace: MyPlace?
    var breedFromInput: String = ""
    var drawLat: Double = 0.0
    var drawLong: Double = 0.0
    var radiusFromSlider:Int = 0
    var sourceForMainMapFunction: String = ""
    // don't fire viewWillAppear at first open
    var firstLoad: Bool = true
    var bounds = GMSCoordinateBounds()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //initializeTheLocationManager()
        mapView.delegate = self
        txtFieldSearch.delegate = self

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        let coordinateValues = locationManager.location?.coordinate
        
        drawLat = (coordinateValues?.latitude)!
        drawLong = (coordinateValues?.longitude)!
        
        Shared.shared.radiusValue = 10
        radiusFromSlider = Shared.shared.radiusValue
        
        breedFromInput = Shared.shared.breedChoice == "Select Breed" ? "" : Shared.shared.breedChoice

        setupSearchField()
        initGoogleMaps(lat: (drawLat), long: (drawLong))
        
        customMarkerPreviewView=CustomMarkerPreviewView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width-100, height: 190))
        sourceForMainMapFunction = "mainView"
        print("Wywoluje reloadDataOnMap z viewDidLoad place z lat = ", drawLat, ", long = ", drawLong)
        reloadDataOnMap(lat: (drawLat), long: (drawLong), rad: Double(radiusFromSlider))
        firstLoad = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !firstLoad {
            print("Wywoluje reloadDataOnMap z viewWillAppear z lat = ", drawLat, ", long = ", drawLong)
            reloadDataOnMap(lat: (drawLat), long: (drawLong), rad: Double(radiusFromSlider))
        }
        firstLoad = false
    }
    
    func initGoogleMaps(lat: Double, long: Double) {
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        
        showMarkers()
    }
    
    func reloadDataOnMap(lat: CLLocationDegrees, long: CLLocationDegrees, rad: Double){
        petsArrayMap = []
        drawLat = lat
        drawLong = long
        
        let url = "\(self.URL_GET_PETS_RADIUS_STR)" + "?centerLatitude=" + "\(lat)" + "&centerLongitude=" + "\(long)" + "&radiusKM=" + "\(rad)" + "&breed=" + "\(Shared.shared.breedChoiceID)"
        print("reloadDataOnMap: ", url)
        connectToJson(link: url, mainFunctionName: mainMapFunction)
        
    }
    
    
    
    func mainMapFunction (passedJsonArray: [[String: Any]]) {
        self.petsArrayMap = JsonToArray(inputJsonArray: passedJsonArray, downloadThumbnail: true)
        
        if (sourceForMainMapFunction == "mainView"){
            
            showMarkers()
            
            self.mapView.settings.compassButton = true
            self.mapView.settings.myLocationButton = true
            self.mapView.settings.scrollGestures = true
            self.mapView.settings.zoomGestures = true
        } else if (sourceForMainMapFunction == "afterSearchPlace"){
            

//            let camera = GMSCameraPosition.camera(withLatitude: drawLat, longitude: drawLong, zoom: 16.0)
//            self.mapView.camera = camera;

            showMarkers()

            drawMarker()
            // dostosowanie zooma automatycznie do wyswietlanych markerów
            //self.mapView.animate(with: GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(50.0 , 50.0 ,50.0 ,50.0)))

            let coordinate = CLLocationCoordinate2D(latitude: drawLat, longitude: drawLong)
            self.mapView.animate(toLocation: coordinate)
        }
    }
    
    func drawCircle (coordinate: CLLocationCoordinate2D, radius: Double){
        let circle = GMSCircle()
        //print("W drawCircle, radius =", radius)
        circle.radius = radius * 1000 // Meters
        circle.fillColor = UIColor(red: 0.09, green: 0.6, blue: 0.41, alpha: 0.5)
        circle.position = (coordinate) // Your CLLocationCoordinate2D  position
        circle.strokeWidth = 1;
        circle.strokeColor = UIColor.black
        circle.map = mapView; // Add it to the map
    }
    
    func drawMarker(){
        // to draw single marker for searched location
        let marker=GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: drawLat, longitude: drawLong)
        marker.title = "\(chosenPlace?.name ?? "")"
        marker.snippet = "\(txtFieldSearch.text!)"
        marker.map = self.mapView
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
        self.mapView?.clear()
        for (index, pet) in self.petsArrayMap!.enumerated() {
            let marker=GMSMarker()
            let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: customMarkerWidth, height: customMarkerHeight), image: pet.ImageData ?? UIImage(), borderColor: UIColor.darkGray, tag: index)
            marker.iconView=customMarker
            marker.position = CLLocationCoordinate2D(latitude: pet.Latitude, longitude: pet.Longitude)
            marker.map = self.mapView
            // dostosowanie zooma automatycznie do wyswietlanych markerów
            bounds = bounds.includingCoordinate(marker.position)
        }
        drawCircle(coordinate: (CLLocationCoordinate2D(latitude: drawLat, longitude: drawLong)), radius: Double(radiusFromSlider))
        
        // dostosowanie zooma automatycznie do wyswietlanych markerów
        self.mapView.animate(with: GMSCameraUpdate.fit(bounds, with: UIEdgeInsetsMake(50.0 , 50.0 ,50.0 ,50.0)))

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
    
    
    
    
    
    // places and search
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        drawLat = lat
        drawLong = long
        print ("skonczylem szukanie ostatniej lokalizacji. Lat: ", lat, ", Long: ", long)

        txtFieldSearch.text=place.formattedAddress
        chosenPlace = MyPlace(name: place.formattedAddress!, lat: lat, long: long)

        sourceForMainMapFunction = "afterSearchPlace"
        // nie trzeba wywoływać tutaj reloadDataOnMap, bo znikniecie okna z wyborem nowej lokalizacji z wyszukiwarki spowoduje wywowlanie reloadmapy z onViewWillAppear
        //print("Wywoluje reloadDataOnMap z didAutocompleteWith place z lat = ", drawLat, ", long = ", drawLong)
        //reloadDataOnMap(lat: lat, long: long, rad: Double(radiusFromSlider))

        self.dismiss(animated: true, completion: nil) // dismiss after place selected
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    // search
    
    let txtFieldSearch: UITextField = {
        let tf=UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .white
        tf.layer.borderColor = UIColor.darkGray.cgColor
        tf.placeholder="Search for a location"
        tf.translatesAutoresizingMaskIntoConstraints=false
        return tf
    }()
    
    func setupSearchField(){
        self.view.addSubview(txtFieldSearch)
        txtFieldSearch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive=true
        txtFieldSearch.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        txtFieldSearch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        txtFieldSearch.heightAnchor.constraint(equalToConstant: 35).isActive=true
        setupTextField(textField: txtFieldSearch, img: #imageLiteral(resourceName: "map_Pin"))
    }
    
    func setupTextField(textField: UITextField, img: UIImage){
        textField.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        imageView.image = img
        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        paddingView.addSubview(imageView)
        textField.leftView = paddingView
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        autoCompleteController.autocompleteFilter = filter
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
        return false
    }

}



