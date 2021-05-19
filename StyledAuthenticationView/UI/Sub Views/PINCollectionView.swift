//
//  PINCollectionView.swift
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
import FlexCollections
import FlexMenu
import FlexControls

class PINCollectionView: ShakeableFlexCollectionView {
    var viewMenuItems: [FlexMenuItem] = []
    var cancelDeleteMenu: FlexMenu?
    var shouldShowCancel: Bool = true
    
    var pinStyle = FlexShapeStyle(style: .thumb)
    var pinBorderColor: UIColor = .white
    var pinSelectionColor: UIColor = .white
    var pinInnerColor: UIColor = .clear
    var pinBorderWidth: CGFloat = 0.5
    var pinFont: UIFont = UIFont.systemFont(ofSize: 36)
    var pinTextColor: UIColor = .white
    
    public func applyConfiguration(_ configuration: StyledAuthenticationViewConfiguration) {
        self.pinStyle = configuration.pinStyle
        self.pinBorderColor = configuration.pinBorderColor
        self.pinSelectionColor = configuration.pinSelectionColor
        self.pinInnerColor = configuration.pinInnerColor
        self.pinBorderWidth = configuration.pinBorderWidth
        self.pinFont = configuration.pinFont
        self.pinTextColor = configuration.pinTextColor
        self.cancelDeleteMenu?.separatorFont = configuration.cancelDeleteButtonFont
        self.cancelDeleteMenu?.separatorTextColor = configuration.cancelDeleteButtonTextColor
    }
    
    func updateCancelDeleteButtonTitle(forEnteredDigitsCount count: Int) {
        if count == 0 {
            self.cancelDeleteMenu?.isHidden = !shouldShowCancel
            self.viewMenuItems[0].title = "Cancel"
        }
        else {
            self.viewMenuItems[0].title = "Delete"
            self.cancelDeleteMenu?.isHidden = false
        }
        self.cancelDeleteMenu?.setNeedsLayout()
    }
    
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
}
