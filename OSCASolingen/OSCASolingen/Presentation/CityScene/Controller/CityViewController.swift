//
//  CityViewControllerTest.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 21.06.22.
//  Reviewed by Stephan Breidenbach on 29.08.2022
//  Reviewed by Stephan Breidenbach on 16.02.2023
//

import Combine
import CoreLocation
import MapKit
import OSCAEssentials
import OSCAMap
import OSCAMapUI
import OSCAPressReleases
import OSCAPressReleasesUI
import OSCAWeather
import OSCAWaste
import OSCAWasteUI
import UIKit
import OSCAEnvironmentUI
import OSCADistrict

final class CityViewController: UIViewController {
  /// handle to the activity indicator
  public var activityIndicatorView: ActivityIndicatorView = ActivityIndicatorView(style: .large)
  
  /// bottom tab bar controller
  private var homeTabRootViewController: HomeTabRootViewController!
  /// Waste widget
  var wasteWidgetViewController: OSCAWasteAppointmentViewControllerWidget? {
    didSet {
      guard let widgetVC = self.wasteWidgetViewController,
            let widget = self.wasteWidgetViewController?.view,
            let section = self.viewModel.sections.first(where: { $0 == .waste })
      else { return }
      
      widgetVC.collectionView.layer.masksToBounds = false
      
//      self.addChild(widgetVC)
      
      let heading = self.getHeading(
        title: section.rawValue,
        tag: section.tag)
      
      self.wasteWidget.isHidden = !UserDefaults.standard
            .getOSCAWasteDashboardEnabled()
      self.wasteWidget.addArrangedSubview(heading)
      self.wasteWidget.addArrangedSubview(widget)
      
      widget.heightAnchor.constraint(equalToConstant: 200 + 8)
        .isActive = true
      VStack.insertArrangedSubview(self.wasteWidget, at: 5)
//      widgetVC.didMove(toParent: self)
      let spacer = UIView()
      spacer.backgroundColor = .clear
      spacer.heightAnchor.constraint(equalToConstant: 16)
        .isActive = true
      VStack.insertArrangedSubview(spacer, at: 6)
    }
  }
  /// handle to the view model
  private var viewModel: CityViewModel!
  /// handle to the cancellable bindings
  private var bindings = Set<AnyCancellable>()
  
  let locationManager = CLLocationManager()
  var currentLocation: CLLocation?
  
  var cityImageViewHeightConstraint: NSLayoutConstraint?
  /// The original heigt of the headerContainer
  var originalHeight: CGFloat!
  /// Maximum height for the headerContainer
  var headerViewMaxHeight: CGFloat = 0
  /// Minimum height for the headerContainer
  var headerViewMinHeight: CGFloat = 0
  
  private lazy var statusBarBackgroundView: UIView = {
    let style: UIBlurEffect.Style
    style = UITraitCollection.current.userInterfaceStyle == .light
      ? .light
      : .dark
    let effect = UIBlurEffect(style: style)
    let view = UIVisualEffectView(effect: effect)
    let window = self.parent?.view.window?.windowScene?.keyWindow
    let height = window?.safeAreaInsets.top ?? 0
    view.heightAnchor.constraint(equalToConstant: height)
      .isActive = true
    return view
  }()
  
