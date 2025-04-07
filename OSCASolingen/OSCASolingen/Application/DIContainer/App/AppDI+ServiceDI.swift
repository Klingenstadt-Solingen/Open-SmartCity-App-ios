//
//  AppDI+ServiceDI.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 24.06.22.
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCACoworkingUI
import OSCAEssentials
import OSCAEventsUI
import OSCAJobsUI
import OSCAPublicTransportUI
import OSCASafariView
import UIKit

extension AppDI {
  final class ServiceDI {
    struct Dependencies {
      let appDI: AppDI
      let deeplinkScheme: String
    } // end struct Dependencies

    let dependencies: ServiceDI.Dependencies

    var serviceFlow: ServiceFlow?
    var publicTransportFlow: Coordinator?
    var eventsFlow: Coordinator?
    var coworkingFlow: Coordinator?
    var jobsFlow: Coordinator?
    var cultureFlow: Coordinator?
    var mobilityFlow: Coordinator?
    var serviceMenu: OSCAServiceMenu?

    init(dependencies: ServiceDI.Dependencies) {
      self.dependencies = dependencies
    } // end init

    func makeOSCAServiceMenuDependencies() -> OSCAServiceMenu.Dependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
#if DEBUG
      let networkService = dependencies.appDI.devNetworkService
#else
      let networkService = dependencies.appDI.productionNetworkService
#endif
      let userDefaults = dependencies.appDI.userDefaults
      let serviceDependencies = OSCAServiceMenu.Dependencies(networkService: networkService,
                                                             userDefaults: userDefaults)
      return serviceDependencies
    }

    /// singleton `OSCAServiceMenu`
    func makeOSCAServiceMenu() -> OSCAServiceMenu {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let serviceMenu = serviceMenu {
        return serviceMenu
      } else {
        let serviceDependencies = makeOSCAServiceMenuDependencies()
        let oscaService = OSCAServiceMenu(dependencies: serviceDependencies)
        serviceMenu = oscaService
        return oscaService
      } // end if
    } // end func makeOSCAServiceMenu

    func makeServiceViewModel(actions: ServiceListViewModelActions) -> ServiceListViewModel {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let oscaService = makeOSCAServiceMenu()
      let deeplinkPrefixes = makeDeeplinkPrefixes()
      return ServiceListViewModel(
        oscaServiceMenu: oscaService,
        actions: actions,
        deeplinkPrefixes: deeplinkPrefixes
      )
    } // end func makeModuleNavigationViewModel

    /// singleton `ServiceFlow`
    func makeServiceFlowCoordinator(router: Router) -> ServiceFlow {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let serviceFlow = serviceFlow {
        return serviceFlow
      } else {
        let flow = ServiceFlow(router: router, dependencies: self)
        serviceFlow = flow
        return flow
      } // end if
    } // end func make makeCityFlowCoordinator
  } // end final class ServiceDI
} // end extension public final class AppDI

// MARK: - ServiceFlowDependencies conformance

extension AppDI.ServiceDI: ServiceFlowDependencies {
  func makeServiceListViewController(actions: ServiceListViewModelActions) -> ServiceListViewController {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let serviceViewModel = makeServiceViewModel(actions: actions)
    return ServiceListViewController.create(with: serviceViewModel)
  } // end func makeServiceListViewController

