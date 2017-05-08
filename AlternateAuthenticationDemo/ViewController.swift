//
//  ViewController.swift
//  AlternateAuthenticationDemo
//
//  Created by Martin Rehder on 08.05.2017.
//  Copyright © 2017 Martin Jacob Rehder. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let authenticationService = AlternateAuthenticationDemoService()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        authenticationService.authenticate(useTouchID: true, usePin: false, usePassword: false) { success in
            if success {
                NSLog("You authenticated!")
            }
            else {
                NSLog("You failed!")
            }
        }
    }

}

