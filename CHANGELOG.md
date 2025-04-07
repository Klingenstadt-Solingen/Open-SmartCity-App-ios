# [Changelog](https://keepachangelog.com/en/1.1.0/)

All significant changes (incl. versioning) are documented here.

## [Unreleased](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/releases)

## [3.8.8](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.8.8)

### Changed
- Update readme

## [3.8.7](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.8.7)

### Changed
- Update readme

## [3.8.6](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.8.6)

### Added
- Dark mode app icon

### Changed
- Filter event query by event status

## [3.8.5](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.8.5)

### Added
- Waste appointment calendar subscription
- Green waste container in waste appointments

## [3.8.4](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.8.4)

### Changed
- District politics api url by reading it from the plist

## [3.8.3](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.8.3)

### Changed
- Updated submodule versions

## [3.8.2](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.8.2)

### Changed
- Updated environment module

## [3.8.1](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.8.1)

### Changed
- Updated submodule versions

## [3.8.0](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.8.0)

## Added
- Matomo navigation tracking

### Changed
- District link for widget and dynamic district widget button text

## [3.7.0](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.7.0)

### Added
- Event module widget
- District diashow

### Changed
- Replaced all event module with district event module

## [3.6.2](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.6.2)

### Changed
- District module event filter button

## [3.6.1](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.6.1)

### Fixed
- District politics meeting filter

## [3.6.0](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.6.0)

### Changed
- Updated submodules

### Fixed
- First url item in service menu determining all url items links by checking if the link to be opened has changed

## [3.5.1](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.5.1)

### Changed
- Extended Weather Station List

## [3.5.0](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.5.0)

### Added
- District module
- Removed hardcoded api credentials in district module by passing it through the core app

## [3.4.1](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.4.1)

### Added
- Sentry config

## [3.4.0](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.4.0)

### Added
- Environment module

### Changed
- Update submodule

## [3.3.0](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.3.0)

### Added
- Sentry error logging

## [3.2.1](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.2.1)

### Fix
- Cold start app via push notification center from push notification

## [3.2.0](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.2.0)

### Added
- Swipe and zoom in POI Detail Image View

### Changed
- Update submodules

## [3.1.0](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.1.0)

### Changed

- Replaced event ui with SwiftUI

### Fixed

- Laggy event module

## [v3.0.13](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.13)

### Changed

- Updated Mobilitymonitor UI Module
- Update Contact UI Module

### Fix
- cold start app via deeplink

## [v3.0.12](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.12)

### Added

- Foreground push notification handling
- Navigation to deeplink from push notification payload

### Changed

- launch activity indicator disabled

* Update Waste UI Module
* Update Press Release UI Module
* Update Map UI Module

## [v3.0.11](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.11)

### Added

- `Quartier Wald` image gallery

### Changed

- Updated Mobilitymonitor UI Module

* `API_Develop.plist` or `API_Release.plist` in application bundle
* `OSCASolingen` module's `AppDelegate` base class lazy injected `AppDI.Config` class utilizes the `.plist` files from app bundle
* prebuild script in `Solingen` target removed !!!
* changed text of 6th welcome slide
* changed Privacy policy text on 3rd welcome slide
* When user refresh on start screen without internet, the Error Text is readable now
* added Text for BeaconSearchViewController to always allow location access rights
* Swift Package Manager: toggle switch between local and remote package

### Fixed

- weather module default location
- mobility module default location
- Defect module default location
- Mobility Monitor infinite loading if no location permission is given by using a default location instead
- Coworking data module di tree
- ParseInstallation not updating and thus not subscribing to push notifications, not setting device token and not updating app version
- fix reflecting di default location and app store url

## [v3.0.10](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.10)

fix reflecting di default location and app store url

## [3.0.9](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/3.0.9)

### Changed

- `API_Develop.plist` or `API_Release.plist` in application bundle
- `OSCASolingen` module's `AppDelegate` base class lazy injected `AppDI.Config` class utilizes the `.plist` files from app bundle
- prebuild script in `Solingen` target removed !!!
- changed text of 6th welcome slide
- changed Privacy policy text on 3rd welcome slide
- When user refresh on start screen without internet, the Error Text is readable now
- added Text for BeaconSearchViewController to always allow location access rights

### Fixed

- Correct Image Urls in Events

## [v3.0.8](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.8)

refactor: fix / optimized onboarding

## [v3.0.7](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.7)

fix onboarding async work

## [v3.0.6](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.6)

fix device data in settings

## [v3.0.5](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.5)

app start retailoring

## [v3.0.4](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.4)

fix OSCAWeatherUI: default title / temperature removed

## [v3.0.3](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.3)

fix respecting new Parse ACL policy

## [v3.0.2](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.2)

change semantic versioning of all OSCA modules to 1.0.0

## [v3.0.1](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.1)

hotfix credentials

## [v3.0.0](https://git-dev.solingen.de/smartcityapp/oscasolingen-ios/-/tags/v3.0.0)

state of OSCA modularization iOS

## Upcoming Release

### Breaking Change

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

---
