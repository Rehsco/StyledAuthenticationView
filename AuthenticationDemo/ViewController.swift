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

