//
//  ViewController.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit
import Network

final class ViewController: UIViewController {
    
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        return locationManager
    }()
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Карта", "Список"])
        segmentedControl.backgroundColor = .systemBlue
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(selectChange), for: .valueChanged)
        return segmentedControl
    }()
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        return mapView
    }()
    private var atms: [ATMElement]?
    private var mapChangedFromUserInteraction = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        if NetworkMonitor.shared.isReachable {
            loadData()
        } else {
            self.noInternetConnectionAlert()
        }
        locationServicesAuth()
        setupNavBar()
        addSubviews()
        setConstraints()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshVC))
        navigationController?.navigationBar.isTranslucent = false
        title = "Банкоматы"
    }
    
    private func addSubviews() {
        view.addSubview(mapView)
        view.addSubview(segmentedControl)
    }
    
    private func setConstraints() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        segmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
    }
    
    private func loadData() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        APIService.loadATMData { [weak self] result in
            switch result {
            case .success( let atms ):
                self?.atms = atms
                self?.createAnnotations()
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
            case .failure(let failure):
                print(failure)
                self?.navigationItem.rightBarButtonItem?.isEnabled = true
                if failure != .decodingError {
                    self?.networkErrorAlert(repeatAction: {
                        self?.loadData()
                    })
                }
            }
        }
    }
    
    private func createAnnotations() {
        guard let atms = atms else { return }
        for atm in atms {
            let coordinates = CLLocationCoordinate2D(
                latitude: (Double(atm.gpsX) ?? 0) as CLLocationDegrees,
                longitude: (Double(atm.gpsY) ?? 0) as CLLocationDegrees)
            let annotation = CustomAnnotation(
                placeName: atm.installPlace,
                workTime: atm.workTime,
                currency: atm.currency,
                cashIn: atm.cashIn,
                id: atm.id,
                coordinate: coordinates)
            mapView.addAnnotation(annotation)
        }
    }
    
    private func locationServicesAuth() {
        DispatchQueue.global().async { [weak self] in
            if CLLocationManager.locationServicesEnabled() {
                self?.locationManager.requestWhenInUseAuthorization()
                if self?.locationManager.authorizationStatus == .denied {
                    DispatchQueue.main.async {
                        self?.locationServicesOffAlert()
                    }
                }
                self?.locationManager.startUpdatingLocation()
            } else {
                DispatchQueue.main.async {
                    self?.locationServicesOffAlert()
                }
            }
        }
    }
    
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view: UIView = mapView.subviews[0] as UIView
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer.state == UIGestureRecognizer.State.began
                    || recognizer.state == UIGestureRecognizer.State.ended {
                    return true
                }
            }
        }
        return false
    }
    
    @objc private func selectChange() {
        let atmVC = ATMListViewController()
        atmVC.delegate = self
        navigationController?.pushViewController(atmVC, animated: true)
        atmVC.atms = atms
    }
    
    @objc private func refreshVC() {
        if NetworkMonitor.shared.isReachable {
            loadData()
        } else {
            self.networkErrorAlert {
                self.loadData()
            }
        }
    }
}

extension ViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        let customAnnotationViewIdentifier = "MyAnnotation"

        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: customAnnotationViewIdentifier)
        if pin == nil {
            pin = CustomAnnotationView(annotation: annotation, reuseIdentifier: customAnnotationViewIdentifier)
        } else {
            pin?.annotation = annotation
        }
        return pin
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        mapChangedFromUserInteraction = mapViewRegionDidChangeFromUserInteraction()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if mapChangedFromUserInteraction != true {
            guard let userLocation = locations.first else { return }
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            mapView.showsUserLocation = true
        }
    }
}

extension ViewController: CalloutViewDelegate {
    func mapView(_ mapView: MKMapView, didTapDetailsButton button: UIButton, for annotation: MKAnnotation) {
        guard let annotation = annotation as? CustomAnnotation else { return }
        let detailsVC = DetailsViewController()
        navigationController?.pushViewController(detailsVC, animated: true)
        let currentATM = atms?.first(where: { atm in
            atm.id == annotation.id
        })
        detailsVC.atm = currentATM
        detailsVC.authorizationStatusDenied = locationManager.authorizationStatus == .denied
    }
}

extension ViewController: ATMListVCDelegate {
    func collectinItemSelected(installPlace: String) {
        guard let annotation = mapView.annotations.first(where: { annotation in
            guard let customAnnotation = annotation as? CustomAnnotation else { return false }
            return customAnnotation.placeName == installPlace
        }) as? CustomAnnotation else { return }
        mapView.selectAnnotation(annotation, animated: true)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: annotation.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
}
