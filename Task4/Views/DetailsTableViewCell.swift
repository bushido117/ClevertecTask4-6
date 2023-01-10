//
//  DetailsTableViewCell.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import UIKit
import SnapKit

final class DetailsTableViewCell: UITableViewCell {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(descriptionLabel)
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().offset(10)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(20)
        }
    }
    
    func setProperties(cellsNames: CellsNames, cellsDescriptions: ATMElement) {
        switch cellsNames {
        case .id:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.id
        case .area:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.area
        case .city:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.cityType + cellsDescriptions.city
        case .adress:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.addressType + cellsDescriptions.address + cellsDescriptions.house
        case .installPlace:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.installPlace
        case .workTime:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.workTime
        case .coordinates:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.gpsX + ", " + cellsDescriptions.gpsY
        case .workTimeFull:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.workTimeFull
        case .atmType:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.atmType
        case .atmError:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.atmError
        case .currency:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.currency
        case .cashIn:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.cashIn
        case .atmPrinter:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.atmPrinter
        }
    }
}
