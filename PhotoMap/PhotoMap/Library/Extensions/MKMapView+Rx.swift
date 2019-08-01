//
//  MKMapView+Rx.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 7/31/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa

extension MKMapView: HasDelegate {
    public typealias Delegate = MKMapViewDelegate
}

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
    
    public weak private(set) var mapView: MKMapView?
    
    public init(mapView: ParentObject) {
        self.mapView = mapView
        super.init(parentObject: mapView, delegateProxy: RxMKMapViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RxMKMapViewDelegateProxy(mapView: $0) }
    }
}

extension Reactive where Base: MKMapView {
    public var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        return RxMKMapViewDelegateProxy.proxy(for: base)
    }
    
    // TODO: - Remove unused method
    var regionDidChangeAnimated: Observable<Void> {
        return delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
            .map { _ in
                return Void()
            }
    }
    
    var didChangeUserTrackingMode: Observable<MKUserTrackingMode> {
        return delegate.methodInvoked(#selector(MKMapViewDelegate.mapView(_:didChange:animated:)))
            .map { parameters in
                let mapView = parameters[0] as! MKMapView
                
                return mapView.userTrackingMode
            }
    }
    
    var mapViewDidFinishLoadingMap: Observable<MKMapView> {
        return delegate.methodInvoked(#selector(MKMapViewDelegate.mapViewDidFinishLoadingMap(_:)))
            .map { parameters in
                return parameters.first as! MKMapView
            }
    }
}
