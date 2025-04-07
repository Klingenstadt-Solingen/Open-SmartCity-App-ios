//
//  CityFlow.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 17.06.22.
//  Reviewed by Stephan Breidenbach on 02.09.2022.
//

import Foundation
import OSCAEssentials
import OSCAPressReleases
import OSCAPressReleasesUI
import OSCAWeather
import OSCAWeatherUI
import OSCAMapUI
import OSCAWasteUI
import OSCASafariView
import OSCAEnvironmentUI
import OSCANetworkService
import OSCADistrict
import OSCANetworkService
import UIKit

protocol CityFlowDependencies {
  var deeplinkScheme: String { get }
  func makeDeeplinkPrefixes() -> [String]
  func makeCityViewController(actions: CityViewModelActions) -> CityViewController
  func makeOSCAWeatherCoordinator(router: Router, selectedId: String) -> Coordinator
  func makeOSCADistrictCoordinator(router: Router) -> OSCADistrictFlowCoordinator
  func makeOSCAWeatherListCoordinator(router: Router) -> Coordinator
  func makeTownhallCoordinator(router: Router) -> TownhallFlow
  func makeOSCAPressReleasesCoordinator(router: Router) -> OSCAPressReleasesFlowCoordinator
  func makeOSCAWasteWidgetFlowCoordinator(router: Router) -> Coordinator
  func makeMapCoordinator(router: Router) -> Coordinator
  func makeOSCAContactFormFlowCoordinator(router: Router) -> Coordinator
  func makeOSCAWasteFlowCoordinator(router: Router) -> Coordinator
  func makeOSCADefectFormFlowCoordinator(router: Router) -> Coordinator
  func makeOSCASafariViewFlowCoordinator(router: Router, url: URL) -> Coordinator
  func makeOSCAPublicTransportFlowCoordinator(router: Router) -> Coordinator
  func makeOSCAEventsFlowCoordinator(router: Router) -> Coordinator
  func makeOSCACoworkingFlowCoordinator(router: Router) -> Coordinator
  func makeOSCAJobsFlowCoordinator(router: Router) -> Coordinator
  func makeOSCACultureFlowCoordinator(router: Router) -> Coordinator
  func makeOSCAMobilityMonitorFlowCoordinator(router: Router) -> Coordinator
  func makeOSCAEnvironmentCoordinator(router: Router) -> OSCAEnvironmentFlowCoordinator
}// end protocol CityFlowDependencies

/**
 The concrete coordinator implements the coordinator protocol. It knows how to create concrete view controllers and the order in which view controllers should be displayed.
 */
final class CityFlow: Coordinator {
  /// list of `Coordinator`s
  var children: [Coordinator] = []
  
  /// router injected via initializer: `router`will be used to push and pop view controllers
  var router: Router
  
  let dependencies: CityFlowDependencies
  /// child flow coordinator instance
  var childFlow: Coordinator?
  
  var safariFlow: OSCASafariViewFlowCoordinator?
    
  var networkConfig: OSCANetworkConfiguration
  
  /// Module Navigation view controller instance
  weak var cityVC: CityViewController?
  weak var weatherScene: Coordinator?
  weak var weatherListScene: Coordinator?
  weak var districtScene: Coordinator?
  weak var mapScene: Coordinator?
  weak var wasteWidgetFlow: OSCAWasteWidgetFlowCoordinator?
  weak var wasteWidgetVC: OSCAWasteAppointmentViewControllerWidget?
  weak var environmentScene: Coordinator?
  
  init(router: Router,
       dependencies: CityFlowDependencies, networkConfig: OSCANetworkConfiguration) {
    self.router = router
    self.dependencies = dependencies
    self.networkConfig = networkConfig
  } // end init
  
  func horizontallyNavigateTo() -> Void {
    #warning("TODO: implementation")
  }
  
