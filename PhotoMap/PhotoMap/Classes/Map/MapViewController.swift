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
import RxMKMapView

class MapViewController: UIViewController, StoryboardInitializable {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    // MARK: - Properties
    
    var viewModel: MapViewModel!
    private let bag = DisposeBag()
    private let locationManager = CLLocationManager()
    private let longPressGesture = UILongPressGestureRecognizer()
    private var location: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        locationManager.rx.didUpdateLocations
            .subscribe(onNext: { locations in
                // TODO: - Process location data here
            })
            .disposed(by: bag)

        mapView.register(PostAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        mapView.rx.didSelectAnnotationView
            .filter { !($0.annotation is MKUserLocation) }
            .bind(onNext: { view in
                let postAnnotation = view.annotation as! PostAnnotation
                
                let calloutView = CustomCalloutView()
                calloutView.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(calloutView)
                
                NSLayoutConstraint.activate([
                    calloutView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    calloutView.bottomAnchor.constraint(equalTo: view.topAnchor),
                    calloutView.heightAnchor.constraint(equalToConstant: 100),
                    calloutView.widthAnchor.constraint(equalToConstant: 300)
                    ])
                
                calloutView.photoImage.image = postAnnotation.image
                calloutView.descriptionLabel.text = postAnnotation.postDescription
                calloutView.dateLabel.text = postAnnotation.date

                self.mapView.setCenter((view.annotation?.coordinate)!, animated: true)
            })
            .disposed(by: bag)
        
        mapView.rx.didDeselectAnnotationView
            .filter { $0 is PostAnnotationView }
            .bind(onNext: { view in
                for subview in view.subviews {
                    subview.removeFromSuperview()
                }
            })
            .disposed(by: bag)
        
        longPressGesture.rx.event
            .filter { $0.state == .began }
            .do(onNext: { (recognizer) in
                let touchPoint = recognizer.location(in: self.mapView)
                let touchCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
                let touchLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
                self.location = touchLocation
            })
            .map { _ in return Void() }
            .bind(to: viewModel.cameraButtonTapped)
            .disposed(by: bag)
        
        viewModel.post
            .subscribe(onNext: { post in
                guard let coordinate = self.location?.coordinate else { return }
                post.coordinate = coordinate
                self.mapView.addAnnotation(post)
            })
            .disposed(by: bag)
        
        viewModel.showImageSheet
            .subscribe(onNext: { _ in
                self.displayImageSheet()
            })
            .disposed(by: bag)
        
        cameraButton.rx.tap
            .do(onNext: { self.location = self.locationManager.location })
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
        mapView.addGestureRecognizer(longPressGesture)
        
        mapView.showsUserLocation = true
        
        locationButton.setImage(UIImage(named: "discover"), for: .normal)
        locationButton.setImage(UIImage(named: "follow"), for: .selected)
    }
    
    private func displayImageSheet() {
        let photoMenu = UIAlertController(title: "Just a text for little test", message: "Choose one because i am Ivan", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Take a Picture", style: .default, handler: { _ in
            // TODO: - Camera
        })
        let libraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
            self.viewModel.photoLibrarySelected.onNext(Void())
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        photoMenu.addAction(cameraAction)
        photoMenu.addAction(libraryAction)
        photoMenu.addAction(cancelAction)
        present(photoMenu, animated: true, completion: nil)
    }
}
