//
//  AuthStateMachine.swift
//  StyledAuthenticationView
//
//  Created by Martin Rehder on 02.02.2017.
/*
 * Copyright 2017-present Martin Jacob Rehder.
 * http://www.rehsco.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

import Foundation

enum AuthenticationStateType {
    case touchID
    case pin
    case password
}

class AuthStateMachine {
    var currentState: AuthenticationStateType = .touchID
    var useTouchID: Bool = false
    var usePin: Bool = false
    var usePassword: Bool = false
    
    func initiate() -> Bool {
        if useTouchID {
            currentState = .touchID
            return true
        }
        else if usePin {
            currentState = .pin
            return true
        }
        else if usePassword {
            currentState = .password
            return true
        }
        return false
    }
    
    func next() -> Bool {
        if currentState == .password {
            return false
        }
        if currentState == .touchID {
            currentState = .pin
            if !self.usePin {
                return self.next()
            }
            return true
        }
        if currentState == .pin {
            currentState = .password
            if !self.usePassword {
                return self.next()
            }
            return true
        }
        return false
    }
}
