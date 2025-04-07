//
//  OSCASceneDelegate.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.10.22.
//

import UIKit
import OSCAEssentials

class OSCASGSceneDelegate: UIResponder, UIWindowSceneDelegate {
  var windowScene: UIWindowScene?
  
  var solingenAppFlowOnDismissed: (() -> Void)?
  
  var window: UIWindow? {
    didSet {
      guard let window = self.window else { return }
      window.makeKeyAndVisible()
    }// end didSet
  }// end var window
  unowned var appDI: AppDI?
  unowned var solingenAppFlow: SolingenAppFlow?
  var coreModule: OSCASolingen?
  
  /// Tells the delegate about the addition of a scene to the app.
  /// - Parameter scene: The scene object being connected to your app.
  /// - Parameter session: The session object containing details about the scene's configuration.
  /// - Parameter connectionOptions: Additional options for configuring the scene. Use the information in this object to handle actions that caused the creation of the scene, for example, to respond to a quick action selected by the user.
  func scene(_ scene: UIScene,
             willConnectTo session: UISceneSession,
             options connectionOptions: UIScene.ConnectionOptions) {
    // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
    // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
    // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    ///  cast scene to UIWindowScene
    guard let windowScene = (scene as? UIWindowScene) else { return }
    self.windowScene = windowScene
    sceneInit(windowScene)
    appFlowHandle(connectionOptions: connectionOptions)
  }// end func scene will connect to session
  
