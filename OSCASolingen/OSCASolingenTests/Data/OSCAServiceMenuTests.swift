//
//  OSCAServiceMenuTests.swift
//  OSCASolingenTests
//
//  Created by Stephan Breidenbach on 23.06.22.
//

import Foundation
import XCTest
@testable import OSCASolingen
import OSCANetworkService
import OSCATestCaseExtension
import Combine

class OSCAServiceMenuTests: XCTestCase {
  private var cancellables: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // initialize cancellables
    self.cancellables = []
  }// end override func setUpWithError
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }// end override func tearDownWithError
  
  func testFetchAllServiceMenu() throws -> Void {
    var serviceMenuItems: [ServiceMenu] = []
    var error: Error?
    
    let expectation = self.expectation(description: "fetchAllServiceMenuItmes")
    
    let oscaServiceMenuDev: OSCAServiceMenu = try makeDevOSCAServiceMenu()
    oscaServiceMenuDev.fetchAllServiceMenu()
      .sink { completion in
        switch completion {
        case .finished:
          expectation.fulfill()
        case let .failure(encounteredError):
          error = encounteredError
          expectation.fulfill()
        }// end switch
      } receiveValue: { allServiceMenuItems in
        serviceMenuItems = allServiceMenuItems
      }// end sink
      .store(in: &self.cancellables)
    
    waitForExpectations(timeout: 10)
    
    XCTAssertNil(error)
    XCTAssertTrue(!serviceMenuItems.isEmpty)
  }// end func testFetchAllServiceMenu
  
}//end class OSCAServiceMenuTests

extension OSCAServiceMenuTests {
  public func makeDevDependencies() throws -> OSCAServiceMenu.Dependencies {
    // init dev network service
    let devNetworkService: OSCANetworkService = try makeDevNetworkService()
    // init dependency
    let dependencies = OSCAServiceMenu.Dependencies(networkService: devNetworkService)
    return dependencies
  }// public func makeDevDependencies
  
  public func makeDevOSCAServiceMenu() throws -> OSCAServiceMenu {
    let dependencies = try makeDevDependencies()
    let oscaServiceMenuDev = OSCAServiceMenu(dependencies: dependencies)
    return oscaServiceMenuDev
  }// end public func makeDevOSCAServiceMenu
  
  public func makeProductionDependencies() throws -> OSCAServiceMenu.Dependencies {
    // init dev network service
    let productionNetworkService: OSCANetworkService = try makeProductionNetworkService()
    // init dependency
    let dependencies = OSCAServiceMenu.Dependencies(networkService: productionNetworkService)
    return dependencies
  }// public func makeProductionDependencies
  
  public func makeProductionOSCAServiceMenu() throws -> OSCAServiceMenu {
    let dependencies = try makeProductionDependencies()
    let oscaServiceMenuProduction = OSCAServiceMenu(dependencies: dependencies)
    return oscaServiceMenuProduction
  }// end public func makeProductionOSCAServiceMenu
}// end extension class OSCAServiceMenuTests
