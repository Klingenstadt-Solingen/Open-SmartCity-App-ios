//
//  AppDI+CityDI.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 17.06.22.
//  Reviewed by Stephan Breidenbach on 20.06.2022
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import OSCAWeather
import OSCAMap
import OSCAPressReleases
import OSCAPressReleasesUI
import UIKit
import OSCAEnvironmentUI
import OSCADistrict

extension AppDI {
  final class CityDI {
    struct Dependencies {
      let appDI: AppDI
      let homeTabRootController: HomeTabRootViewController
      let deeplinkScheme: String
    } // end struct Dependencies
    
    let dependencies: CityDI.Dependencies
    
    var cityFlow: CityFlow?
    
    var contactFlow: Coordinator?
    var defectFlow: Coordinator?
    var wasteFlow: Coordinator?
    var wasteWidgetFlow: Coordinator?
    var publicTransportFlow: Coordinator?
    var eventsFlow: Coordinator?
    var coworkingFlow: Coordinator?
    var jobsFlow: Coordinator?
    var cultureFlow: Coordinator?
    var mobilityMonitorFlow: Coordinator?
    
    init(dependencies: CityDI.Dependencies) {
      self.dependencies = dependencies
    } // end init
    
    func makeOSCAPressReleasesModule() -> OSCAPressReleases {
      let module = dependencies
        .appDI
        .makeOSCAPressReleasesUIDI()
        .makeOSCAPressReleasesModule()
      return module
    } // end func makeOSCAPressReleasesModule
    
    func makeOSCAWeatherModule() -> OSCAWeather {
      let module = dependencies
        .appDI
        .makeOSCAWeatherUIDI()
        .makeOSCAWeatherModule()
      return module
    } // end func makeOSCAPressReleasesModule
    
    func makeOSCAMapModule() -> OSCAMap {
      let module = dependencies
        .appDI
        .makeOSCAMapUIDI()
        .makeOSCAMapModule()
      return module
    } // end func makeOSCAPressReleasesModule
    
    func makeOSCATownhallMenu() -> OSCATownhallMenu {
      let townHallMenu = dependencies
        .appDI
        .makeTownhallDI()
        .makeOSCATownhallMenu()
      return townHallMenu
    }// end func makeOSCATownhallMenu
    
    func makeOSCAServiceMenu() -> OSCAServiceMenu {
      let serviceMenu = dependencies
        .appDI
        .makeServiceDI()
        .makeOSCAServiceMenu()
      return serviceMenu
    }// end func makeOSCAServiceMenu
    
      func makeCityViewModel(actions: CityViewModelActions,
                             pressReleasesModule: OSCAPressReleases,
                             mapModule: OSCAMap,
                             weatherModule: OSCAWeather) -> CityViewModel {
#if DEBUG
          print("\(String(describing: self)): \(#function)")
#endif
          let deeplinkPrefixes: [String] = makeDeeplinkPrefixes()
          let deeplinkScheme: String = dependencies.deeplinkScheme
          let oscaTownhallMenu = makeOSCATownhallMenu()
          let oscaServiceMenu = makeOSCAServiceMenu()
          let viewModelDependencies: CityViewModel.Dependencies = CityViewModel.Dependencies(actions: actions,
                                                                                             pressReleasesModule: pressReleasesModule,
                                                                                             weatherModule: weatherModule,
                                                                                             mapModule: mapModule,
                                                                                             oscaTownhallMenu: oscaTownhallMenu,
                                                                                             oscaServiceMenu: oscaServiceMenu,
                                                                                             deeplinkPrefixes: deeplinkPrefixes,
                                                                                             deeplinkScheme: deeplinkScheme)
#if DEBUG
          let networkConfig = dependencies.appDI.devNetworkService.config
#else
          let networkConfig = dependencies.appDI.productionNetworkService.config
#endif
          return CityViewModel(dependencies: viewModelDependencies, networkConfig: networkConfig)
      } // end func makeCityViewModel
    
