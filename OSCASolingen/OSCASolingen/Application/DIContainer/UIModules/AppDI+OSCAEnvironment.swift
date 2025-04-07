import Foundation
import OSCAEssentials
import OSCAEnvironmentUI
import OSCANetworkService
import UIKit

extension AppDI {
    final class OSCAEnvironmentDI {
        /**
         `OSCAEnvironmentModuleDIContainer.Dependencies` defines the dependencies, which goes into the `DIContainer`
         */
        struct Dependencies {
            let userDefaults    : UserDefaults
            let deeplinkScheme: String
        }// end struct Dependencies
        
        private var dependencies: Dependencies
        private var Module: OSCAEnvironmentUI?
        
        var environmentFlow: Coordinator?
        
        init(dependencies: OSCAEnvironmentDI.Dependencies){
            self.dependencies = dependencies
        }// end init
        
        // MARK: - Feature UI Module Config
        func makeOSCAEnvironmentConfig() -> OSCAEnvironmentConfig {
            return OSCAEnvironmentConfig(title: "OSCAEnvironment")
        }// end func makeOSCAEnvironmentConfig
        
        // MARK: - Feature  Module dependencies
        func makeOSCAEnvironmentModuleDependencies() -> OSCAEnvironmentDependencies {
            return OSCAEnvironmentDependencies(moduleConfig: makeOSCAEnvironmentConfig())// end return
        }// end func makeOSCAEnvironmentModuleDependencies
        
        // MARK: - Feature  Module
        /// singleton  module
        func makeOSCAEnvironmentModule() -> OSCAEnvironmentUI {
            if let Module = Module {
                return Module
            } else {
                return OSCAEnvironmentUI.create(with: makeOSCAEnvironmentModuleDependencies())
            }
        }
        
        /// singleton `Coordinator`
        func makeOSCAEnvironmentFlowCoordinator(router: Router) -> OSCAEnvironmentFlowCoordinator {
            let flow = makeOSCAEnvironmentModule()
                .getEnvironmentFlowCoordinator(router: router)
            environmentFlow = flow
            return flow
        }// end func makeOSCAEnvironmentFlowCoordinator
    }// end final class OSCAEnvironmentModuleDIContainer
}
