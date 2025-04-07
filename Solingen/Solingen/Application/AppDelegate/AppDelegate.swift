//
//  AppDelegate.swift
//  Solingen
//
//  Created by Stephan Breidenbach on 01.06.22.
//  Reviewed by Stephan Breidenbach on 29.08.22.
//  Reviewed by Stephan Breidenbach on 29.09.22
//
import UIKit
import CoreData
import OSCASolingen
import OSCAEssentials

/// [deeplink](https://medium.com/@fenceguest/deeplink-handler-in-swift-5-ios-13-eec88c2c5fe7)
@main
class AppDelegate: OSCASGBaseAppDelegate {
  // MARK: - App lifecycle
  /// Tells the delegate that the launch process has begun but that sate restoration has not occured
  /// - Parameter application: singleton app object
  /// - Parameter launchOptions: dictionary indicating the reason the app was launched
  override func application(_ application: UIApplication,
                            willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    OSCAMatomoTracker.shared.initTracker()
    // required for Waste
    UserDefaults.standard.set(AppDI.Environment.parseAPIRootURL, forKey: "parseBaseUrl")
    return super.application(application,
                             willFinishLaunchingWithOptions: launchOptions)
  }// end func application will finish launching with options
  
  /// Tells the delegate that the launch process is almost done and the app is almost ready to run.
  /// - Parameter application: singleton app object
  /// - Parameter launchOptions: dictionary indicating the reason the app was launched
  override func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    // Handle Foreground Notifications
    UNUserNotificationCenter.current().delegate = self
    // Override point for customization after application launch.
    let success = super.application(application,
                                    didFinishLaunchingWithOptions: launchOptions)
    return success
  } // end func application did finish launching with options
  
  /// Tells the delegate that the app is about to enter the foreground
  /// If you are using scenes, UIKit will not call this method.
  /// - Parameter application: singleton app object
  override func applicationWillEnterForeground(_ application: UIApplication) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    super.applicationWillEnterForeground(application)
  }// end func application will enter foreground
  
  /// Tells the delegate that the app has become active
  ///  If you are using scenes, UIKit will not call this method
  ///  - Parameter application: singleton app object
  override func applicationDidBecomeActive(_ application: UIApplication) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    super.applicationDidBecomeActive(application)
  }// end func applicationDidBecomeActive
  
  override func applicationWillResignActive(_ application: UIApplication) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    super.applicationWillResignActive(application)
  }// end func application will resign active
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    super.applicationDidEnterBackground(application)
  }// end override func application did enter background
  
  override func applicationWillTerminate(_ application: UIApplication) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    super.applicationWillTerminate(application)
  }// end override func application will terminate
} // end class AppDelegate

  // MARK: UISceneSession Lifecycle
extension AppDelegate {
  
  /// Retrieves the configuration data for UIKit to use when creating a new scene.
  /// - Returns: scene configuration with name "Default Configuration"
  ///
  /// [without info.plist](https://stackoverflow.com/questions/66729712/how-to-connect-scenedelegate-without-using-sceneconfiguration-in-info-plist-in)
  override func application(_ application: UIApplication,
                            configurationForConnecting connectingSceneSession: UISceneSession,
                            options: UIScene.ConnectionOptions) -> UISceneConfiguration {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    /* let sceneConfiguration = UISceneConfiguration(name: "Default Configuration",
     sessionRole: connectingSceneSession.role)
     return sceneConfiguration
     
     */
    return super.application(application, configurationForConnecting: connectingSceneSession, options: options)
  } // end func application configuration for connecting scene session
  
  override func application(_ application: UIApplication,
                            didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    super.application(application, didDiscardSceneSessions: sceneSessions)
  } // end func application did discard scene sessions
}// end extension class AppDelegate

