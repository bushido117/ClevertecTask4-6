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
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
    }
    
    private func setUpConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(20)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    func setPropertiesForATM(cellsNames: CellsNameForATMAndInfobox, cellsDescriptions: ATMElement) {
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
        case .address:
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
        case .type:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.atmType
        case .error:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.atmError
        case .currency:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.currency
        case .cashIn:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.cashIn
        case .printer:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.atmPrinter
        }
    }
    
    func setPropertiesForInfobox(cellsNames: CellsNameForATMAndInfobox, cellsDescriptions: InfoboxElement) {
        switch cellsNames {
        case .id:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = String(cellsDescriptions.id)
        case .area:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.area
        case .city:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.cityType + cellsDescriptions.city
        case .address:
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
            descriptionLabel.text = cellsDescriptions.timeLong
        case .type:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.infType
        case .error:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.infStatus
        case .currency:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.currency
        case .cashIn:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.cashIn
        case .printer:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.infPrinter
        }
    }
    
    func setPropertiesForFilial(cellsNames: CellsNameForFilial, cellsDescriptions: FilialElement) {
        switch cellsNames {
        case .id:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.id
        case .sapID:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.sapID
        case .filialNumber:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.filialNumber
        case .cbuNumber:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.cbuNumber
        case .city:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.cityType + cellsDescriptions.city
        case .address:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.addressType + cellsDescriptions.address + cellsDescriptions.house
        case .installPlace:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.installPlace
        case .coordinates:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.gpsX + ", " + cellsDescriptions.gpsY
        case .workTimeFull:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.workTime
        case .phoneNumber:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.phoneNumber
        case .belCheckingAccountNumber:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.belCheckingAccountNumber
        case .foreignCheckingAccountNumber:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.foreignCheckingAccountNumber
        case .additionalInfo:
            titleLabel.text = cellsNames.rawValue
            descriptionLabel.text = cellsDescriptions.additionalInfo
        }
    }
}
