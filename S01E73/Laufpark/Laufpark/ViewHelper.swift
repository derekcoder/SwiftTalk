//
//  ViewHelper.swift
//  Laufpark
//
//  Created by Derek on 19/4/18.
//  Copyright © 2018 Derek. All rights reserved.
//

import MapKit

func buildMapView() -> MKMapView {
    let view = MKMapView()
    view.showsCompass = true
    view.showsScale = true
    view.showsUserLocation = true
    view.mapType = .standard
    view.isRotateEnabled = false
    view.isPitchEnabled = false
    return view
}