  let scrollView = UIScrollView()
  lazy var VStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.alignment = .fill
    stack.distribution = .equalSpacing
    stack.spacing = 8
    return stack
  }()
  
  lazy var cityImageContainerView: UIView = {
    let container = UIView()
    
    container.backgroundColor = .systemBackground
    container.layer.cornerRadius = 10
    
    container.addShadow(with: OSCAShadowSettings(
      opacity: 0.2,
      radius: 10,
      offset: CGSize(width: 0, height: 2)))
    
    return container
  }()
  
  lazy var cityImageView: UIImageView = {
    
    let placeholderImage = UIImage(named: "header_image.jpg",
                                   in: OSCASolingen.bundle,
                                   with: .none)
    
    let image: UIImage?
    if let headerImage = placeholderImage {
      image = headerImage
      
    } else if let placeholderImage = placeholderImage {
      image = placeholderImage
      
    } else {
      image = UIImage.placeholder
    }
    
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 17)
    label.textColor = .white.darker(componentDelta: 0.2)
    return label
  }()
  
  lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = viewModel.screenTitle
    label.font = .systemFont(ofSize: 36, weight: .semibold)
    label.textColor = .white.darker()
    return label
  }()
    
    lazy var districtButton: UIButton = {
      let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        button.setTitleColor(.primary, for: .normal)
        button.sizeToFit()
        button.addTarget(self, action: #selector(moreButtonTouched(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
  
  lazy var wasteWidget: UIStackView = {
    let containerStack = UIStackView()
    containerStack.axis = .vertical
    containerStack.distribution = .fill
    containerStack.alignment = .fill
    containerStack.spacing = 8
    return containerStack
  }()

  // MARK: - Data sources
  // Townhall data source
  private typealias TownhallDataSource = UICollectionViewDiffableDataSource<CityViewModel.TownhallSection, TownhallMenu>
  private typealias TownhallSnapshot = NSDiffableDataSourceSnapshot<CityViewModel.TownhallSection, TownhallMenu>
  private var townhallDataSource: TownhallDataSource!
  // Service data source
  private typealias ServiceDataSource = UICollectionViewDiffableDataSource<CityViewModel.ServicesSection, ServiceMenu>
  private typealias ServiceSnapshot = NSDiffableDataSourceSnapshot<CityViewModel.ServicesSection, ServiceMenu>
  private var serviceDataSource: ServiceDataSource!
  // Press release data source
  private typealias PressReleasesDataSource = UICollectionViewDiffableDataSource<CityViewModel.PressReleasesSection, OSCAPressRelease>
  private typealias PressReleasesSnapshot = NSDiffableDataSourceSnapshot<CityViewModel.PressReleasesSection, OSCAPressRelease>
  private var pressReleaseDataSource: PressReleasesDataSource!
  // weather data source
  private typealias WeatherDataSource = UICollectionViewDiffableDataSource<CityViewModel.WeatherSection, OSCAWeatherObserved>
  private typealias WeatherSnapshot = NSDiffableDataSourceSnapshot<CityViewModel.WeatherSection, OSCAWeatherObserved>
  private var weatherDataSource: WeatherDataSource!

  private var mapView: MKMapView?
    
  private var districtWidgetController:OSCADistrictWidgetViewController? = nil
  
  lazy var townhallCollectionView: UICollectionView = {
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200), collectionViewLayout: layout)
    collectionView.tag = CityViewModel.Section.townhall.tag
    let bundle = OSCASolingen.bundle
    collectionView.register(UINib(nibName: "TownhallCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: "townhallCell")
    
    collectionView.isScrollEnabled = false
    collectionView.clipsToBounds = false
    
    return collectionView
  }()
  
  lazy var serviceCollectionView: UICollectionView = {
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300),
                                          collectionViewLayout: layout)
    collectionView.tag = CityViewModel.Section.services.tag
    let bundle = OSCASolingen.bundle
    collectionView.register(UINib(nibName: "ServiceCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: "serviceCell")
    collectionView.isScrollEnabled = false
    collectionView.clipsToBounds = false
    
    return collectionView
  }()
  
  lazy var pressReleaseCollectionView: UICollectionView = {
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200), collectionViewLayout: layout)
    collectionView.tag = CityViewModel.Section.pressReleases.tag
    
    collectionView.register(UINib(nibName: "OSCAPressReleasesMainCollectionViewCell", bundle: OSCAPressReleasesUI.bundle), forCellWithReuseIdentifier: OSCAPressReleasesMainCollectionViewCell.identifier)
    
    collectionView.isScrollEnabled = false
    collectionView.clipsToBounds = false
    
    return collectionView
  }()
  
  lazy var weatherCollectionView: UICollectionView = {
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 180), collectionViewLayout: layout)
    collectionView.tag = CityViewModel.Section.weather.tag
    let bundle = OSCASolingen.bundle
    collectionView.register(UINib(nibName: "CityWeatherCollectionViewCell", bundle: bundle), forCellWithReuseIdentifier: CityWeatherCollectionViewCell.identifier)
    
    collectionView.isScrollEnabled = false
    collectionView.clipsToBounds = false
    
    return collectionView
  }()
    
  var townhallCollectionViewHeight: CGFloat = 0.0
  var serviceCollectionViewHeight: NSLayoutConstraint?
  
  var pressReleasesCollectionViewHeight: NSLayoutConstraint?
  var weatherCollectionViewHeight: CGFloat = 0.0
  // MARK: - bind to view model
  /// module navigation view controller bind to view model method
  private func bind(to viewModel: CityViewModel) {
    
    self.viewModel.$dateString
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] dateString in
        guard let `self` = self else { return }
        self.dateLabel.text = dateString
      })
      .store(in: &bindings)
    
    self.viewModel.$townhallMenuItems
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] menuItems in
        guard let `self` = self else { return }
        self.updateTownhallSections(menuItems)
      })
      .store(in: &bindings)
    
    self.viewModel.$serviceMenuItems
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] menuItems in
        guard let `self` = self else { return }
        self.updateServiceSections(menuItems)
      })
      .store(in: &bindings)
    
    self.viewModel.$pressReleases
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] pressReleases in
        guard let `self` = self else { return }
        self.updatePressReleasesSections(pressReleases)
      })
      .store(in: &bindings)
    
    self.viewModel.$weatherStations
      .sink(receiveValue: { [weak self] stations in
        guard let `self` = self else { return }
        self.updateWeatherSections(stations)
      })
      .store(in: &bindings)
    
    self.viewModel.$pois
      .sink(receiveValue: { [weak self] pois in
        guard let `self` = self else { return }
        DispatchQueue.main.async {
          self.updateMap(with: pois)
        }
      })
      .store(in: &bindings)
      
    self.viewModel.$districtWidgetButtonText
        .receive(on: RunLoop.main)
        .sink(receiveValue: { [weak self] districtString in
          guard let `self` = self else { return }
            self.districtButton.setTitle(districtString, for: .normal)
        })
        .store(in: &bindings)
  
    let stateValueHandler: (CityViewModelState) -> Void = { [weak self] state in
      guard let `self` = self else { return }
      switch state {
      case .loading: // start loading
        self.beginLoading()
      case .finishedLoading: // finished loading
        self.finishLoading()
      case let .error(error): // error
        self.finishLoading()
        switch error {
        case .pressReleasesFetch,
            .serviceMenuItemsFetch,
            .townhallMenuItemsFetch,
            .weatherStationsFetch:
          self.showAlert(
            title: self.viewModel.alertTitleError,
            message: error.localizedDescription,
            actionTitle: self.viewModel.alertActionConfirm)
        default:
          #warning("poi nearby cloud function error!!!")
          return
        }// end switch case
      }// end switch case
    }// end stateValueHandler
    
    viewModel.$state
      .receive(on: RunLoop.main)
      .removeDuplicates()
      .sink(receiveValue: stateValueHandler)
      .store(in: &bindings)
  } // end private func bind to view model
  
  private func beginLoading() -> Void {
    self.scrollView.isUserInteractionEnabled = false
    self.mapView?.isUserInteractionEnabled = false
    self.townhallCollectionView.isUserInteractionEnabled = false
    self.serviceCollectionView.isUserInteractionEnabled = false
    self.weatherCollectionView.isUserInteractionEnabled = false
    self.pressReleaseCollectionView.isUserInteractionEnabled = false
    self.showActivityIndicator()
  }// end private func beginLoading
  
  private func finishLoading() -> Void {
    self.scrollView.isUserInteractionEnabled = true
    self.mapView?.isUserInteractionEnabled = true
    self.townhallCollectionView.isUserInteractionEnabled = true
    self.serviceCollectionView.isUserInteractionEnabled = true
    self.weatherCollectionView.isUserInteractionEnabled = true
    self.pressReleaseCollectionView.isUserInteractionEnabled = true
    self.hideActivityIndicator()
  }// end private func endLoading
  
  /// City view configuration method
  /// * delegates
  /// * screen title
  /// * activity indicator
  /// * show press releases button
  /// * show contact button
  /// * show weather button
  /// * show events button
  /// * show map button
  /// * show defect button
  /// * show coworking button
  /// * show public transport button
  private func setupViews() {
    self.view.addSubview(self.statusBarBackgroundView)
    self.view.addSubview(self.scrollView)
    
    self.statusBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.statusBarBackgroundView.centerXAnchor
        .constraint(equalTo: self.view.centerXAnchor),
      self.statusBarBackgroundView.widthAnchor
        .constraint(equalTo: self.view.widthAnchor),
      self.statusBarBackgroundView.topAnchor
        .constraint(equalTo: self.view.topAnchor)
    ])
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      self.scrollView.centerXAnchor
        .constraint(equalTo: self.view.centerXAnchor),
      self.scrollView.widthAnchor
        .constraint(equalTo: self.view.widthAnchor),
      self.scrollView.topAnchor
        .constraint(equalTo: self.statusBarBackgroundView.topAnchor),
      self.scrollView.bottomAnchor
        .constraint(equalTo: self.view.bottomAnchor)
    ])
    
    self.view.bringSubviewToFront(self.statusBarBackgroundView)
    
    /// delegates
    setupHomeTabRootCoordinatoreDelegate()
    townhallCollectionView.delegate = self
    serviceCollectionView.delegate = self
    pressReleaseCollectionView.delegate = self
    weatherCollectionView.delegate = self
    
    /// configure activity indicator
    setupActivityIndicator()
    setupScrollView()
    setupUI()
  } // end private func setupViews
  
  func setupUI() {
    let cityImageView = getCityImage()
    VStack.addArrangedSubview(cityImageView)

    let spacer = UIView()
    spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
    VStack.addArrangedSubview(spacer)
      
    for section in viewModel.sections {
      if section != .waste && section != .district {
        let hStack = getHeading(title: section.rawValue, tag: section.tag)
        VStack.addArrangedSubview(hStack)
      }
      
      switch section {
      case .services:
        let collectionView = serviceCollectionView
        collectionView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        serviceCollectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 112)
        serviceCollectionViewHeight?.isActive = true
        VStack.addArrangedSubview(collectionView)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
        VStack.addArrangedSubview(spacer)
      case .townhall:
        let collectionView = townhallCollectionView
        collectionView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: townhallCollectionViewHeight).isActive = true
        VStack.addArrangedSubview(collectionView)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
        VStack.addArrangedSubview(spacer)
      case .map:
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.2
        containerView.layer.shadowRadius = 10
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.masksToBounds = false
        
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.mapType = .mutedStandard
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 10.0
        mapView.clipsToBounds = true
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTouched))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        mapView.addGestureRecognizer(tapRecognizer)
        
        containerView.addSubview(mapView)
        
        mapView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        mapView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        let height = UIScreen.main.bounds.width / 21 * 12
        containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: height).isActive = true
        VStack.addArrangedSubview(containerView)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
        VStack.addArrangedSubview(spacer)
        
        self.mapView = mapView
      case .district:
          let url: String? = viewModel.networkConfig.baseURL.absoluteString
          let clientKey: String? = viewModel.networkConfig.headers["X-PARSE-CLIENT-KEY"] as? String
          let appId: String? = viewModel.networkConfig.headers["X-PARSE-APPLICATION-ID"] as? String
          let sessionToken: String? = UserDefaults.standard.parseSessionToken
          let politicsURL: String? = AppDI.Environment.politicsURL
          OSCADistrictSettings
              .initDistrict(
                  url: url,
                  clientKey: clientKey,
                  appId: appId,
                  sessionToken: sessionToken,
                  deeplink: nil,
                  politicsURL: politicsURL
              )
          DistrictMatomo.shared.initTracker(OSCAMatomoTracker.shared.tracker)
          self.districtWidgetController = OSCADistrictWidgetViewController()
          let widgetView: UIView = self.districtWidgetController!.view

          //custom getHeading()
          let hStack = UIStackView()
          hStack.spacing = 16
          hStack.axis = .horizontal
          hStack.translatesAutoresizingMaskIntoConstraints = false
          
          let label = UILabel()
          label.text = section.rawValue
          label.font = .systemFont(ofSize: 15, weight: .medium)
          label.numberOfLines = 1
          label.sizeToFit()
          label.translatesAutoresizingMaskIntoConstraints = false
          
          self.districtButton.tag = section.tag
          self.districtButton.addTarget(self, action: #selector(moreButtonTouched(_:)), for: .touchUpInside)
          self.districtButton.translatesAutoresizingMaskIntoConstraints = false
          
          let spacerOne = UIView()
          let spacerWidthConstraint = spacerOne.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
          spacerWidthConstraint.priority = .defaultLow
          spacerWidthConstraint.isActive = true
          
          hStack.addArrangedSubview(label)
          hStack.addArrangedSubview(spacerOne)
          hStack.addArrangedSubview(self.districtButton)
          
          VStack.addArrangedSubview(hStack)
          widgetView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
          let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(districtWidgetTouched))
          tapRecognizer.numberOfTapsRequired = 1
          tapRecognizer.numberOfTouchesRequired = 1
          widgetView.addGestureRecognizer(tapRecognizer)
          
          VStack.addArrangedSubview(widgetView)
          let spacer = UIView()
          spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
          VStack.addArrangedSubview(spacer)
      case .events:
          let url: String? = viewModel.networkConfig.baseURL.absoluteString
          let clientKey: String? = viewModel.networkConfig.headers["X-PARSE-CLIENT-KEY"] as? String
          let appId: String? = viewModel.networkConfig.headers["X-PARSE-APPLICATION-ID"] as? String
          let sessionToken: String? = UserDefaults.standard.parseSessionToken
          let politicsURL: String? = AppDI.Environment.politicsURL
          OSCADistrictSettings
              .initDistrict(
                  url: url,
                  clientKey: clientKey,
                  appId: appId,
                  sessionToken: sessionToken,
                  deeplink: nil,
                  politicsURL: politicsURL
              )
          
          let widgetView: UIView = OSCAEventsWidgetViewController().view
          widgetView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
          VStack.addArrangedSubview(widgetView)
          let spacer = UIView()
          spacer.heightAnchor.constraint(equalToConstant: 1).isActive = true
          VStack.addArrangedSubview(spacer)
      case .pressReleases:
        let collectionView = pressReleaseCollectionView
        collectionView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        pressReleasesCollectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 80)
        pressReleasesCollectionViewHeight?.isActive = true
        VStack.addArrangedSubview(collectionView)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
        VStack.addArrangedSubview(spacer)
      case .weather:
        let collectionView = weatherCollectionView
        collectionView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: weatherCollectionViewHeight).isActive = true
        VStack.addArrangedSubview(collectionView)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
        VStack.addArrangedSubview(spacer)
        
      case .waste:
#if DEBUG
        print("\(String(describing: self)): \(#function) " +
              "Section: \(section.rawValue) --> Waste Widget is used instead")
#endif
      case .environment:
          let url: String? = viewModel.networkConfig.baseURL.absoluteString
          let clientKey: String? = viewModel.networkConfig.headers["X-PARSE-CLIENT-KEY"] as? String
          let appId: String? = viewModel.networkConfig.headers["X-PARSE-APPLICATION-ID"] as? String
          let sessionToken = UserDefaults.standard.parseSessionToken
          let widgetView: UIView = OSCAEnvironmentWidgetViewController(url: url, clientKey: clientKey, appId: appId, sessionToken: sessionToken).view
          widgetView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)
          VStack.addArrangedSubview(widgetView)
          let spacer = UIView()
          spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
      default:
        let colorView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 400))
        colorView.backgroundColor = .systemPurple
        colorView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        colorView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        VStack.addArrangedSubview(colorView)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 16).isActive = true
        VStack.addArrangedSubview(spacer)
      }
    }
  }
    
    func getDistrictHeadingButtonText(){
        self.viewModel.setDistrictWidgetButtonText(text: (self.districtWidgetController?.getDistrict() == nil ?
              NSLocalizedString("SHOW_ALL_BUTTON", bundle: OSCASolingen.bundle, comment: "Show all button") :
                                                            NSLocalizedString("show_district %@".localizeWithFormat(arguments: self.districtWidgetController!.getDistrict()!), bundle: OSCASolingen.bundle, comment: "Show all button")))
    }
  
  func getHeading(title: String, tag: Int) -> UIStackView {
    let hStack = UIStackView()
    hStack.spacing = 16
    hStack.axis = .horizontal
    hStack.translatesAutoresizingMaskIntoConstraints = false
    
    let label = UILabel()
    label.text = title
    label.font = .systemFont(ofSize: 15, weight: .medium)
    label.numberOfLines = 1
    label.sizeToFit()
    label.translatesAutoresizingMaskIntoConstraints = false
    
    let button = UIButton(type: .custom)
    button.setTitle(NSLocalizedString("SHOW_ALL_BUTTON",
                                      bundle: OSCASolingen.bundle,
                                      comment: "Show all button"), for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
    button.setTitleColor(.primary, for: .normal)
    button.sizeToFit()
    button.tag = tag
    button.addTarget(self, action: #selector(moreButtonTouched(_:)), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    
    let spacer = UIView()
    let spacerWidthConstraint = spacer.widthAnchor.constraint(equalToConstant: .greatestFiniteMagnitude)
    spacerWidthConstraint.priority = .defaultLow
    spacerWidthConstraint.isActive = true
    
    hStack.addArrangedSubview(label)
    hStack.addArrangedSubview(spacer)
    hStack.addArrangedSubview(button)
    
    return hStack
  }
  
  /// * [pull to refresh control](https://mobikul.com/pull-to-refresh-in-swift/)
  func setupScrollView() {
    scrollView.delegate = self
    VStack.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(VStack)
    
    VStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16).isActive = true
    VStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16).isActive = true
    VStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    VStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32).isActive = true
    VStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8).isActive = true
    VStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    
    // pull to refresh
    scrollView.refreshControl = UIRefreshControl()
    // add target to UIRefreshControl
    scrollView.refreshControl?.addTarget(self,
                                         action: #selector(callPullToRefresh),
                                        for: .valueChanged)
  }
  
  @objc private func toggleWasteReminder() {
    self.wasteWidget.isHidden = !UserDefaults.standard
      .getOSCAWasteDashboardEnabled()
  }
  
  @objc func moreButtonTouched(_ sender: UIButton) -> Void {
    let section = CityViewModel.Section.from(tag: sender.tag)
    let deeplinkScheme = viewModel.deeplinkScheme
    switch section {
    case .weather: // Weather
      viewModel.showWeatherTouch()
    case .district:
        viewModel.showDistrictTouch() // District
    case .events:
        if let url = URL(string: "\(deeplinkScheme)://events/") {
            DispatchQueue.main.async {
                UIApplication.shared.open(url)
            }
        }
    case .waste: // Waste
      guard let url = URL(string: "\(deeplinkScheme)://waste/") else { return }
      self.homeTabRootViewController.navigate(url: url)
    case .map: // Map
      viewModel.showMapTouch()
    case .townhall: // Townhall
      guard let url = URL(string: "\(deeplinkScheme)://townhall/") else { return }
      self.homeTabRootViewController.navigate(url: url)
    case .services: // Services
      guard let url = URL(string: "\(deeplinkScheme)://service/") else { return }
      self.homeTabRootViewController.navigate(url: url)
    case .pressReleases: // PressReleases
      guard let url = URL(string: "\(deeplinkScheme)://pressreleases/") else { return }
      self.homeTabRootViewController.navigate(url: url)
    case .environment:
        viewModel.showEnvironmentTouch()
    default:
      break
    } // end switch case
  } // end @objc func moreButtonTouched
  
  @objc func mapTouched() {
    viewModel.showMapTouch()
  }//
    
  @objc func districtWidgetTouched() {
    viewModel.showDistrictTouch()
  }//
  
  /// [Apple documentation ui refresh control](https://developer.apple.com/documentation/uikit/uirefreshcontrol)
  @objc func callPullToRefresh(){
    viewModel.callPullToRefresh()
    DispatchQueue.main.async {
      self.scrollView.refreshControl?.endRefreshing()
    }// end
  }// end @objc func callPullToRefresh
  
  private func getHeaderHeight() -> CGFloat {
    self.cityImageContainerView.layoutIfNeeded()
    guard let image = self.cityImageView.image
    else { return 1.0 }
    let aspectRatio = image.size.height / image.size.width
    return self.cityImageContainerView.frame.width * aspectRatio
  }
  
  private func getCityImage() -> UIView {
    self.cityImageContainerView.addSubview(self.cityImageView)
    
    self.cityImageView.translatesAutoresizingMaskIntoConstraints = false
    self.cityImageView.leadingAnchor
      .constraint(equalTo: self.cityImageContainerView.leadingAnchor)
      .isActive = true
    self.cityImageView.trailingAnchor
      .constraint(equalTo: self.cityImageContainerView.trailingAnchor)
      .isActive = true
    self.cityImageView.topAnchor
      .constraint(equalTo: self.cityImageContainerView.topAnchor)
      .isActive = true
    self.cityImageView.bottomAnchor
      .constraint(equalTo: self.cityImageContainerView.bottomAnchor)
      .isActive = true
    self.cityImageViewHeightConstraint = self.cityImageView.heightAnchor
      .constraint(equalToConstant: 0)
    if let heightConstraint = self.cityImageViewHeightConstraint {
      heightConstraint.isActive = true
    }
    
    self.cityImageView.layer.cornerRadius = 10
    self.cityImageView.clipsToBounds = true
    
    self.cityImageContainerView.addSubview(self.dateLabel)
    self.cityImageContainerView.addSubview(self.titleLabel)
    
    let shadow = OSCAShadowSettings(opacity: 1.0,
                                    radius: 1.5,
                                    offset: CGSize(width: 1, height: 1))
    self.dateLabel.addShadow(with: shadow)
    self.titleLabel.addShadow(with: shadow)
    
    self.titleLabel.numberOfLines = 2
    
    self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    self.dateLabel.leadingAnchor
      .constraint(equalTo: self.cityImageContainerView.leadingAnchor, constant: 16)
      .isActive = true
    self.dateLabel.trailingAnchor
      .constraint(equalTo: self.cityImageContainerView.trailingAnchor, constant: -16)
      .isActive = true
    self.dateLabel.topAnchor
      .constraint(equalTo: self.cityImageContainerView.topAnchor, constant: 16)
      .isActive = true
    self.dateLabel.bottomAnchor
      .constraint(equalTo: self.titleLabel.topAnchor, constant: -8)
      .isActive = true
    
    self.titleLabel.leadingAnchor
      .constraint(equalTo: self.cityImageContainerView.leadingAnchor, constant: 16)
      .isActive = true
    self.titleLabel.trailingAnchor
      .constraint(equalTo: self.cityImageContainerView.trailingAnchor, constant: -16)
      .isActive = true
    self.titleLabel.bottomAnchor
      .constraint(lessThanOrEqualTo: self.cityImageContainerView.bottomAnchor, constant: -16)
      .isActive = true
    
    return self.cityImageContainerView
  }
} // end final class CityViewController

