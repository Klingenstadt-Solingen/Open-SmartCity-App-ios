//
//  OSCASGBaseAppDelegate+StateRestauration.swift
//  OSCASolingen
//
//  Created by Stephan Breidenbach on 25.10.22.
//

import UIKit
import CoreData

// MARK: - State restauration
extension OSCASGBaseAppDelegate {
  /// Asks the delegate whether to securely preserve the App's state
  /// - Parameter application: singleton app object
  /// - Parameter coder: A keyed archiver containing the app's previously saved state. The coder's requiresSecureCoding property is set to true, and any objects you decode must adopt NSSecureCoding
  open dynamic func application(_ application: UIApplication,
                          shouldSaveSecureApplicationState coder: NSCoder) -> Bool {
    let requiresSecureCoding = coder.requiresSecureCoding
#if DEBUG
    print("\(String(describing: Self.self)): \(#function): requires secure coding: \(requiresSecureCoding ? "true" : "false")")
#endif
    #warning("TODO: implementation state restauration")
    return true
  }// end public func application should save secure application state
  
  /// Asks the delegate whether to restore the app's saved state
  /// - Parameter application: singleton app object
  ///
  open dynamic func application(_ application: UIApplication,
                          shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
    let requiresSecureCoding = coder.requiresSecureCoding
#if DEBUG
    print("\(String(describing: Self.self)): \(#function): requires secure coding: \(requiresSecureCoding ? "true" : "false")")
#endif
    #warning("TODO: implementation state restauration")
    return true
  }// end public func application should restore secure application state
  
  // MARK: - Core Data Saving support
  
  func saveContext() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
#warning("TODO: fatalError")
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  } // end func saveContext
}// end extension class OSCASGAppDelegate
