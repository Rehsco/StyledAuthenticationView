//
//  AuthenticationDemoService.swift
//  StyledAuthenticationView
//
//  Created by Martin Rehder on 09.02.2017.
//  Copyright © 2017 Martin Jacob Rehder. All rights reserved.
//

import UIKit
import MJRFlexStyleComponents

class AuthenticationDemoService {
    private var authView: AuthenticationView?
    
    // MARK: Authentication handling
    
    static let pinCodeEvaluator: ((String) -> Bool) = {
        digits in
        if digits == "123456" { // Use some kind of secure store to fetch a real pin code
            return true
        }
        return false
    }
    
    static let passwordEvaluator: ((String) -> Bool) = {
        password in
        if password == "pass" { // Use some kind of secure store to fetch a real password
            return true
        }
        return false
    }
    
    // Demo colors, fonts and layout styling
    private func applyAuthViewStyle() {
        self.authView?.pinStyle = FlexShapeStyle(style: .roundedFixed(cornerRadius: 10))
        self.authView?.pinBorderColor = .gray
        self.authView?.pinSelectionColor = .lightGray
        self.authView?.pinFont = UIFont.systemFont(ofSize: 18)
        self.authView?.pinTextColor = .gray
        self.authView?.cancelDeleteButtonTextColor = .gray
        self.authView?.cancelDeleteButtonFont = UIFont.systemFont(ofSize: 18)
        self.authView?.headerTextColor = .gray
        self.authView?.headerTextFont = UIFont.systemFont(ofSize: 18)
        self.authView?.backgroundColor = .white
        self.authView?.passwordStyle = FlexShapeStyle(style: .roundedFixed(cornerRadius: 5))
        self.authView?.passwordBorderColor = .gray
    }
    
    func authenticate(useTouchID: Bool, usePin: Bool, usePassword: Bool, authSuccess: @escaping ((Bool) -> Void)) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if self.authView == nil {
                if let tvc = appDelegate.getTopViewController() {
                    self.authView = AuthenticationView(frame: UIScreen.main.bounds)
                    self.applyAuthViewStyle()
                    if let liv = self.authView {
                        DispatchQueue.main.async {
                            tvc.view.addSubview(liv)
                            liv.pinCodeEvaluator = AuthenticationDemoService.pinCodeEvaluator
                            liv.passwordEvaluator = AuthenticationDemoService.passwordEvaluator
                            liv.authenticate(useTouchID: useTouchID, usePin: usePin, usePassword: usePassword, authHandler: {
                                success, errorType in
                                if !success {
                                    let alertView = UIAlertController(title: "Error", message: errorType.description(), preferredStyle:.alert)
                                    let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                                        authSuccess(success)
                                        self.dismissAuthView()
                                    }
                                    alertView.addAction(okAction)
                                    tvc.present(alertView, animated: true) {}
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
    
    // MARK: - Pin Handling
    
    func createNewPin(createPinSuccess: @escaping ((Bool) -> Void)) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if self.authView == nil {
                if let tvc = appDelegate.getTopViewController() {
                    self.authView = AuthenticationView(frame: UIScreen.main.bounds)
                    self.applyAuthViewStyle()
                    if let liv = self.authView {
                        DispatchQueue.main.async {
                            tvc.view.addSubview(liv)
                            liv.createPINCode(createPinHandler: { (newPin, success, errorType) in
                                if success {
                                    NSLog("Save the new PIN: \(newPin)")
                                }
                                else {
                                    NSLog(errorType.description())
                                }
                                self.dismissAuthView()
                                createPinSuccess(success)
                            })
                        }
                    }
                }
            }
        }
    }
    
    func changePin(createPinSuccess: @escaping ((Bool) -> Void)) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if self.authView == nil {
                if let tvc = appDelegate.getTopViewController() {
                    self.authView = AuthenticationView(frame: UIScreen.main.bounds)
                    self.applyAuthViewStyle()
                    if let liv = self.authView {
                        DispatchQueue.main.async {
                            tvc.view.addSubview(liv)
                            liv.pinCodeEvaluator = AuthenticationDemoService.pinCodeEvaluator
                            liv.changePINCode(createPinHandler: { (newPin, success, errorType) in
                                if success {
                                    NSLog("Save the changed PIN: \(newPin)")
                                }
                                else {
                                    NSLog(errorType.description())
                                }
                                self.dismissAuthView()
                                createPinSuccess(success)
                            })
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Password handling
    
    func createNewPassword(createPasswordSuccess: @escaping ((Bool) -> Void)) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if self.authView == nil {
                if let tvc = appDelegate.getTopViewController() {
                    self.authView = AuthenticationView(frame: UIScreen.main.bounds)
                    self.applyAuthViewStyle()
                    if let liv = self.authView {
                        DispatchQueue.main.async {
                            tvc.view.addSubview(liv)
                            liv.createPassword(createPasswordHandler: { (newPassword, success) in
                                if success {
                                    NSLog("Save the new password: \(newPassword)")
                                }
                                self.dismissAuthView()
                                createPasswordSuccess(success)
                            })
                        }
                    }
                }
            }
        }
    }
    
    func changePassword(createPasswordSuccess: @escaping ((Bool) -> Void)) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if self.authView == nil {
                if let tvc = appDelegate.getTopViewController() {
                    self.authView = AuthenticationView(frame: UIScreen.main.bounds)
                    self.applyAuthViewStyle()
                    if let liv = self.authView {
                        DispatchQueue.main.async {
                            tvc.view.addSubview(liv)
                            liv.passwordEvaluator = AuthenticationDemoService.passwordEvaluator
                            liv.changePassword(createPasswordHandler: { (newPassword, success) in
                                if success {
                                    NSLog("Save the changed password: \(newPassword)")
                                }
                                self.dismissAuthView()
                                createPasswordSuccess(success)
                            })
                        }
                    }
                }
            }
        }
    }

}