// MARK: - UIViewController lifecycle

extension CityViewController {
  /// Called after the controller's view is loaded into memory.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = viewModel.screenTitle
    
    setupTownhallCollectionView()
    setupServiceCollectionView()
    setupPressReleasesCollectionView()
    setupWeatherCollectionView()
    
    configureTownhallDataSource()
    configureServiceDataSource()
    configurePressReleasesDataSource()
    configureWeatherDataSource()
    
    setupViews()
    bind(to: viewModel)
    
    locationManager.requestWhenInUseAuthorization()
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.distanceFilter = 50
      locationManager.startUpdatingLocation()
    }
    
    viewModel.viewDidLoad()
  } // end override func viewDidLoad
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let heightConstraint = self.cityImageViewHeightConstraint {
      heightConstraint.constant = self.getHeaderHeight()
    }
  }
  
  // MARK: - lifecycle
  
  /// Called before the controlller's view will appear
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.viewModel.viewWillAppear()
    OSCAMatomoTracker.shared.trackNavigation(self, true)
    self.toggleWasteReminder()
    
    var location = AppDI.Environment.defaultLocation?.clLocationCoordinate2D
    
    var latMeters: CLLocationDistance = 7000
    var lonMeters: CLLocationDistance = 7000
    
    if let userLocation = self.locationManager.location {
      location = userLocation.coordinate
      latMeters = 1000
      lonMeters = 1000
    }
    
    self.mapView?.region = MKCoordinateRegion(
      center: location ?? CLLocationCoordinate2D(latitude: 0.0,
                                                 longitude: 0.0),
      latitudinalMeters: latMeters,
      longitudinalMeters: lonMeters)
    
    self.navigationController?
      .setNavigationBarHidden(true, animated: false)
      
    self.getDistrictHeadingButtonText()
  } // end override func viewWillAppear
  
  /// Called before the controller's view will disappear
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
    navigationController?.setNavigationBarHidden(false, animated: false)
  } // end override func viewWillDisappear
  
  /// Called after the controllers's view did disappear
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewModel.viewDidDisappear()
  } // end override func viewDidDisappear
} // end extension final class ModuleNavigationViewController

