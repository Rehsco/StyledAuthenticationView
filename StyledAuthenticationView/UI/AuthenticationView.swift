//
//  AuthenticationView.swift
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

import UIKit
import LocalAuthentication
import MJRFlexStyleComponents

public enum AuthErrorType {
    case success
    case cancelled
    case authFail
    case tooManyRetries
    case fallback
    case touchIDUnavailable
    case unableToEvalPinCode
    case unableToEvalPassword
    case pinEntriesDidNotMatch
    
    public func description() -> String {
        switch self {
        case .success:
            return "Successfully authenticated"
        case .cancelled:
            return "You cancelled the authentication."
        case .authFail:
            return "There was a problem verifying your identity."
        case .tooManyRetries:
            return "Too many retries. Authentication failed."
        case .fallback:
            return "It was not possible to authenticate in any other way."
        case .touchIDUnavailable:
            return "TouchID appears to be disabled"
        case .unableToEvalPinCode:
            return "Unable to verify PIN code"
        case .unableToEvalPassword:
            return "Unable to verify Password"
        case .pinEntriesDidNotMatch:
            return "The verifying PIN code did not match the new one"
        }
    }
}

open class AuthenticationView: UIView, UITextFieldDelegate {
    private let passwordFieldId = "passwordField"
    private var context = LAContext()
    
    private var bgGradientLayer: CAGradientLayer?

    private var passwordCollectionView: PasswordCollectionView?

    private var pinCollectionView: PINCollectionView?
    private var microPinCollectionView: MicroPINCollectionView?
    private var secRefs: [String] = []
    
    private var cancelDeleteViewMenu: FlexViewMenu?
    
    private var pwItem: FlexTextFieldCollectionItem?
    
    private var enteredDigits: [Digit] = []

    private var tries = 0

    // TODO: Refactor to use DIP
    open var configuration = StyledAuthenticationViewConfiguration() {
        didSet {
            refreshCollectionViews()
        }
    }

    // TODO: Refactor to use DIP
    open var pinCodeEvaluator: ((String) -> Bool)?

    // TODO: Refactor to use DIP
    open var passwordEvaluator: ((String) -> Bool)?
    
    
    private class Digit {
        var digit: Int?
        
        init(digit: Int?) {
            self.digit = digit
        }
    }

    private let authStateMachine = AuthStateMachine()
    
    // MARK: - Public interface
    
    open func authenticate(useTouchID: Bool, usePin: Bool, usePassword: Bool, authHandler: @escaping ((Bool, AuthErrorType) -> Void)) {
        self.tries = 0
        self.authStateMachine.usePin = usePin
        self.authStateMachine.useTouchID = useTouchID
        self.authStateMachine.usePassword = usePassword

        if !self.authStateMachine.initiate() {
            // There is nothing to verify!
            authHandler(true, .success)
        }
        
        self.authWorkflow(authHandler: authHandler)
    }

    open func createPINCode(createPinHandler: @escaping ((String, Bool, AuthErrorType) -> Void)) {
        self.enteredDigits = []
        var proposedDigitStr: String? = nil
        self.createDigitView(configuration.createPinHeaderText) { (digits, success) in
            if success {
                if proposedDigitStr == nil {
                    proposedDigitStr = digits
                    self.microPinCollectionView?.headerText = self.configuration.verifyPinHeaderText
                    self.enteredDigits = []
                    self.pinCollectionView?.updateCancelDeleteButtonTitle(forEnteredDigitsCount: self.enteredDigits.count)
                    self.microPinCollectionView?.deselectAll()
                }
                else {
                    if proposedDigitStr == digits {
                        createPinHandler(digits, true, .success)
                    }
                    else {
                        self.microPinCollectionView?.deselectAll()
                        self.enteredDigits = []
                        self.pinCollectionView?.updateCancelDeleteButtonTitle(forEnteredDigitsCount: self.enteredDigits.count)
                        self.microPinCollectionView?.shake(shouldVibrate: self.configuration.vibrateOnFail)
                        self.microPinCollectionView?.headerText = self.configuration.createPinHeaderText
                        proposedDigitStr = nil
                    }
                }
            }
            else {
                createPinHandler("", false, .cancelled)
            }
        }
    }

