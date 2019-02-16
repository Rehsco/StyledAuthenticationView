//
//  ViewController.swift
//  AuthenticationDemo
//
//  Created by Martin Rehder on 08.02.2017.
//  Copyright © 2017 Martin Jacob Rehder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let authenticationService = AuthenticationDemoService()
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        authenticationService.updateAuthenticationViewLayout(newSize: size)
    }
    
    @IBAction func changePinAction(_ sender: Any) {
        authenticationService.changePin { (success) in
            if success {
                NSLog("You changed the Pin")
            }
            else {
                NSLog("You failed to change the Pin!")
            }
        }
    }
    
    @IBAction func changePasswordAction(_ sender: Any) {
        authenticationService.changePassword { (success) in
            if success {
                NSLog("You changed the Password")
            }
            else {
                NSLog("You failed to change the Password!")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        authenticationService.authenticate(useTouchID: true, usePin: true, usePassword: true) { success in
            if success {
                NSLog("You authenticated!")
            }
            else {
                NSLog("You failed!")
            }
        }
    }
}