  /// make singleton public transport flow
  func makeOSCAPublicTransportCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let flow = publicTransportFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCAPublicTransportUIDI()
        .makeOSCAPublicTransportFlowCoordinator(router: router)
      publicTransportFlow = flow
      return flow
    } // end if
  } // end func makeOSCAPublicTransportCoordinator

  func getOSCAPublicTransportDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = makeOSCAPublicTransportCoordinator(router: router)
    guard let typedFlow = flow as? OSCADeeplinkHandeble
    else {
      return dependencies
        .appDI
        .makeOSCASolingenDI()
        .makeOSCASolingen()
        .getOSCAPublicTransportDeeplinkHandeble(router: router)
    } // end guard
    return typedFlow
  } // end func getOSCAPublicTransportDeeplinkHandeble

  /// make events singleton flow
  func makeOSCAEventsCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let flow = eventsFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCAEventsUIDI()
        .makeOSCAEventsFlowCoordinator(router: router)
      eventsFlow = flow
      return flow
    } // end if
  } // end func makeOSCAEventsCoordinator

  func getOSCAEventsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = makeOSCAEventsCoordinator(router: router)
    guard let typedFlow = flow as? OSCADeeplinkHandeble
    else {
      return dependencies
        .appDI
        .makeOSCASolingenDI()
        .makeOSCASolingen()
        .getOSCAEventsDeeplinkHandeble(router: router)
    } // end guard
    return typedFlow
  } // end func getOSCAEventsDeeplinkHandeble

  /// make singleton coworking flow
  func makeOSCACoworkingCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let flow = coworkingFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCACoworkingUIDI()
        .makeOSCACoworkingFlowCoordinator(router: router)
      coworkingFlow = flow
      return flow
    } // end if
  } // end func makeOSCACoworkingCoordinator

  func getOSCACoworkingDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = makeOSCACoworkingCoordinator(router: router)
    guard let typedFlow = flow as? OSCADeeplinkHandeble
    else {
      return dependencies
        .appDI
        .makeOSCASolingenDI()
        .makeOSCASolingen()
        .getOSCACoworkingDeeplinkHandeble(router: router)
    } // end guard
    return typedFlow
  } // end func getOSCACoworkingDeeplinkHandeble

  /// make singleton jobs flow
  func makeOSCAJobsCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let flow = jobsFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCAJobsUIDI()
        .makeOSCAJobsFlowCoordinator(router: router)
      jobsFlow = flow
      return flow
    } // end if
  } // end func makeOSCAJobsCoordinator

  func getOSCAJobsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = makeOSCAJobsCoordinator(router: router)
    guard let typedFlow = flow as? OSCADeeplinkHandeble
    else {
      return dependencies
        .appDI
        .makeOSCASolingenDI()
        .makeOSCASolingen()
        .getOSCAJobsDeeplinkHandeble(router: router)
    } // end guard
    return typedFlow
  } // end func getOSCAJobsDeeplinkHandeble

  /// singleton culture flow
  func makeBeaconSearchFlow(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let flow = cultureFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCACultureUIDI()
        .makeBeaconSearchFlow(router: router)
      cultureFlow = flow
      return flow
    } // end if
  } // end func makeBeaconSearchFlow
  
  func getBeaconSearchHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = makeBeaconSearchFlow(router: router)
    guard let typedFlow = flow as? OSCADeeplinkHandeble
    else {
      return dependencies
        .appDI
        .makeOSCASolingenDI()
        .makeOSCASolingen()
        .getBeaconSearchDeeplinkHandeble(router: router)
    } // end guard
    return typedFlow
  } // end func getOSCAMobilityDeeplinkHandeble

  func makeOSCAMobilityFlow(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let flow = mobilityFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCAMobilityUIDI()
        .makeOSCAMobilityFlowCoordinator(router: router)
      mobilityFlow = flow
      return flow
    } // end if
  }// end func makeOSCAMobilityFlow
  
  func getOSCAMobilityHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = makeOSCAMobilityFlow(router: router)
    guard let typedFlow = flow as? OSCADeeplinkHandeble
    else {
      return dependencies
        .appDI
        .makeOSCASolingenDI()
        .makeOSCASolingen()
        .getOSCAMobilityDeeplinkHandeble(router: router)
    } // end guard
    return typedFlow
  } // end func getOSCAMobilityDeeplinkHandeble

  /// make http flow
  func makeOSCASafariViewCoordinator(router: Router, url: URL) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return dependencies
      .appDI
      .makeSafariViewDI()
      .makeOSCASafariViewFlowCoordinator(url: url, router: router)
  } // end func makeOSCASafariViewCoordinator

  func makeMobilityViewCoordinator(router: Router, url: URL) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return dependencies
      .appDI
      .makeOSCAMobilityUIDI()
      .makeOSCAMobilityFlowCoordinator(router: router)
  }
} // end extension final class ServiceDI
