//
//  CityViewModel.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 17.06.22.
//  Reviewed by Stephan Breidenbach on 19.09.2022.
//

import Combine
import CoreLocation
import Foundation
import OSCAMap
import OSCAPressReleases
import OSCAWeather
import OSCAEssentials
import OSCANetworkService
import OSCADistrict

struct CityViewModelActions {
  let showWeatherScene: (String) -> Void
  let showWeatherSceneWithURL: (URL) -> Void
  let showWeatherListScene: () -> Void
  let showWeatherDetailScene: (String) -> Void
  let showDistrictScene: (URL?) -> Void
  let showMapScene: () -> Void
  let showMapSceneWithURL: (URL) -> Void
  let showPressReleaseScene: () -> Void
  let showPressReleaseDetailScene: (OSCAPressRelease, OSCAPressReleases) -> Void
  let showPressReleasesWidget: () -> Void
  let makeWasteWidget: () -> Void
  let showServicesScene: () -> Void
  let showServicesDetailScene: () -> Void
  let showTownhallScene: () -> Void
  let showTownhallDetailScene: () -> Void
  let navigateToTownhallMenu: (TownhallMenu /* , Data? */ ) -> Void
  let navigateToServiceMenu: (ServiceMenu  /* , Data? */ ) -> Void
  let showEnvironmentScene: () -> Void
} // end struct CityViewModelActions

public enum CityViewModelError: Error, Equatable {
  case townhallMenuItemsFetch
  case serviceMenuItemsFetch
  case pressReleasesFetch
  case weatherStationsFetch
  case poisFetch
  case noDefaultLocation
} // end public enum CityViewModelError

public enum CityViewModelState: Equatable {
  case loading
  case finishedLoading
  case error(CityViewModelError)
} // end public enum CityViewModelState

final class CityViewModel {
  private let actions: CityViewModelActions?
  var deeplinkURL: URL?
  private let deeplinkPrefixes: [String]
  public let deeplinkScheme: String
  let pressReleasesModule: OSCAPressReleases
  let weatherModule: OSCAWeather
  let mapModule: OSCAMap
  let oscaTownhallMenu: OSCATownhallMenu
  let oscaServiceMenu: OSCAServiceMenu
  private var bindings: Set<AnyCancellable> = []
  let imageDataCache = NSCache<NSString, NSData>()
  var defaultLocation: OSCAGeoPoint? { mapModule.defaultGeoPoint }
  let networkConfig: OSCANetworkConfiguration
  
  
  @Published private(set) var state: CityViewModelState = .loading
  @Published private(set) var dateString: String = ""
  @Published private(set) var pressReleases: [OSCAPressRelease] = []
  @Published private(set) var townhallMenuItems: [TownhallMenu] = []
  @Published private(set) var serviceMenuItems: [ServiceMenu] = []
  @Published private(set) var weatherStations: [OSCAWeatherObserved] = []
  @Published private(set) var pois: [OSCAPoi] = []
  @Published private(set) var districtWidgetButtonText: String = NSLocalizedString("SHOW_ALL_BUTTON",
                                                                                 bundle: OSCASolingen.bundle,
                                                                                 comment: "Show all button")
  
  enum ServicesSection {
    case servicesMenu
  }
  
  enum TownhallSection {
    case townhallMenu
  }
  
  enum PressReleasesSection {
    case pressReleaseItems
  }
  
  enum WeatherSection {
    case weatherStation
  }
  
  enum WasteSection {
    case waste
  }
  
  let alertTitleError: String = NSLocalizedString(
    "error_alert_title_error",
    bundle: OSCASolingen.bundle,
    comment: "The alert title for an error")
  let alertActionConfirm: String = NSLocalizedString(
    "error_alert_title_confirm",
    bundle: OSCASolingen.bundle,
    comment: "The alert action title to confirm")
  
    var sections: [CityViewModel.Section] = [.events,
                                            .district,
                                           .environment,
                                           .weather,
                                           .waste,
                                           .map,
                                           .townhall,
                                           .services,
                                           .pressReleases]
  
  let screenTitle = "Klingenstadt Solingen"
  
  /// inject view model actions
  init(dependencies: CityViewModel.Dependencies, networkConfig: OSCANetworkConfiguration) {
#if DEBUG
    print("\(Self.self): \(#function)")
#endif
    self.actions = dependencies.actions
    self.pressReleasesModule = dependencies.pressReleasesModule
    self.oscaTownhallMenu = dependencies.oscaTownhallMenu
    self.oscaServiceMenu = dependencies.oscaServiceMenu
    self.mapModule = dependencies.mapModule
    self.weatherModule = dependencies.weatherModule
    self.deeplinkPrefixes = dependencies.deeplinkPrefixes
    self.deeplinkScheme = dependencies.deeplinkScheme
    self.networkConfig = networkConfig
  } // end init
  
