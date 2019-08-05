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
    
    // MARK: - Properties
    
    var viewModel: MapViewModel!
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

        viewModel.image
            .subscribe(onNext: { [weak self] image in
                // TODO: - Implement passing in new VC if it necessary ( but this image is alredy in Map Coordinator)
                guard let self = self else { return }
                print("Image in MapViewController = \(image)")
            })
            .disposed(by: bag)
        
        
        cameraButton.rx.tap
            .bind(to: viewModel.cameraButtonTapped)
            .disposed(by: bag)
        
        locationButton.rx.tap
            .bind(to: viewModel.locationButtonTapped)
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
                default: break
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
}