      /// singleton `CityFlow`
      func makeCityFlowCoordinator(router: Router) -> CityFlow {
#if DEBUG
          print("\(String(describing: self)): \(#function)")
#endif
          if let cityFlow = cityFlow {
              return cityFlow
          } else {
#if DEBUG
              let networkConfig = dependencies.appDI.devNetworkService.config
#else
              let networkConfig = dependencies.appDI.productionNetworkService.config
#endif
              let flow = CityFlow(router: router,
                                  dependencies: self, networkConfig: networkConfig)
              cityFlow = flow
              return flow
          }// end if
      } // end func make makeCityFlowCoordinator
  } // end final class CityDI
}// end extension public final class AppDI

// MARK: - CityFlowDependencies conformance
extension AppDI.CityDI: CityFlowDependencies {
  func makeCityViewController(actions: CityViewModelActions) -> CityViewController {
    _ = dependencies.appDI.makeOSCAPressReleasesUIDI().makeOSCAPressReleasesUIModule()
    let pressReleasesModule = makeOSCAPressReleasesModule()
    let weatherModule = makeOSCAWeatherModule()
    let mapModule = makeOSCAMapModule()
    let cityViewModel = makeCityViewModel(actions: actions,
                                          pressReleasesModule: pressReleasesModule,
                                          mapModule: mapModule,
                                          weatherModule: weatherModule)
    let homeTabRootController = dependencies.homeTabRootController
    return CityViewController.create(with: homeTabRootController,
                                     viewModel: cityViewModel)
  } // end func makeCityViewController
    
    func makeOSCAEnvironmentCoordinator(router: Router) -> OSCAEnvironmentFlowCoordinator {
        return dependencies.appDI.makeOSCAEnvironmentDI().makeOSCAEnvironmentFlowCoordinator(router: router)
    }
  
  func makeOSCAWeatherCoordinator(router: Router, selectedId: String = "") -> Coordinator {
    return dependencies
      .appDI
      .makeOSCAWeatherUIDI()
      .makeOSCAWeatherFlowCoordinator(router: router, selectedWeatherObservedId: selectedId)
  } // end func makeOSCAWeatherCoordinator
  
  func makeOSCAWeatherListCoordinator(router: Router) -> Coordinator {
    return dependencies
      .appDI
      .makeOSCAWeatherUIDI()
      .makeOSCAWeatherListFlowCoordinator(
        router: router,
        selectedWeatherObservedId: "",
        didSelectStation: self.navigateToWeatherStation(router)
      )
  }
  
    func navigateToWeatherStation(_ router: Router) -> (_ objectId: String) -> () {
        return {
            objectId in
            self.makeOSCAWeatherCoordinator(router: router,selectedId: objectId).present(animated: false, onDismissed: nil)
        }

  }
    
    func makeOSCADistrictCoordinator(router: Router) -> OSCADistrictFlowCoordinator {
    return dependencies
       .appDI
       .makeOSCADistrictDI()
       .makeOSCADistrictFlowCoordinator(router: router)
  }

  
  func makeTownhallCoordinator(router: Router) -> TownhallFlow {
    return dependencies
      .appDI
      .makeTownhallDI()
      .makeTownhallFlowCoordinator(router: router)
  } // end func make makeTownhallCoordinator
  
  func makeOSCAPressReleasesCoordinator(router: Router) -> OSCAPressReleasesFlowCoordinator {
    return dependencies
      .appDI
      .makeOSCAPressReleasesUIDI()
      .makeOSCAPressReleasesFlowCoordinator(router: router)
  }// end func makeOSCAPressReleasesCoordinator
  
  func makeMapCoordinator(router: Router) -> Coordinator {
    return dependencies
      .appDI
      .makeOSCAMapUIDI()
      .makeOSCAMapFlowCoordinator(router: router)
  }// end func makeMapCoordinator
  