  // MARK: - Private
  @objc private func updateUserWeatherStation() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    updateWeatherStationCells(weatherStations)
  }
  
  private func updateWeatherStationCells(_ stations: [OSCAWeatherObserved]) {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    var weatherStations = stations
    if let id = weatherModule.userDefaults.getOSCAWeatherObserved() {
      let index = stations.firstIndex {
        guard let objectId = $0.objectId else { return false }
        return objectId == id
      }
      if let index = index {
        let station = weatherStations.remove(at: index)
        weatherStations.insert(station, at: 0)
        self.weatherStations = weatherStations
      }
    } else {
      self.weatherStations = stations
    }
  }
} // end final class CityViewModel

// MARK: - View Model dependencies
extension CityViewModel {
  public struct Dependencies {
    var actions: CityViewModelActions
    var pressReleasesModule: OSCAPressReleases
    var weatherModule: OSCAWeather
    var mapModule: OSCAMap
    var oscaTownhallMenu: OSCATownhallMenu
    var oscaServiceMenu: OSCAServiceMenu
    var deeplinkPrefixes: [String]
    var deeplinkScheme: String
  }// end public struct Dependencies
}// end extension final class CityViewModel

// MARK: - View Model Input lifecycle

extension CityViewModel {
  public enum Section: String, CaseIterable {
    case weather = "Wetter in Solingen"
    case waste = "Nächste Termine"
    case district = "Stadtteile in Solingen"
      case events = "Großveranstaltungen"
    case map = "Interessante Orte"
    case townhall =  "Digitales Rathaus"
    case services =  "Services"
    case pressReleases = "Nachrichten"
    case unknown = ""
    case environment = "Umwelt in Solingen"
    
    @_transparent var tag: Int { Self.allCases.firstIndex(of: self)! }
    
    static func from(tag index: Int) -> Section {
      guard index >= 0, index < allCases.count else {
        return .unknown
      }
      return allCases[index]
    }
  }
}

extension CityViewModel {
  /// Module Navigation view lifecycle method
  func viewDidLoad() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateUserWeatherStation),
      name: .userWeatherStationDidChange,
      object: nil)
    
    self.setupWidgets()
    
    fetchPressReleases()
    fetchTownhallMenuItems()
    fetchServiceMenuItems()
    fetchWeatherStations()
    fetchPOIs()
  } // end func viewDidLoad
  
  /// Module Navigation view lifecycle method
  func viewWillAppear() {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, d. MMMM YYYY"
    dateString = dateFormatter.string(from: Date())
    
    updateWeatherStationCells(weatherStations)
  } // end func viewWillAppear
  
  /// Module Navigation view lifecycle method
  func viewWillDisappear() {
  } // end func viewWillDisappear
  
  /// Module Navigation view lifecycle method
  func viewDidDisappear() {
  } // end func viewDidDisappear
  
  /// City scene weather show all callback method
  /// * navigation: show weather stations
  func showWeatherTouch() {
#if DEBUG
    print("\(String(describing: self)): \(#function)")
#endif
    actions?.showWeatherListScene()
  } // end func showWeatherTouch
  
  /// City scene weather detail callback method
  /// * navigation: show weather stations
  func showWeatherDetailTouch() {
#warning("Not in use!")
    //    actions?.showWeatherDetailScene()
  } // end func showWeatherDetailTouch
    func showDistrictTouch() {
        actions?.showDistrictScene(nil)
    }

  /// City scene map module callback method
  /// * navigation: show map module
  func showMapTouch() {
    actions?.showMapScene()
  } // end func showMapTouch
  
  /// City scene press releases module callback method
  /// * navigation: show press releases overview
  func showPressReleasesTouch() {
    actions?.showPressReleaseScene()
  } // end func showPressReleasesTouch
  
  /// City scene services callback method
  /// * navigation: show services overview
  func showServicesTouch() {
    actions?.showServicesScene()
  } // end func showServicesTouch
  
  /// City scene services detail callback method
  /// * navigation: route directly to destination
  func showServicesDetailTouch() {
    actions?.showServicesDetailScene()
  } // end func showServicesDetailTouch
  
  func showTownhallTouch() {
    actions?.showTownhallScene()
  }// end func showTownhallTouch
  
  func showTownhallDetailTouch() {
    actions?.showTownhallDetailScene()
  }// end func showServicesDetailTouch
    
    func showEnvironmentTouch() {
        actions?.showEnvironmentScene()
    }
    
    func setDistrictWidgetButtonText(text: String){
        self.districtWidgetButtonText = text
    }
} // end extension final class CityViewModel