  func showCityMain(animated: Bool,
                    onDismissed: (() -> Void)?) -> Void {
    if let cityVC = cityVC {
      router.present(cityVC,
                     animated: animated,
                     onDismissed: onDismissed)
    } else {
      let debugClosure: () -> Void = {
      }// end debugClosure
      
      let actions = CityViewModelActions(
        showWeatherScene: showWeatherScene,
        showWeatherSceneWithURL: showWeatherSceneWithURL(url:),
        showWeatherListScene: showWeatherListScene,
        showWeatherDetailScene: showWeatherScene(selectedWeatherStationId:),
        showDistrictScene: showDistrictScene,
        showMapScene: showMapScene,
        showMapSceneWithURL: showMapSceneWithURL(url:),
        showPressReleaseScene: showPressRelesesMain,
        showPressReleaseDetailScene: showPressReleaseDetail(pressRelease:dataModule:),
        showPressReleasesWidget: debugClosure,
        makeWasteWidget: self.makeWasteWidget,
        showServicesScene: debugClosure,
        showServicesDetailScene: debugClosure,
        showTownhallScene: debugClosure,
        showTownhallDetailScene: debugClosure,
        navigateToTownhallMenu: navigateToTownhallMenu(townhallMenu:),
        navigateToServiceMenu: navigateToServiceMenu(serviceMenu:),
        showEnvironmentScene: showEnvironmentScene)
      
      /// instantiate view controller with view model actions
      let cityViewController: CityViewController = dependencies
        .makeCityViewController(actions: actions)
      /// present view controller
      router.present(cityViewController,
                     animated: animated,
                     onDismissed: onDismissed)
      /// local handle to the presenting `CityViewController` instance
      cityVC = cityViewController
    }// end if
  }// end func showCityMain
  /// present Module Navigation view controller method
  /// * instantiate view model actions
  /// * instantiate view controller with view model actions
  /// * present view controller
  ///
  func present(animated: Bool,
               onDismissed: (() -> Void)?) {
    showCityMain(animated: animated,
                 onDismissed: onDismissed)
  } // end func present
  
  func showPressRelesesMain() {
    let flow = self.dependencies.makeOSCAPressReleasesCoordinator(router: self.router)
    
    return flow.showPressReleasesMain(animated: true, onDismissed: nil)
  }
  
  func showPressReleaseDetail(pressRelease: OSCAPressRelease,
                              dataModule: OSCAPressReleases) {
    let flow = self
      .dependencies
      .makeOSCAPressReleasesCoordinator(router: self.router)
    
    return flow
      .showPressReleasesDetailFromChild(child: self,
                                        dataModule: dataModule,
                                        pressRelease: pressRelease)
  }// end func
  
  func showWeatherScene(selectedWeatherStationId: String) {
    // construct child flow coordinator
    let flow = dependencies
      .makeOSCAWeatherCoordinator(router: router, selectedId: selectedWeatherStationId)
    // start child flow coordinator for the splash scene
    flow.present(animated: false) {
    } // end flow.present onDismissed closure
    weatherScene = flow
  } // end private func showWeatherScene
  
