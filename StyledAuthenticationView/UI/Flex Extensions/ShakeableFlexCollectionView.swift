//
//  ShakeableFlexCollectionView.swift
//  StyledAuthenticationView
//
//  Created by Martin Rehder on 08.02.2017.
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
import AVFoundation

open class ShakeableFlexCollectionView: FlexCollectionView {
    private var numShakes = 0
    private var shakeDirection: Int = 0
    private var shakeAmplitude: CGFloat = 0
    private let totalShakes = 6
    private let initialShakeAmplitude: CGFloat = 40.0
    
    func shake(shouldVibrate: Bool, completionHandler: (() -> Void)? = nil) {
        self.numShakes = 0
        self.shakeDirection = -1
        self.shakeAmplitude = self.initialShakeAmplitude
        self.performShake(completionHandler)
        if shouldVibrate {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    private func performShake(_ completionHandler: (() -> Void)? = nil) {
        UIView.animate(withDuration:0.03, animations: {
            self.transform = CGAffineTransform(translationX: CGFloat(self.shakeDirection) * self.shakeAmplitude, y: 0.0)
        }, completion: {
            finished in
            if self.numShakes < self.totalShakes {
                self.numShakes += 1
                self.shakeDirection = -1 * self.shakeDirection
                self.shakeAmplitude = CGFloat(self.totalShakes - self.numShakes) * (self.initialShakeAmplitude / CGFloat(self.totalShakes))
                self.performShake(completionHandler)
            } else {
                self.transform = CGAffineTransform.identity
                completionHandler?()
            }
        })
    }
}
