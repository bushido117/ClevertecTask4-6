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
import CoreData

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
    private let userDefaults = UserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationServicesAuth()
        setupNavBar()
        addSubviews()
        if NetworkMonitor.shared.isReachable {
            loadData(reload: false)
        } else {
            if userDefaults.bool(forKey: "NotfirstLaunch") {
                getATMsFromEntity()
                getInfoboxesFromEntity()
                getFilialsFromEntity()
            } else {
                self.noInternetConnectionAlert()
            }
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
                    CoreDataService.shared.saveATMs(atms: sortedAtms)
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
                    CoreDataService.shared.saveInfoboxes(infoboxes: sortedInfoboxes)
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
                    CoreDataService.shared.saveFilials(filials: sortedFilials)
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
            self?.userDefaults.set(true, forKey: "NotfirstLaunch")
        }
    }
    
    private func sortArraysByDistance<T: BelarusbankElement>(array: [T]) -> [T] {
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
            let annotation = atm.createAnnotation()
            mapView.addAnnotation(annotation)
            atmAnnotations.append(annotation)
        }
    }
    
    private func createInfoboxAnnotations() {
        for infobox in infoboxes {
            let annotation = infobox.createAnnotation()
            mapView.addAnnotation(annotation)
            infoboxAnnotations.append(annotation)
        }
    }
    
    private func createFilialAnnotations() {
        for filial in filials {
            let annotation = filial.createAnnotation()
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
        checkBoxView.removeFromSuperview()
        isCheckBoxOpened = false
        checkBoxView = CheckBoxView()
        if NetworkMonitor.shared.isReachable {
            loadData(reload: true)
        } else {
            getATMsFromEntity()
            getInfoboxesFromEntity()
            getFilialsFromEntity()
        }
    }
    
    private func getATMsFromEntity() {
        let atmsEntities = CoreDataService.shared.readATMs()
        atms = [ATMElement]()
        for atm in atmsEntities {
        let atm = ATMElement(
            id: atm.id ?? "",
            area: atm.area ?? "",
            cityType: atm.cityType ?? "",
            city: atm.city ?? "",
            addressType: atm.addressType ?? "",
            address: atm.address ?? "",
            house: atm.house ?? "",
            installPlace: atm.installPlace ?? "",
            currency: atm.currency,
            cashIn: atm.cashIn,
            workTime: atm.workTime ?? "",
            gpsX: atm.gpsX ?? "",
            gpsY: atm.gpsY ?? "",
            installPlaceFull: atm.installPlaceFull ?? "",
            workTimeFull: atm.workTimeFull ?? "",
            atmType: atm.atmType ?? "",
            atmError: atm.atmError ?? "",
            atmPrinter: atm.atmPrinter ?? "")
            atms.append(atm)
        }
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.atms = (self.sortArraysByDistance(array: self.atms))
        }
        createATMAnnotations()
    }
    
    private func getInfoboxesFromEntity() {
        let infoboxesEntity = CoreDataService.shared.readInfoboxes()
        infoboxes = [InfoboxElement]()
        for infobox in infoboxesEntity {
        let infobox = InfoboxElement(
            id: Int(bitPattern: infobox.id),
            area: infobox.area ?? "",
            cityType: infobox.cityType ?? "",
            city: infobox.city ?? "",
            addressType: infobox.addressType ?? "",
            currency: infobox.currency,
            cashIn: infobox.cashIn,
            address: infobox.address ?? "",
            house: infobox.house ?? "",
            locationNameDescription: infobox.locationNameDescription ?? "",
            installPlace: infobox.installPlace ?? "",
            workTime: infobox.workTime ?? "",
            timeLong: infobox.timeLong ?? "",
            gpsX: infobox.gpsX ?? "",
            gpsY: infobox.gpsY ?? "",
            infType: infobox.infType ?? "",
            cashInError: infobox.cashInError ?? "",
            infStatus: infobox.infStatus ?? "",
            typeCashIn: infobox.typeCashIn ?? "",
            infPrinter: infobox.infPrinter ?? "",
            regionPayment: infobox.regionPayment ?? "",
            rechargePayment: infobox.rechargePayment ?? "")
            infoboxes.append(infobox)
        }
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.infoboxes = (self.sortArraysByDistance(array: self.infoboxes))
        }
        createInfoboxAnnotations()
    }
    
    private func getFilialsFromEntity() {
        let filialsEntity = CoreDataService.shared.readFilials()
        filials = [FilialElement]()
        for filial in filialsEntity {
        let filial = FilialElement(
            id: filial.id ?? "",
            sapID: filial.sapID ?? "",
            installPlace: filial.installPlace ?? "",
            phoneNumber: filial.phoneNumber,
            cityType: filial.cityType ?? "",
            city: filial.city ?? "",
            addressType: filial.addressType ?? "",
            address: filial.address ?? "",
            house: filial.house ?? "",
            temporaryCityType: filial.temporaryCityType,
            temporaryCity: filial.temporaryCity,
            bik: filial.bik,
            unp: filial.unp,
            temporaryAddressType: filial.temporaryAddressType ?? "",
            temporaryAddress: filial.temporaryAddress ?? "",
            temporaryHouse: filial.temporaryHouse ?? "",
            additionalInfo: filial.additionalInfo ?? "",
            workTime: filial.workTime ?? "",
            gpsX: filial.gpsX ?? "",
            gpsY: filial.gpsY ?? "",
            belCheckingAccountNumber: filial.belCheckingAccountNumber ?? "",
            foreignCheckingAccountNumber: filial.foreignCheckingAccountNumber ?? "",
            filialNumber: filial.filialNumber ?? "",
            cbuNumber: filial.cbuNumber ?? "",
            otdNumber: filial.otdNumber ?? "",
            dopNumber: filial.dopNumber ?? "")
            filials.append(filial)
        }
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.filials = (self.sortArraysByDistance(array: self.filials))
        }
        createFilialAnnotations()
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
