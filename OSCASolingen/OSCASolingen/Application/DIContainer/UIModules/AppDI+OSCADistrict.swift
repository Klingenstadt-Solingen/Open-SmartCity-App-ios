import Foundation
import OSCAEssentials
import OSCADistrict
import OSCANetworkService
import UIKit

extension AppDI {
  final class OSCADistrictDI {
    /**
     `OSCADistrictModuleDIContainer.Dependencies` defines the dependencies, which goes into the `DIContainer`
     */
    struct Dependencies {
      let userDefaults    : UserDefaults
      let deeplinkScheme: String
    }// end struct Dependencies
    
    private var dependencies: Dependencies
    private var Module: OSCADistrict?
    
    var districtFlow: Coordinator?
    
      init(dependencies: OSCADistrictDI.Dependencies){
        self.dependencies = dependencies
      }// end init
      
      // MARK: - Feature UI Module Config
      func makeOSCADistrictConfig() -> OSCADistrictConfig {
        return OSCADistrictConfig(title: "OSCADistrict")
      }// end func makeOSCADistrictConfig
    
    // MARK: - Feature  Module dependencies
    func makeOSCADistrictModuleDependencies() -> OSCADistrictDependencies {
      return OSCADistrictDependencies(moduleConfig: makeOSCADistrictConfig())// end return
    }// end func makeOSCADistrictModuleDependencies
    
        // MARK: - Feature  Module
        /// singleton  module
        func makeOSCADistrictModule() -> OSCADistrict {
            if let Module = Module {
                return Module
            } else {
                return OSCADistrict.create(with: makeOSCADistrictModuleDependencies())
            }
        }

        /// singleton `Coordinator`
      func makeOSCADistrictFlowCoordinator(router: Router) -> OSCADistrictFlowCoordinator {
            let flow = makeOSCADistrictModule()
              .getDistrictFlowCoordinator(router: router)
            districtFlow = flow
            return flow
        }// end func makeOSCADistrictFlowCoordinator
  }// end final class OSCADistrictModuleDIContainer
}// end extension final class OSCADistrictDI
