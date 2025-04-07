//
//  OSCASGBaseAppDelegate.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.10.22.
//

import UIKit
import CoreData
import OSCAEssentials
import Sentry

/// [based upon](https://stackoverflow.com/questions/34185839/is-there-a-way-to-override-an-app-delegate-in-a-framework-in-swift)
open class OSCASGBaseAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  override init(){
    do {
      /// register DI
      try OSCASGBaseAppDelegate.registerDI(Self.config)
    } catch {
#warning("TODO: fatalError")
      fatalError("Unresolved error \(error), \(error.localizedDescription)")
    }// end do catch
  }// end
  
  deinit {
    DIContainer.container(for: Self.config).removeAllDependencies()
  }// end deinit
  
  @LazyInjected(.by(key: "OSCASGAppConfig"),
                container: DIContainer.container(for: OSCASGBaseAppDelegate.config),
                mode: .shared)
  var appConfig: AppDI.Config
  
  let solingenAppFlowOnDismissed: (() -> Void)? = {
#if DEBUG
    print("SolingenAppFlowOnDismissed: \(#function)")
#endif
  }// end solingenAppFlowOnDismissed closure
  public var window: UIWindow?
  var appDI: AppDI?
  var coreModule: OSCASolingen?
  var appFlow: SolingenAppFlow?
  
  // MARK: - Core Data stack
  /// The persistent container for the application **with name "Solingen"**. This implementation creates and returns a container, having loaded the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
  lazy var persistentContainer: NSPersistentCloudKitContainer = {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    #if DEBUG
    let container = NSPersistentCloudKitContainer(name: "SolingenApp")
    #else
    let container = NSPersistentCloudKitContainer(name: "Solingen")
    #endif
    container.loadPersistentStores(completionHandler: { _, error in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
#warning("TODO: fatalError")
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }() // end lazy var persistentContainer
  
  // MARK: - App lifecycle
  
  /// - parameter application: singleton app object
  /// - parameter launchOptions: dictionary indicating the reason the app was launched. The contents of this dictionary may be empty in situations where the user launched the app directly.
  /// - returns: `false` if
  /// * the app cannot handle the `URL` resource
  /// * the app cannot continue a user activity
  /// * the app should not perform the `application(_: performActionFor:completionHAndler:)` method becoaus you're handling the invocation of a Home screen quck action in this method
  /// ** The return value is ignored if the app is launched as a result of a remote notification! **
  open func application(_ application: UIApplication,
                        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    extractOptions(from: launchOptions)
    return true
  }// end func application will finish launching with options
  
  /// Tells the delegate that the launch process is almost done and the app is almost ready to run.
  /// * initialize app
  /// * handle possible push notifications
  ///
  /// - Parameter application: singleton app object
  /// - Parameter launchOptions: dictionary indicationg the reason the app was launched
  open func application(_ application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
      // initialize Sentry
      if (AppDI.Environment.sentryEnabled) {
          SentrySDK.start { options in
              options.dsn = AppDI.Environment.sentryDSN
#if DEBUG
              options.debug = true
#endif
              options.beforeSend = { event in
#if DEBUG
                  return nil
#else
                  return event
#endif
              }
          }
      }
    // Override point for customization after application launch.
    applicationInit()
    var success = true
    // handle possible push notifications
    if let userInfo = self.extractPushOptions(from: launchOptions) {
      success = self.application(application, didFinishLaunchingWithPushOptions: userInfo)
    }// end if
    return success
  } // end func application did finish launching with options
  
  /// Tells the delegate that the app is about to enter the foreground
  /// - Parameter application: singleton app object
  /// If you are using scenes, UIKit will not call this method
  open func applicationWillEnterForeground(_ application: UIApplication) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
  }// end func application will enter foreground
  
  /// Tells the delegate that the app has become active
  /// - Parameter application: singleton app object
  /// If you are using scenes, UIKit will not call this method
  open func applicationDidBecomeActive(_ application: UIApplication) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
  }// end func applicationDidBecomeActive
  
  /// Tells the delegate that the app is about to become inactive.
  /// - Parameter application: singleton app object
  /// If you are using scenes, UIKit will not call this method
  open func applicationWillResignActive(_ application: UIApplication) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
  }// end func application will resign active
  
  /// Tells the delegate that the app is now in the background.
  /// - Parameter application: singleton app object
  /// If you are using scenes, UIKit will not call this method
  open func applicationDidEnterBackground(_ application: UIApplication) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
  }// end func application did enter background
  
  
  /// Tells the delegate when the app is about to terminate.
  /// - Parameter application: singleton app object
  open func applicationWillTerminate(_ application: UIApplication) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
  }// end func application will terminate
  
  // MARK: UISceneSession Lifecycle
  
  /// Retrieves the configuration data for UIKit to use when creating a new scene.
  /// Delegate class: `OSCASGSceneDelegate`
  /// storyboard: "LaunchScreen"
  /// - Returns: scene configuration with name "Default Configuration"
  ///
  /// [without info.plist](https://stackoverflow.com/questions/66729712/how-to-connect-scenedelegate-without-using-sceneconfiguration-in-info-plist-in)
  /// By applying the dynamic declaration modifier to a member of a class, you tell the compiler that dynamic dispatch should be used to access that member.
  open dynamic func application(_ application: UIApplication,
                        configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    if connectingSceneSession.role == UISceneSession.Role.windowApplication {
      let config = UISceneConfiguration(name: "Default Configuration",
                                        sessionRole: connectingSceneSession.role)
      config.delegateClass = OSCASGSceneDelegate.self
      let storyboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
      config.storyboard = storyboard
      return config
    }// end if
    fatalError("Unhandled scene role \(connectingSceneSession.role)")
  } // end func application configuration for connecting scene session
  
  open dynamic func application(_ application: UIApplication,
                        didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    
  } // end func application did discard scene session
}// end class OSCASGBaseAppDelegate

