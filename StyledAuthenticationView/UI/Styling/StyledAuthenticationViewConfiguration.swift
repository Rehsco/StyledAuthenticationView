//
//  StyledAuthenticationViewConfiguration.swift
//  StyledAuthenticationView
//
//  Created by Martin Rehder on 16.02.2019.
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

import UIKit
import MJRFlexStyleComponents

public class StyledAuthenticationViewConfiguration {

    // Touch ID
    public var touchIDDetailText = "Authentication using Touch ID"
    
    // PIN
    public var pinHeaderText = "Enter PIN Code"
    public var usePinCodeText = "Use PIN Code"
    public var createPinHeaderText = "Enter new PIN Code"
    public var verifyPinHeaderText = "Verify PIN Code"
    
    public var expectedPinCodeLength = 6

    // Password
    public var passwordHeaderText = "Enter Password"
    public var createPasswordHeaderText = "Enter new Password"
    public var verifyPasswordHeaderText = "Verify Password"

    // Options
    public var vibrateOnFail = true
    public var allowedRetries = 3
    public var showCancel = true

    // Styling
    public var securityViewPreferredSize: CGSize = CGSize(width: 300, height: 480)
    public var pinCellPreferredSize: CGSize = CGSize(width: 80, height: 80)
    public var microPinViewHeight: CGFloat = 75
    public var pinViewFooterHeight: CGFloat = 25
    public var passwordViewHeight: CGFloat = 120

    public var pinStyle: FlexShapeStyle = FlexShapeStyle(style: .thumb)
    public var pinBorderColor: UIColor = .white
    public var pinSelectionColor: UIColor = .white
    public var pinInnerColor: UIColor = .clear
    public var pinBorderWidth: CGFloat = 0.5
    public var pinTextColor: UIColor = .white
    public var pinFont: UIFont = UIFont.systemFont(ofSize: 36)
    public var cancelDeleteButtonFont: UIFont = UIFont.systemFont(ofSize: 18)
    public var cancelDeleteButtonTextColor: UIColor = .white
    public var headerTextColor: UIColor = .white
    public var headerTextFont: UIFont = UIFont.systemFont(ofSize: 18)

    public var passwordStyle: FlexShapeStyle = FlexShapeStyle(style: .box)
    public var passwordBorderColor: UIColor = .white
    public var passwordAcceptButtonIcon: UIImage? = UIImage(named: "Accept_36pt", in: Bundle(for: StyledAuthenticationViewConfiguration.self), compatibleWith: nil)

    public var backgroundGradientStartColor: UIColor?
    public var backgroundGradientEndColor: UIColor?

}
