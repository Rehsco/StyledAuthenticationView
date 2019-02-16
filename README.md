# StyledAuthenticationView
StyledAuthenticationView is a UIView with styling options to authenticate with TouchID, PIN and Passwords

![](https://cloud.githubusercontent.com/assets/476994/22781809/84a5f2b0-eec4-11e6-81e9-d3d52b3088be.jpg)
![](https://cloud.githubusercontent.com/assets/476994/22781808/84a547de-eec4-11e6-966a-6a98ce455d50.jpg)
![](https://cloud.githubusercontent.com/assets/476994/22781810/84da1b94-eec4-11e6-802c-27075b9f4cae.jpg)

# Usage

Please look at the AuthenticationDemo project for a complete use case.

Note that from version 3.0 the library is using the StyledAuthenticationViewConfiguration class for styling and configuration and no longer parameters on the StyledAuthenticationView.

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