  /// Tells the delegate that UIKit removed a scene from your app.
  /// no customization from our side
  /// - Parameter scene: The scene that UIKit disconnected from your app.
  func sceneDidDisconnect(_ scene: UIScene) -> Void {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    if let sceneDelegate = scene.delegate as? OSCASGSceneDelegate {
      let equal = sceneDelegate === self
      print("\(#function):\(equal ? "equals scene delegate": "doesn't equal scene delegate")")
    }// end if
  }// end func scene did disconnect
  
  /// Tells the delegate that the scene is about to begin running in the foreground and become visible to the user.
  /// No customization from our side.
  ///  - Parameter scene: The scene that is about to enter the foreground.
  func sceneWillEnterForeground(_ scene: UIScene) -> Void {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    if let sceneDelegate = scene.delegate as? OSCASGSceneDelegate {
      let equal = sceneDelegate === self
      print("\(#function):\(equal ? "equals scene delegate": "doesn't equal scene delegate")")
    }// end if
  }// end func scene will enter foreground
  
  ///  Tells the delegate that the scene became active and is now responding to user events.
  ///  No customization from our side.
  ///  - Parameter scene: The scene that became active and is now responding to user events.
  func sceneDidBecomeActive(_ scene: UIScene) -> Void {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    if let sceneDelegate = scene.delegate as? OSCASGSceneDelegate {
      let equal = sceneDelegate === self
      print("\(#function):\(equal ? "equals scene delegate": "doesn't equal scene delegate")")
    }// end if
  }// end func scene did become active
  
  /// Tells the delegate that the scene is about to resign the active state and stop responding to user events.
  /// No customization from our side.
  ///  - Parameter scene: The scene that became active and is now responding to user events.
  func sceneWillResignActive(_ scene: UIScene) -> Void {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    if let sceneDelegate = scene.delegate as? OSCASGSceneDelegate {
      let equal = sceneDelegate === self
      print("\(#function):\(equal ? "equals scene delegate": "doesn't equal scene delegate")")
    }// end if
  }// end func scene will resign active
  
  /// Tells the delegate that the scene is running in the background and is no longer onscreen.
  /// save context
  ///  - Parameter scene: The scene that entered the background.
  func sceneDidEnterBackground(_ scene: UIScene) -> Void {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
    
    // Save changes in the application's managed object context when the application transitions to the background.
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    if let sceneDelegate = scene.delegate as? OSCASGSceneDelegate {
      let equal = sceneDelegate === self
      print("\(#function):\(equal ? "equals scene delegate": "doesn't equal scene delegate")")
    }// end if
    (UIApplication.shared.delegate as? OSCASGBaseAppDelegate)?.saveContext()
  }// end func scene did enter background
}// end class OSCASGSceneDelegate


extension OSCASGSceneDelegate {
  func sceneInit(_ windowScene: UIWindowScene) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.solingenAppFlowOnDismissed = nil
    self.window = nil
    self.appDI = nil
    self.coreModule = nil
    self.solingenAppFlow = nil
    initSolingenAppFlowDismissed()
    /// main window
    initWindow()
    /// app DI Container
    initAppDI()
    /// core module
    initCoreModule()
    /// app flow
    initAppFlow()
  }// end func sceneInit
}// end extension class OSCASGSceneDelegate

extension OSCASGSceneDelegate {
  func initSolingenAppFlowDismissed() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    do {
      guard let delegate = UIApplication.shared.delegate,
            let appDelegate = delegate as? OSCASGBaseAppDelegate,
            let closure = appDelegate.solingenAppFlowOnDismissed else {
        throw OSCASGError.appInit(msg: "on dismissed closure")
      }// end guard
      self.solingenAppFlowOnDismissed = closure
    } catch {
      var err: OSCASGError?
      if let oscaSGError = error as? OSCASGError {
        err = oscaSGError
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "on dismissed closure: \(error.localizedDescription)")
        err = oscaSGError
      }// end if
      guard let oscaSGError = err else { return }
      let retryHandler = {[weak self] in
        guard let `self` = self,
              let windowScene = self.windowScene else { return }
        self.sceneInit(windowScene)
      }// end let
      handle(oscaSGError,
             retryHandler: retryHandler)
    }// end do catch
  }// end func initSolingenAppFlowDismissed
}// end extension lass OSCASGSceneDelegate

// MARK: - main window
extension OSCASGSceneDelegate {
  /// set `windowScene` to application's main window
  func initWindow() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    do {
      guard let delegate = UIApplication.shared.delegate,
            let appDelegate = delegate as? OSCASGBaseAppDelegate,
            let appDelegateWindow = appDelegate.window,
            let windowScene = self.windowScene else { throw OSCASGError.appInit(msg: "Main window") }
      self.window = appDelegateWindow
      guard let window = self.window else {
        // fatalError("The Application's main window is not properly initialized")
        throw OSCASGError.appInit(msg: "Main window")
      }// end guard
      window.windowScene = windowScene
      window.makeKeyAndVisible()
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
        guard let `self` = self,
              let windowScene = self.windowScene else { return }
        self.sceneInit(windowScene)
      }// end let
      handle(oscaSGError,
             retryHandler: retryHandler)
    }// end do catch
  }// end func initWindow
}// end extension class OSCASGSceneDelegate

// MARK: - App DI
extension OSCASGSceneDelegate {
  /// * hold a `unowned`reference to `AppDI``
  func initAppDI() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    do {
      /// app DI container
      guard let delegate = UIApplication.shared.delegate,
            let appDelegate = delegate as? OSCASGBaseAppDelegate,
            let appDI = appDelegate.appDI else { throw OSCASGError.appInit(msg: "Application DI container") }
      self.appDI = appDI
      guard let _ = self.appDI else {
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
        guard let `self` = self,
              let windowScene = self.windowScene else { return }
        self.sceneInit(windowScene)
      }// end let
      handle(oscaSGError,
             retryHandler: retryHandler)
    }// end do catch
  }// end func initAppDI
}// end extension class OSCASGSceneDelegate

// MARK: - core module
extension OSCASGSceneDelegate {
  /// * hold a reference to `CoreModule`
  func initCoreModule() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    do {
      /// core module
      guard let delegate = UIApplication.shared.delegate,
            let appDelegate = delegate as? OSCASGBaseAppDelegate,
            let coreModule = appDelegate.coreModule else { throw OSCASGError.appInit(msg: "Core module") }
      self.coreModule = coreModule
      guard let _ = self.coreModule else { throw OSCASGError.appInit(msg: "Core module") }
    } catch {
      var err: OSCASGError?
      if let oscaSGError = error as? OSCASGError {
        err = oscaSGError
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "Core module: \(error.localizedDescription)")
        err = oscaSGError
      }// end if
      guard let oscaSGError = err else { return }
      let retryHandler = {[weak self] in
        guard let `self` = self,
              let windowScene = self.windowScene else { return }
        self.sceneInit(windowScene)
      }// end let
      handle(oscaSGError,
             retryHandler: retryHandler)
    }// end do catch
  }// end func initCoreModule
}// end extension class OSCASGSceneDelegate

