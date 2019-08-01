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
    @IBOutlet weak var cameraButton: UIButton!
    
    // MARK: Properties
    
    private let bag = DisposeBag()
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        
        locationManager.rx.didUpdateLocations
            .subscribe(onNext: { locations in
                // TODO: - Process location data here
            })
            .disposed(by: bag)

        
        cameraButton.rx.tap.asObservable()
            .subscribe(onNext: {
                
                // TODO: - Show Action Sheet (Think through the logic. Perhaps through the RX.
                // Is it possible to send the answer in the form of enum to the coordinator through the model?)
                
                self.displayActionSheet()
            })
            .disposed(by: bag)
        
        
        locationButton.rx.tap.asObservable()
            .subscribe(onNext: {
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    if self.locationButton.isSelected {
                        self.mapView.userTrackingMode = .none
                    } else {
                        self.mapView.userTrackingMode = .follow
                    }
                default:
                    // TODO: - Rename function
                    self.needMap()
                }
            })
            .disposed(by: bag)

        
        mapView.rx.didChangeUserTrackingMode
            .subscribe(onNext: { _ in
                self.locationButton.isSelected = !self.locationButton.isSelected
            })
            .disposed(by: bag)
        
        
        locationManager.rx.didChangeAuthorization
            .subscribe(onNext: { status in
                switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    self.mapView.userTrackingMode = .follow
                case .notDetermined, .restricted, .denied:
                    self.mapView.userTrackingMode = .none
                @unknown default:
                    break
                }
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
    
    // TODO: - Replace alerts ????
    
    private func displayActionSheet() {
        let photoMenu = UIAlertController(title: "Just a text for little test", message: "Choose one because i am Ivan", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a Picture", style: .default)
        let libraryAction = UIAlertAction(title: "Choose From Library", style: .default)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        photoMenu.addAction(cameraAction)
        photoMenu.addAction(libraryAction)
        photoMenu.addAction(cancelAction)
        
        self.present(photoMenu, animated: true, completion: nil)
    }
    
    private func needMap() {
        
        // initialise a pop up for using later
        let alertController = UIAlertController(title: "TITLE", message: "Please go to Settings and turn on the permissions", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        

        self.present(alertController, animated: true, completion: nil)
    }
}