// MARK: - Application init
extension OSCASGBaseAppDelegate {
  /// * initialize application's main window
  /// * register DI
  /// * initialize application's `DIContainer`
  /// * initialize application's `CoreModule`
  /// * initialize application's `AppFlow`
  func applicationInit() {
    self.window = nil
    self.appDI = nil
    self.coreModule = nil
    self.appFlow = nil
    /// main window
    initWindow()
    /// app DI Container
    initAppDI()
    /// core module
    initCoreModule()
    /// app flow
    initAppFlow()
  }// end func applicationInit
}// end extension class OSCASGBaseAppDelegate

// MARK: - main window
extension OSCASGBaseAppDelegate {
  /// * create a new `UIWindow` instance
  /// * make the window instance `key and visible`
  /// * create a new `UINavigationController` instance
  /// * make the navigationController instance `rootViewController` of the window instance
  func initWindow() {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    do {
      /**
       creating `window` from `windowScene`which holds on the app's `UIWindow` instance
       */
      self.window = UIWindow(frame: UIScreen.main.bounds)
      guard let window = self.window else {
        // fatalError("The Application's main window is not properly initialized")
        throw OSCASGError.appInit(msg: "Main window")
      }// end guard
      window.makeKeyAndVisible()
      let navController = UINavigationController()
      window.rootViewController = navController
    } catch {
      var err: OSCASGError?
      if let oscaSGError = error as? OSCASGError {
        err = oscaSGError
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "Application main window: \(error.localizedDescription)")
        err = oscaSGError
      }// end if
      guard let oscaSGError = err else { return }
      let retryHandler = {[weak self] in
        guard let `self` = self else { return }
        self.applicationInit()
      }// end let
      handle(oscaSGError,
             retryHandler: retryHandler)
    }// end do catch
  }// end func initWindow
}// end extension class OSCASGBaseAppDelegate

// MARK: - App DI
extension OSCASGBaseAppDelegate {
  /// construct AppDI instance `AppDI.create()`
  func initAppDI() {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    do {
      /// app DI container
      self.appDI = try AppDI.create(appConfig: self.appConfig)
      guard let _ = self.appDI else {
        // fatalError("The Application's DI container is not properly initialized")
        throw OSCASGError.appInit(msg: "Application DI container")
      }// end guard
    } catch {
      var err: OSCASGError?
      if let oscaSGError = error as? OSCASGError {
        err = oscaSGError
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "Application DI Container: \(error.localizedDescription)")
        err = oscaSGError
      }// end if
      guard let oscaSGError = err else { return }
      let retryHandler = {[weak self] in
        guard let `self` = self else { return }
        self.applicationInit()
      }// end let
      handle(oscaSGError,
             retryHandler: retryHandler)
    }// end do catch
  }// end func initAppDI
}// end extension class OSCASGBaseAppDelegate