// MARK: - Widgets
extension CityViewModel {
  func setupWidgets() {
    self.actions?.makeWasteWidget()
  }
}

// MARK: - data access

extension CityViewModel {
  func fetchPressReleases() {
    state = .loading
    pressReleasesModule
      .getPressReleases()
      .sink { subscribers in
        switch subscribers {
        case .finished:
          self.state = .finishedLoading
        case .failure:
          self.state = .error(.pressReleasesFetch)
        }
      } receiveValue: { result in
        switch result {
        case let .success(pressReleases):
          self.pressReleases = pressReleases.sorted(by: { first, next in
            guard let firstDate = first.date, let nextDate = next.date else { return false }
            return firstDate > nextDate
          })
        case .failure:
          if self.state != .error(.pressReleasesFetch) {
            self.state = .error(.pressReleasesFetch)
          }
        }
      }
      .store(in: &bindings)
  } // end func fetchPressReleases
  
  func fetchTownhallMenuItems() {
    state = .loading
    oscaTownhallMenu
      .fetchAllTownhallMenu()
      .map {
        $0.filter({ $0.enabled == true })
      }
      .map {
        $0.sorted(by: { $0.position ?? 99 < $1.position ?? 99 })
      }
      .sink { subscribers in
        switch subscribers {
        case .finished:
          self.state = .finishedLoading
        case .failure:
          if self.state != .error(.townhallMenuItemsFetch) {
            self.state = .error(.townhallMenuItemsFetch)
          }
        }
      } receiveValue: { menuItems in
        self.townhallMenuItems = menuItems
      }
      .store(in: &bindings)
  } // end func fetchTownhallMenuItems
  
  func fetchServiceMenuItems() {
    state = .loading
    oscaServiceMenu
      .fetchAllServiceMenu()
    //.dropFirst()
      .map {
        $0.filter({ $0.enabled == true })
      }
      .map {
        $0.sorted(by: { $0.position ?? 99 < $1.position ?? 99 })
      }
      .sink { subscribers in
        switch subscribers {
        case .finished:
          self.state = .finishedLoading
        case .failure:
          if self.state != .error(.serviceMenuItemsFetch) {
            self.state = .error(.serviceMenuItemsFetch)
          }
        }
      } receiveValue: { menuItems in
        self.serviceMenuItems = menuItems
      }
      .store(in: &bindings)
    
  } // end func fetchTownhallMenuItems
  
  func fetchWeatherStations() {
    if state != .loading { state = .loading }
    var query: [String: String]
    if let location = CLLocationManager().location {
      query = OSCAWeather.query(with: OSCAGeoPoint(location))
    } else {
      query = OSCAWeather.query(with: defaultLocation)
    }// end if
    weatherModule
      .getWeatherObserved(query: query)
      .sink { subscribers in
        switch subscribers {
        case .finished:
          self.state = .finishedLoading
        case .failure:
          self.state = .error(.weatherStationsFetch)
        }
      } receiveValue: { result in
        switch result {
        case let .success(stations):
          self.updateWeatherStationCells(stations)
          self.selectItem(with: self.deeplinkURL)
        case .failure:
          self.state = .error(.weatherStationsFetch)
        }
      }
      .store(in: &bindings)
  } // end func fetchWeatherStations
  
  func fetchPOIs() {
    var publisher: OSCAMap.OSCAMapPublisher
    let locationManager = CLLocationManager()
    
    if let location = OSCAGeoPoint(clLocation: locationManager.location) {
      publisher = mapModule.fetchNearbyPois(geoPoint: location,
                                            distance: 1000,
                                            random: true,
                                            limit: 10)
    } else {
      publisher = mapModule.fetchNearbyPois(geoPoint: defaultLocation,
                                            distance: 1000,
                                            random: true,
                                            limit: 10)
    }
    publisher
      .sink { subscribers in
        switch subscribers {
        case .finished:
          self.state = .finishedLoading
        case .failure:
          self.state = .error(.poisFetch)
        }
      } receiveValue: { pois in
        self.pois = pois
        print("SET \(self.pois.count) POIS ON home screen")
        self.selectItem(with: self.deeplinkURL)
      }
      .store(in: &bindings)
  } // end func fetchPOIs
  
