//
//  AppDI+OSCASolingenDI.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 05.09.22.
//

import UIKit
import OSCAEssentials
import OSCASafariView
import OSCANetworkService

extension AppDI {
  final class OSCASolingenDI {
    struct Dependencies {
      var appDI: AppDI
      let deeplinkScheme: String
      
      init(appDI: AppDI,
           deeplinkScheme: String) {
        self.appDI = appDI
        self.deeplinkScheme = deeplinkScheme
      }// end memberwise init
    }// end struct Dependencies
    
    let dependencies: AppDI.OSCASolingenDI.Dependencies
    
    private var coreModule: OSCASolingen?
    
    private var homeTabRootCoordinator: HomeTabRootCoordinator?
    
    private var webModule: OSCASafariView?
    
    private var launchFlow: Coordinator?
    
    private var onBoardingFlow: Coordinator?
    
    private var cityRootFlow: Coordinator?
    
    private var townhallRootFlow: Coordinator?
    
    private var serviceRootFlow: Coordinator?
    
    private var settingsRootFlow: Coordinator?
    
    private var contactFlow: Coordinator?
    
    private var pressReleasesFlow: Coordinator?
    
    private var weatherFlow: Coordinator?
    
    private var eventsFlow: Coordinator?
    
    private var mapFlow: Coordinator?
    
    private var defectFlow: Coordinator?
    
    private var coworkingFlow: Coordinator?
    
    private var publicTransportFlow: Coordinator?
    
    private var wasteFlow: Coordinator?
    
    private var jobsFlow: Coordinator?
    
    private var coronaFlow: Coordinator?
    
    private var cultureFlow: Coordinator?
    
    init(dependencies: OSCASolingenDI.Dependencies) {
      self.dependencies = dependencies
    }// end init
  }// end final class OSCASolingenDI
}// end extension public final class AppDI

// MARK: - core module
extension AppDI.OSCASolingenDI {
  func makeOSCASolingenDependencies() -> OSCASolingen.Dependencies {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let appDI = self.dependencies.appDI
    let analyticsModule = self
      .dependencies
      .appDI
      .analyticsModule
    
    let moduleDependencies: OSCASolingen.Dependencies =
    OSCASolingen.Dependencies(appDI: appDI,
                              analyticsModule: analyticsModule)
    return moduleDependencies
  }// end func makeOSCASolingenDependencies
  
  /// singleton module `OSCASolingen`
  func makeOSCASolingen() -> OSCASolingen {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let coreModule = self.coreModule {
      return coreModule
    } else {
      let moduleDependencies: OSCASolingen.Dependencies = makeOSCASolingenDependencies()
      let coreModule: OSCASolingen = OSCASolingen.create(with: moduleDependencies)
      self.coreModule = coreModule
      return coreModule
    }// end if
  }// end func makeOSCASolingen
}// end extension public final class AppDI

// MARK: - web module
extension AppDI.OSCASolingenDI {
  func makeOSCASafariViewDependencies() -> OSCASafariView.Dependencies {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let moduleConfig: OSCASafariView.Config = OSCASafariView.Config(title: "OSCASafariView",
                                                                    fontConfig: OSCAFontSettings(), colorConfig: OSCAColorSettings())
    let dependencies: OSCASafariView.Dependencies = OSCASafariView.Dependencies(moduleConfig: moduleConfig)
    return dependencies
  }// end func makeOSCASafariViewDependencies
  
  /// singleton web module `OSCASafariView`
  func makeOSCASafariView() -> OSCASafariView {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let webModule = self.webModule {
      return webModule
    } else {
      let module = OSCASafariView.create(with: makeOSCASafariViewDependencies())
      self.webModule = module
      return module
    }// end if
  }// end func makeOSCASafariView
  
  func makeSafariViewCoordinator(router: Router, url: URL) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return makeOSCASafariView()
      .getSafariViewFlowCoordinator(router: router, url: url)
  }// end func makeSafariViewCoordinator
}// end extension inal class OSCASolingenDI

// MARK: - HomeTabRoot Flow
extension AppDI.OSCASolingenDI {
  /// singleton `HomeTabRootCoordinator`
  func makeHomeTabRootCoordinator(window: UIWindow,
                                  onDismissed: (() -> Void)?) -> HomeTabRootCoordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let homeTabRootCoordinator = homeTabRootCoordinator {
      return homeTabRootCoordinator
    } else {
      let coordinator = makeOSCASolingen()
        .getHomeTabRootCoordinator(window: window,
                                   onDismissed:onDismissed)
      homeTabRootCoordinator = coordinator
      return coordinator
    }// end if
  }// end func makeHomeTabRootCoordinator
  
  func makeHomeTabRootDeeplinkHandeble(window: UIWindow,
                                       onDismissed: (() -> Void)?) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let homeTabRootDeeplinkHandeble = makeHomeTabRootCoordinator(window: window,
                                                                 onDismissed: onDismissed) as OSCADeeplinkHandeble
    return homeTabRootDeeplinkHandeble
  }// end func makeHomeTabRootDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Launch Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeLaunchCoordinator(router: Router,
                             appFlow: SolingenAppFlow,
                             firstStartDeeplinkURL: URL?,
                             presentOnboarding: @escaping () -> Void,
                             presentMain: @escaping (URL?) -> Void,
                             presentLogin: @escaping () -> Void) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let launchFlow = launchFlow {
      return launchFlow
    } else {
      let flow =  makeOSCASolingen()
        .getLaunchCoordinator(router: router,
                              appFlow: appFlow,
                              firstStartDeeplinkURL: firstStartDeeplinkURL,
                              presentOnboarding: presentOnboarding,
                              presentMain: presentMain,
                              presentLogin: presentLogin)
      launchFlow = flow
      return flow
    }// end if
  }// end func makeLaunchCoordinator
}// end extension final class OSCASolingenDI

