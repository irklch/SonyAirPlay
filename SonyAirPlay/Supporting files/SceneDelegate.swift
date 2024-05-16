//
//  SceneDelegate.swift
//  SonyAirPlay
//
//  Created by Ирина Кольчугина on 03.12.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = MainScreenVC()
        window?.makeKeyAndVisible()
    }
}

