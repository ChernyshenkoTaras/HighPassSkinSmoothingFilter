//
//  AppDelegate.swift
//  HighPassSmoothSkinFilter
//
//  Created by Taras Chernyshenko on 7/25/19.
//  Copyright © 2019 Taras Chernyshenko. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
        let router = ContentRouter(controller: controller)
        let presenter = ContentPresenter(controller: controller, router: router)
        controller.output = presenter
        let window = UIWindow()
        window.rootViewController = controller
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
}
