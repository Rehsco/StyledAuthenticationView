//
//  AppDelegate+RootView.swift
//  StyledAuthenticationView
//
//  Created by Martin Rehder on 09.02.2017.
//  Copyright © 2017 Martin Jacob Rehder. All rights reserved.
//

import UIKit

extension AppDelegate {
    func getTopViewController() -> UIViewController? {
        if let viewController = self.window?.rootViewController {
            var topController = viewController
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return self.window?.rootViewController
    }
    
    func getRootViewController() -> UIViewController? {
        return self.window?.rootViewController
    }
}
