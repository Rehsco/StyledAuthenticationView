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
    private var context = LAContext()
    
    private var pinCollectionView: PINCollectionView?
    private var microPinCollectionView: MicroPINCollectionView?
    private var secRefs: [String] = []
    
    private var cancelDeleteViewMenu: FlexViewMenu?
    
    private var pwItem: FlexTextFieldCollectionItem?
    
    private var enteredDigits: [Digit] = []
    
    open var pinHeaderText: String = "Enter PIN Code"
    open var passwordHeaderText: String = "Enter Password"
    open var usePinCodeText = "Use PIN Code"
    open var touchIDDetailText = "Authentication using Touch ID"
    
    open var createPinHeaderText = "Enter new PIN Code"
    open var verifyPinHeaderText = "Verify PIN Code"

    open var expectedPinCodeLength = 6
    open var pinCodeEvaluator: ((String) -> Bool)?

    private var passwordCollectionView: PasswordCollectionView?
    open var createPasswordHeaderText = "Enter new Password"
    open var verifyPasswordHeaderText = "Verify Password"

    open var passwordEvaluator: ((String) -> Bool)?

    open dynamic var vibrateOnFail = true
    open var allowedRetries = 3
    private var tries = 0
    
    open dynamic var showCancel = true
    
    open dynamic var pinStyle: FlexShapeStyle = FlexShapeStyle(style: .thumb) {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var pinBorderColor: UIColor = .white {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var pinSelectionColor: UIColor = .white {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var pinInnerColor: UIColor = .clear {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var pinBorderWidth: CGFloat = 0.5 {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var pinTextColor: UIColor = .white {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var pinFont: UIFont = UIFont.systemFont(ofSize: 36) {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var cancelDeleteButtonFont: UIFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var cancelDeleteButtonTextColor: UIColor = .white {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var passwordAcceptButtonIcon: UIImage? = nil {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var headerTextColor: UIColor = .white {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var headerTextFont: UIFont = UIFont.systemFont(ofSize: 18) {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var passwordStyle: FlexShapeStyle = FlexShapeStyle(style: .box) {
        didSet {
            self.refreshCollectionViews()
        }
    }
    open dynamic var passwordBorderColor: UIColor = .white {
        didSet {
            self.refreshCollectionViews()
        }
    }
    
    private var bgGradientLayer: CAGradientLayer?
    open dynamic var backgroundGradientStartColor: UIColor? {
        didSet {
            self.setNeedsLayout()
        }
    }
    open dynamic var backgroundGradientEndColor: UIColor? {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    private class Digit {
        var digit: Int?
        
        init(digit: Int?) {
            self.digit = digit
        }
    }
    
    enum AuthenticationStateType {
        case touchID
        case pin
        case password
    }
    
    private class AuthStateMachine {
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
    
    private let authStateMachine = AuthStateMachine()
    
    private class SCPMenuItem : FlexMenuItem {
        var selectionHandler: ((Void) -> Void)?
    }

    private class PINCollectionView: FlexCollectionView, FlexMenuDataSource {
        var viewMenuItems: [FlexMenuItem] = []
        var cancelDeleteMenu: FlexMenu?

        var pinStyle = FlexShapeStyle(style: .thumb)
        var pinBorderColor: UIColor = .white
        var pinSelectionColor: UIColor = .white
        var pinInnerColor: UIColor = .clear
        var pinBorderWidth: CGFloat = 0.5
        var pinFont: UIFont = UIFont.systemFont(ofSize: 36)
        var pinTextColor: UIColor = .white
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            if let pinCell = cell as? FlexBaseCollectionViewCell {
                pinCell.flexContentView?.style = self.pinStyle
                
                if pinCell.item?.text != nil {
                    pinCell.selectedStyleColor = self.pinSelectionColor
                    pinCell.borderColor = self.pinBorderColor
                    pinCell.selectedBorderColor = self.pinBorderColor
                    pinCell.borderWidth = self.pinBorderWidth
                    pinCell.selectedBorderWidth = self.pinBorderWidth
                    pinCell.textLabel?.labelFont = self.pinFont
                    pinCell.textLabel?.labelTextColor = self.pinTextColor
                    pinCell.textLabel?.labelTextAlignment = .center
                    pinCell.styleColor = self.pinInnerColor
                }
                else {
                    pinCell.selectedStyleColor = .clear
                    pinCell.borderColor = .clear
                    pinCell.selectedBorderColor = .clear
                    pinCell.styleColor = .clear
                }
            }
            return cell
        }
        
        // MARK: - FlexMenuDataSource
        
        func menuItemSelected(_ menu: FlexMenu, index: Int) {
            if let mi = self.menuItemForIndex(menu, index: index) as? SCPMenuItem {
                mi.selectionHandler?()
            }
        }
        
        func menuItemForIndex(_ menu: FlexMenu, index: Int) -> FlexMenuItem {
            return self.viewMenuItems[index]
        }
        
        func numberOfMenuItems(_ menu: FlexMenu) -> Int {
            return self.viewMenuItems.count
        }
    }

    private class MicroPINCollectionView: ShakeableFlexCollectionView {
        var pinStyle = FlexShapeStyle(style: .thumb)
        var pinBorderColor: UIColor = .white

        func deselectAll() {
            if let section = self.sectionReference(atIndex: 0) {
                if let secItems = self.contentDic?[section] {
                    for item in secItems {
                        self.deselectItem(item.reference)
                    }
                }
            }
        }
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            if let pinCell = cell as? FlexBaseCollectionViewCell {
                pinCell.flexContentView?.style = self.pinStyle
                pinCell.styleColor = .clear
                pinCell.selectedStyleColor = self.pinBorderColor
                pinCell.borderColor = self.pinBorderColor
                pinCell.selectedBorderColor = self.pinBorderColor
                pinCell.borderWidth = 0.5
                pinCell.selectedBorderWidth = 0.5
            }
            return cell
        }

        override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            if let secRef = self.sectionReference(atIndex: section), let itemCount = self.contentDic?[secRef]?.count, let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
                let cellCount = CGFloat(itemCount)
                
                if cellCount > 0 {
                    let spacing:CGFloat = flowLayout.minimumInteritemSpacing * 0.5
                    let cellWidth = self.defaultCellSize.width + spacing
                    let totalCellWidth = cellWidth*cellCount + spacing * (cellCount-1)
                    let ci = self.viewMargins.left + self.viewMargins.right
                    let contentWidth = collectionView.frame.size.width - ci
                    
                    if (totalCellWidth < contentWidth) {
                        let padding = (contentWidth - totalCellWidth) / 2.0
                        return UIEdgeInsetsMake(2, padding, 0, padding)
                    }
                }
            }
            return .zero
        }
    }

    private class PasswordCollectionView: ShakeableFlexCollectionView {
        var pwStyle = FlexShapeStyle(style: .thumb)
        var pwBorderColor: UIColor = .white
        
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            if let pinCell = cell as? FlexBaseCollectionViewCell {
                pinCell.flexContentView?.style = self.pwStyle
                pinCell.styleColor = .clear
                pinCell.selectedStyleColor = .clear
                pinCell.borderColor = self.pwBorderColor
                pinCell.selectedBorderColor = self.pwBorderColor
                pinCell.borderWidth = 1
                pinCell.selectedBorderWidth = 1
            }
            return cell
        }
    }

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
        self.createDigitView(self.createPinHeaderText) { (digits, success) in
            if success {
                if proposedDigitStr == nil {
                    proposedDigitStr = digits
                    self.microPinCollectionView?.headerText = self.verifyPinHeaderText
                    self.enteredDigits = []
                    self.updateCancelDeleteButtonTitle()
                    self.microPinCollectionView?.deselectAll()
                }
                else {
                    if proposedDigitStr == digits {
                        createPinHandler(digits, true, .success)
                    }
                    else {
                        self.microPinCollectionView?.deselectAll()
                        self.enteredDigits = []
                        self.updateCancelDeleteButtonTitle()
                        self.microPinCollectionView?.shake(shouldVibrate: self.vibrateOnFail)
                        self.microPinCollectionView?.headerText = self.createPinHeaderText
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
                self.updateCancelDeleteButtonTitle()
                self.createPINCode(createPinHandler: createPinHandler)
            }
            else {
                createPinHandler("", false, errorType)
            }
        }
    }

    open func createPassword(createPasswordHandler: @escaping ((String, Bool) -> Void)) {
        var proposedPassword: String? = nil
        self.createPasswordView(self.createPasswordHeaderText) { (password, success) in
            if success {
                if proposedPassword == nil {
                    proposedPassword = password
                    self.pwItem?.text = NSAttributedString(string: "")
                    self.passwordCollectionView?.headerText = self.verifyPasswordHeaderText
                    self.passwordCollectionView?.itemCollectionView.reloadData()
                }
                else {
                    if proposedPassword == password {
                        createPasswordHandler(password, true)
                    }
                    else {
                        self.pwItem?.text = NSAttributedString(string: "")
                        self.passwordCollectionView?.itemCollectionView.reloadData()
                        self.passwordCollectionView?.shake(shouldVibrate: self.vibrateOnFail)
                        self.passwordCollectionView?.headerText = self.createPasswordHeaderText
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.bgGradientLayer?.frame = self.bounds
    }
    
    private func refreshCollectionViews() {
        self.microPinCollectionView?.pinStyle = self.pinStyle
        self.microPinCollectionView?.pinBorderColor = self.pinBorderColor
        self.microPinCollectionView?.header.caption.labelTextColor = self.headerTextColor
        self.microPinCollectionView?.header.caption.labelFont = self.headerTextFont
        self.microPinCollectionView?.itemCollectionView.reloadData()

        self.passwordCollectionView?.pwStyle = self.passwordStyle
        self.passwordCollectionView?.pwBorderColor = self.passwordBorderColor
        self.passwordCollectionView?.header.caption.labelTextColor = self.headerTextColor
        self.passwordCollectionView?.header.caption.labelFont = self.headerTextFont
        self.passwordCollectionView?.itemCollectionView.reloadData()

        self.pinCollectionView?.pinStyle = self.pinStyle
        self.pinCollectionView?.pinBorderColor = self.pinBorderColor
        self.pinCollectionView?.pinSelectionColor = self.pinSelectionColor
        self.pinCollectionView?.pinInnerColor = self.pinInnerColor
        self.pinCollectionView?.pinBorderWidth = self.pinBorderWidth
        self.pinCollectionView?.pinFont = self.pinFont
        self.pinCollectionView?.pinTextColor = self.pinTextColor
        self.pinCollectionView?.cancelDeleteMenu?.separatorFont = self.cancelDeleteButtonFont
        self.pinCollectionView?.cancelDeleteMenu?.separatorTextColor = self.cancelDeleteButtonTextColor
        self.pinCollectionView?.itemCollectionView.reloadData()
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
            context.localizedFallbackTitle = self.usePinCodeText
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: self.touchIDDetailText,
                                   reply: { (success : Bool, error : Error? ) -> Void in
                                    
                                    DispatchQueue.main.async(execute: {
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
                                    })
            })
        } else {
            authHandler(false, .touchIDUnavailable)
        }
    }
    
    private func authenticateWithPINCode(_ authHandler: @escaping ((Bool, AuthErrorType) -> Void)) {
        self.tries = 0
        if let pce = self.pinCodeEvaluator {
            self.enteredDigits = []
            self.createDigitView(self.pinHeaderText) { (digits, success) in
                if success {
                    if pce(digits) {
                        authHandler(true, .success)
                    }
                    else {
                        // Retry
                        self.tries += 1
                        if self.allowedRetries == self.tries {
                            authHandler(false, .tooManyRetries)
                        }
                        else {
                            self.enteredDigits = []
                            self.updateCancelDeleteButtonTitle()
                            self.microPinCollectionView?.deselectAll()
                            self.microPinCollectionView?.shake(shouldVibrate: self.vibrateOnFail)
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
            self.createPasswordView(self.passwordHeaderText) { (password, success) in
                if success {
                    if pce(password) {
                        authHandler(true, .success)
                    }
                    else {
                        // Retry
                        self.tries += 1
                        if self.allowedRetries == self.tries {
                            authHandler(false, .tooManyRetries)
                        }
                        else {
                            self.pwItem?.text = NSAttributedString(string: "")
                            self.passwordCollectionView?.shake(shouldVibrate: self.vibrateOnFail)
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
        self.microPinCollectionView?.removeFromSuperview()
        self.pinCollectionView?.removeFromSuperview()
        
        if let gradStart = self.backgroundGradientStartColor, let gradEnd = self.backgroundGradientEndColor {
            self.bgGradientLayer?.removeFromSuperlayer()
            self.bgGradientLayer = CAGradientLayer()
            if let bl = self.bgGradientLayer {
                bl.colors = [gradStart.cgColor, gradEnd.cgColor]
                self.layer.insertSublayer(bl, at: 0)
            }
        }
        let xoffset:CGFloat = (self.bounds.size.width - 300) * 0.5
        let yoffset:CGFloat = (self.bounds.size.height - 400) * 0.5 + 30
        let pcvRect = CGRect(origin: CGPoint(x: xoffset, y: yoffset), size: CGSize(width: 300, height: 400))
        self.pinCollectionView = PINCollectionView(frame: pcvRect)
        if let pcv = self.pinCollectionView {
            pcv.defaultCellSize = CGSize(width: 80, height: 80)
            pcv.styleColor = .clear
            pcv.footerSize = 35
            pcv.viewMargins = UIEdgeInsetsMake(5, 5, 5, 5)
            pcv.header.caption.labelTextAlignment = .center
            
            let vm1 = SCPMenuItem(title: "Cancel", titleShortcut: "", color: UIColor.clear, thumbColor: UIColor.clear, thumbIcon: nil, disabledThumbIcon: nil)
            vm1.selectionHandler = {
                if self.enteredDigits.count == 0 {
                    digitsEnteredHandler("", false)
                }
                else {
                    self.microPinCollectionView?.deselectItem("\(self.enteredDigits.count-1)")
                    self.enteredDigits.removeLast()
                    self.updateCancelDeleteButtonTitle()
                    pcv.cancelDeleteMenu?.setNeedsLayout()
                }
            }
            pcv.viewMenuItems.append(vm1)
            pcv.cancelDeleteMenu = FlexMenu()
            pcv.cancelDeleteMenu?.menuDataSource = pcv
            self.cancelDeleteViewMenu = FlexViewMenu(menu: pcv.cancelDeleteMenu!, size: CGSize(width: 140, height: 35), hPos: .right, vPos: .footer)
            pcv.addMenu(self.cancelDeleteViewMenu!)
            
            pcv.cancelDeleteMenu?.isHidden = !self.showCancel
            
            pcv.removeAllSections()
            self.secRefs = []
            for _ in 0 ..< 4 {
                self.secRefs.append(pcv.addSection())
            }
            for r in 0 ..< 4 {
                let section = self.secRefs[r]
                let sec = pcv.getSection(section)
                sec?.insets = UIEdgeInsetsMake(5, 5, 5, 5)
                let pinRow = self.getDigitRow(row: r)
                for pm in pinRow {
                    let cellItem = FlexBaseCollectionItem(reference: "\(r),\(pm.digit)")
                    if let dtext = pm.digit {
                        cellItem.text = NSAttributedString(string: "\(dtext)")
                        cellItem.itemSelectionActionHandler = {
                            self.enteredDigits.append(Digit(digit: pm.digit))
                            DispatchQueue.main.async {
                                self.microPinCollectionView?.selectItem("\(self.enteredDigits.count-1)")
                            }
                            vm1.title = "Delete"
                            pcv.cancelDeleteMenu?.isHidden = false
                            pcv.cancelDeleteMenu?.setNeedsLayout()
                            if self.enteredDigits.count == self.expectedPinCodeLength {
                                let pinDigits: [String] = self.enteredDigits.flatMap({"\($0.digit!)"})
                                // The last dot must have time to be displayed
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(100), execute: {
                                    digitsEnteredHandler(pinDigits.joined(), true)
                                })
                            }
                        }
                    }
                    cellItem.autoDeselectCellAfter = .milliseconds(100)
                    cellItem.canMoveItem = false
                    pcv.addItem(section, item: cellItem)
                }
            }
            self.addSubview(pcv)
        }
        
        let microPinViewWidth = self.bounds.size.width - 20
        let mxoffset:CGFloat = (self.bounds.size.width - microPinViewWidth) * 0.5
        let mpcvRect = CGRect(origin: CGPoint(x: mxoffset, y: yoffset - 70), size: CGSize(width: microPinViewWidth, height: 75))
        self.microPinCollectionView = MicroPINCollectionView(frame: mpcvRect)
        if let pcv = self.microPinCollectionView {
            (pcv.itemCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 20
            
            pcv.headerText = headerText
            pcv.headerSize = 30
            pcv.header.styleColor = .clear
            pcv.header.caption.labelTextAlignment = .center
            
            pcv.isUserInteractionEnabled = false
            pcv.defaultCellSize = CGSize(width: 10, height: 10)
            pcv.styleColor = .clear
            pcv.viewMargins = UIEdgeInsetsMake(5, 5, 0, 5)
            pcv.allowsMultipleSelection = true
            
            pcv.removeAllSections()
            let msection = pcv.addSection()
            for col in 0..<self.expectedPinCodeLength {
                let cellItem = FlexBaseCollectionItem(reference: "\(col)")
                cellItem.canMoveItem = false
                cellItem.contentInteractionWillSelectItem = false
                pcv.addItem(msection, item: cellItem)
            }
            self.addSubview(pcv)
        }
        self.refreshCollectionViews()
    }

    
    private func updateCancelDeleteButtonTitle() {
        if self.enteredDigits.count == 0 {
            self.pinCollectionView?.cancelDeleteMenu?.isHidden = !self.showCancel
            self.pinCollectionView?.viewMenuItems[0].title = "Cancel"
        }
        else {
            self.pinCollectionView?.viewMenuItems[0].title = "Delete"
            self.pinCollectionView?.cancelDeleteMenu?.isHidden = false
        }
        self.pinCollectionView?.cancelDeleteMenu?.setNeedsLayout()
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
        self.microPinCollectionView?.removeFromSuperview()
        self.pinCollectionView?.removeFromSuperview()
        self.passwordCollectionView?.removeFromSuperview()
        
        let yoffset:CGFloat = (self.bounds.size.height - 400) * 0.5 + 30
        let microPinViewWidth = self.bounds.size.width - 20
        let mxoffset:CGFloat = (self.bounds.size.width - microPinViewWidth) * 0.5
        let mpcvRect = CGRect(origin: CGPoint(x: mxoffset, y: yoffset - 70), size: CGSize(width: microPinViewWidth, height: 120))
        self.passwordCollectionView = PasswordCollectionView(frame: mpcvRect)
        if let pcv = self.passwordCollectionView {
            pcv.styleColor = .clear
            pcv.headerText = headerText
            pcv.headerSize = 30
            pcv.header.styleColor = .clear
            pcv.header.caption.labelTextAlignment = .center

            pcv.isUserInteractionEnabled = true
            pcv.defaultCellSize = CGSize(width: 220, height: 40)
            pcv.viewMargins = UIEdgeInsetsMake(5, 5, 5, 5)
            
            pcv.removeAllSections()
            let msection = pcv.addSection()
            let pwIcon = self.passwordAcceptButtonIcon ?? UIImage(named: "Accept_36pt")
            self.pwItem = FlexTextFieldCollectionItem(reference: "passwordField", accessoryImage: pwIcon) {
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
        self.refreshCollectionViews()
    }

    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
