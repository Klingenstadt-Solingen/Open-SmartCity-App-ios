//
//  SolingenDeeplinkingTests.swift
//  SolingenAppUITests
//
//  Created by Stephan Breidenbach on 19.12.23.
//

#if canImport(XCTest) && canImport(OSCASolingen) && canImport(OSCANetworkService)
#if SWIFT_PACKAGE
#warning("all SolingenDeeplinkingTests have to run from a xcproject NOT from SPM")
#else
import XCTest
import OSCANetworkService
import OSCASolingen

/// test deeplinks with `solingen://` scheme by automated launching `safari` app and open the `url` there
/// [based upon](https://medium.com/trendyol-tech/how-to-test-deeplinks-with-xcuitest-d24c8e5318ee)
final class SolingenDeeplinkingTests: DeeplinkingTestSuite {
  override func setUpWithError() throws {
    try super.setUpWithError()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }// end setUpWithError
  
  override func tearDownWithError() throws {
    try super.tearDownWithError()
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }// end tearDownWithError
  
  /// is it possible to open the home deeplink
  /// **please turn off search enginge suggestions in Safari settings of the simulator**
  func testDeeplinkHome() throws {
    openDeeplink(deeplink: "solingen://home/")
  }// end func testDeeplinkHome
  
  /// is it possible to open the townhall deeplink
  /// **please turn off search enginge suggestions in Safari settings of the simulator**
  func testDeeplinkTownHall() throws {
    openDeeplink(deeplink: "solingen://townhall/")
  }// end func testDeeplinkTownHall
  
  /// is it possible to open the service deeplink
  /// **please turn off search enginge suggestions in Safari settings of the simulator**
  func testDeeplinkService() throws {
    openDeeplink(deeplink: "solingen://service/")
  }// end func testDeeplinkService
  
  /// is it possible to open the settings deeplink
  /// **please turn off search enginge suggestions in Safari settings of the simulator**
  func testDeeplinkSettings() throws {
    openDeeplink(deeplink: "solingen://settings/")
  }// end func testDeeplinkSettings
  
  /// is it possible to open the appointments deeplink
  /// **please turn off search enginge suggestions in Safari settings of the simulator**
  func testDeeplinkAppointments() throws {
    openDeeplink(deeplink: "solingen://appointments/")
  }// end func testDeeplinkAppointments
}// end final class SolingenDeeplinkingTests
#endif
#endif
