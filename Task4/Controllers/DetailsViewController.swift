//
//  DetailsViewController.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import UIKit
import SnapKit
import MapKit

final class DetailsViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(DetailsTableViewCell.self,
                           forCellReuseIdentifier: String(describing: DetailsTableViewCell.self))
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    private lazy var routButton: UIButton = {
        let button = UIButton(configuration: .borderedTinted())
        button.setTitle("Построить маршрут", for: .normal)
        button.addTarget(self, action: #selector(makeRout), for: .touchUpInside)
        return button
    }()
    var atm: ATMElement?
    var authorizationStatusDenied: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Detail info"
        addSubviews()
        setupConstraints()
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(routButton)
    }
    
    private func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(50)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
        }
        routButton.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.bottom.equalToSuperview().inset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().inset(15)
        }
    }
    
    @objc private  func makeRout() {
        guard let authorizationStatusDenied = authorizationStatusDenied else { return }
        if authorizationStatusDenied {
            self.locationServicesOffAlert()
        } else {
            if let atm = atm {
                let coordinate = CLLocationCoordinate2D(
                    latitude: (Double(atm.gpsX) ?? 0),
                    longitude: (Double(atm.gpsY) ?? 0))
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary: nil))
                mapItem.name = "Destination"
                mapItem.openInMaps(launchOptions: [
                    MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
                ])
            }
        }
    }
}

extension DetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 7 {
            return 175
        }
        return 70
    }
}

extension DetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CellsNames.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: DetailsTableViewCell.self),
            for: indexPath) as? DetailsTableViewCell else { return UITableViewCell()}
        if let atm = atm {
            cell.setProperties(cellsNames: CellsNames.allCases[indexPath.row], cellsDescriptions: atm)
        }
        return cell
    }
}
