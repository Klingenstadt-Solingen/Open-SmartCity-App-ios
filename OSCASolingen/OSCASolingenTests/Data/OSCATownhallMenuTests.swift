//
//  OSCATownhallMenuTests.swift
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

class OSCATownhallMenuTests: XCTestCase {
  private var cancellables: Set<AnyCancellable>!
  
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // initialize cancellables
    self.cancellables = []
  }// end override func setUpWithError
  
  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }// end override func tearDownWithError
  
  func testFetchAllTownhallMenu() throws -> Void {
    var townHallMenuItems: [TownhallMenu] = []
    var error: Error?
    
    let expectation = self.expectation(description: "fetchAllServiceMenuItmes")
    
    let oscaTownhallMenuDev: OSCATownhallMenu = try makeDevOSCATownhallMenu()
    oscaTownhallMenuDev.fetchAllTownhallMenu()
      .sink { completion in
        switch completion {
        case .finished:
          expectation.fulfill()
        case let .failure(encounteredError):
          error = encounteredError
          expectation.fulfill()
        }// end switch
      } receiveValue: { allTownhallMenuItems in
        townHallMenuItems = allTownhallMenuItems
      }// end sink
      .store(in: &self.cancellables)
    
    waitForExpectations(timeout: 10)
    
    XCTAssertNil(error)
    XCTAssertTrue(!townHallMenuItems.isEmpty)
  }// end func testFetchAllServiceMenu
  
}//end class OSCATownhallMenuTests

extension OSCATownhallMenuTests {
  public func makeDevDependencies() throws -> OSCATownhallMenu.Dependencies {
    // init dev network service
    let devNetworkService = try makeDevNetworkService()
    // init dependency
    let dependencies = OSCATownhallMenu.Dependencies(networkService: devNetworkService)
    return dependencies
  }// public func makeDevDependencies
  
  public func makeDevOSCATownhallMenu() throws -> OSCATownhallMenu {
    let dependencies: OSCATownhallMenu.Dependencies = try makeDevDependencies()
    let oscaServiceMenuDev = OSCATownhallMenu(dependencies: dependencies)
    return oscaServiceMenuDev
  }// end public func makeDevOSCATownhallMenu
  
  public func makeProductionDependencies() throws -> OSCATownhallMenu.Dependencies {
    // init dev network service
    let productionNetworkService = try makeProductionNetworkService()
    // init dependency
    let dependencies = OSCATownhallMenu.Dependencies(networkService: productionNetworkService)
    return dependencies
  }// public func makeProductionDependencies
  
  public func makeProductionOSCATownhallMenu() throws -> OSCATownhallMenu {
    let dependencies: OSCATownhallMenu.Dependencies = try makeProductionDependencies()
    let oscaServiceMenuProduction = OSCATownhallMenu(dependencies: dependencies)
    return oscaServiceMenuProduction
  }// end public func makeProductionOSCATownhallMenu
}// end extension class OSCATownhallMenuTests

