//
//  UIViewController+ext.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import UIKit

extension UIViewController {
//    swiftlint:disable line_length
    func locationServicesOffAlert() {
        let alertController = UIAlertController(
            title: "Приложение не знает, где Вы находитесь",
            message: "Разрешите приложению определять Ваше местоположение в настройках иначе некоторые функции могут быть недоступны",
            preferredStyle: .alert)
//    swiftlint:enable line_length
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        let settingsAction = UIAlertAction(title: "Настройки", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
        alertController.addAction(settingsAction)
        present(alertController, animated: true)
    }
    
    func noInternetConnectionAlert() {
        let alertController = UIAlertController(
            title: "Вы не подключены к интернету",
            message: "Данное приложение не работает без доступа к интернету",
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Закрыть", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true)
    }
    
    func networkErrorAlert(repeatAction: @escaping () -> Void) {
        let alertController = UIAlertController(
            title: "Вы не подключены к интернету",
            message: "Данное приложение не работает без доступа к интернету",
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Закрыть", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        let settingsAction = UIAlertAction(title: "Повторить еще раз", style: .default) { _ in
            repeatAction()
        }
        alertController.addAction(settingsAction)
        present(alertController, animated: true)
    }

}
