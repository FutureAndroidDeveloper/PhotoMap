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
import Kingfisher
import UICircularProgressRing

class MapViewController: UIViewController, StoryboardInitializable {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var categoriesMenuButton: UIButton!
    
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
        
        mapView.rx.regionDidChangeAnimated
            .map { [weak self] _ in
                guard let self = self else { fatalError() }
                return self.mapView.region
            }
            .bind(to: self.viewModel.coordinateInterval)
            .disposed(by: bag)
        
        viewModel.posts
            .subscribe(onNext: { [weak self] posts in
                guard let self = self else { return }
                let allAnnotations = self.mapView.annotations
                self.mapView.removeAnnotations(allAnnotations)
                self.mapView.addAnnotations(posts)
            })
            .disposed(by: bag)
        
        viewModel.isLoading
            .map { !$0 }
            .bind(to: spinner.rx.isHidden)
            .disposed(by: bag)
        
        viewModel.isLoading
            .bind(to: spinner.rx.isAnimating)
            .disposed(by: bag)

        mapView.register(PostAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(PostClusterView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        
        categoriesMenuButton.rx.tap
            .bind(to: viewModel.showCategoriesFilter)
            .disposed(by: bag)
        
        calloutView.detailButton.rx.tap
            .compactMap { [weak self] _ in
                guard let self = self else { fatalError() }
                return self.postAnnotation
            }
            .bind(to: viewModel.fullPhotoTapped)
            .disposed(by: bag)
        
        viewModel.shortDate
            .bind(to: calloutView.dateLabel.rx.text)
            .disposed(by: bag)

        mapView.rx.didSelectAnnotationView
            .filter { !($0.annotation is MKUserLocation) }
            .filter { $0.annotation is PostAnnotation }
            .bind(onNext: { [weak self] view in
                guard let self = self else { return }
                self.postAnnotation = view.annotation as? PostAnnotation
                view.addSubview(self.calloutView)
                
                NSLayoutConstraint.activate([
                    self.calloutView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    self.calloutView.bottomAnchor.constraint(equalTo: view.topAnchor),
                    self.calloutView.heightAnchor.constraint(equalToConstant: 100),
                    self.calloutView.widthAnchor.constraint(equalToConstant: 300)
                    ])
                
                let indicator = UICircularProgressRing()
                
                indicator.maxValue = 100
                indicator.outerRingColor = UIColor(white: 1, alpha: 0.7)
                indicator.innerRingColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
                indicator.style = .bordered(width: 1, color: #colorLiteral(red: 0.2078431373, green: 0.7294117647, blue: 0.6549019608, alpha: 1))
                indicator.font = UIFont.systemFont(ofSize: self.calloutView.photoImage.bounds.height / 5, weight: .medium)
                indicator.translatesAutoresizingMaskIntoConstraints = false
                self.calloutView.photoImage.addSubview(indicator)
                indicator.isHidden = false
                self.calloutView.detailButton.isUserInteractionEnabled = indicator.isHidden
                
                NSLayoutConstraint.activate([
                    indicator.centerXAnchor.constraint(equalTo: self.calloutView.photoImage.centerXAnchor),
                    indicator.centerYAnchor.constraint(equalTo: self.calloutView.photoImage.centerYAnchor),
                    indicator.widthAnchor.constraint(equalTo: self.calloutView.photoImage.widthAnchor),
                    indicator.heightAnchor.constraint(equalTo: self.calloutView.photoImage.heightAnchor)
                    ])

                guard let imageUrl = URL(string: self.postAnnotation.imageUrl!) else { return }
                self.calloutView.photoImage
                    .kf.setImage(
                        with: imageUrl,
                        progressBlock: { receivedSize, totalSize in
                            let percentage = (Float(receivedSize) / Float(totalSize)) * 100.0
                            indicator.value = CGFloat(percentage)
                        },
                        completionHandler: { [weak self] result in
                            guard let self = self else { return }
                            switch result {
                            case .success(let value): self.postAnnotation.image = value.image
                            case .failure(let error): print(error)
                            }
                            indicator.isHidden = true
                            self.calloutView.detailButton.isUserInteractionEnabled = indicator.isHidden
                        })
                
                self.calloutView.photoImage.image = self.postAnnotation.image
                self.calloutView.descriptionLabel.text = self.postAnnotation.postDescription
                self.viewModel.timestamp.onNext(self.postAnnotation.date)
                self.mapView.setCenter((view.annotation?.coordinate)!, animated: true)
            })
            .disposed(by: bag)
        
        mapView.rx.didDeselectAnnotationView
//            .filter { $0 is PostAnnotationView }
            .bind(onNext: { view in
                for subview in view.subviews {
                    subview.removeFromSuperview()
                }
            })
            .disposed(by: bag)
        
        longPressGesture.rx.event
            .filter { $0.state == .began }
            .do(onNext: { [weak self] recognizer in
                guard let self = self else { return }
                let touchPoint = recognizer.location(in: self.mapView)
                let touchCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
                let touchLocation = CLLocation(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
                self.location = touchLocation
                self.viewModel.location.onNext(touchLocation)
            })
            .map { _ in return Void() }
            .bind(to: viewModel.cameraButtonTapped)
            .disposed(by: bag)
        
        viewModel.post
            .subscribe(onNext: { [weak self] post in
                guard let self = self else { return }
                self.mapView.addAnnotation(post)
            })
            .disposed(by: bag)
        
        viewModel.showImageSheet
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.displayImageSheet()
            })
            .disposed(by: bag)
        
        cameraButton.rx.tap
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.location = self.locationManager.location
                self.viewModel.location.onNext(self.location!)
            })
            .bind(to: viewModel.cameraButtonTapped)
            .disposed(by: bag)

        locationButton.rx.tap
            .bind(to: viewModel.locationButtonTapped)
            .disposed(by: bag)
        
        locationButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
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
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.locationButton.isSelected = !self.locationButton.isSelected
            })
            .disposed(by: bag)
        
        locationManager.rx.didChangeAuthorization
            .subscribe(onNext: { [weak self] status in
                guard let self = self else { return }
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
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
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
        let libraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
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
