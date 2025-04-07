//
//  SettingsViewModel.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 20.06.22.
//

import OSCAMap
import OSCAPressReleases
import OSCAWaste
import OSCAWasteUI
import OSCAWeather
import Foundation
import OSCAEssentials
import Combine

struct SettingsViewModelActions {
  let showWeatherStations: () -> Void
  let showWasteAddressPicker: () -> Void
  let showImprint: (String, String) -> Void
  let showPrivacy: (String, String) -> Void
}

public enum SettingsViewModelError: Error, Equatable {
  case weatherObservedFetch
  case parseConfigFetch
  case parseInstallationSave
}

public enum SettingsViewModelState: Equatable {
  case loading
  case finishedLoading
  case error(SettingsViewModelError)
}

final class SettingsViewModel {
  private let actions: SettingsViewModelActions?
  private let settings: Settings
  let weatherModule: OSCAWeather
  private var bindings = Set<AnyCancellable>()
  
  private var sectionFooter: String? {

    let bundle = Bundle.main

    var installationId = ""
    var appIdentifier = ""
    var parseRootURL = ""
      
    var appShortVersion: String = ""
    var appVersion = settings.appVersion ?? "AppVersion"
    if bundle.bundleIdentifier != nil {
    appShortVersion = bundle.infoDictionary!["CFBundleShortVersionString"] as? String ?? "ShortVersion"
    } else
    if let bundle = OSCASolingen.bundle {
    appShortVersion = bundle.infoDictionary!["CFBundleShortVersionString"] as? String ?? "ShortVersion"
    }// end

    #if DEBUG

    installationId = settings.installationId ?? "InstallationId"
    appIdentifier = settings.appIdentifier ?? "AppIdentifier"
    parseRootURL = settings.parseRootURL ?? "ParseRootURL"

    #endif
    return """
               \(parseRootURL)
               \(appIdentifier)
               \(appShortVersion) (\(appVersion))
               \(installationId)
             """

      
  }// end private var sectionFooter
  
  
  var sectionTitles = ["Wetter", // section 0
                       "Abfall", // section 1
                       "Benachrichtigungen", // section 2
                       "Rechtliches"] // section 3

  var sectionFooters: [String?] = []
  
  let screenTitle = "Einstellungen"
  var wasteUserFullStreetAddress: String? {
    if let address = newWasteUserAddress,
       let streetAddress = address.streetAddress {
      return "\(streetAddress) \(address.houseNumber ?? "")"
    }
    else { return nil }
  }
  var newWasteUserAddress: OSCAWasteAddress? = nil
  
  @Published var state: SettingsViewModelState = .loading
  @Published var currentUserWeatherStation: String? = nil
  @Published var currentWasteUserAddress: OSCAWasteAddress? = nil
  @Published var constructionSitesIsEnabled: Bool = false
  @Published var pressReleasesIsEnabled: Bool = false
  @Published var wasteIsEnabled: Bool = false
  @Published var wasteDashboardIsEnabled: Bool = false
  /* Disabled module Corona
  @Published var coronaStatsIsEnabled: Bool
   */
  
  /// inject view model actions
  init(actions: SettingsViewModelActions,
       settings: Settings,
       weatherModule: OSCAWeather) {
#if DEBUG
    print("\(Self.self): \(#function)")
#endif
    self.actions = actions
    self.settings    = settings
    self.weatherModule = weatherModule
    sectionFooters =
    ["Lege hier deine Wetterstation für den Startbildschirm fest", // section 0
     "Lege hier deine Adresse für den Abfallmanager fest", // section 1
     nil, // section 2
     sectionFooter]// section 3
  } // end init
  
  // MARK: - Private
  
  @objc private func updateUserWeatherStation() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    guard let id = self.weatherModule.userDefaults.getOSCAWeatherObserved()
    else { return }
    
