//
//  AlternateAuthenticationDemoService.swift
//  StyledAuthenticationView
//
//  Created by Martin Rehder on 08.05.2017.
//  Copyright © 2017 Martin Jacob Rehder. All rights reserved.
//

import UIKit

class AlternateAuthenticationDemoService {
    private var authView: AuthenticationView?
    
    func authenticate(useTouchID: Bool, usePin: Bool, usePassword: Bool, authSuccess: @escaping ((Bool) -> Void)) {
        if self.authView == nil {
            if let view = UIApplication.shared.keyWindow {
                self.authView = AuthenticationView(frame: UIScreen.main.bounds)
                if let liv = self.authView {
                    DispatchQueue.main.async {
                        view.addSubview(liv)
                        liv.authenticate(useTouchID: useTouchID, usePin: usePin, usePassword: usePassword, authHandler: {
                            success, errorType in
                            if !success {
                                self.dismissAuthView()
                                authSuccess(false)
                            }
                            else {
                                self.dismissAuthView()
                                authSuccess(success)
                            }
                        })
                    }
                }
            }
        }
    }
    
    private func dismissAuthView() {
        DispatchQueue.main.async {
            if let liv = self.authView {
                UIView.animate(withDuration: 0.5, animations: {
                    liv.alpha = 0
                }, completion: { _ in
                    liv.removeFromSuperview()
                    self.authView = nil
                })
            }
        }
    }
    
}
