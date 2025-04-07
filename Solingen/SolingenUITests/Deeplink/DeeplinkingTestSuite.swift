//
//  DeeplinkingTestSuite.swift
//  SolingenAppUITests
//
//  Created by Stephan Breidenbach on 19.12.23.
//

#if canImport(XCTest) && canImport(Combine) && canImport(OSCASolingen) && canImport(OSCANetworkService) && canImport(OSCAPressReleases)
#if SWIFT_PACKAGE
#warning("all DeeplinkingTests have to run from a xcproject NOT from SPM")
#else
import XCTest
import Combine
import OSCANetworkService
import OSCASolingen

/// test deeplinks with `solingen://` scheme by automated launching `safari` app and open the `url` there
/// [based upon](https://medium.com/trendyol-tech/how-to-test-deeplinks-with-xcuitest-d24c8e5318ee)
open class DeeplinkingTestSuite: XCTestCase {
  open override func setUpWithError() throws {
    try super.setUpWithError()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    continueAfterFailure = false
  }// end setUpWithError
  
  open override func tearDownWithError() throws {
    try super.tearDownWithError()
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }// end tearDownWithError
}// end final class DeeplinkingTestSuite

extension DeeplinkingTestSuite {
  enum UIStatus: String {
    case exist = "exists == true"
    case notExist = "exists == false"
    case selected = "selected == true"
    case notSelected = "selected == false"
    case hittable = "isHittable == true"
    case notHittable = "isHittable == false"
    case isEqual = "label MATCHES '%@'"
  }// end enum UIStatus
  
  //safari identifiers
  enum SafariIdentifiers: String {
    case bundleId = "com.apple.mobilesafari"
    // case url = "URL"
    case url = "Address"
    case clearText = "Clear text"
    case webView = "WebView"
    case open = "Open"
    case cancel = "Cancel"
    case continueText = "Continue"
    case quickPathText = "Speed up your typing by sliding your finger across the letters to compose a word."
  }// end enum SafariIdentifiers
  
  //native keyboard identifiers
  enum KeyboardKeys: String {
    case go = "Go"
  }// end enum KeyboardKeys
  
  //expect method for waiting elements
  func expect(element: XCUIElement,
              status: UIStatus,
              timeout: TimeInterval = 5,
              message: String? = nil) {
    let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: status.rawValue), object: element)
    let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
    
    if result == .timedOut {
      XCTFail(message ?? expectation.description)
    }// end if
  }// end func expect
  
  //open deeplink method
  func openDeeplink(deeplink: String) {
    let app = XCUIApplication()
    //set variables for multiple usage
    let safari = XCUIApplication(bundleIdentifier: SafariIdentifiers.bundleId.rawValue)
    let openButton = safari.scrollViews
      .otherElements
      .webViews[SafariIdentifiers.webView.rawValue]
      .children(matching: .other)
      .element
      .children(matching: .other)
      .element(boundBy: 1)
      .buttons[SafariIdentifiers.open.rawValue]
    let urlTextField = safari.textFields[SafariIdentifiers.url.rawValue]
    let urlField = safari.buttons[SafariIdentifiers.url.rawValue]
    let quickPathText = safari.scrollViews.otherElements.containing(.staticText, identifier: SafariIdentifiers.quickPathText.rawValue).element
    let quickPathContinueTextButton = safari.staticTexts[SafariIdentifiers.continueText.rawValue].firstMatch
    //launch safari
    safari.launch()
    //waiting hittable status
    /*
     you should not use app.wait(for: .runningForeground, timeout: 5)
     because sometimes even if the foreground status of the safari is true, it cannot be clicked
     */
    expect(element: safari, status: .hittable)
    //sometimes safari opens with different states. I control that
    if !urlTextField.waitForExistence(timeout: 3) {
      expect(element: urlField, status: .hittable)
      urlField.tap()
    }// end if
    
    expect(element: urlTextField, status: .hittable)
    urlTextField.tap()
    //sometimes when automation clicked the textfield, quickPathTutorial comes in
    //if comes, pass by tapping continue button
    if quickPathText.exists {
      quickPathContinueTextButton.tap()
    }//endif
    
    //sometimes safari goes into bug when try too many deeplinks
    // In that situation relaunch the safari
    /*
     if safari.buttons[SafariIdentifiers.clearText.rawValue].exists {
     safari.terminate()
     safari.wait(for: .notRunning, timeout: 5)
     safari.launch()
     }// end if
     */
    
    //type the deeplink
    urlTextField.typeText(deeplink)
    safari.buttons[KeyboardKeys.go.rawValue].waitForExistence(timeout: 5)
    safari.buttons[KeyboardKeys.go.rawValue].tap()
    expect(element: openButton, status: .hittable)
    //tap open button
    openButton.tap()
    //expect app to be hittable
    expect(element: app,
           status: .hittable)
    safari.terminate()
    app.terminate()
  }// end func openDeeplink
}// end extension DeeplinkingTestSuite

extension DeeplinkingTestSuite {
  /// factory method for plist
  func make() -> [String: Any]? {
    let bundle: Bundle = Bundle(for: Self.self)
    guard let filePath = bundle.path(forResource: "API_Develop", ofType: "plist"),
          let apiData = try? Data(contentsOf: URL(fileURLWithPath: filePath)),
          let dict = try? PropertyListSerialization.propertyList(from: apiData,
                                                                 options: [],
                                                                 format: nil) as? [String: Any]
    else { return nil }
    return dict
  }// end func make
  
  /// factory method for `OSCANetworkService`
  func make(userDefaults: UserDefaults) -> OSCANetworkService? {
    guard let dict: [String: Any] = make(),
          let parseAPIKey = dict[AppDI.Environment.Keys.Plist.devParseAPIKey] as? CustomStringConvertible,
          let parseAPIApplicationID = dict[AppDI.Environment.Keys.Plist.devParseAPIApplicationID] as? CustomStringConvertible,
          let parseAPIBaseURL = dict[AppDI.Environment.Keys.Plist.devParseAPIRootURL] as? String,
          let parseRESTAPIKey = dict[AppDI.Environment.Keys.Plist.devParseRESTAPIKey] as? String,
          let parseMasterAPIKey = dict[AppDI.Environment.Keys.Plist.devParseMasterAPIKey] as? String
    else { return nil }
    // take headers from app config secrets
    let headers: [String: CustomStringConvertible] = [
      "X-PARSE-CLIENT-KEY": parseAPIKey,
      "X-PARSE-APPLICATION-ID": parseAPIApplicationID,
      "X-PARSE-REST-API-KEY": parseRESTAPIKey,
      "X-Parse-Master-Key": parseMasterAPIKey
    ]// end headers
    // take base url from app config secrets
    guard let baseURL = URL(string: parseAPIBaseURL) else { return nil }
    // network config
    let config = OSCANetworkConfiguration(
      baseURL: baseURL,
      headers: headers,
      session: URLSession.shared
    )// end let config
    // initialize network service
    let dependencies = OSCANetworkServiceDependencies(config: config,
                                                      userDefaults: userDefaults)
    return OSCANetworkService.create(with: dependencies)
  }// end func make
  
  /// factory method for `UserDefaults`
  func make(domainString: String) -> UserDefaults? {
    return UserDefaults(suiteName: domainString)
  }// end func make
}// end extension DeeplinkingTestSuite

extension XCUIApplication {
  func setUpAndLaunch() {
    launchArguments += ["UI-Testing"]
    launch()
  }// end func setUpAndLaunch
}// end extension XCUIApplication
#endif
#endif
