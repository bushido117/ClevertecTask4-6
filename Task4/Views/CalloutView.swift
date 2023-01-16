//
//  CalloutView.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import UIKit
import MapKit
import SnapKit

protocol CalloutViewDelegate: AnyObject {
    func mapView(_ mapView: MKMapView, didTapDetailsButton button: UIButton, for annotation: MKAnnotation)
}

final class CalloutView: UIView {

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()

    private lazy var installPlaceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.sizeToFit()
        return label
    }()
    
    private lazy var workTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 4
        return label
    }()
    
    private lazy var currencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var cashInLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var detailsButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Подробнее", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .lightGray
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(detailButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.contentSize = CGSize(width: 210, height: 190)
        return scrollView
    }()
    
    private var mapView: MKMapView? {
        var view = superview
        while view != nil {
            if let mapView = view as? MKMapView { return mapView }
            view = view?.superview
        }
        return nil
    }
    
    private lazy var backgroundButton = UIButton()
    weak var annotation: CustomAnnotation?

    init(annotation: CustomAnnotation) {
        self.annotation = annotation
        super.init(frame: .zero)
        addSubviews()
        setupConstraints()
        setProperties(for: annotation)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        contentView.addSubview(backgroundButton)
        contentView.addSubview(installPlaceLabel)
        contentView.addSubview(workTimeLabel)
        contentView.addSubview(currencyLabel)
        contentView.addSubview(cashInLabel)
        scrollView.addSubview(contentView)
        addSubview(scrollView)
        addSubview(detailsButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { make in
            make.height.equalTo(190)
            make.width.equalToSuperview()
        }
        backgroundButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        installPlaceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(2)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().inset(5)
        }
        workTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(installPlaceLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().inset(5)
        }
        currencyLabel.snp.makeConstraints { make in
            make.top.equalTo(workTimeLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().inset(5)
        }
        cashInLabel.snp.makeConstraints { make in
            make.top.equalTo(currencyLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().inset(5)
        }
        detailsButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(2)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().inset(5)
        }
    }
    
    private func setProperties(for annotation: CustomAnnotation) {
        installPlaceLabel.text = annotation.placeName
        workTimeLabel.text = annotation.workTime
        if annotation.type == .filial {
            currencyLabel.text = annotation.address
            cashInLabel.text = annotation.phoneNumber
        } else {
            currencyLabel.text = annotation.currency
            cashInLabel.text = annotation.cashIn
        }
    }
    
    @objc func detailButtonTapped(_ sender: UIButton) {
        guard let annotation = annotation else { return }
        if let mapView = mapView, let delegate = mapView.delegate as? CalloutViewDelegate {
            delegate.mapView(mapView, didTapDetailsButton: sender, for: annotation)
        }
    }
}