// MARK: - Onboarding Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeOnboardingCoordinator(router: Router,
                                 onboardingCompletion: @escaping (() -> Void)) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let onBoardingFlow = onBoardingFlow {
      return onBoardingFlow
    } else {
      let flow =  makeOSCASolingen()
        .getOnboardingCoordinator(router: router,
                                  onboardingCompletion: onboardingCompletion)
      onBoardingFlow = flow
      return flow
    }// end if
  }// end func makeOnboardingCoordinator
}// end extension final class OSCASolingenDI

// MARK: - City Root Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeCityCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let cityRootFlow = cityRootFlow {
      return cityRootFlow
    } else {
      let flow = makeOSCASolingen()
        .getCityCoordinator(router: router)
      cityRootFlow = flow
      return flow
    }// end if
  }// end func makeCityViewFlowCoordinator
  
  func makeCityDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let cityDeeplinkHandeble = makeCityCoordinator(router: router) as? OSCADeeplinkHandeble
    else {
      return makeOSCASolingen()
        .getCityDeeplinkHandeble(router: router)
    }// end guard
    return cityDeeplinkHandeble
  }// end func makeCityDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Townhall Root Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeTownhallCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let townhallRootFlow = townhallRootFlow {
      return townhallRootFlow
    } else {
      let flow = makeOSCASolingen()
        .getTownhallCoordinator(router: router)
      townhallRootFlow = flow
      return flow
    }// end if
  }// end func makeTownhallFlowCoordinator
  
  func makeTownhallDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
    guard let townhallDeeplinkHandeble = makeTownhallCoordinator(router: router) as? OSCADeeplinkHandeble
    else {
      return makeOSCASolingen()
        .getTownhallDeeplinkHandeble(router: router)
    }// end guard
    return townhallDeeplinkHandeble
  }// end func makeTownhallDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Service Root Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeServiceCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let serviceRootFlow = serviceRootFlow {
      return serviceRootFlow
    } else {
      let flow = makeOSCASolingen()
        .getServiceCoordinator(router: router)
      serviceRootFlow = flow
      return flow
    }// end if
  }// end func makeServiceFlowCoordinator
  
  func makeServiceDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let serviceDeeplinkHandeble = makeServiceCoordinator(router: router) as? OSCADeeplinkHandeble
    else { return makeOSCASolingen()
      .getServiceDeeplinkHandeble(router: router)}
    return serviceDeeplinkHandeble
  }// end func makeServiceDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Settings Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeSettingsCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let settingsRootFlow = settingsRootFlow {
      return settingsRootFlow
    } else {
      let flow = makeOSCASolingen()
        .getSettingsCoordinator(router: router)
      settingsRootFlow = flow
      return flow
    }// end if
  }// end func makeSettingsCoordinator
  
  func makeSettingsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let settingsDeeplinkHandeble = makeSettingsCoordinator(router: router) as? OSCADeeplinkHandeble
    else { return makeOSCASolingen()
      .getSettingsDeeplinkHandeble(router: router) }
    return settingsDeeplinkHandeble
  }// end func makeSettingsDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Contact Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeContactCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let contactFlow = contactFlow {
      return contactFlow
    } else {
      let flow = makeOSCASolingen()
        .getOSCAContactCoordinator(router: router)
      contactFlow = flow
      return flow
    }// end if
  }// end func makeContactCoordinator
  
  func makeContactDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return makeOSCASolingen()
      .getOSCAContactDeeplinkHandeble(router: router)
  }// end func makeContactDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - PressRelease Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makePressReleasesCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let pressReleasesFlow = pressReleasesFlow {
      return pressReleasesFlow
    } else {
      let flow = makeOSCASolingen()
        .getOSCAPressReleasesCoordinator(router: router)
      pressReleasesFlow = flow
      return flow
    }// end if
  }// end func makePressReleasesCoordinator
  
  func makePressReleasesDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let pressReleasesDeeplinkHandeble = makePressReleasesCoordinator(router: router) as? OSCADeeplinkHandeble
    else {
      return makeOSCASolingen()
        .getOSCAPressReleasesDeeplinkHandeble(router: router)
    }// end guard
    return pressReleasesDeeplinkHandeble
  }// end func makePressReleasesDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Weather Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeWeatherCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let weatherFlow = weatherFlow {
      return weatherFlow
    } else {
      let flow = makeOSCASolingen()
        .getOSCAWeatherCoordinator(router: router)
      weatherFlow = flow
      return flow
    }// end if
  }// end func makeWeatherCoordinator
  
  func makeWeatherDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return makeOSCASolingen()
      .getOSCAWeatherDeeplinkHandeble(router: router)
  }// end func makeWeatherDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Events Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeEventsCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let eventsFlow = eventsFlow {
      return eventsFlow
    } else {
      let flow = makeOSCASolingen()
        .getOSCAEventsCoordinator(router: router)
      eventsFlow = flow
      return flow
    }// end if
  }// end func makeEventsCoordinator
  
  func makeEventsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return makeOSCASolingen()
      .getOSCAEventsDeeplinkHandeble(router: router)
  }// end func makeEventsDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Map Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeMapCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let mapFlow = mapFlow {
      return mapFlow
    } else {
      let flow = makeOSCASolingen()
        .getOSCAMapCoordinator(router: router)
      mapFlow = flow
      return flow
    }// end if
  }// end func makeMapCoordinator
  
  func makeMapDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return makeOSCASolingen()
      .getOSCAMapDeeplinkHandeble(router: router)
  }// end func makeMapDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Defect Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeDefectCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let defectFlow = defectFlow {
      return defectFlow
    } else {
      let flow = makeOSCASolingen()
        .getOSCADefectCoordinator(router: router)
      defectFlow = flow
      return flow
    }// end if
  }// end func makeDefectCoordinator
  
  func makeDefectDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return makeOSCASolingen()
      .getOSCADefectDeeplinkHandeble(router: router)
  }// end func makePressReleasesDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Coworking Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeCoworkingCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let coworkingFlow = coworkingFlow {
      return coworkingFlow
    } else {
      let flow = makeOSCASolingen()
        .getOSCACoworkingCoordinator(router: router)
      coworkingFlow = flow
      return flow
    }// end if
  }// end func makeCoworkingCoordinator
  
  func makeCoworkingDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return makeOSCASolingen()
      .getOSCACoworkingDeeplinkHandeble(router: router)
  }// end func makeCoworkingDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Public Transport Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makePublicTransportCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let publicTransportFlow = publicTransportFlow {
      return publicTransportFlow
    } else {
      let flow = makeOSCASolingen()
        .getOSCAPublicTransportCoordinator(router: router)
      publicTransportFlow = flow
      return flow
    }// end if
  }// end func makePublicTransportCoordinator
  
  func makePublicTransportDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return makeOSCASolingen()
      .getOSCAPublicTransportDeeplinkHandeble(router: router)
  }// end func makeCoronaDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Waste Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeWasteCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let wasteFlow = wasteFlow {
      return wasteFlow
    } else {
      let flow = makeOSCASolingen()
        .getOSCAWasteCoordinator(router: router)
      wasteFlow = flow
      return flow
    }// end if
  }// end func makeWasteCoordinator
  
  func makeWasteSetupCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return makeOSCASolingen()
      .getOSCAWasteSetupCoordinator(router: router)
  }// end func makeWasteSetupCoordinator
  
  func makeWasteDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return makeOSCASolingen()
      .getOSCAWasteDeeplinkHandeble(router: router)
  }// end func makeWasteDeeplinkHandeble
}// end extension final class OSCASolingenDI

