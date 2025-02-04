# KoalaCI - A build monitor in Flutter 

A simple Flutter app to monitor your build of your goCD instance.
Flutter allows to build app for both Android and iOS but for now only the Android build is provided.

## Setup (for Android only)
1. Download binary (`apk`) here: [DOWNLOAD](https://github.com/biocarl/koala_ci/raw/master/bin/koalaCI.apk)
2. Install on your phone
2. On first start, provide the url of your goCD instance

## Screenshots
___             |  __
:-------------------------:|:-------------------------:
![Koala View](/screenshots/success.jpg?raw=true "Positive build status") | ![Koala View](/screenshots/fail.jpg?raw=true "Failing build status") 

## Build locally
1. [Setup](https://flutter.dev/docs/get-started/install/macos) Flutter on your machine
1. `flutter build apk`
2. `flutter install` (when your device is connected)

## How build states are handled
- ::Fail:: Failed, Cancelled
- ::Success:: Passed
- ::Wait:: Building, Unknown

