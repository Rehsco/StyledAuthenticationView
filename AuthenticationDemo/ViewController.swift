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

