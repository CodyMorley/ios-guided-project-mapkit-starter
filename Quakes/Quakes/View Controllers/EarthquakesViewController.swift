//
//  EarthquakesViewController.swift
//  Quakes
//
//  Created by Paul Solt on 10/3/19.
//  Copyright © 2019 Lambda, Inc. All rights reserved.
//

import UIKit
import MapKit

class EarthquakesViewController: UIViewController {
	//MARK: - Properties -
	@IBOutlet var mapView: MKMapView!
    
    var quakeFetcher = QuakeFetcher()
	
    
    //MARK: - Life Cycles -
	override func viewDidLoad() {
		super.viewDidLoad()
		
        mapView.delegate = self
        mapView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: "QuakeView")
        
        quakeFetcher.fetchQuakes { [weak self] (quakes, error) in
            guard let self = self else { return }
            if let error = error {
                NSLog("Error fetching quakes. Here's what happened: \(error) \(error.localizedDescription)")
            }
            
            guard let quakes = quakes else {
                NSLog("No quakes returned")
                return
            }
            
            let first50Quakes = Array(quakes.dropFirst(3000))
            
            DispatchQueue.main.async {
                self.mapView.addAnnotations(first50Quakes)
                
                ///zoom into the first earthquake
                guard let firstQuake = first50Quakes.first else { return }
                //let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
                //let region = MKCoordinateRegion(center: firstQuake.coordinate, span: span)
                let region = MKCoordinateRegion(center: firstQuake.coordinate,
                                                latitudinalMeters: 1000,
                                                longitudinalMeters: 1000)
                self.mapView.setRegion(region, animated: true)
            }
        }
	}
}


extension EarthquakesViewController: MKMapViewDelegate {
    ///operates similarly to cellForRowAt indexPath in a UITableView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let quake = annotation as? Quake else {
            fatalError("Only quake objects are supported right now.")
        }
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "QuakeView",
                                                                         for: quake) as? MKMarkerAnnotationView else {
                                                                            fatalError("Missing registered map annotation views.")
        }
        
        annotationView.glyphImage = UIImage(named: "QuakeIcon")
        
        switch quake.magnitude {
        case -10..<0:
            annotationView.markerTintColor = .systemGray
        case 0..<3:
            annotationView.markerTintColor = .systemYellow
        case 3..<5:
            annotationView.markerTintColor = .systemOrange
        default:
            annotationView.markerTintColor = .systemRed
        }
        
        annotationView.canShowCallout = true
        let detailView = QuakeDetailView()
        detailView.quake = quake
        annotationView.detailCalloutAccessoryView = detailView
        
        return annotationView
    }
}
