//
//  CheckBoxView.swift
//  Task4
//
//  Created by Вадим Сайко on 14.01.23.
//

import UIKit
import SnapKit

protocol CheckBoxDelegate: AnyObject {
    func buttonTap(button: UIButton)
}

final class CheckBoxView: UIView {
    private lazy var atmButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle"), for: .selected)
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        button.setTitle("Банкоматы", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(atmCheckButtonTap), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.tag = 0
        return button
    }()
    
    private lazy var infoboxesButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle"), for: .selected)
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        button.setTitle("Инфокиоски", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(atmCheckButtonTap), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.tag = 1
        return button
    }()
    
    private lazy var filialsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "circle"), for: .selected)
        button.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        button.setTitle("Филиалы", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.addTarget(self, action: #selector(atmCheckButtonTap), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        button.tag = 2
        return button
    }()
    
    weak var checkBoxDelegate: CheckBoxDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        addSubview(atmButton)
        addSubview(infoboxesButton)
        addSubview(filialsButton)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        atmButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(5)
            make.left.equalToSuperview().inset(2)
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }
        infoboxesButton.snp.makeConstraints { make in
            make.top.equalTo(atmButton.snp.bottom).offset(6)
            make.left.equalToSuperview().inset(2)
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }
        filialsButton.snp.makeConstraints { make in
            make.top.equalTo(infoboxesButton.snp.bottom).offset(6)
            make.left.equalToSuperview().inset(2)
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    @objc func atmCheckButtonTap(button: UIButton) {
        checkBoxDelegate?.buttonTap(button: button)
    }
}