  func getImageData(from urlString: String) -> AnyPublisher<Data, OSCAMapError>? {
    guard let url = URL(string: urlString) else { return nil }
    
    let pubisher: AnyPublisher<Data, OSCAMapError> = mapModule.fetchImageData(url: url)
    return pubisher
  } // end func getImageData
  
  func getImageDataFromCache(with urlString: String) -> Data? {
    let imageData = imageDataCache.object(forKey: NSString(string: urlString))
    return imageData as Data?
  } // end func getImageDataFromCache
  
  func getIconUrl(for poi: OSCAPoi) -> String {
    if let defaultThematicView = poi.poiCategoryObject?.defaultThematicView {
      print("found defaultThematicView: \(defaultThematicView)")
      if let detail = poi.details?.first(where: { $0?.filterField == defaultThematicView }) {
        print("found detail for defaultThematicView: \(detail?.title ?? "")")
        if var path = detail?.symbolPath, let symbolName = detail?.symbolName, let mimeType = detail?.symbolMimetype {
          if path.last == "/" {
            path.removeLast()
          }
          print("path to image: \(path)/\(symbolName)\(mimeType)")
          return "\(path)/\(symbolName)\(mimeType)"
        }
      }
    }
    
    guard var path = poi.poiCategoryObject?.symbolPath,
          let symbolName = poi.poiCategoryObject?.symbolName,
          let mimeType = poi.poiCategoryObject?.symbolMimetype
    else { return "" }
    
    if path.last == "/" {
      path.removeLast()
    }
    
    print("path to image: \(path)/\(symbolName)\(mimeType)")
    return "\(path)/\(symbolName)\(mimeType)"
  } // end func getIconUrl
} // end extension final class CityViewModel

// MARK: - View Model Input

extension CityViewModel {
  func didSelectServiceItem(at index: Int) {
    guard index < serviceMenuItems.count else { return }
    //    let imageData = imageDataCache.object(forKey: NSString(string: objectId)) as Data?
    actions?.navigateToServiceMenu(serviceMenuItems[index] /* , imageData */ )
  }// end func didSelectServiceItem
  
  func didSelectTownhallItem(at index: Int) {
    guard index < townhallMenuItems.count else { return }
    //    let imageData = imageDataCache.object(forKey: NSString(string: objectId)) as Data?
    actions?.navigateToTownhallMenu(townhallMenuItems[index] /* , imageData */ )
  } // end func didSelectTownhallItem
  
  func didSelectPressReleaseItem(at index: Int) {
    guard index < pressReleases.count,
          let objectId = pressReleases[index].objectId else { return }
    let imageData = imageDataCache.object(forKey: NSString(string: objectId)) as Data?
    actions?.showPressReleaseDetailScene(pressReleases[index], pressReleasesModule)
  } // end func didSelectPressReleaseItem
  
  func didSelectWeatherItem(at index: Int) {
    guard index < weatherStations.count,
          let objectId = weatherStations[index].objectId else { return }
    actions?.showWeatherDetailScene(objectId)
  } // end func didSelectWeatherItem
  
  /// pull to refresh event
  func callPullToRefresh() {
    fetchPressReleases()
    fetchTownhallMenuItems()
    fetchServiceMenuItems()
    fetchWeatherStations()
    fetchPOIs()
  }// end func callPullToRefresh
} // end extension final class CityViewModel

// MARK: - Deeplinking

extension CityViewModel {
  func didReceiveDeeplink(with url: URL) {
    guard !url.absoluteString.isEmpty else { return }
    deeplinkURL = url
    selectItem(with: url)
  } // end func didReceiveDeeplinkDetail
  
  private func selectItem(with url: URL?) {
      // redirect defined deeplinks to district
      if let url = url, let prefix = OSCADistrictSettings.shared.deeplinkPrefixes.first(where: { url.absoluteString.hasPrefix($0) }) {
          actions?.showDistrictScene(url)
          return
      }
      
    guard let url = url,
          let prefix = deeplinkPrefixes.first(where: { url.absoluteString.hasPrefix($0) }),
          let deeplinkScheme = url.scheme
    else { return }
    switch prefix {
    case "\(deeplinkScheme)://home":
      deeplinkURL = nil
      return
    case "\(deeplinkScheme)://poi":
      /* guard !pois.isEmpty
       else { return } */
      actions?.showMapSceneWithURL(url)
    case "\(deeplinkScheme)://sensorstation":
      /* guard !weatherStations.isEmpty
       else { return } */
      actions?.showWeatherSceneWithURL(url)
    default:
      deeplinkURL = nil
      return
    } // end switch case
    deeplinkURL = nil
  } // end private func selectItem with url
} // end extension final class CityViewModel