  func makeOSCAContactFormFlowCoordinator(router: Router) -> Coordinator {
    if let flow = contactFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCAContactUIDI()
        .makeOSCAContactFormFlowCoordinator(router: router)
      contactFlow = flow
      return flow
    }// end if
  }// end func makeOSCAContactFormFlowCoordinator
  
  /// singleton defect flow
  func makeOSCADefectFormFlowCoordinator(router: Router) -> Coordinator {
    if let flow = defectFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCADefectUIDI()
        .makeOSCADefectFormFlowCoordinator(router: router)
      defectFlow = flow
      return flow
    }// end if
  }// end func makeOSCADefectFormFlowCoordinator
  
  /// singleton waste coordinator flow
  func makeOSCAWasteFlowCoordinator(router: Router) -> Coordinator {
    if let flow = wasteFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCAWasteUIDI()
        .makeOSCAWasteFlowCoordinator(router: router)
      wasteFlow = flow
      return flow
    }// end if
  }// end func makeOSCAWasteFlowCoordinator
  
  /// singleton waste widget coordinator flow
  func makeOSCAWasteWidgetFlowCoordinator(router: Router) -> Coordinator {
    if let flow = self.wasteWidgetFlow {
      return flow
      
    } else {
      let flow = self.dependencies.appDI
        .makeOSCAWasteUIDI()
        .makeOSCAWasteWidgetFlowCoordinator(router: router)
      self.wasteWidgetFlow = flow
      
      return flow
    }
  }
  
  /// singleton mobility monitor coordinator flow
  func makeOSCAMobilityMonitorFlowCoordinator(router: Router) -> Coordinator {
    if let flow = mobilityMonitorFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCAMobilityUIDI()
        .makeOSCAMobilityFlowCoordinator(router: router)
      mobilityMonitorFlow = flow
      return flow
    }// end if
  }// end func makeOSCAMobilityMonitorFlowCoordinator
  
  /// singleton culture coordinator flow
  func makeOSCACultureFlowCoordinator(router: Router) -> Coordinator {
    if let flow = cultureFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCACultureUIDI()
        .makeBeaconSearchFlow(router: router)
      cultureFlow = flow
      return flow
    }// end if
  }// end func makeOSCACultureFlowCoordinator
  
  /// singleton jobs coordinator flow
  func makeOSCAJobsFlowCoordinator(router: Router) -> Coordinator {
    if let flow = jobsFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCAJobsUIDI()
        .makeOSCAJobsFlowCoordinator(router: router)
      jobsFlow = flow
      return flow
    }// end if
  }// end func makeOSCAJobsFlowCoordinator
  
  /// singleton coworking coordinator flow
  func makeOSCACoworkingFlowCoordinator(router: Router) -> Coordinator {
    if let flow = coworkingFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCACoworkingUIDI()
        .makeOSCACoworkingFlowCoordinator(router: router)
      coworkingFlow = flow
      return flow
    }// end if
  }// end func makeOSCACoworkingFlowCoordinator
  
  /// singleton events coordinator flow
  func makeOSCAEventsFlowCoordinator(router: Router) -> Coordinator {
    if let flow = eventsFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCAEventsUIDI()
        .makeOSCAEventsFlowCoordinator(router: router)
      eventsFlow = flow
      return flow
    }// end if
  }// end func makeOSCAEventsFlowCoordinator
  
  /// singleton public transport coordinator flow
  func makeOSCAPublicTransportFlowCoordinator(router: Router) -> Coordinator {
    if let flow = publicTransportFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCAPublicTransportUIDI()
        .makeOSCAPublicTransportFlowCoordinator(router: router)
      publicTransportFlow = flow
      return flow
    }// end if
  }// end func makeOSCAPublicTransportFlowCoordinator
  
  /// make web view  flow
  func makeOSCASafariViewFlowCoordinator(router: Router, url: URL) -> Coordinator {
    return self.dependencies
      .appDI
      .makeSafariViewDI()
      .makeOSCASafariViewFlowCoordinator(url: url, router: router)
  }// end func makeOSCASafariViewFlowCoordinator
}// end extension final class CityDI