// MARK: - view controller alerts

extension CityViewController: Alertable {}

// MARK: - view controller activity indicator

extension CityViewController: ActivityIndicatable {}

// MARK: - instantiate view conroller

extension CityViewController: StoryboardInstantiable {
  /// function call: var vc = ModuleNavigationViewController.create(viewModel)
  static func create(with homeTabRootViewController: HomeTabRootViewController,
                     viewModel: CityViewModel) -> CityViewController {
    let bundle = OSCASolingen.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.homeTabRootViewController = homeTabRootViewController
    vc.viewModel = viewModel
    return vc
  } // end static func create
} // end extension final class CityViewController

// MARK: - Townhall
extension CityViewController {
  private func updateTownhallSections(_ townhallMenuItems: [TownhallMenu]) {
    var snapshot = TownhallSnapshot()
    snapshot.appendSections([.townhallMenu])
    let items = Array(townhallMenuItems.prefix(3))
    snapshot.appendItems(items)
    townhallDataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func setupTownhallCollectionView() {
    townhallCollectionView.collectionViewLayout = createTownhallLayout()
  }
  
  private func createTownhallLayout() -> UICollectionViewLayout {
    let screenWidth = UIScreen.main.bounds.width
    let minCells: CGFloat = 3
    var maxWidth: CGFloat = 200
    let space: CGFloat = 16
    
    var cellCount = ceil((screenWidth - (2 * space)) / (maxWidth + (space / 2)))
    
    if cellCount < minCells {
      maxWidth = (screenWidth / minCells) - ((minCells - 1) * space)
      cellCount = screenWidth / (maxWidth + (space / 2))
    }
    
    let cellWidth = floor((screenWidth - (2 * space) - ((cellCount - 1) * space)) / cellCount)
    let cellHeight = floor(cellWidth)
    
    townhallCollectionViewHeight = cellHeight
    
    let size = NSCollectionLayoutSize(
      widthDimension: .estimated(cellWidth),
      heightDimension: .estimated(cellHeight))
    let item = NSCollectionLayoutItem(layoutSize: size)
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.interGroupSpacing = 8
    
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  private func configureTownhallDataSource() {
    townhallDataSource = TownhallDataSource(
      collectionView: townhallCollectionView,
      cellProvider: { collectionView, indexPath, item -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: "townhallCell",
          for: indexPath) as? TownhallCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.viewModel = TownhallCollectionViewCellViewModel(imageCache: self.viewModel.imageDataCache, oscaTownhallMenu: self.viewModel.oscaTownhallMenu, listItem: item, at: indexPath.row)
        return cell
      })
  }
}

// - MARK: Services
extension CityViewController {
  private func updateServiceSections(_ serviceMenuItems: [ServiceMenu]) {
    var snapshot = ServiceSnapshot()
    snapshot.appendSections([.servicesMenu])
    let items = Array(serviceMenuItems.prefix(2))
    serviceCollectionViewHeight?.constant = CGFloat((items.count * 112) + ((items.count - 1) * 16))
    snapshot.appendItems(items)
    serviceDataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func setupServiceCollectionView() {
    serviceCollectionView.collectionViewLayout = createServiceLayout()
  }
  
  private func createServiceLayout() -> UICollectionViewLayout {
    let size = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(112))
    let item = NSCollectionLayoutItem(layoutSize: size)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
    section.interGroupSpacing = 8
    
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  private func configureServiceDataSource() {
    serviceDataSource = ServiceDataSource(
      collectionView: serviceCollectionView,
      cellProvider: { collectionView, indexPath, item -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: "serviceCell",
          for: indexPath) as? ServiceCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.viewModel = ServiceCollectionViewCellViewModel(imageCache: self.viewModel.imageDataCache,
                                                            oscaServiceMenu: self.viewModel.oscaServiceMenu,
                                                            listItem: item,
                                                            at: indexPath.row)
        return cell
      })
  }
}

// MARK: - Press Releases
extension CityViewController {
  private func updatePressReleasesSections(_ pressReleases: [OSCAPressRelease]) {
    var snapshot = PressReleasesSnapshot()
    snapshot.appendSections([.pressReleaseItems])
    let items = Array(pressReleases.prefix(5))
    pressReleasesCollectionViewHeight?.constant = CGFloat((items.count * 100) + ((items.count - 1) * 16))
    snapshot.appendItems(items)
    pressReleaseDataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func setupPressReleasesCollectionView() {
    pressReleaseCollectionView.collectionViewLayout = createPressReleasesLayout()
  }
  
  private func createPressReleasesLayout() -> UICollectionViewLayout {
    let size = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .estimated(100))
    let item = NSCollectionLayoutItem(layoutSize: size)
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitem: item, count: 1)
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
    section.interGroupSpacing = 8
    
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  private func configurePressReleasesDataSource() {
    self.pressReleaseDataSource = PressReleasesDataSource(
      collectionView: self.pressReleaseCollectionView,
      cellProvider: { (collectionView, indexPath, item )-> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: OSCAPressReleasesMainCollectionViewCell.identifier,
          for: indexPath) as? OSCAPressReleasesMainCollectionViewCell
        else { return UICollectionViewCell() }
        
        let cellViewModel = OSCAPressReleasesMainCellViewModel(
          dataModule: self.viewModel.pressReleasesModule,
          pressRelease: item)
        cell.fill(with: cellViewModel)
        
        return cell
      })
  }
}