    open func changePINCode(createPinHandler: @escaping ((String, Bool, AuthErrorType) -> Void)) {
        self.authenticateWithPINCode { success, errorType in
            if success {
                self.microPinCollectionView?.deselectAll()
                self.pinCollectionView?.updateCancelDeleteButtonTitle(forEnteredDigitsCount: self.enteredDigits.count)
                self.createPINCode(createPinHandler: createPinHandler)
            }
            else {
                createPinHandler("", false, errorType)
            }
        }
    }

    open func createPassword(createPasswordHandler: @escaping ((String, Bool) -> Void)) {
        var proposedPassword: String? = nil
        self.createPasswordView(configuration.createPasswordHeaderText) { (password, success) in
            if success {
                if proposedPassword == nil {
                    proposedPassword = password
                    self.pwItem?.text = NSAttributedString(string: "")
                    self.passwordCollectionView?.headerText = self.configuration.verifyPasswordHeaderText
                    self.passwordCollectionView?.itemCollectionView.reloadData()
                    self.showKeyboardForEnteringPassword()
                }
                else {
                    if proposedPassword == password {
                        createPasswordHandler(password, true)
                    }
                    else {
                        self.pwItem?.text = NSAttributedString(string: "")
                        self.passwordCollectionView?.itemCollectionView.reloadData()
                        self.passwordCollectionView?.shake(shouldVibrate: self.configuration.vibrateOnFail)
                        self.passwordCollectionView?.headerText = self.configuration.createPasswordHeaderText
                        proposedPassword = nil
                    }
                }
            }
            else {
                createPasswordHandler("", false)
            }
        }
    }
    
    open func changePassword(createPasswordHandler: @escaping ((String, Bool) -> Void)) {
        self.authenticateWithPassword { success, errorType in
            if success {
                self.createPassword(createPasswordHandler: createPasswordHandler)
            }
            else {
                createPasswordHandler("", false)
            }
        }
    }
    
    // MARK: - View logic
    
    fileprivate func getPasswordCell() -> FlexTextFieldCollectionViewCell? {
        if let ip = self.passwordCollectionView?.getIndexPathForItem(self.passwordFieldId) {
            if let cell = passwordCollectionView?.itemCollectionView.cellForItem(at: ip) as? FlexTextFieldCollectionViewCell {
                return cell
            }
        }
        return nil
    }
    
