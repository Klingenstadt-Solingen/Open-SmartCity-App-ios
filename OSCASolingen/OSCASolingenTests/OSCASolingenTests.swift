//
//  OSCASolingenTests.swift
//  OSCASolingenTests
//
//  Created by Stephan Breidenbach on 29.08.22.
//
#if canImport(XCTest) && canImport(OSCATestCaseExtension) && canImport(OSCANetworkService)
#if SWIFT_PACKAGE
#warning("all OSCASolingenTests have to run from a xcproject NOT from SPM")
#else
import XCTest
@testable import OSCASolingen
import OSCANetworkService
import OSCATestCaseExtension

final class OSCASolingenTests: XCTestCase {  
  
  static let moduleVersion = "3.0.11"
  func testModuleInit() throws -> Void {
    XCTAssertNoThrow(try makeProductionNetworkService())
    XCTAssertNoThrow(try makeDevNetworkService())
    let coreModule = try makeOSCASolingen()
    XCTAssertNotNil(coreModule)
    XCTAssertNotNil(OSCASolingen.bundle)
    XCTAssertEqual(coreModule.version, OSCASolingenTests.moduleVersion)
    XCTAssertEqual(coreModule.bundlePrefix, "de.osca.solingen.core")
    XCTAssertNotNil(self.productionPlistDict)
    XCTAssertNotNil(self.devPlistDict)
  }// end func testModuleInit
}// end finla Class OSCASolingenTests

extension OSCASolingenTests {
  public func makeOSCASolingen() throws -> OSCASolingen {
    let appConfig = AppDI.Config()
    let appDI = try AppDI.create(appConfig: appConfig)
    let dependencies: OSCASolingen.Dependencies = OSCASolingen.Dependencies(
      appDI: appDI
    )// end dependencies
    let coreModule = OSCASolingen.create(with: dependencies)
    
    return coreModule
  }// end public func makeOSCASolingen
}// end extension final class OSCASolingenTests
#endif
#endif
