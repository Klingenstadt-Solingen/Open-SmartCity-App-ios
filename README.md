<div style="display:flex;gap:1%;margin-bottom:20px">
  <h1 style="border:none">Open SmartCity Core Module of the Open SmartCity App</h1>
  <img height="100px" alt="logo" src="logo.svg">
</div>

## Important Notice

- **Changed Commit History** Commit history in some submodules changed due to removal of credentials in previous commits ❗❗❗
- **Read-Only Repository:** This GitHub repository is a mirror of our project's source code. It is not intended for direct changes.
- **Contribution Process:** Once our Open Code platform is live, any modifications, improvements, or contributions must be made through our [Open Code](https://gitlab.opencode.de/) platform. Direct changes via GitHub are not accepted.

---

- [Important Notice](#important-notice)
- [Changelog 📝](#changelog-)
- [License](#license)

<p align="center">
<img src="https://img.shields.io/badge/Platform%20Compatibility%20-ios-red">
<img src="https://img.shields.io/badge/Swift%20Compatibility%20-5.5%20%7C%205.4%20%7C%205.3%20%7C%205.2%20%7C%205.1-blue">
<a href="#"><img src="https://img.shields.io/badge/Swift-Doc-inactive"></a>
<a href="https://swift.org/package-manager/"><img src="https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat"></a>
</p>


## Repository structure
### Overview
<details>
<summary> root (please inflate for details) </summary>

<blockquote>

[`oscasolingen-ios`](#the-oscasolingen-ios-repository) repository

<details>
<summary> OSCASG.xcworkspace </summary>
<blockquote>

[OSCASG](#the-oscasg-workspace)-`XCode Workspace` is the place where every `Feature`-module, comes together with the `Core`-module and the `App`-project.\
**please open this one in `XCode` !!**
</blockquote>
</details>

<details>
<summary> modules </summary>
<blockquote>

The [`Feature`](#the-feature-gitsubmodules)-modules are:

* [OSCAAnalytics](https://git-dev.solingen.de/smartcityapp/modules/oscaanalytics-ios.git)
* [OSCASafariView](https://git-dev.solingen.de/smartcityapp/modules/oscasafariview-ios.git)
* [OSCAContact](https://git-dev.solingen.de/smartcityapp/modules/oscacontact-ios.git)
* [OSCAContactUI](https://git-dev.solingen.de/smartcityapp/modules/oscacontactui-ios.git)
* [OSCACorona](https://git-dev.solingen.de/smartcityapp/modules/oscacorona-ios.git)
* [OSCACoronaUI](https://git-dev.solingen.de/smartcityapp/modules/oscacoronaui-ios.git)
* [OSCACoworking](https://git-dev.solingen.de/smartcityapp/modules/oscacoworking-ios.git)
* [OSCACoworkingUI](https://git-dev.solingen.de/smartcityapp/modules/oscacoworkingui-ios.git)
* [OSCACulture](https://git-dev.solingen.de/smartcityapp/modules/oscaculture-ios.git)
* [OSCACultureUI](https://git-dev.solingen.de/smartcityapp/modules/oscacultureui-ios.git)
* [OSCADefect](https://git-dev.solingen.de/smartcityapp/modules/oscadefect-ios.git)
* [OSCADefectUI](https://git-dev.solingen.de/smartcityapp/modules/oscadefectui-ios.git)
* [OSCAEssentials](https://git-dev.solingen.de/smartcityapp/modules/oscaessentials-ios.git)
* [OSCAEvents](https://git-dev.solingen.de/smartcityapp/modules/oscaevents-ios.git)
* [OSCAEventsUI](https://git-dev.solingen.de/smartcityapp/modules/oscaeventsui-ios.git)
* [OSCAJobs](https://git-dev.solingen.de/smartcityapp/modules/oscajobs-ios.git)
* [OSCAJobsUI](https://git-dev.solingen.de/smartcityapp/modules/oscajobsui-ios.git)
* [OSCAMap](https://git-dev.solingen.de/smartcityapp/modules/oscamap-ios.git)
* [OSCAMapUI](https://git-dev.solingen.de/smartcityapp/modules/oscamapui-ios.git)
* [OSCANetworkService](https://git-dev.solingen.de/smartcityapp/modules/oscanetworkservice-ios.git)
* [OSCAPressReleases](https://git-dev.solingen.de/smartcityapp/modules/oscapressreleases-ios.git)
* [OSCAPressReleasesUI](https://git-dev.solingen.de/smartcityapp/modules/oscapressreleasesui-ios.git)
* [OSCAPublicTransport](https://git-dev.solingen.de/smartcityapp/modules/oscapublictransport-ios.git)
* [OSCAPublicTransportUI](https://git-dev.solingen.de/smartcityapp/modules/oscapublictransportui-ios.git)
* [OSCATemplate](https://git-dev.solingen.de/smartcityapp/modules/oscatemplate-ios.git)
* [OSCATestCaseExtension](https://git-dev.solingen.de/smartcityapp/modules/oscatestcaseextension-ios.git)
* [OSCAWaste](https://git-dev.solingen.de/smartcityapp/modules/oscawaste-ios.git)
* [OSCAWasteUI](https://git-dev.solingen.de/smartcityapp/modules/oscawasteui-ios.git)
* [OSCAWeather](https://git-dev.solingen.de/smartcityapp/modules/oscaweather-ios.git)
* [OSCAWeatherUI](https://git-dev.solingen.de/smartcityapp/modules/oscaweatherui-ios.git)
* [OSCAMobility](https://git-dev.solingen.de/smartcityapp/modules/oscamobilitymonitor-ios.git)
* [OSCAMobilityUI](https://git-dev.solingen.de/smartcityapp/modules/oscamobilitymonitorui-ios.git)
</blockquote>
</details>

<details>
<summary> OSCASolingen </summary>
<blockquote>

[`Core`](#the-core-module)-module project
</blockquote>
</details>

<details>
<summary> Solingen </summary>
<blockquote>

[`App`](#the-solingen-app-project) project
<details>
<summary> SolingenApp </summary>
<blockquote>

[`Target`](#the-solingenapp-app-target) depending on the `Core`-module `OSCASolingen`'s `framework` product
</blockquote>
</details>
<details>
<summary> Solingen </summary>
<blockquote>

[`Target`](#the-solingen-app-target) depending on the `Core`-module `OSCASolingen`'s local `Swift Package` only
</blockquote>
</details>
</blockquote>
</details>
<details>
<summary> SupportingFiles </summary>
<blockquote>

[Secrets-Folder](#the-supportingfiles-folder): please copy `gitignored` secret files in this folder:

* <span style="color:red">API_Develop.plist</span>
* <span style="color:red">API_Release.plist</span>
* <span style="color:red">Development.xcconfig</span>
* <span style="color:red">Production.xcconfig</span>
</blockquote>
</details>

</blockquote>
</details>

### The `oscasolingen-ios`-Repository
I have something to say about this repository.
### The `OSCASG`-Workspace
I have something to say about the OSCASG-Workspace
### The `Feature`-`Gitsubmodules`
I have something to say about the submodules
### The `Core`-module
I have something to say about the `Core`-module
### The `Solingen`-App-project
I have something to say about the App-project
### The `SolingenApp`-App-Target
I have something to say about the SolingenApp Target
### The `Solingen`-App-Target
I have something to say about the Solingen Target
### The `SupportingFiles` folder
I have something to say about the Secrets folder

## Flow Chart Test

```mermaid
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
```

## Requirements

- iOS 15.0+
- Swift 5.0+
- [DeviceKit 5.0.0+](https://github.com/devicekit/DeviceKit/releases/tag/5.0.0)

### Installation	
#### Swift Package Manager
- File > Swift Packages > Add Package Dependency
- Add `URL`
- Select "Up to Next Major" with "VERSION"

#### `SupportingFiles` secrets #####
* copy `Development.xcconfig` and `Production.xcconfig` to `OSCATemplate/OSCATemplate/SupportingFiles`, these files have to be ignored by git

## Other
### Developments and Tests

Any contributing and pull requests are warmly welcome. However, before you plan to implement some features or try to fix an uncertain issue, it is recommended to open a discussion first. It would be appreciated if your pull requests could build and with all tests green.

## Changelog 📝

Please see the [Changelog](CHANGELOG.md).

## License

OSCA Server is licensed under the [Open SmartCity License](LICENSE.md).
