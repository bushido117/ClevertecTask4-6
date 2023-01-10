//
//  SceneDelegate.swift
//  Task4
//
//  Created by Вадим Сайко on 9.01.23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let viewController = ViewController()
        let navVC = UINavigationController(rootViewController: viewController)
        window.rootViewController = navVC
        window.backgroundColor = .systemBackground
        window.makeKeyAndVisible()
        self.window = window
    }
}