    private func showKeyboardForEnteringPassword() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(500)) {
            let cell = self.getPasswordCell()
            cell?.textField?.becomeFirstResponder()
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        bgGradientLayer?.frame = self.bounds
        
        microPinCollectionView?.frame = calculateMicroPinFrame()
        pinCollectionView?.frame = calculatePinFrame()
        passwordCollectionView?.frame = calculatePasswordViewFrame()
        pinCollectionView?.defaultCellSize = calculateFittingPinCellSize()
    }
    
    private func refreshCollectionViews() {
        microPinCollectionView?.applyConfiguration(configuration)
        passwordCollectionView?.applyConfiguration(configuration)
        pinCollectionView?.applyConfiguration(configuration)
    }
    
    private func removeAllSubViews() {
        microPinCollectionView?.removeFromSuperview()
        pinCollectionView?.removeFromSuperview()
        passwordCollectionView?.removeFromSuperview()
    }

    private func calculateSecurityViewRect() -> CGRect {
        let minRect = CGRect(origin: .zero, size: CGSize(width: min(bounds.width, configuration.securityViewPreferredSize.width), height: min(bounds.height, configuration.securityViewPreferredSize.height)))
        let secViewRect = CGRect(origin: .zero, size: configuration.securityViewPreferredSize)
        let fitRect = CGRectHelper.AspectFitRectInRect(secViewRect, rtarget: minRect)
        return CGRect(origin: CGPoint(x: (bounds.size.width - fitRect.size.width) * 0.5, y: (bounds.size.height - fitRect.size.height) * 0.5), size: fitRect.size)
    }

    private func calculatePasswordViewFrame() -> CGRect {
        let secViewFrame = calculateSecurityViewRect()
        let passwordViewFrame = CGRect(origin: secViewFrame.origin, size: CGSize(width: secViewFrame.size.width, height: configuration.passwordViewHeight))
        return passwordViewFrame
    }

    private func calculateMicroPinFrame() -> CGRect {
        let secViewFrame = calculateSecurityViewRect()
        let microPinViewFrame = CGRect(origin: secViewFrame.origin, size: CGSize(width: secViewFrame.size.width, height: configuration.microPinViewHeight))
        return microPinViewFrame
    }

    private func calculatePinFrame() -> CGRect {
        let secViewFrame = calculateSecurityViewRect()
        let microPinViewFrame = CGRect(origin: CGPoint(x: secViewFrame.origin.x, y: secViewFrame.origin.y + configuration.microPinViewHeight), size: CGSize(width: secViewFrame.size.width, height: secViewFrame.size.height - configuration.microPinViewHeight))
        return microPinViewFrame
    }

    private func calculateFittingPinCellSize() -> CGSize {
        if let pinView = pinCollectionView {
            let maxPinViewSize = calculatePinFrame().size
            let pinViewSize = CGSize(width: maxPinViewSize.width, height: maxPinViewSize.height - configuration.pinViewFooterHeight)
            let collMargins = pinView.viewMargins
            let horizontalSpacing = pinView.getHorizontalSpacing()
            
            var rowWidth: CGFloat = 0
            if #available(iOS 11.0, *), pinViewSize.width == bounds.width {
                rowWidth = pinViewSize.width - (collMargins.left + collMargins.right + pinView.itemCollectionView.safeAreaInsets.left + pinView.itemCollectionView.safeAreaInsets.right)
            } else {
                rowWidth = pinViewSize.width - (collMargins.left + collMargins.right)
            }
            rowWidth -= pinView.getHorizontalSectionInset(forSection: 0)
            
            let cellWidth = (rowWidth - max(0, 3 - 1) * horizontalSpacing) / 3
            
            let verticalSpacing = pinView.getVerticalSpacing()
            let rowHeight = pinViewSize.height - (collMargins.top + collMargins.bottom + pinView.getVerticalSectionInset(forSection: 0))

            let cellHeight = (rowHeight - max(0, 4 - 1) * verticalSpacing) / 4

            if cellWidth < configuration.pinCellPreferredSize.width || cellHeight < configuration.pinCellPreferredSize.height {
                return CGRectHelper.AspectFitRectInRect(CGRect(origin: .zero, size: configuration.pinCellPreferredSize), rtarget: CGRect(origin: .zero, size: CGSize(width: cellWidth, height: cellHeight))).size
            }
        }
        return configuration.pinCellPreferredSize
    }
    
    // MARK: - Business logic
    
    /// This is the workflow of the authentication. All available authentication methods will be applied in the order of touchID -> Pin -> Password
    private func authWorkflow(authHandler: @escaping ((Bool, AuthErrorType) -> Void)) {
        let handler: ((Bool, AuthErrorType) -> Void) = {
            success, errorType in
            if success {
                authHandler(success, errorType)
            }
            else {
                if self.authStateMachine.next() {
                    self.authWorkflow(authHandler: authHandler)
                }
                else {
                    authHandler(success, errorType)
                }
            }
        }
        
        switch self.authStateMachine.currentState {
        case .touchID:
            self.authenticateWithTouchID(handler)
        case .pin:
            self.authenticateWithPINCode(handler)
        case .password:
            self.authenticateWithPassword(handler)
        }
    }

    private func authenticateWithTouchID(_ authHandler: @escaping ((Bool, AuthErrorType) -> Void)) {
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error:nil) {
            context.localizedFallbackTitle = self.configuration.usePinCodeText
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: self.configuration.touchIDDetailText,
                                   reply: { (success : Bool, error : Error? ) -> Void in
                                    
                                    DispatchQueue.main.async {
                                        if success {
                                            authHandler(true, .success)
                                        }
                                        if let error = error {
                                            switch(error._code) {
                                            case LAError.authenticationFailed.rawValue:
                                                authHandler(false, .authFail)
                                            case LAError.userCancel.rawValue:
                                                authHandler(false, .cancelled)
                                            case LAError.userFallback.rawValue:
                                                authHandler(false, .fallback)
                                            default:
                                                authHandler(false, .touchIDUnavailable)
                                            }
                                        }
                                    }
            })
        } else {
            authHandler(false, .touchIDUnavailable)
        }
    }
    
    private func authenticateWithPINCode(_ authHandler: @escaping ((Bool, AuthErrorType) -> Void)) {
        self.tries = 0
        if let pce = self.pinCodeEvaluator {
            self.enteredDigits = []
            self.createDigitView(self.configuration.pinHeaderText) { (digits, success) in
                if success {
                    if pce(digits) {
                        authHandler(true, .success)
                    }
                    else {
                        // Retry
                        self.tries += 1
                        if self.configuration.allowedRetries == self.tries {
                            authHandler(false, .tooManyRetries)
                        }
                        else {
                            self.enteredDigits = []
                            self.pinCollectionView?.updateCancelDeleteButtonTitle(forEnteredDigitsCount: self.enteredDigits.count)
                            self.microPinCollectionView?.deselectAll()
                            self.microPinCollectionView?.shake(shouldVibrate: self.configuration.vibrateOnFail)
                        }
                    }
                }
                else {
                    authHandler(false, .cancelled)
                }
            }
        }
        else {
            authHandler(false, .unableToEvalPinCode)
        }
    }
    
    private func authenticateWithPassword(_ authHandler: @escaping ((Bool, AuthErrorType) -> Void)) {
        self.tries = 0
        if let pce = self.passwordEvaluator {
            self.createPasswordView(self.configuration.passwordHeaderText) { (password, success) in
                if success {
                    if pce(password) {
                        authHandler(true, .success)
                    }
                    else {
                        // Retry
                        self.tries += 1
                        if self.configuration.allowedRetries == self.tries {
                            authHandler(false, .tooManyRetries)
                        }
                        else {
                            self.pwItem?.text = NSAttributedString(string: "")
                            self.passwordCollectionView?.shake(shouldVibrate: self.configuration.vibrateOnFail)
                            self.passwordCollectionView?.itemCollectionView.reloadData()
                        }
                    }
                }
            }
        }
        else {
            authHandler(false, .unableToEvalPassword)
        }
    }

    private func createDigitView(_ headerText: String, digitsEnteredHandler: @escaping ((String, Bool) -> Void)) {
        removeAllSubViews()

        if let gradStart = configuration.backgroundGradientStartColor, let gradEnd = configuration.backgroundGradientEndColor {
            self.bgGradientLayer?.removeFromSuperlayer()
            self.bgGradientLayer = CAGradientLayer()
            if let bl = self.bgGradientLayer {
                bl.colors = [gradStart.cgColor, gradEnd.cgColor]
                self.layer.insertSublayer(bl, at: 0)
            }
        }
        self.pinCollectionView = PINCollectionView(frame: calculatePinFrame())
        if let pcv = self.pinCollectionView {
            pcv.shouldShowCancel = configuration.showCancel
            pcv.centerCellsHorizontally = true
            pcv.defaultCellSize = calculateFittingPinCellSize()
            pcv.styleColor = .clear
            pcv.footerSize = 35
            pcv.viewMargins = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
            pcv.header.caption.labelTextAlignment = .center
            
            let vm1 = FlexMenuItem(title: "Cancel", titleShortcut: "", color: UIColor.clear, thumbColor: UIColor.clear, thumbIcon: nil, disabledThumbIcon: nil)
            vm1.selectionHandler = {
                if self.enteredDigits.count == 0 {
                    digitsEnteredHandler("", false)
                }
                else {
                    self.microPinCollectionView?.deselectItem("\(self.enteredDigits.count-1)")
                    self.enteredDigits.removeLast()
                    self.pinCollectionView?.updateCancelDeleteButtonTitle(forEnteredDigitsCount: self.enteredDigits.count)
                    pcv.cancelDeleteMenu?.setNeedsLayout()
                }
            }
            pcv.viewMenuItems.append(vm1)
            pcv.cancelDeleteMenu = FlexMenu()
            pcv.cancelDeleteMenu?.menuItems = pcv.viewMenuItems
            self.cancelDeleteViewMenu = FlexViewMenu(menu: pcv.cancelDeleteMenu!, size: CGSize(width: 140, height: 35), hPos: .right, vPos: .footer)
            pcv.addMenu(self.cancelDeleteViewMenu!)
            
            pcv.cancelDeleteMenu?.isHidden = !configuration.showCancel
            
            pcv.removeAllSections()
            self.secRefs = []
            for _ in 0 ..< 4 {
                self.secRefs.append(pcv.addSection())
            }
            for r in 0 ..< 4 {
                let section = self.secRefs[r]
                let sec = pcv.getSection(section)
                sec?.insets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
                let pinRow = self.getDigitRow(row: r)
                var col = 0
                for pm in pinRow {
                    if let dtext = pm.digit {
                        let cellItem = FlexBaseCollectionItem(reference: "\(r),\(pm.digit ?? col)")
                        cellItem.text = NSAttributedString(string: "\(dtext)")
                        cellItem.itemSelectionActionHandler = {
                            self.enteredDigits.append(Digit(digit: pm.digit))
                            DispatchQueue.main.async {
                                self.microPinCollectionView?.selectItem("\(self.enteredDigits.count-1)")
                            }
                            vm1.title = "Delete"
                            pcv.cancelDeleteMenu?.isHidden = false
                            pcv.cancelDeleteMenu?.setNeedsLayout()
                            if self.enteredDigits.count == self.configuration.expectedPinCodeLength {
                                let pinDigits: [String] = self.enteredDigits.compactMap({"\($0.digit!)"})
                                // The last dot must have time to be displayed
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100), execute: {
                                    digitsEnteredHandler(pinDigits.joined(), true)
                                })
                            }
                        }
                        cellItem.autoDeselectCellAfter = .milliseconds(100)
                        cellItem.canMoveItem = false
                        pcv.addItem(section, item: cellItem)
                    }
                    col += 1
                }
            }
            self.addSubview(pcv)
        }
        
        self.microPinCollectionView = MicroPINCollectionView(frame: calculateMicroPinFrame())
        self.microPinCollectionView?.centerCellsHorizontally = true
        if let pcv = self.microPinCollectionView {
            (pcv.itemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 20
            
            pcv.headerText = headerText
            pcv.headerSize = 30
            pcv.header.styleColor = .clear
            pcv.header.caption.labelTextAlignment = .center
            
            pcv.isUserInteractionEnabled = false
            pcv.defaultCellSize = CGSize(width: 10, height: 10)
            pcv.styleColor = .clear
            pcv.viewMargins = UIEdgeInsets.init(top: 5, left: 5, bottom: 0, right: 5)
            pcv.allowsMultipleSelection = true
            
            pcv.removeAllSections()
            let msection = pcv.addSection()
            for col in 0..<configuration.expectedPinCodeLength {
                let cellItem = FlexBaseCollectionItem(reference: "\(col)")
                cellItem.canMoveItem = false
                cellItem.contentInteractionWillSelectItem = false
                pcv.addItem(msection, item: cellItem)
            }
            self.addSubview(pcv)
        }
        self.refreshCollectionViews()
    }
    
    private func getDigitRow(row: Int) -> [Digit] {
        var dRow: [Digit] = []
        for x in 0 ..< 3 {
            var digit: Int? = row * 3 + x + 1
            if row == 3 {
                if x == 0 || x == 2 {
                    digit = nil
                }
            }
            if let d = digit, d > 9 {
                digit = 0
            }
            dRow.append(Digit(digit: digit))
        }
        return dRow
    }
    
    private func createPasswordView(_ headerText: String, passwordEnteredHandler: @escaping ((String, Bool) -> Void)) {
        removeAllSubViews()
        
        self.passwordCollectionView = PasswordCollectionView(frame: calculatePasswordViewFrame())
        if let pcv = self.passwordCollectionView {
            pcv.styleColor = .clear
            pcv.headerText = headerText
            pcv.headerSize = 30
            pcv.header.styleColor = .clear
            pcv.header.caption.labelTextAlignment = .center

            pcv.isUserInteractionEnabled = true
            pcv.defaultCellSize = CGSize(width: 220, height: 40)
            pcv.viewMargins = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)
            
            pcv.removeAllSections()
            let msection = pcv.addSection()
            let pwIcon = configuration.passwordAcceptButtonIcon
            self.pwItem = FlexTextFieldCollectionItem(reference: passwordFieldId, accessoryImage: pwIcon) {
                if let pw = self.pwItem?.text?.string {
                    if pw != "" {
                        passwordEnteredHandler(pw, true)
                    }
                }
            }
            self.pwItem?.canMoveItem = false
            self.pwItem?.contentInteractionWillSelectItem = false
            self.pwItem?.textIsMutable = true
            self.pwItem?.isPasswordField = true
            self.pwItem?.text = NSAttributedString(string: "")
            self.pwItem?.placeholderText = NSAttributedString(string: "Password")
            self.pwItem?.textFieldDelegate = self
            pcv.addItem(msection, item: self.pwItem!)
            self.addSubview(pcv)
        }
        refreshCollectionViews()
        showKeyboardForEnteringPassword()
    }

    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        pwItem?.accessoryImageActionHandler?()
        return true
    }
}
