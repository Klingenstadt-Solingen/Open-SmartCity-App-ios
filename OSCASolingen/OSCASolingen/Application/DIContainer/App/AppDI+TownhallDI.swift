//
//  AppDI+TownhallDI.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 21.06.22.
//  Reviewed by Stephan Breidenbach on 30.08.2022
//

import OSCAEssentials
import UIKit
import OSCAContactUI
import OSCADefectUI
import OSCAWasteUI
import OSCASafariView

extension AppDI {
  final class TownhallDI: TownhallFlowDependencies {
    struct Dependencies {
      let appDI: AppDI
      let deeplinkScheme: String
    } // end struct Dependencies
    
    let dependencies: TownhallDI.Dependencies
    var townhallMenu: OSCATownhallMenu?
    
    var townhallFlow: TownhallFlow?
    var contactFlow: Coordinator?
    var defectFlow: Coordinator?
    var wasteFlow: Coordinator?
    var appointmentsFlow: Coordinator?
    
    init(dependencies: TownhallDI.Dependencies) {
      self.dependencies = dependencies
    } // end init
    
    func makeTownhallViewController(actions: TownhallViewModelActions) -> TownhallViewController {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let townhallViewModel = makeTownhallViewModel(actions: actions)
      return TownhallViewController.create(with: townhallViewModel)
    } // end func makeCityViewController
    
    func makeOSCATownhallMenuDependencies() -> OSCATownhallMenu.Dependencies {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
#if DEBUG
      let networkService = dependencies.appDI.devNetworkService
#else
      let networkService = dependencies.appDI.productionNetworkService
#endif
      let userDefaults = dependencies.appDI.userDefaults
      let townhallDependencies = OSCATownhallMenu.Dependencies(networkService: networkService,
                                                               userDefaults: userDefaults)
      return townhallDependencies
    }
    
    /// singleton `OSCATownhallMenu`
    func makeOSCATownhallMenu() -> OSCATownhallMenu {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      if let townhallMenu = townhallMenu {
        return townhallMenu
      } else {
        let townhallDependencies = makeOSCATownhallMenuDependencies()
        let oscaTownhall = OSCATownhallMenu(dependencies: townhallDependencies)
        townhallMenu = oscaTownhall
        return oscaTownhall
      }// end if
    }// end func makeOSCATownhallMenu
    
    func makeTownhallViewModel(actions: TownhallViewModelActions) -> TownhallViewModel {
#if DEBUG
      print("\(String(describing: self)): \(#function)")
#endif
      let oscaTownhall = makeOSCATownhallMenu()
      let deeplinkPrefixes: [String] = makeDeeplinkPrefixes()
      return TownhallViewModel(
        oscaTownhallMenu: oscaTownhall,
        actions: actions,
        deeplinkPrefixes: deeplinkPrefixes
      )
    } // end func makeModuleNavigationViewModel
}// end final class TownhallDI
}// end extension public final class AppDI

// MARK: - Flow Coordinators
extension AppDI.TownhallDI {
  /// singleton `TownhallFlow`
  func makeTownhallFlowCoordinator(router: Router) -> TownhallFlow {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let townhallFlow = townhallFlow {
      return townhallFlow
    } else {
      let flow = TownhallFlow(router: router, dependencies: self)
      townhallFlow = flow
      return flow
    }// end if
  } // end func make makeCityFlowCoordinator
  
  /// singleton contact flow
  func makeOSCAContactFormFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
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
  
  func getOSCAContactDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = makeOSCAContactFormFlowCoordinator(router: router)
    guard let typedFlow = flow as? OSCADeeplinkHandeble
    else {
      return dependencies
        .appDI
        .makeOSCASolingenDI()
        .makeOSCASolingen()
        .getOSCAContactDeeplinkHandeble(router: router)
    }// end guard
    return typedFlow
  }// end func getOSCAContactDeeplinkHandeble
  
  /// singleton defect flow
  func makeOSCADefectFormFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
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
  
  func getOSCADefectDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = makeOSCADefectFormFlowCoordinator(router: router)
    guard let typedFlow = flow as? OSCADeeplinkHandeble
    else {
      return dependencies
        .appDI
        .makeOSCASolingenDI()
        .makeOSCASolingen()
        .getOSCADefectDeeplinkHandeble(router: router)
    }// end guard
    return typedFlow
  }// end func getOSCADefectDeeplinkHandeble
  
  /// singleton waste coordinator flow
  func makeOSCAWasteFlowCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
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
  
  func getOSCAWasteDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let flow = makeOSCAWasteFlowCoordinator(router: router)
    guard let typedFlow = flow as? OSCADeeplinkHandeble
    else {
      return dependencies
        .appDI
        .makeOSCASolingenDI()
        .makeOSCASolingen()
        .getOSCAWasteDeeplinkHandeble(router: router)
    }// end guard
    return typedFlow
  }// end func getOSCAWasteDeeplinkHandeble
  
  /// make web view  flow
  func makeOSCASafariViewFlowCoordinator(router: Router, url: URL) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return self.dependencies
      .appDI
      .makeSafariViewDI()
      .makeOSCASafariViewFlowCoordinator(url: url, router: router)
  }// end func makeOSCASafariViewFlowCoordinator
  
  /// make singleton appointments flow
  func makeOSCAAppointmentsFlowCoordinator(router: Router) -> Coordinator {
    if let flow = self.appointmentsFlow {
      return flow
    } else {
      let flow = dependencies
        .appDI
        .makeOSCAAppointmentsUIDI()
        .makeOSCAAppointmentsFlowCoordinator(router: router)
      self.appointmentsFlow = flow
      return flow
    }
  }
  
  func getOSCAAppointmentsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    let flow = makeOSCAAppointmentsFlowCoordinator(router: router)
    guard let typedFlow = flow as? OSCADeeplinkHandeble
    else {
      return dependencies
        .appDI
        .makeOSCASolingenDI()
        .makeOSCASolingen()
        .getOSCAAppointmentsDeeplinkHandeble(router: router)
    }
    return typedFlow
  }
} // end final class TownhallDI