// MARK: - Jobs Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeJobsCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let jobsFlow = jobsFlow {
      return jobsFlow
    } else {
      let flow = makeOSCASolingen()
        .getOSCAJobsCoordinator(router: router)
      jobsFlow = flow
      return flow
    }// end if
  }// end func makeJobsCoordinator
  
  func makeJobsDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    return makeOSCASolingen()
      .getOSCAJobsDeeplinkHandeble(router: router)
  }// end func makeJobsDeeplinkHandeble
}// end extension final class OSCASolingenDI

/* Disabled module Corona
// MARK: - Corona Flow
extension AppDI.OSCASolingenDI {
  /// singleton `Coordinator`
  func makeCoronaCoordinator(router: Router) -> Coordinator {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    if let coronaFlow = coronaFlow {
      return coronaFlow
    } else {
      let flow = makeOSCASolingen()
        .getOSCACoronaCoordinator(router: router)
      coronaFlow = flow
      return flow
    }// end if
  }// end func makeCoronaCoordinator
  
  func makeCoronaDeeplinkHandeble(router: Router) -> OSCADeeplinkHandeble {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let coronaDeeplinkHandeble = makeCoronaCoordinator(router: router) as? OSCADeeplinkHandeble
    else {
      return makeOSCASolingen()
        .getOSCACoronaDeeplinkHandeble(router: router)
    }// end guard
    return coronaDeeplinkHandeble
  }// end func makeCoronaDeeplinkHandeble
}// end extension final class OSCASolingenDI
 */

// MARK: - Culture Flow
extension AppDI.OSCASolingenDI {
  // MARK: - Todo implementation
}// end extension inal class OSCASolingenDI
