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
    private var postAnnotation: PostAnnotation!
    private let spinner = UIActivityIndicatorView(style: .gray)
    
    private lazy var calloutView: CustomCalloutView = {
        let view = CustomCalloutView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        viewModel.isLoading
            .map { !$0 }
            .bind(to: spinner.rx.isHidden)
            .disposed(by: bag)
        
        viewModel.isLoading
            .bind(to: spinner.rx.isAnimating)
            .disposed(by: bag)

        mapView.register(PostAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        calloutView.detailButton.rx.tap
            .compactMap { self.postAnnotation }
            .bind(to: viewModel.fullPhotoTapped)
            .disposed(by: bag)
        
        viewModel.shortDate
            .bind(to: calloutView.dateLabel.rx.text)
            .disposed(by: bag)
        
        mapView.rx.didSelectAnnotationView
            .filter { !($0.annotation is MKUserLocation) }
            .bind(onNext: { view in
                self.postAnnotation = view.annotation as? PostAnnotation
                view.addSubview(self.calloutView)
                
                NSLayoutConstraint.activate([
                    self.calloutView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    self.calloutView.bottomAnchor.constraint(equalTo: view.topAnchor),
                    self.calloutView.heightAnchor.constraint(equalToConstant: 100),
                    self.calloutView.widthAnchor.constraint(equalToConstant: 300)
                    ])
                
                self.calloutView.photoImage.image = self.postAnnotation.image
                self.calloutView.descriptionLabel.text = self.postAnnotation.postDescription
                self.viewModel.timestamp.onNext(self.postAnnotation.date)
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
        
        viewModel.error
            .subscribe(onNext: { message in
                self.showStorageError(message: message)
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
        view.addSubview(spinner)
        spinner.center = view.center
        
        locationButton.setImage(UIImage(named: "discover"), for: .normal)
        locationButton.setImage(UIImage(named: "follow"), for: .selected)
    }
    
    private func displayImageSheet() {
        let photoMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
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
    
    private func showStorageError(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