    self.getWeatherObserved(for: id)
  }
  
  @objc private func updateUserWasteAddress() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    newWasteUserAddress = try? self.settings.getWasteUserAddress()
    
    if currentWasteUserAddress != newWasteUserAddress {
      currentWasteUserAddress = newWasteUserAddress
    }
  }
  
  @objc private func updateMapConstructionSitesPush() {
    self.constructionSitesIsEnabled = self.isMapConstructionSitesEnabled
  }
  
  @objc private func updatePressReleasesPush() {
    self.pressReleasesIsEnabled = self.isPressReleasesEnabled
  }
  
  @objc private func updateWasteReminder() {
    self.wasteIsEnabled = self.isWasteReminding
  }
  
  private func getWeatherObserved(for id: String) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.state = .loading
    let query = ["where":"{\"objectId\":\"\(id)\"}"]
    self.weatherModule
      .getWeatherObserved(query: query)
      .sink { completion in
        switch completion {
        case .finished:
          self.state = .finishedLoading
          
        case .failure:
          self.state = .error(.weatherObservedFetch)
        }
      } receiveValue: { results in
        switch results {
        case let .success(weatherObserved):
          guard let weatherObserved = weatherObserved.first else {
            self.state = .error(.weatherObservedFetch)
            return
          }
          
          if let shortName = weatherObserved.shortName {
            self.currentUserWeatherStation = shortName
          } else if let name = weatherObserved.name {
            self.currentUserWeatherStation = name
          }
          
        case .failure:
          self.state = .error(.weatherObservedFetch)
        }
      }
      .store(in: &bindings)
  }
  
  private func fetchParseConfigParams(index: Int) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    state = .loading
    
    self.settings
      .getParseConfigParams()
      .sink { completion in
        switch completion {
        case .finished:
          self.state = .finishedLoading
          
        case .failure:
          self.state = .error(.parseConfigFetch)
        }
      } receiveValue: { config in
        switch index {
        case 0:
          guard let privacyText = config.privacyText
          else {
            self.state = .error(.parseConfigFetch)
            return
          }
          self.actions?.showPrivacy("Datenschutz", privacyText)
          
        case 1:
          guard let imprintText = config.imprintText
          else {
            self.state = .error(.parseConfigFetch)
            return
          }
          self.actions?.showImprint("Impressum", imprintText)
          
        default: return
        }
        
      }
      .store(in: &self.bindings)
  }
  
}

// MARK: - Data access Push
extension SettingsViewModel {
  var isMapConstructionSitesEnabled: Bool {
    self.settings.userDefaults.isOSCAMapConstructionSitesPushingNotification()
  }
  
  func setMapConstructionSitesPush(notification isPushing: Bool) {
    self.settings.userDefaults.setOSCAMapConstructionSitesPush(notification: isPushing)
  }
  
  var isPressReleasesEnabled: Bool {
    self.settings.userDefaults.isOSCAPressReleasesPushingNotification()
  }
  
  func setPressReleasesPush(notification isPushing: Bool) {
    self.settings.userDefaults.setOSCAPressReleasesPush(notification: isPushing)
  }
  
  var isWasteReminding: Bool {
    self.settings.userDefaults.getOSCAWasteReminder()
  }
  
  func setWasteReminder(notification isPushing: Bool) {
    self.settings.userDefaults.setOSCAWasteReminder(isPushing)
  }
    
    var isWasteDashboardEnabled: Bool {
      return self.settings.userDefaults.getOSCAWasteDashboardEnabled()
    }
    
    func setWasteDashboardEnabled(_ enabled: Bool) {
        self.settings.userDefaults.setOSCAWasteDashboardEnabled(enabled)
    }
}

// MARK: - View Model Input

extension SettingsViewModel {
  /// Module Navigation view lifecycle method
  func viewDidLoad() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.updateUserWasteAddress),
      name: .userWasteAddressDidChange,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.updateWasteReminder),
      name: .wasteReminderDidChange,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.updateUserWeatherStation),
      name: .userWeatherStationDidChange,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.updatePressReleasesPush),
      name: .pressReleasesPushDidChange,
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.updateMapConstructionSitesPush),
      name: .mapConstructionSitesPushDidChange,
      object: nil)
    
    self.wasteIsEnabled = self.isWasteReminding
    self.pressReleasesIsEnabled = self.isPressReleasesEnabled
    self.constructionSitesIsEnabled = self.isMapConstructionSitesEnabled
  } // end func viewDidLoad
  
  /// Module Navigation view lifecycle method
  func viewWillAppear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    updateUserWeatherStation()
    updateUserWasteAddress()
  } // end func viewWillAppear
  
  /// Module Navigation view lifecycle method
  func viewWillDisappear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  } // end func viewWillDisappear
  
  /// Module Navigation view lifecycle method
  func viewDidDisappear() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
  } // end func viewDidDisappear
  
  func didSelectItem(at indexPath: IndexPath) {
    switch indexPath.section {
    case 0: // section weather
      switch indexPath.row {
      case 0: showWeatherStations()
      default: break
      }
    case 1: // section my waste address
      switch indexPath.row {
      case 0: showWasteAddressPicker()
      default: break
      }
    case 2: // section push
      break
    case 3: // section legal stuff
      switch indexPath.row {
      case 0: showPrivacy(index: 0)
      case 1: showImprint(index: 1)
      default: break
      }
      #if DEBUG
    case 4: // developer options
      break
      #endif
    default: break
    }
  }
  
  func showWeatherStations() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    actions?.showWeatherStations()
  }
  
  func showWasteAddressPicker() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    actions?.showWasteAddressPicker()
  }
  
  func showImprint(index: Int) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.fetchParseConfigParams(index: index)
  }
  
  func showPrivacy(index: Int) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    self.fetchParseConfigParams(index: index)
  }
}
