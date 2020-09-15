//
//  GoogleMapViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 5/2/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit
import GoogleMaps

class GoogleMapViewController: UIViewController,CLLocationManagerDelegate {
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var sliderOutlet: UISlider!
    
    var currentTask:Task!// a task must be passed else fail
    var mapView: GMSMapView? = nil //create a new map view object
    var locationManager: CLLocationManager!//create new location manager
    var currentLocation: CLLocation?//optional global var for user's location
    
    var clientLatitude:Double = 0.0 //the destination's latitude
    var clientLongitude:Double = 0.0 //the destination's longitude
    let MIN_ZOOM:Float = 2.0 //zoom constants for map view
    let MAX_ZOOM:Float = 20.0
    let STARTING_ZOOM:Float = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //get destination latitide and longitude from current task, store it in global var
        clientLatitude = currentTask.address.latitude
        clientLongitude = currentTask.address.longitude
        
        setupLocationManager()//setup location from user
        
        //setup slider view settings
        sliderOutlet.minimumValue = MIN_ZOOM
        sliderOutlet.maximumValue = MAX_ZOOM
        sliderOutlet.value = STARTING_ZOOM
        
        setupGoogleMapView() //setup the google map view
    }
    
    func setupGoogleMapView(){
        //pan to the destinations location and with appropiate zoom
        let camera = GMSCameraPosition.camera(withLatitude:clientLatitude , longitude: clientLongitude, zoom: STARTING_ZOOM)
        
        //create a map view visual object in the predefined view
        //NOTE: google maps renders is smaller sometimes, hard to debug issue
        mapView = GMSMapView.map(withFrame: self.mapViewContainer.bounds, camera: camera)
        
        if let mv = mapView{
            mv.accessibilityElementsHidden = false
            mv.isMyLocationEnabled = true //get user current location
            mv.settings.myLocationButton = true//show user location in map
            self.mapViewContainer.addSubview(mv)// add this to mapview
        }
        
        //create marker object at the destination's coordinations and display address
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: clientLatitude, longitude: clientLongitude)
        marker.title = NSLocalizedString("destination", comment: "")
        marker.snippet = currentTask.address.toString
        marker.map = mapView
    }
    
    @IBAction func trafficButtonClicked(_ sender: UIButton) {
        //when user clicks the toggle traffic button show opposite of current setting
        if let mapView = self.mapView{
            if mapView.isTrafficEnabled{
                mapView.isTrafficEnabled = false
            }else{
                mapView.isTrafficEnabled = true
            }
        }
    }
    
    @IBAction func getDirectionsClicked(_ sender: UIButton) {
        //if user clicks this button, send them to google maps in the browser
        var destinationString = ""
        if let cl = currentLocation{//if there is a current location for user send them with their coordinations in the destination
            destinationString = "https://www.google.com/maps/dir/?api=1&origin=\(cl.coordinate.latitude),\(cl.coordinate.longitude)&destination=\(clientLatitude),\(clientLongitude)&travelmode=driving"
        }else{
            //if users location is not set, send them with directiosn to the place and
            //allow them to put in starting destination
            destinationString = "https://www.google.com/maps/dir/?api=1&origin=&destination=\(clientLatitude),\(clientLongitude)&travelmode=driving"
        }
        
        //send them to the internet with the appropiate website address to google maps
        if let destinationURL = URL.init(string:destinationString) {
            UIApplication.shared.open(destinationURL)
        }
    }
    
    @IBAction func mapTypeChanged(_ sender: UISegmentedControl) {
        //depending on which segment the user selects, display the approaiate setting in the map view
        if let mv = self.mapView{
            switch sender.selectedSegmentIndex {
            case 0:
                mv.mapType = .normal
            case 1:
                mv.mapType = .hybrid
            case 2:
                mv.mapType = .satellite
            case 3:
                mv.mapType = .terrain
            default:
                mv.mapType = .normal
            }
        }
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        //when user slides the slider, zoom in or out depending on their value
        if let mv = mapView{
            mv.animate(toZoom: sender.value)
        }
    }
    
    
    @IBAction func viewFocusChanged(_ sender: UISegmentedControl) {
        //depending on which segment the user selects either show destination or both destination and current location in the map view
        switch sender.selectedSegmentIndex {
        case 0:
            viewClient()
        case 1:
            viewBoth()
        default:
            viewBoth()
        }
    }
    
    func viewClient(){
        //make the google map view go to the clients coordinations with appropiate zoom
        if let mv = mapView{
            mv.animate(toLocation: CLLocationCoordinate2D(latitude: clientLatitude, longitude: clientLongitude))
            mv.animate(toZoom: STARTING_ZOOM)
            sliderOutlet.setValue(STARTING_ZOOM, animated: true)
        }
    }
    
    func viewBoth(){
        //calculate the map settings to enable to see both client and self in one view
        //then set the google map camera to those bounds with appropiate zoom
        if let cl = self.currentLocation{//only if users current location is set
            if let mv = self.mapView{
                let userLocation = CLLocationCoordinate2D(latitude: cl.coordinate.latitude, longitude: cl.coordinate.longitude)
                let clientLocation = CLLocationCoordinate2D(latitude: clientLatitude,longitude: clientLongitude)
                let bounds = GMSCoordinateBounds(coordinate: userLocation, coordinate: clientLocation)
                let camera = mv.camera(for: bounds, insets: UIEdgeInsets())!
                mv.camera = camera
                sliderOutlet.setValue(camera.zoom-0.5, animated: true)
                mv.animate(toZoom: camera.zoom-0.5)
            }
        }
    }
    
    func setupLocationManager(){
        //create location manager instance and setup settings then update users location
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get users current location from location manager
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        self.currentLocation = userLocation
    }
}