extension CityViewController {
  private func updateMap(with pois: [OSCAPoi]) {
    // clean the map
    let allAnnotations = mapView?.annotations
    mapView?.removeAnnotations(allAnnotations ?? [])
    
    // add the new pois to the map
    var annotations: [OSCAPoiAnnotation] = []
    for poi in pois {
      guard let lat = poi.geopoint?.latitude, let lon = poi.geopoint?.longitude,
            let objectId = poi.objectId else { return }
      let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: lon)
      
      let imageUrl = viewModel.getIconUrl(for: poi)
      let annotation = OSCAPoiAnnotation(
        title: poi.name ?? "",
        subtitle: poi.poiCategoryObject?.name ?? "",
        coordinate: coordinates,
        poiObjectId: objectId,
        imageUrl: imageUrl,
        uiSettings: nil
      )
      
      annotations.append(annotation)
    } // end for poi
    mapView?.addAnnotations(annotations)
  }
}

// MARK: - Weather
extension CityViewController {
  private func updateWeatherSections(_ weatherStations: [OSCAWeatherObserved]) {
    var snapshot = WeatherSnapshot()
    snapshot.appendSections([.weatherStation])
    let items = Array(weatherStations.prefix(3))
    snapshot.appendItems(items)
    weatherDataSource.apply(snapshot, animatingDifferences: true)
  }
  
