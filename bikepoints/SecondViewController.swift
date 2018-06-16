//
//  SecondViewController.swift
//  bikepoints
//
//  Created by Eric Hunzeker on 6/15/18.
//  Copyright © 2018 Eric Hunzeker. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class SecondViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var blur: UIVisualEffectView!
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var mileslabel: UILabel!
    var locationManager = CLLocationManager()
    private var locationList: [CLLocation] = []
    private var dist = Measurement(value: 0, unit: UnitLength.meters)

    private var currentLocation: CLLocation?
    @IBOutlet weak var stopbutton: UIButton!
    @IBOutlet weak var startbutton: UIButton!
    @IBOutlet weak var timer: UILabel!
    @IBOutlet weak var distance: UILabel!
    var seconds = 0
    var time : Timer?

    
    @IBAction func clickstart(_ sender: UIButton) {
        startbutton.isHidden = true
        stopbutton.isHidden = false
        seconds = 0
        dist = Measurement(value: 0, unit: UnitLength.meters)
        timer.text = timeformat(0)
        distance.text = distanceformat(0)
        time = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.eachSecond()
        }
        locationManager.startUpdatingLocation()
        blur.isHidden = true
        
        mileslabel.text = nil

    }
    func eachSecond() {
        seconds += 1
        updateDisplay()
    }
    
    private func updateDisplay() {
        let formattedTime = timeformat(seconds)
        let formattedDist = distanceformat(dist)
        
        timer.text = "\(formattedTime)"
        distance.text = "\(formattedDist)"
    }
    
    func timeformat(_ seconds: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(seconds))!
    }
    
    
    func distanceformat(_ distance: Double) -> String {
        let distanceMeasurement = Measurement(value: distance, unit: UnitLength.meters)
        return distanceformat(distanceMeasurement)
    }
    
    func distanceformat(_ distance: Measurement<UnitLength>) -> String {
        let formatter = MeasurementFormatter()
        return formatter.string(from: distance)
    }
    
    @IBAction func clickstop(_ sender: UIButton) {
        startbutton.isHidden = false
        stopbutton.isHidden = true
        
        time?.invalidate()
        locationManager.stopUpdatingLocation()
        blur.isHidden = false
        let formattedDist = distanceformat(dist)

        mileslabel.text = "you earned \(formattedDist)les"
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self
        map.showsUserLocation = true
        map.userTrackingMode = MKUserTrackingMode.follow
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        stopbutton.isHidden = true
        blur.isHidden = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        defer { currentLocation = locations.last }
        
        for newLocation in locations {
            let howRecent = newLocation.timestamp.timeIntervalSinceNow
            guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
            
            if let lastLocation = locationList.last {
                let delta = newLocation.distance(from: lastLocation)
                dist = dist + Measurement(value: delta, unit: UnitLength.meters)
            }
            
            let viewRegion = MKCoordinateRegionMakeWithDistance(newLocation.coordinate, 200, 200)
            map.setRegion(viewRegion, animated: true)
            
            locationList.append(newLocation)
        }
        
        if currentLocation == nil {
            // Zoom to user location
            if let userLocation = locations.last {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 200, 200)
                map.setRegion(viewRegion, animated: false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

