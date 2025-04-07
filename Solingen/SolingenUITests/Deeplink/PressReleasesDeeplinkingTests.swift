//
//  DeeplinkingTests.swift
//  Solingen
//
//  Created by Stephan Breidenbach on 19.12.23.
//
#if canImport(XCTest) && canImport(Combine) && canImport(OSCANetworkService) && canImport(OSCAPressReleases)
#if SWIFT_PACKAGE
#warning("all PressReleasesDeeplinkingTests have to run from a xcproject NOT from SPM")
#else
import XCTest
import Combine
import OSCANetworkService
import OSCAPressReleases

/// test deeplinks with `solingen://` scheme by automated launching `safari` app and open the `url` there
/// [based upon](https://medium.com/trendyol-tech/how-to-test-deeplinks-with-xcuitest-d24c8e5318ee)
final class PressReleasesDeeplinkingTests: DeeplinkingTestSuite {
  private var cancellables: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    try super.setUpWithError()
    cancellables = []
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }// end setUpWithError
  
  override func tearDownWithError() throws {
    cancellables.forEach { $0.cancel() }
    cancellables = nil
    try super.tearDownWithError() 
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }// end tearDownWithError
  
  /// get list of `OSCAPressRelease` from server asynchronously
  func getPressReleases() -> [OSCAPressRelease]? {
    var pressReleases: [OSCAPressRelease]?
    var error: Error?
    guard let pressReleasesDependencies: OSCAPressReleasesDependencies = make(),
          let pressReleaseModule: OSCAPressReleases = make(dependencies: pressReleasesDependencies)
    else { XCTFail("No valid PressReleases data module"); return pressReleases }
    
    let expectation = self.expectation(description: "GetPressReleases")
    
    pressReleaseModule.getPressReleases(limit: 5)
      .sink { completion in
        switch completion {
        case .finished:
          expectation.fulfill()
        case let .failure(encounteredError):
          error = encounteredError
          expectation.fulfill()
        }
      } receiveValue: { result in
        switch result {
        case let .success(objects):
          pressReleases = objects
        case let .failure(encounteredError):
          error = encounteredError
        }
      }
      .store(in: &cancellables)
    
    waitForExpectations(timeout: 10)
    XCTAssertNil(error)
    guard let pressReleases = pressReleases
    else { XCTFail("no valid press releases"); return pressReleases }
    return pressReleases
  }// end getPressReleases
  
  /// is it possible to use deeplinks for `OSCAPressReleases`
  ///
  /// **please turn off search enginge suggestions in Safari settings of the simulator**
  func testDeeplinkPressReleases() throws {
    guard let pressReleases = getPressReleases(),
          let pressRelease = pressReleases.first,
          let objectId = pressRelease.objectId
    else { XCTFail("no valid press release"); return }
    openDeeplink(deeplink: "solingen://pressreleases/")
    openDeeplink(deeplink: "solingen://pressreleases/detail?object=\(objectId)")
  }// end func testDeeplinkPressReleases
}// end final class PressReleasesDeeplinkingTests

extension PressReleasesDeeplinkingTests {
  /// factory method for  `OSCAPressReleases` dependencies
  func make() -> OSCAPressReleasesDependencies? {
    guard let userDefaults: UserDefaults = make(domainString: "de.osca.pressreleases"),
          let networkService: OSCANetworkService = make(userDefaults: userDefaults)
    else { return nil }
    return OSCAPressReleasesDependencies(networkService: networkService,
                                         userDefaults: userDefaults)
  }// end func make
  /// factory method for `OSCAPresReleases`
  func make(dependencies: OSCAPressReleasesDependencies) -> OSCAPressReleases? {
    // initialize module
    return OSCAPressReleases.create(with: dependencies)
  }// end func make
}// end extension PressReleasesDeeplinkingTests
#endif
#endif