  private func setupWeatherCollectionView() {
    weatherCollectionView.collectionViewLayout = createWeatherLayout()
  }
  
  private func createWeatherLayout() -> UICollectionViewLayout {
    let screenWidth = UIScreen.main.bounds.width
    let minCells: CGFloat = 3
    var maxWidth: CGFloat = 200
    let space: CGFloat = 16
    
    var cellCount = ceil((screenWidth - (2 * space)) / (maxWidth + (space / 2)))
    
    if cellCount < minCells {
      maxWidth = (screenWidth / minCells) - ((minCells - 1) * space)
      cellCount = screenWidth / (maxWidth + (space / 2))
    }
    
    let cellWidth = floor((screenWidth - (2 * space) - ((cellCount - 1) * space)) / cellCount)
    
    weatherCollectionViewHeight = cellWidth
    
    let size = NSCollectionLayoutSize(
      widthDimension: .absolute(cellWidth),
      heightDimension: .absolute(cellWidth))
    let item = NSCollectionLayoutItem(layoutSize: size)
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: Int(cellCount))
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    section.interGroupSpacing = 8
    
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  private func configureWeatherDataSource() {
    weatherDataSource = WeatherDataSource(
      collectionView: weatherCollectionView,
      cellProvider: { collectionView, indexPath, item -> UICollectionViewCell in
        guard let cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: CityWeatherCollectionViewCell.identifier,
          for: indexPath) as? CityWeatherCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.viewModel = CityWeatherCollectionViewCellViewModel(weatherStation: item, at: indexPath.row)
        
        return cell
      })
  }
}

