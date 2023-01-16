//
//  ListCollectionViewCell.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import UIKit
import SnapKit

final class ListCollectionViewCell: UICollectionViewCell {
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isUserInteractionEnabled = false
        scrollView.contentSize = CGSize(width: 300, height: 0)
        return scrollView
    }()
    
    private lazy var installPlaceLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var workTimeLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.numberOfLines = 3
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        layer.cornerRadius = 3
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.accent?.cgColor
        layer.masksToBounds = false
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        contentView.addSubview(installPlaceLabel)
        contentView.addSubview(workTimeLabel)
        contentView.addSubview(currencyLabel)
        scrollView.addSubview(contentView)
        addSubview(scrollView)
        addGestureRecognizer(scrollView.panGestureRecognizer)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.width.equalTo(300)
        }
        installPlaceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(2)
            make.left.equalToSuperview().offset(2)
        }
        workTimeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(installPlaceLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(2)

        }
        currencyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(workTimeLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(2)
        }
    }
    
    func setPropertiesForATM(atm: ATMElement) {
        installPlaceLabel.text = atm.installPlace
        workTimeLabel.text = atm.workTime
        currencyLabel.text = atm.currency
    }
    
    func setPropertiesForInfobox(infobox: InfoboxElement) {
        installPlaceLabel.text = infobox.installPlace
        workTimeLabel.text = infobox.workTime
        currencyLabel.text = infobox.currency
    }
    
    func setPropertiesForFilial(filial: FilialElement) {
        installPlaceLabel.text = filial.installPlace
        workTimeLabel.text = filial.workTime
        currencyLabel.text = filial.phoneNumber
    }
}
