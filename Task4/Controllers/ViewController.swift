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
    
    private lazy var checkBoxView = CheckBoxView()
    private lazy var activityIndicator = ActivityIndicatorView()
    private var atms = [ATMElement]()
    private var infoboxes = [InfoboxElement]()
    private var filials = [FilialElement]()
    private var checkBoxAtms = [ATMElement]()
    private var checkBoxInfoboxes = [InfoboxElement]()
    private var checkBoxFilials = [FilialElement]()
    private var atmAnnotations = [CustomAnnotation]()
    private var infoboxAnnotations = [CustomAnnotation]()
    private var filialsAnnotations = [CustomAnnotation]()
    private var mapChangedFromUserInteraction = false
    private var isCheckBoxOpened = false

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationServicesAuth()
        setupNavBar()
        addSubviews()
        if NetworkMonitor.shared.isReachable {
            loadData(reload: false)
        } else {
            self.noInternetConnectionAlert()
        }
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        segmentedControl.selectedSegmentIndex = 0
    }

    private func setupNavBar() {
        navigationController?.navigationBar.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshVC))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape.fill"),
            style: .plain,
            target: self,
            action: #selector(checkBoxButtonTapped))
        navigationController?.navigationBar.isTranslucent = false
        title = "Беларусбанк"
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
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(50)
        }
    }
    
    private func loadData(reload: Bool) {
        let group = DispatchGroup()
        var message = ""
        setupActivityIndicator()
        view.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem?.isEnabled = false
        group.enter()
        APIService.loadData(for: "https://belarusbank.by/api/atm", type: atms) { [weak self] result in
            switch result {
            case .success( let atms ):
                guard let sortedAtms = (self?.sortArraysByDistance(array: atms)) else { return }
                self?.atms = sortedAtms
                self?.checkBoxAtms = sortedAtms
                DispatchQueue.main.async {
                    self?.createATMAnnotations()
                }
            case .failure(let failure):
               print(failure)
               if failure != .decodingError {
               }
           }
            if reload {
                group.leave()
            }
        }
        APIService.loadData(for: "https://belarusbank.by/api/infobox", type: infoboxes) { [weak self] result in
            switch result {
            case .success( let infoboxes ):
                guard let sortedInfoboxes = (self?.sortArraysByDistance(array: infoboxes)) else { return }
                self?.infoboxes = sortedInfoboxes
                self?.checkBoxInfoboxes = sortedInfoboxes
                DispatchQueue.main.async {
                    self?.createInfoboxAnnotations()
                }
            case .failure(let failure):
               print(failure)
               if failure != .decodingError {
                   message += "\n Инфокиоски"
               }
           }
        }
        APIService.loadData(for: "https://belarusbank.by/api/filials_info", type: filials) { [weak self] result in
            switch result {
            case .success( let filials ):
                guard let sortedFilials = (self?.sortArraysByDistance(array: filials)) else { return }
                self?.filials = sortedFilials
                self?.checkBoxFilials = sortedFilials
                DispatchQueue.main.async {
                    self?.createFilialAnnotations()
                }
            case .failure(let failure):
               print(failure)
               if failure != .decodingError {
                   message += "\n Филиалы"
               }
           }
            if !reload {
                group.leave()
            }
        }
        group.notify(queue: .main) { [weak self] in
            if !reload {
                if !message.isEmpty {
                    self?.networkErrorAlert(message: message, repeatAction: {
                        self?.loadData(reload: false)
                    })
                }
            }
            self?.activityIndicator.removeFromSuperview()
            self?.view.isUserInteractionEnabled = true
            self?.navigationItem.rightBarButtonItem?.isEnabled = true
            self?.navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
    
    private func sortArraysByDistance<T: Coordinate>(array: [T]) -> [T] {
        let defaultLocation = CLLocation(latitude: 52.425163, longitude: 31.015039)
        var sortedArray = [T]()
            if CLLocationManager.locationServicesEnabled() &&
                locationManager.authorizationStatus != .denied &&
                locationManager.authorizationStatus != .notDetermined {
                sortedArray = array.sorted(by: {
                    (locationManager.location?.distance(from: CLLocation(
                        latitude: Double($0.gpsX) ?? 0,
                        longitude: Double($0.gpsY) ?? 0))) ?? 0
                    < (locationManager.location?.distance(from: CLLocation(
                        latitude: Double($1.gpsX) ?? 0,
                        longitude: Double($1.gpsY) ?? 0))) ?? 0
                })
                return sortedArray
            } else {
                sortedArray = array.sorted(by: {
                    (defaultLocation.distance(from: CLLocation(
                        latitude: Double($0.gpsX) ?? 0,
                        longitude: Double($0.gpsY) ?? 0)))
                    < (defaultLocation.distance(from: CLLocation(
                        latitude: Double($1.gpsX) ?? 0,
                        longitude: Double($1.gpsY) ?? 0)))
                })
                return sortedArray
        }
    }
    
    private func createATMAnnotations() {
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
                    coordinate: coordinates,
                    type: .atm)
                mapView.addAnnotation(annotation)
            atmAnnotations.append(annotation)
        }
    }
    
    private func createInfoboxAnnotations() {
        for infobox in infoboxes {
            let coordinates = CLLocationCoordinate2D(
                latitude: (Double(infobox.gpsX) ?? 0) as CLLocationDegrees,
                longitude: (Double(infobox.gpsY) ?? 0) as CLLocationDegrees)
            let annotation = CustomAnnotation(
                placeName: infobox.installPlace,
                workTime: infobox.workTime,
                currency: infobox.currency,
                cashIn: infobox.cashIn,
                id: String(infobox.id),
                coordinate: coordinates,
                type: .infobox)
            mapView.addAnnotation(annotation)
            infoboxAnnotations.append(annotation)
        }
    }
    
    private func createFilialAnnotations() {
        for filial in filials {
            let filialFullAdress = filial.cityType + filial.city + filial.addressType + filial.address + filial.house
            let coordinates = CLLocationCoordinate2D(
                latitude: (Double(filial.gpsX) ?? 0) as CLLocationDegrees,
                longitude: (Double(filial.gpsY) ?? 0) as CLLocationDegrees)
            let annotation = CustomAnnotation(
                placeName: filial.installPlace,
                workTime: filial.workTime,
                address: filialFullAdress,
                phoneNumber: filial.phoneNumber ?? "",
                id: filial.id,
                coordinate: coordinates,
                type: .filial)
            mapView.addAnnotation(annotation)
            filialsAnnotations.append(annotation)
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
        let listVC = ListViewController()
        navigationController?.pushViewController(listVC, animated: true)
        listVC.delegate = self
        listVC.atms = atms
        listVC.infoboxes = infoboxes
        listVC.filials = filials
    }
    
    @objc private func refreshVC() {
        if NetworkMonitor.shared.isReachable {
            checkBoxView.removeFromSuperview()
            isCheckBoxOpened = false
            checkBoxView = CheckBoxView()
            loadData(reload: true)
        } else {
            self.networkErrorAlert(message: "") {
                self.loadData(reload: true)
            }
        }
    }
    
    @objc private func checkBoxButtonTapped() {
        checkBoxView.checkBoxDelegate = self
        if !isCheckBoxOpened {
            view.addSubview(checkBoxView)
            checkBoxView.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(10)
                make.left.equalToSuperview().inset(10)
                make.size.equalTo(110)
            }
        } else {
            checkBoxView.removeFromSuperview()
        }
        isCheckBoxOpened.toggle()
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let customAnnotationViewIdentifier = "MyAnnotation"
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: customAnnotationViewIdentifier)
        pin = CustomAnnotationView(annotation: annotation, reuseIdentifier: customAnnotationViewIdentifier)
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
        if annotation.type == .atm {
            let currentATM = atms.first(where: { atm in
                atm.id == annotation.id
            })
            detailsVC.atm = currentATM
        }
        if annotation.type == .infobox {
            let currentInfobox = infoboxes.first(where: { infobox in
                String(infobox.id) == annotation.id
            })
            detailsVC.infobox = currentInfobox
        }
        if annotation.type == .filial {
            let currentFilial = filials.first(where: { filial in
                filial.id == annotation.id
            })
            detailsVC.filial = currentFilial
        }
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

extension ViewController: CheckBoxDelegate {
    func buttonTap(button: UIButton) {
        button.isSelected = !button.isSelected
        switch button.tag {
        case 0:
            if button.isSelected {
                mapView.removeAnnotations(atmAnnotations)
                self.atms = [ATMElement]()
            } else {
                mapView.addAnnotations(atmAnnotations)
                self.atms = self.checkBoxAtms
            }
        case 1:
            if button.isSelected {
                mapView.removeAnnotations(infoboxAnnotations)
                self.infoboxes = [InfoboxElement]()
            } else {
                mapView.addAnnotations(infoboxAnnotations)
                self.infoboxes = self.checkBoxInfoboxes
            }
        case 2:
            if button.isSelected {
                mapView.removeAnnotations(filialsAnnotations)
                self.filials = [FilialElement]()
            } else {
                mapView.addAnnotations(filialsAnnotations)
                self.filials = self.checkBoxFilials
            }
        default:
            break
        }
    }
}