extension CityViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let section = CityViewModel.Section.from(tag: collectionView.tag)
    switch section {
    case .weather: /* weather */
      viewModel.didSelectWeatherItem(at: indexPath.row)
    case .townhall: /* townhall */
      viewModel.didSelectTownhallItem(at: indexPath.row)
    case .services: /* service */
      viewModel.didSelectServiceItem(at: indexPath.row)
    case .pressReleases: /* press releases */
      viewModel.didSelectPressReleaseItem(at: indexPath.row)
    default:
      break
    }
  }
}

extension CityViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations.first
    if let location = locations.first {
      mapView?.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
      viewModel.fetchPOIs()
    }
  }
}

extension CityViewController: MKMapViewDelegate {
  func mapView(_: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    print(#function)
    guard annotation is OSCAPoiAnnotation else { return nil }
    
    guard let oscaAnnotation = annotation as? OSCAPoiAnnotation else { return nil }
    
    let annotationView = MKAnnotationView(annotation: oscaAnnotation, reuseIdentifier: "Annotation")
    annotationView.annotation = oscaAnnotation
    annotationView.canShowCallout = false
    
    if let imageUrl = oscaAnnotation.imageUrl {
      if let imageData = viewModel.getImageDataFromCache(with: imageUrl) {
        annotationView.image = UIImage(data: imageData)
      } else {
        let publisher: AnyPublisher<Data, OSCAMapError>? = viewModel.getImageData(from: imageUrl)
        publisher?.receive(on: RunLoop.main)
          .sink { completion in
            switch completion {
            case .finished:
              print("\(Self.self): finished \(#function)")
              
            case let .failure(error):
              print(error)
              print("\(Self.self): .sink: failure \(#function)")
            }
          } receiveValue: { imageData in
            self.viewModel.imageDataCache.setObject(
              NSData(data: imageData),
              forKey: NSString(string: oscaAnnotation.imageUrl!)
            )
            
            annotationView.image = UIImage(data: imageData)
          }
          .store(in: &bindings)
      }
    } else {}
    
    return annotationView
  } // end map view view for annotation
}

// MARK: - Deeplinking

extension CityViewController {
  func didReceiveDeeplink(with url: URL) {
    viewModel.didReceiveDeeplink(with: url)
  } // end func didReceiveDeeplinkDetail
} // end extension CityViewController

// MARK: - HomeTabRootCoordinatorDelegate
extension CityViewController: HomeTabRootControllerDelegate{
  func navigate(url: URL) {
    guard let delegate = homeTabRootViewController.tabBarDelegate,
          delegate === self else { return }
    homeTabRootViewController.navigate(url: url)
  }// end func navigate url
  
  func setupHomeTabRootCoordinatoreDelegate() -> Void {
    self.homeTabRootViewController?.tabBarDelegate = self
  }// end setupHomeTabRootCoordinatoreDelegate
}// end extension CityViewController