// MARK: - core module
extension OSCASGBaseAppDelegate {
  /// enshure application's `DIContainer` is initialized
  /// construct `CoreModule`
  func initCoreModule() {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    do {
      /// core module
      guard let appDI = self.appDI else { throw OSCASGError.appInit(msg: "App DI Container") }
      let coreModuleDependencies = OSCASolingen.Dependencies(appDI: appDI)
      self.coreModule = OSCASolingen.create(with: coreModuleDependencies)
      guard let _ = self.coreModule else { throw OSCASGError.appInit(msg: "Core module") }
    } catch {
      var err: OSCASGError?
      if let oscaSGError = error as? OSCASGError {
        err = oscaSGError
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "Application DI Container: \(error.localizedDescription)")
        err = oscaSGError
      }// end if
      guard let oscaSGError = err else { return }
      let retryHandler = {[weak self] in
        guard let `self` = self else { return }
        self.applicationInit()
      }// end let
      handle(oscaSGError,
             retryHandler: retryHandler)
    }// end do catch
  }// end func initCoreModule
}// end extension class OSCASGBaseAppDelegate

// MARK: - app flow
extension OSCASGBaseAppDelegate {
  /// * enshure there is a `MainWindow`
  /// * enshure there is a `RootViewController`
  /// * enshure there is a `CoreModule`
  func initAppFlow() {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    do {
      guard let window = window,
            let _ = window.rootViewController,
            let coreModule = coreModule
      else { throw OSCASGError.appInit(msg: "app flow") }
      
      let appFlow = coreModule.getSolingenAppFlow(window: window,
                                                  onDismissed: solingenAppFlowOnDismissed)
      self.appFlow = appFlow
    } catch {
      var err: OSCASGError?
      if let oscaSGError = error as? OSCASGError {
        err = oscaSGError
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "Application DI Container: \(error.localizedDescription)")
        err = oscaSGError
      }// end if
      guard let oscaSGError = err else { return }
      let retryHandler = {[weak self] in
        guard let `self` = self else { return }
        self.applicationInit()
      }// end let
      handle(oscaSGError,
             retryHandler: retryHandler)
    }// end do catch
  }// end func initAppFlow
}// end extension class OSCASGBaseAppDelegate

// MARK: - Launch options
extension OSCASGBaseAppDelegate {
  func extractOptions(from launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Void {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    // there are launch options
    guard let launchOptions = launchOptions else { return }
    if let annotation = launchOptions[.annotation] {
#if DEBUG
      print("Deprecated: URL passed to your app contained custom annotation data from the source app: \(annotation)")
#endif
    }// end if
    if let localNotification = launchOptions[.localNotification] {
#if DEBUG
      print("Deprecated: App was launched to handle a local notification: \(localNotification)")
#endif
    }// end if
    if let bluetoothCentrals = launchOptions[.bluetoothCentrals] {
#if DEBUG
      print("App was relaunched to handle Bluetooth-related events: \(bluetoothCentrals)")
#endif
    }// end if
    if let bluetoothPeriferals = launchOptions[.bluetoothPeripherals] {
#if DEBUG
      print("App should countinue actions associated with its Bluetooth peripherals objects: \(bluetoothPeriferals)")
#endif
    }// end if
    if let cloudKitMetadata = launchOptions[.cloudKitShareMetadata] {
#if DEBUG
      print("App received a CloudKit share invitation: \(cloudKitMetadata)")
#endif
    }// end if
    if let eventAttribution = launchOptions[.eventAttribution] {
#if DEBUG
      print("App has received an event: \(eventAttribution)")
#endif
    }// end if
    if let location = launchOptions[.location] {
#if DEBUG
      print("App was launched to handle an incoming location event: \(location)")
#endif
    }// end if
    if let newsstandDownloads = launchOptions[.newsstandDownloads] {
#if DEBUG
      print("App was launched to process newly downloaded Newsstand assets: \(newsstandDownloads)")
#endif
    }// end if
    if let remoteNotification = launchOptions[.remoteNotification] {
#if DEBUG
      print("A remote notification is available for the app to process: \(remoteNotification)")
#endif
    }// end if
    if let shortcutItem = launchOptions[.shortcutItem] {
#if DEBUG
      print("App was launched in response to the user selecting a Home screen quick action: \(shortcutItem)")
#endif
    }// end if
    if let sourceApplication = launchOptions[.sourceApplication] {
#if DEBUG
      print("Another App requested the launch of your App: \(sourceApplication)")
#endif
    }// end if
    if let url = launchOptions[.url] {
#if DEBUG
      print("App was launched so that it could open the specified URL: \(url)")
#endif
    }// end if
    if let userActivityDict = launchOptions[.userActivityDictionary] {
#if DEBUG
      print("Dictionary associated with an activity that he user wants to continue: \(userActivityDict)")
#endif
    }// end if
    if let userActivityType = launchOptions[.userActivityType] {
#if DEBUG
      print("Type of user activity that the user wants to continue: \(userActivityType)")
#endif
    }// end if
  }// end func extractOptions
}// end extension class OSCASGBaseAppDelegate
