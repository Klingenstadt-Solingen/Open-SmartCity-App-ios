//
//  CultureDeeplinkingTests.swift
//  SolingenAppUITests
//
//  Created by Stephan Breidenbach on 20.12.23.
//

#if canImport(XCTest)
#if SWIFT_PACKAGE
#warning("all CultureDeeplinkingTests have to run from a xcproject NOT from SPM")
#else
import XCTest

/// test deeplinks with `solingen://` scheme by automated launching `safari` app and open the `url` there
/// [based upon](https://medium.com/trendyol-tech/how-to-test-deeplinks-with-xcuitest-d24c8e5318ee)
final class CultureDeeplinkingTests: DeeplinkingTestSuite {
  override func setUpWithError() throws {
    try super.setUpWithError()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }// end setUpWithError
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }// end tearDownWithError
  
  /// is it possible to open the culture deeplink
  /// **please turn off search enginge suggestions in Safari settings of the simulator**
  func testDeeplinkCulture() throws {
    openDeeplink(deeplink: "solingen://art/")
  }// end func testDeeplinkCulture
}// end final class CultureDeeplinkingTests
#endif
#endif
