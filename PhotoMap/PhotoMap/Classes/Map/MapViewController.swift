//
//  ViewController.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import MapKit
import CoreLocation

class MapViewController: UIViewController, StoryboardInitializable {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK: Properties
    
    private let bag = DisposeBag()
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        // TODO: - Change button color
        
        locationManager.rx.didUpdateLocations
            .subscribe(onNext: { locations in
                // TODO: - Process location data here
            })
            .disposed(by: bag)

        
        locationButton.rx.tap.asObservable()
            .subscribe(onNext: {
                if self.locationButton.isSelected {
                    self.mapView.userTrackingMode = .none
                } else {
                    self.mapView.userTrackingMode = .follow
                }
            })
            .disposed(by: bag)

        
        mapView.rx.didChangeUserTrackingMode
            .subscribe(onNext: { mode in
                switch mode {
                case .none:
                    self.locationButton.isSelected = false
                case .follow:
                    self.locationButton.isSelected = true
                default:
                    print("Unkown mode")
                }
            })
            .disposed(by: bag)
        
        
        mapView.rx.mapViewDidFinishLoadingMap
            .subscribe(onNext: { map in
                map.userTrackingMode = .follow
            })
            .disposed(by: bag)
        }
    
    // MARK: - Private Methods
    
    private func setupView() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        locationButton.setImage(UIImage(named: "discover"), for: .normal)
        locationButton.setImage(UIImage(named: "follow"), for: .selected)
    }

}

