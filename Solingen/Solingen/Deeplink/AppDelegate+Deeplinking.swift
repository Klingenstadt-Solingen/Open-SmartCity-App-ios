//
//  AppDelegate+Deeplinking.swift
//  Solingen
//
//  Created by Stephan Breidenbach on 13.09.22.
//

import UIKit

extension AppDelegate {
  override open func application(_ application: UIApplication,
                                 open url: URL,
                                 options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    //first launch after install
    // DeepLinkHandler.shared.handle(url: url)
    // url
    return super.application(application, open: url, options: options)
  } // end override func application open url options
  
  override open func application(_ application: UIApplication,
                                 open url: URL,
                                 sourceApplication: String?,
                                 annotation: Any) -> Bool {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    return super.application(application,
                             open: url,
                             sourceApplication: sourceApplication,
                             annotation: annotation)
  }// end override func application open url source application annotaion
  
  override open func application(_ application: UIApplication,
                                 continue userActivity: NSUserActivity,
                                 restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    return super.application(application,
                             continue: userActivity,
                             restorationHandler: restorationHandler)
  }// end override func application continue restoration handler
}// end extension class AppDelegate
