//
//  ViewController.swift
//  NewBrightonMurals
//
//  Created by Moldovan, Eusebiu on 09/12/2022.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate , CLLocationManagerDelegate{
    
    //----  Variables
    
    var locationManager = CLLocationManager()
    var firstRun = true
    var startTrackingTheUser = false
    var locationOfUser = CLLocation()
    var location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var dictionary = [String:UIImage]()
    
    
    //----  References
    
    @IBOutlet weak var theTable: UITableView!
    
    @IBOutlet weak var theMap: MKMapView!
    
    @IBOutlet weak var centreButton: UIButton!
    
    @IBAction func reCentre(_ sender: Any) {
        theMap.setCenter(location, animated: true)
        if startTrackingTheUser == true{
            startTrackingTheUser = false
            centreButton.setImage(UIImage(systemName: "location.north.circle"), for: .normal)
        } else {
            startTrackingTheUser = true;
            centreButton.setImage(UIImage(systemName: "location.north.circle.fill"), for: .normal)
        }
    }
    //----- ViewDidLoad (Main func)
    
    override func viewDidLoad() {
        
        //----  Getting data from API
        super.viewDidLoad()
        if let url = URL(string: "https://cgi.csc.liv.ac.uk/~phil/Teaching/COMP228/nbm/data2.php?class=newbrighton_murals") {
            let session = URLSession.shared
            session.dataTask(with: url) { (data, response, err) in
                guard let jsonData = data else {
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let muralList = try decoder.decode(muralsCollection.self, from: jsonData)
                    self.murals = muralList
                    for place in self.murals!.newbrighton_murals{
                        if let thumbURL = URL(string:(place.thumbnail)!){
                            if let data = try? Data(contentsOf: thumbURL){
                                if let thumbnail = UIImage(data: data){
                                    self.dictionary[place.id] = thumbnail
                                }
                            }
                        }
                        self.addMural(place)
                    }
                    DispatchQueue.main.async {
                        self.updateTheTable()
                    }
                } catch let jsonErr {
                    print("Error decoding JSON", jsonErr)
                }
            }.resume()
            print("You are here!")
            
            
        }
        
        //----  Location Setup
        locationManager.delegate = self as CLLocationManagerDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        theMap.showsUserLocation = true
        
    }

    //-----  Location/Map Related
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        locationOfUser = locations[0]
        let latitude = locationOfUser.coordinate.latitude
        let longitude = locationOfUser.coordinate.longitude
        location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        //If this is run for the first time, it centres on the user
        if firstRun {
            firstRun = false
            let latDelta: CLLocationDegrees = 0.0025
            let lonDelta: CLLocationDegrees = 0.0025
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
            let region = MKCoordinateRegion(center: location, span: span)
            self.theMap.setRegion(region, animated: true)
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(startUserTracking), userInfo: nil, repeats: false)
        }
        
        //If user is tracked than the map centre is set on the user
        if startTrackingTheUser == true{
            theMap.setCenter(location, animated: true)
        }
        
        //Sorting the table and murals by distance from the user
        if let listMurals = murals?.newbrighton_murals{
            var listMurals2 = listMurals
            listMurals2.sort(by:calculateDis)
            murals?.newbrighton_murals = listMurals2
            theTable.reloadData()
        }
    }
    
    //If an annotation is selected, it takes the user to the detail view of said mural
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotation){
        let title = view.title
        for m in murals!.newbrighton_murals{
            if title == m.title{
                passMural = m
                performSegue(withIdentifier: "toDetail", sender: nil)
            }
        }
    }
    
    //This function is used to compare the distance to user from two murals and see which one is closer to the user
    func calculateDis(mural1: muralStructure, mural2:muralStructure) -> Bool {
        let lat1 = Double(mural1.lat)
        let lon1 = Double(mural1.lon)
        let coordinate1 = CLLocation(latitude: lat1!, longitude: lon1!)
        let distance1 = coordinate1.distance(from: locationOfUser)
        
        let lat2 = Double(mural2.lat)
        let lon2 = Double(mural2.lon)
        let coordinate2 = CLLocation(latitude: lat2!, longitude: lon2!)
        let distance2 = coordinate2.distance(from: locationOfUser)
        return distance1 < distance2
    }
    
    //Function used to start tracking the user
    @objc func startUserTracking(){
        startTrackingTheUser = true
    }
    
    //Mural is added as annotation
    func addMural(_ mural: muralStructure){
        guard let lat = Double(mural.lat) else { return }
        guard let lon = Double(mural.lon) else {return }
        guard let title = mural.title else { return }
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        self.theMap.addAnnotation(annotation)
    }

    
    //------ Table Related
    
    //Variables
    var murals:muralsCollection? = nil
    var mural:muralStructure? = nil
    var passMural:muralStructure? = nil
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return murals?.newbrighton_murals.count ?? 1
    }
    
    //Set the cells to correct title, subtitle, and thumbnails
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "theCell", for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        content.text = murals?.newbrighton_murals[indexPath.row].title ?? "no title"
        content.secondaryText = murals?.newbrighton_murals[indexPath.row].artist ?? "no authors"
        content.image = dictionary[murals?.newbrighton_murals[indexPath.row].id ?? ""]
        cell.contentConfiguration = content
        return cell
    }
    
    //Once user selects a row in the tabel, seue is performed and mural is passed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        passMural = murals?.newbrighton_murals[indexPath.row]
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    //Before segue happens, we send the muralobject to the dtail view controller to then use it to display the data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            let viewController = segue.destination as! DetailViewController
            viewController.mural = passMural
            passMural = nil
        }
    }
    
    //Function used to reload the data in the table
    func updateTheTable(){
        theTable.reloadData()
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
