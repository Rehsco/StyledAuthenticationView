//
//  PasswordCollectionView.swift
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

class PasswordCollectionView: ShakeableFlexCollectionView {
    var pwStyle = FlexShapeStyle(style: .thumb)
    var pwBorderColor: UIColor = .white
    
    public func applyConfiguration(_ configuration: StyledAuthenticationViewConfiguration) {
        self.pwStyle = configuration.passwordStyle
        self.pwBorderColor = configuration.passwordBorderColor
        self.header.caption.labelTextColor = configuration.headerTextColor
        self.header.caption.labelFont = configuration.headerTextFont
        self.itemCollectionView.reloadData()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        if let passwordInputCell = cell as? FlexBaseCollectionViewCell {
            passwordInputCell.flexContentView?.style = self.pwStyle
            passwordInputCell.styleColor = .clear
            passwordInputCell.selectedStyleColor = .clear
            passwordInputCell.borderColor = self.pwBorderColor
            passwordInputCell.selectedBorderColor = self.pwBorderColor
            passwordInputCell.borderWidth = 1
            passwordInputCell.selectedBorderWidth = 1
        }
        return cell
    }
}
