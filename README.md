# StyledAuthenticationView
StyledAuthenticationView is a UIView with styling options to authenticate with TouchID, PIN and Passwords

![img_2712](https://cloud.githubusercontent.com/assets/476994/22781402/a517cc50-eec2-11e6-9050-7cd35a41b2ad.PNG =240x320)
![img_2713](https://cloud.githubusercontent.com/assets/476994/22781403/a5268ce0-eec2-11e6-8d13-aa0f1565cd67.PNG =240x320)
![img_2715](https://cloud.githubusercontent.com/assets/476994/22781404/a52792e8-eec2-11e6-806e-9f02c18222aa.PNG =240x320)

# Usage

Please look at the AuthenticationDemo project for a complete use case.

# Installation

## CocoaPods

Install CocoaPods if not already available:

``` bash
$ [sudo] gem install cocoapods
$ pod setup
```
Go to the directory of your Xcode project, and Create and Edit your Podfile and add _StyledLabel_:

``` bash
$ cd /path/to/MyProject
$ touch Podfile
$ edit Podfile
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, ‘10.0’

use_frameworks!
pod ‘StyledAuthenticationView’
```

Install into your project:

``` bash
$ pod install
```

Open your project in Xcode from the .xcworkspace file (not the usual project file):

``` bash
$ open MyProject.xcworkspace
```

You can now `import StyledAuthenticationView` framework into your files.

## Manually

[Download](https://github.com/Rehsco/StyledAuthenticationView/archive/master.zip) the project and copy the `StyledAuthenticationView` folder into your project to use it in.

You will also need MJRFlexStyleComponents and dependencies copied into your project manually.

# License (MIT)

Copyright (c) 2017-present - Martin Jacob Rehder, Rehsco, Teletronics.ae

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