// MARK: - app flow
extension OSCASGSceneDelegate {
  /// hold an `unowned` reference to `AppFlow`
  func initAppFlow() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    do {
      guard let delegate = UIApplication.shared.delegate,
            let appDelegate = delegate as? OSCASGBaseAppDelegate,
            let appFlow = appDelegate.appFlow else { throw OSCASGError.appInit(msg: "App flow") }
      self.solingenAppFlow = appFlow
    } catch {
      var err: OSCASGError?
      if let oscaSGError = error as? OSCASGError {
        err = oscaSGError
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "App flow: \(error.localizedDescription)")
        err = oscaSGError
      }// end if
      guard let oscaSGError = err else { return }
      let retryHandler = {[weak self] in
        guard let `self` = self,
              let windowScene = self.windowScene else { return }
        self.sceneInit(windowScene)
      }// end let
      handle(oscaSGError,
             retryHandler: retryHandler)
    }// end do catch
  }// end func initAppFlow
  
  func startAppFlow() throws {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let solingenAppFlow = solingenAppFlow else { throw OSCASGError.appInit(msg: "App Flow") }
    solingenAppFlow
      .present(animated: true,
               onDismissed: solingenAppFlowOnDismissed)
  }// end func startAppFlow
  
  func appFlowHandle(connectionOptions: UIScene.ConnectionOptions) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    do {
      /// handle connection options for Deeplinking
      let isHandled = try handle(connectionOptions: connectionOptions)
      if !isHandled {
        try startAppFlow()
      }// end
    } catch let error {
      let retryHandler: () -> Void = {[weak self] in
        guard let `self` = self else { return }
        self.appFlowHandle(connectionOptions: connectionOptions)
      }// end let retry handler
      
      if let oscaSGError = error as? OSCASGError {
        handle(oscaSGError,
               retryHandler: retryHandler)
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "unknown")
        handle(oscaSGError,
               retryHandler: retryHandler)
      }// end if
    }// end try catch
  }// end func appFlowHandle connectionOptions
  
  func appFlowHandle(openURLContexts urlContexts: Set<UIOpenURLContext>) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    do {
      /// handle connection options for Deeplinking
      let isHandled = try handle(openURLContexts: urlContexts)
      if !isHandled {
        try startAppFlow()
      }// end
    } catch let error {
      let retryHandler: () -> Void = {[weak self] in
        guard let `self` = self else { return }
        self.appFlowHandle(openURLContexts: urlContexts)
      }// end let retry handler
      
      if let oscaSGError = error as? OSCASGError {
        handle(oscaSGError,
               retryHandler: retryHandler)
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "unknown")
        handle(oscaSGError,
               retryHandler: retryHandler)
      }// end if
    }// end try catch
  }// end func appFlowHandle openURLContexts
  
  func appFlowHandle(continue userActivity: NSUserActivity) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    do {
      /// handle connection options for Deeplinking
      let isHandled = try handle(continue: userActivity)
      if !isHandled {
        try startAppFlow()
      }// end
    } catch let error {
      let retryHandler: () -> Void = {[weak self] in
        guard let `self` = self else { return }
        self.appFlowHandle(continue: userActivity)
      }// end let retry handler
      
      if let oscaSGError = error as? OSCASGError {
        handle(oscaSGError,
               retryHandler: retryHandler)
      } else {
        let oscaSGError = OSCASGError.appInit(msg: "unknown")
        handle(oscaSGError,
               retryHandler: retryHandler)
      }// end if
    }// end try catch
  }// end appFlowHandle user activity
}// end extension class OSCASGSceneDelegate
