//
//  AddressLookupViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/23/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit
import MapKit
import CoreLocation
import Network

class AddressLookupViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate,CLLocationManagerDelegate{
    
    @IBOutlet weak var searchBarOutlet: UISearchBar!
    @IBOutlet weak var tableViewOutlet: UITableView!
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var addressResults: [MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewOutlet.dataSource = self
        tableViewOutlet.delegate = self
        searchBarOutlet.delegate = self
        
        //call these setup functions
        setupUserLocation()
        checkInternetConnection()
        loadFromDefaults()
        
        searchBarOutlet.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //when view appears again, show keyboard and load address from defaults if any
        searchBarOutlet.becomeFirstResponder()
        loadFromDefaults()
    }
    
    func checkInternetConnection(){
        //checks internet connection using nwpathmontor
        //if there is not connection tell user they must have connection to continue
        let nwpm = NWPathMonitor()
        nwpm.pathUpdateHandler = {handler in
            if handler.status != .satisfied {//if there is no connection, show alert informing them
                let alertController = UIAlertController(title: NSLocalizedString("No_internet", comment: ""), message: NSLocalizedString("No_internet_message", comment: ""), preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
                }
                alertController.addAction(okAction)
                self.present(alertController,animated: true,completion: nil)
            }
        }
        
        let q = DispatchQueue(label: "Monitor")//create dispatch queue
        nwpm.start(queue: q)//start the queue monotoring
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //get the users's current location and store it in the global var
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        self.currentLocation = userLocation
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        requestLocations(text:searchText)//when the user changes value of search bar, update search request
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //when return key is pressed , hide keyboard
        searchBar.resignFirstResponder()
    }
    
    func setupUserLocation(){
        //using a new instance of location manager , start update the user's current location
        self.locationManager = CLLocationManager()
        if let lm = self.locationManager{
            lm.delegate = self
            lm.desiredAccuracy = kCLLocationAccuracyBest
            lm.requestWhenInUseAuthorization()
            lm.startUpdatingLocation()
            
            if CLLocationManager.locationServicesEnabled() {
                lm.startUpdatingLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //check if user has granted location access, tell to grant if not
        switch status {
            case .restricted: fallthrough
            case .denied: fallthrough
            case .notDetermined:
                displayLocationAlert()
                break;
            case .authorizedAlways: fallthrough
            case .authorizedWhenInUse:
                print("User granted location access!")
            default:
                print("Unknown error occured when user changed location authorization")
        }
    }
    
    func displayLocationAlert(){
        //display alert telling user they must allow location access
        let alertController = UIAlertController(title:NSLocalizedString("location_error", comment: ""), message: NSLocalizedString("location_error_message", comment: ""), preferredStyle: .alert)
           
            let settingsSender = UIAlertAction(title: NSLocalizedString("go_settings", comment: ""), style: .default) { (UIAlertAction) in

                if let destinationURL = NSURL(string: UIApplication.openSettingsURLString) as URL? {
                     UIApplication.shared.open(destinationURL)
                 }
            }
        
           //add this action to the alert controller
           alertController.addAction(settingsSender)
           self.present(alertController,animated: true,completion: nil) //present this view controller
    }
    
    func requestLocations(text:String){
        //searches for address user typed in
        if !text.isEmpty{//if the text is not empty from serach bar
            let request = MKLocalSearch.Request()//create request object
            request.naturalLanguageQuery = text//set the text as query
            if let currLocation = currentLocation{//if the user has set current location
                //create a region for the local search request to aid in better serach results
                request.region = MKCoordinateRegion(center: currLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100))
            }
            let search = MKLocalSearch(request: request)//create a search object with the request
            search.start { (response, error) in //start the requestion
                if let response = response{//if there is a result
                    self.addressResults = response.mapItems//store results in gloabl array
                    self.tableViewOutlet.reloadData()//reload table view with new ata
                }
            }
        }else{
            self.addressResults = []//if text is empty,delete array and reload table view
            self.tableViewOutlet.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //when a user select a certain search result from table view
        //get the location's various address data properties and store them in appropiate userdefaults key
        if let indexPath = tableViewOutlet.indexPathForSelectedRow{
            let selectedPlacemark = addressResults[indexPath.row].placemark
            UserDefaults.standard.set(selectedPlacemark.coordinate.latitude, forKey: "latitude")
            UserDefaults.standard.set(selectedPlacemark.coordinate.longitude, forKey: "longitude")
            UserDefaults.standard.set("\(selectedPlacemark.subThoroughfare ?? "") \(selectedPlacemark.thoroughfare ?? "") ",forKey: "AddressName")
            UserDefaults.standard.set(selectedPlacemark.locality,forKey: "City")
            UserDefaults.standard.set(selectedPlacemark.administrativeArea,forKey: "State")
            UserDefaults.standard.set(selectedPlacemark.country,forKey: "Country")
            UserDefaults.standard.set(selectedPlacemark.postalCode, forKey: "ZipCode")
        }
    }
    
    func loadFromDefaults(){
        //if the user has previously typed in an address , get the address name and put in search bar
        //then request the location object for that address
        if let addressName = UserDefaults.standard.string(forKey: "AddressName"){
            searchBarOutlet.text = addressName
            requestLocations(text: addressName)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //set the number of cells == to the number of results returned
        addressResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //creata a new cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "addressCell", for: indexPath) as! AddressTableViewCell
        let thisPlacemark = addressResults[indexPath.row].placemark//get the place mark object for this locaiton
        if let placemarkNameLabel = cell.placemarkNameLabel{
            //if it has a street address, display it
            var streetAddress = ""
            if let subThoroughfare = thisPlacemark.subThoroughfare{
                streetAddress += subThoroughfare + " "
            }
            if let thoroughfare = thisPlacemark.thoroughfare{
                streetAddress += thoroughfare + " "
            }
            placemarkNameLabel.text = streetAddress
        }
        if let provinceNameLabel = cell.provinceNameLabel{
            //if the following are available from the placemark returned, then set respective variables ==
            // the content returned
            var provinceNameLabelText = ""
            if let thisItemCity = thisPlacemark.locality{
                provinceNameLabelText += "\(thisItemCity)"
            }
            if let thisItemState = thisPlacemark.administrativeArea{
                provinceNameLabelText += ", \(thisItemState)"
            }
            if let thisItemCountry = thisPlacemark.isoCountryCode{
                provinceNameLabelText += ", \(thisItemCountry)"
            }
            if let thisItemPostalCode = thisPlacemark.postalCode{
                provinceNameLabelText += ", \(thisItemPostalCode)"
            }
            
            provinceNameLabel.text = provinceNameLabelText//upate lable to include this information
        }
        
        if let currentLocation = self.currentLocation{
            if let thisLocation = thisPlacemark.location{
                //get the distance from user and returned location then conver it to miles
                let distance = currentLocation.distance(from: thisLocation)/1609// in miles
                if(distance <= 1){//if less than one mile display this
                    cell.milesLabel.text = "<1 \(NSLocalizedString("mile_away", comment: ""))"
                }else{//else display this
                    cell.milesLabel.text = String(format: "%.2f\n \(NSLocalizedString("miles_away", comment: ""))", distance)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //set cell height to 75
        return 75
    }
    
}