  func showWeatherListScene() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    // construct child flow coordinator
    let flow = dependencies
      .makeOSCAWeatherListCoordinator(router: router)
    // start child flow coordinator for the splash scene
    flow.present(animated: false) {
    } // end flow.present onDismissed closure
      weatherListScene = flow
  }
    
    func showDistrictScene(deeplink: URL?) {
        let url: String? = networkConfig.baseURL.absoluteString
        let clientKey: String? = networkConfig.headers["X-PARSE-CLIENT-KEY"] as? String
        let appId: String? = networkConfig.headers["X-PARSE-APPLICATION-ID"] as? String
        let sessionToken: String? = UserDefaults.standard.parseSessionToken
        let politicsURL: String? = AppDI.Environment.politicsURL
        // construct child flow coordinator
        let flow = dependencies
            .makeOSCADistrictCoordinator(router: router)
        // start child flow coordinator for the splash scene
        OSCADistrictSettings
            .initDistrict(
                url: url,
                clientKey: clientKey,
                appId: appId,
                sessionToken: sessionToken,
                deeplink: deeplink,
                politicsURL: politicsURL
            )
        DispatchQueue.main.async {
            flow.showDistrictMain(
                animated: false,
                deeplink: deeplink
            ) {}
        }
        districtScene = flow
    }
  
  func showMapScene() {
    if let mapScene = mapScene {
      mapScene.present(animated: false,
                       onDismissed: nil)
    } else {
      // construct child flow coordinator
      let flow = dependencies
        .makeMapCoordinator(router: router)
      // start child flow coordinator for the splash scene
      flow.present(animated: false) {
      } // end flow.present onDismissed closure
      mapScene = flow
    }// end if
  } // end private func showMapScene
  
  func makeWasteWidget() {
    let flow = self.dependencies
      .makeOSCAWasteWidgetFlowCoordinator(router: self.router)
    guard let wasteFlow = flow as? OSCAWasteWidgetFlowCoordinator else { return }
    self.presentChild(flow, animated: false)
    self.wasteWidgetFlow = wasteFlow
    self.wasteWidgetVC = wasteFlow.wasteWidgetVC
    self.cityVC?.wasteWidgetViewController = wasteFlow.wasteWidgetVC
  }
    
    func showEnvironmentScene() {
        let flow = dependencies.makeOSCAEnvironmentCoordinator(router: router)
        let url: String? = networkConfig.baseURL.absoluteString
        let clientKey: String? = networkConfig.headers["X-PARSE-CLIENT-KEY"] as? String
        let appId: String? = networkConfig.headers["X-PARSE-APPLICATION-ID"] as? String
        let sessionToken = UserDefaults.standard.parseSessionToken
        flow.showEnvironmentMain(animated: false, url: url, clientKey: clientKey, appId: appId, sessionToken: sessionToken) {}
        environmentScene = flow
    }
  
  /// navigate to
  /// - Parameter townhallMenu: `TownhallMenu` item
  func navigateToTownhallMenu(townhallMenu: TownhallMenu) -> Void{
    guard let cityVC = self.cityVC,
          let seque = townhallMenu.seque else { return }
    // remove possible modal view
    if let childFlow = childFlow {
      removeChild(childFlow)
      self.childFlow = nil
    }// end if
    var flow: Coordinator?
    var url: URL?
    let deeplinkScheme = dependencies.deeplinkScheme
    switch seque {
    case .contact:
      url = URL(string: "\(deeplinkScheme)://contact/")
    case .waste:
      url = URL(string: "\(deeplinkScheme)://waste/")
    case .defect:
      url = URL(string: "\(deeplinkScheme)://defect/")
    case .school:
        break
    case .http:
      guard let urlString = townhallMenu.link,
            let url = URL(string: urlString)
      else { return }
      
      if let safariFlow = self.safariFlow {
        safariFlow.url = url
        flow = safariFlow
      } else {
        flow = self.dependencies.makeOSCASafariViewFlowCoordinator(router: router, url: url)
        self.safariFlow = flow as? OSCASafariViewFlowCoordinator
      }
    case .appointment:
      url = URL(string: "solingen://appointments/")
    }// end switch case
    
    if let flow = flow {
      presentChild(flow, animated: false)
      self.childFlow = flow
    }// end if
    if let url = url {
      cityVC.navigate(url: url)
    }// end if
  }// end navigateToTownhallMenu
  
  func navigateToServiceMenu(serviceMenu: ServiceMenu /* , imageData: Data? */ ) {
    guard let cityVC = self.cityVC,
          let seque = serviceMenu.seque else { return }
    if let childFlow = childFlow {
      removeChild(childFlow)
      self.childFlow = nil
    }// end if
    var flow: Coordinator?
    var url: URL?
    let deeplinkScheme = dependencies.deeplinkScheme
    switch seque {
    case .events:
        if let url = URL(string: "\(deeplinkScheme)://events/") {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    case .publicTransport:
      url = URL(string: "\(deeplinkScheme)://transport/")
    case .coworking:
      url = URL(string: "\(deeplinkScheme)://coworking/")
    case .jobs:
      url = URL(string: "\(deeplinkScheme)://jobs/")
    case .http:
      guard let urlString = serviceMenu.link,
            let url = URL(string: urlString)
      else { return }
      
      if let safariFlow = self.safariFlow {
        safariFlow.url = url
        flow = safariFlow
      } else {
        flow = self.dependencies.makeOSCASafariViewFlowCoordinator(router: router, url: url)
        self.safariFlow = flow as? OSCASafariViewFlowCoordinator
      }
    case .art:
      url = URL(string: "\(deeplinkScheme)://art/")
    case .mobilityMonitor:
      url = URL(string: "\(deeplinkScheme)://mobilitymonitor/")
    case .investment:
      #warning("TODO: implementation")
    }// end switch case
    
    if let flow = flow {
      presentChild(flow, animated: false)
      self.childFlow = flow
    }// end if
    
    if let url = url {
      cityVC.navigate(url: url)
    }// end if
  }// end func navigateTo
  
  func removeChild(_ child: Coordinator) {
    /// `children` includes `child`!!
    guard let index = children.firstIndex(where: { $0 === child }) else { return } // end guard
    children.remove(at: index)
  } // end private func removeChild
} // end final class CityFlow
