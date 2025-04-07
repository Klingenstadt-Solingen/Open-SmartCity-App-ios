//
//  OSCASGBaseAppDelegate+Deeplinking.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 19.10.22.
//

import UIKit

extension OSCASGBaseAppDelegate {
  open func application(_: UIApplication,
                        open url: URL,
                        options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    //first launch after install
    // DeepLinkHandler.shared.handle(url: url)
    // url
    let deeplink = url.absoluteString
#if DEBUG
    print("Deeplink: \(deeplink)")
#endif
    #warning("TODO: deeplinking")
    return true
  } // end open func application open url options
  
  open func application(_: UIApplication,
                        open url: URL,
                        sourceApplication: String?,
                        annotation: Any) -> Bool {
    // first launch after install for older iOS versions
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    let deeplink = url.absoluteString
#if DEBUG
    print("Deeplink: \(deeplink)")
#endif
    #warning("TODO: deeplinking")
    return true
  }// end open func application open url source application annotation
  
  open func application(_ application: UIApplication,
                        continue userActivity: NSUserActivity,
                        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
#if DEBUG
    print("\(String(describing: Self.self)): \(#function)")
#endif
    #warning("TODO: deeplinking")
    return true
  }// end func application continue
}// end extension class OSCASGBaseAppDelegate
