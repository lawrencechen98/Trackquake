//
//  ViewController.swift
//  Trackquake
//
//  Created by Lawrence Chen on 12/28/16.
//  Copyright © 2016 Lawrence Chen. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreLocation

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var id: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, id: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.id = id;
    }
}

class ViewController: UIViewController, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate{
    
    enum Magnitude{
        case all
        case four
        case two
        case significant
    }
    enum TimeFrame{
        case hour
        case day
        case week
        case month
    }
    
    var loaded:Bool = false
    var magnitude: Magnitude = .all
    var timeFrame: TimeFrame = .day
    var earthquakes: Int = 5
    var json: [String:AnyObject] = ["":"" as AnyObject]
    let regionRadius: CLLocationDistance = 50000
    var pinArray: [MapPin] = []
    
    @IBOutlet var resetButton: UIBarButtonItem!
    @IBOutlet var indicator: UIActivityIndicatorView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var tableView: UITableView!
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loaded = false
        refresh()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        self.mapView.setRegion(region, animated: true)
    }


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapPin {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            return view
        }
        return nil
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnLocation(location: CLLocation, radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.earthquakes
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "earthquake", for: indexPath) as! EarthquakeCell
        
        if let features: [AnyObject] = self.json["features"] as! [AnyObject]? {
            
            let earthquake = features[indexPath.row] as! [String:AnyObject]
            let properties = earthquake["properties"] as! [String:AnyObject]
            let geometry = earthquake["geometry"] as! [String:AnyObject]
            let coordinates = geometry["coordinates"] as! [Double]
            let idString = earthquake["id"] as! String
            let place = properties["place"] as! String
            let index = place.characters.index(of:",")
            var city: String
            var description: String
            if (index != nil){
                let index2 = place.characters.index(index!, offsetBy: 2)
                description = place.substring(to: index!)
                city = place.substring(from: index2)
            }else{
                city = place
                description = place
            }
            
            
            if let mag = properties["mag"] as? Double{
                cell.magLabel.text = String(format: "%.1f", mag)
                let level = 1.0 - (mag - 2.5)/10.0
                if(mag >= 2.5){
                    cell.magLabel.textColor = UIColor(red: 1.0, green: CGFloat(level), blue: 0.6, alpha: 1.0)
                }else if(mag >= 1.0){
                    cell.magLabel.textColor = UIColor(red: 0.8, green: 1.0, blue: 0.6, alpha: 1.0)
                }else{
                    cell.magLabel.textColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
                }
            }
            let time = properties["time"] as! TimeInterval
            let date = NSDate(timeIntervalSince1970: time/1000)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss"
    
            
            cell.mainLabel.text = city
            cell.timeLabel.text = "\(dateFormatter.string(from: date as Date))"
            cell.locationLabel.text = description
            cell.coordinates = coordinates
            cell.idString = idString;
        }

        return cell
    }
    
    @IBAction func refreshButton(_ sender: Any) {
        refresh()
    }
 
    func refresh() -> Void{
        indicator.startAnimating()
        self.resetButton.tintColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        self.resetButton.isEnabled = false
        var magstring:String?
        var timestring:String?
        switch magnitude{
        case .all:
            magstring = "all"
        case .four:
            magstring = "4.5"
        case .two:
            magstring = "2.5"
        case .significant:
            magstring = "significant"
        }
        switch timeFrame{
        case .day:
            timestring = "day"
        case .hour:
            timestring = "hour"
        case .week:
            timestring = "week"
        case .month:
            timestring = "month"
        }
        let requestURL: NSURL = NSURL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/\(magstring!)_\(timestring!).geojson")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared

        let task = session.dataTask(with: urlRequest as URLRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                print("Everyone is fine, file downloaded successfully.")
                do{
                    
                    self.json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
                    
                }catch {
                    print("Error with Json: \(error)")
                }
            }
            DispatchQueue.main.async() {
                
                if let features: [AnyObject] = self.json["features"] as! [AnyObject]? {
                    print(features.count)
                    self.earthquakes =  (features.count > 3000 ? 3000 : features.count)
                    print (self.earthquakes)
                    for i in 0..<self.earthquakes{
                        
                        let earthquake = features[i] as! [String:AnyObject]
                        let geometry = earthquake["geometry"] as! [String:AnyObject]
                        let coordinates = geometry["coordinates"] as! [Double]
                        let longitude = coordinates[0]
                        let latitude = coordinates[1]
                        let idString = earthquake["id"] as! String
                        let properties = earthquake["properties"] as! [String:AnyObject]
                        let place = properties["place"] as! String
                        var mag = properties["mag"] as! Double
                        mag = Double(round(10*mag)/10)
                        
                        
                        let point = MapPin(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                           title: place,
                                           subtitle: "Magnitude: \(mag)", id: idString)
                        
                        self.mapView.addAnnotation(point)
                        self.pinArray.append(point)
                    }
                }
                
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                    if let location = self.mapView.userLocation.location{
                        print (location)
                        self.centerMapOnLocation(location: location)
                    }else{
                        print("No location yet")
                    }
                    self.indicator.stopAnimating()
                    self.resetButton.tintColor = UIColor(red: 0.73, green: 0.49, blue: 1.0, alpha: 1.0)
                    self.resetButton.isEnabled = true
                    self.loaded = true
                    print("loaded")
                })
            }
            
        }
        task.resume()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        //not finished yet
        if (!loaded){
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        let selectedCell:EarthquakeCell = tableView.cellForRow(at: indexPath as IndexPath)! as! EarthquakeCell
        var coordinates = selectedCell.coordinates;
        print(coordinates);
        let location = CLLocation(latitude: coordinates[1], longitude: coordinates[0])
        //resolution
        self.centerMapOnLocation(location: location, radius: 1000000)
        let idString = selectedCell.idString
        var selectedAnnotation = MapPin(coordinate: location.coordinate, title: "temp", subtitle: "temp", id: idString)

        for annotation in pinArray as [MapPin]{
            if(annotation.id == idString){
                selectedAnnotation = annotation
                print(selectedAnnotation);
                mapView.selectAnnotation(selectedAnnotation, animated: true)
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        let newView = segue.destination as! SettingController
        if (segue.identifier == "settingButton"){
            newView.magnitude = magnitude
            newView.timeFrame = timeFrame
        }
    }

    

}

