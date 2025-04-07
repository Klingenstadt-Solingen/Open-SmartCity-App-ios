//
//  SettingsViewController.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 20.06.22.
//

import OSCAEssentials
import OSCAPressReleases
import OSCAWaste
import UIKit
import Combine

final class SettingsViewController: UIViewController {
  @IBOutlet var tableView: UITableView?
  /// handle to the activity indicator
  public lazy var activityIndicatorView = ActivityIndicatorView(style: .large)
  
  /// handle to the view model
  private var viewModel: SettingsViewModel!
  /// handle to the cancellable bindings
  private var bindings = Set<AnyCancellable>()
  
  /// module navigation view controller bind to view model method
  private func bind(to viewModel: SettingsViewModel) {
    // weather
    viewModel.$currentUserWeatherStation
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        guard let `self` = self,
              let tableView = self.tableView else { return }
        tableView.reloadData()
      })
      .store(in: &bindings)
    // waste
    viewModel.$currentWasteUserAddress
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        guard let `self` = self,
              let tableView = self.tableView else { return }
        tableView.reloadData()
      })
      .store(in: &bindings)
    // state
    let stateValueHandler: (SettingsViewModelState) -> Void = { [weak self] state in
      guard let `self` = self else { return }
      
      switch state {
      case .loading:
        self.activityIndicatorView.startAnimating()
        
      case .finishedLoading:
        self.activityIndicatorView.stopAnimating()
        
      case let .error(error):
        print("\(#function) - error: \(error.localizedDescription)")
        self.activityIndicatorView.stopAnimating()
      }
    }
    
    self.viewModel.$state
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: stateValueHandler)
      .store(in: &self.bindings)
    
    // push press releases
    self.viewModel.$pressReleasesIsEnabled
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        guard let `self` = self,
              let tableView = self.tableView else { return }
        tableView.reloadData()
      })
      .store(in: &self.bindings)
    
    // push waste
    self.viewModel.$wasteIsEnabled
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        guard let `self` = self,
              let tableView = self.tableView else { return }
        tableView.reloadData()
      })
      .store(in: &self.bindings)
    
    /* Disabled module Corona
    // push corona stats
    self.viewModel.$coronaStatsIsEnabled
      .receive(on: RunLoop.main)
    //.dropFirst()
      .sink(receiveValue: { [weak self] _ in
        guard let `self` = self,
              let tableView = self.tableView else { return }
        tableView.reloadData()
      })
      .store(in: &self.bindings)
     */
    
    // push construction sites
    self.viewModel.$constructionSitesIsEnabled
      .receive(on: RunLoop.main)
      .dropFirst()
      .sink(receiveValue: { [weak self] _ in
        guard let `self` = self,
              let tableView = self.tableView else { return }
        tableView.reloadData()
      })
      .store(in: &self.bindings)
  } // end private func bind to view model
  
  private func setupViews() {
    /// configure activity indicator
    setupActivityIndicator()
    
    self.view.backgroundColor = .systemGroupedBackground
  } // end private func setupViews
  
  private func setDataSource() {
    tableView?.dataSource = self
  }
  
  private func setDelegate() {
    tableView?.delegate = self
  }
}

// MARK: - UIViewController lifecycle

extension SettingsViewController {
  /// Called after the controller's view is loaded into memory.
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = viewModel.screenTitle
    
    setupViews()
    bind(to: viewModel)
    setDataSource()
    setDelegate()
    viewModel.viewDidLoad()
  } // end override func viewDidLoad
  
  /// Called before the controlller's view will appear
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    OSCAMatomoTracker.shared.trackNavigation(self, true)
    viewModel.viewWillAppear()
    self.navigationController?.navigationBar.prefersLargeTitles = true
  } // end override func viewWillAppear
  
  /// Called before the controller's view will disappear
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewModel.viewWillDisappear()
  } // end override func viewWillDisappear
  
  /// Called after the controllers's view did disappear
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    viewModel.viewDidDisappear()
  } // end override func viewDidDisappear
} // end extension final class ModuleNavigationViewController

// MARK: - view controller alerts

extension SettingsViewController: Alertable {
} // end extension final class CityViewController

// MARK: - view controller activity indicator

extension SettingsViewController: ActivityIndicatable {
} // end extension final class CityViewController

// MARK: - instantiate view conroller

extension SettingsViewController: StoryboardInstantiable {
  /// function call: var vc = ModuleNavigationViewController.create(viewModel)
  static func create(with viewModel: SettingsViewModel) -> SettingsViewController {
    let bundle = OSCASolingen.bundle
    let vc: Self = Self.instantiateViewController(bundle)
    vc.viewModel = viewModel
    return vc
  } // end static func create
} // end extension final class CityViewController

extension SettingsViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.sectionTitles.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
      // section weather
    case 0: return 1
      // section my waste address
    case 1: return 2
      // section push
    case 2: return Launch.notificationCategories.count
      // section legal stuff
    case 3: return 2
#if DEBUG
      // developer options
    case 4: return 1
#endif
    default: return 0
    }// end switch case
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return section < viewModel.sectionTitles.count ? viewModel.sectionTitles[section] : nil
  }
  
  /*
   func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
   return section < viewModel.sectionFooters.count ? viewModel.sectionFooters[section] : nil
   }
   */
  
  
  func tableView(_ tableView: UITableView,
                 viewForFooterInSection section: Int) -> UIView? {
    guard section < viewModel.sectionFooters.count else { return nil }
    let view = UIView()
    var label = UILabel(frame: CGRectMake(0,0, tableView.frame.width, 20))
    if section == 3 {
      label = UILabel(frame: CGRectMake(0, 0, tableView.frame.width, 90))
      label.textAlignment = .center
      label.numberOfLines = 0
    }// end if
    label.font = label.font.withSize(14)
    label.text = viewModel.sectionFooters[section]
    label.textColor = UIColor.lightGray
    view.addSubview(label)
    return view
  }// end table view for footer in section
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell: UITableViewCell = UITableViewCell(style: .value1, reuseIdentifier: "CellRightDetail")
    
    switch indexPath.section {
    case 0: // section weather
      switch indexPath.row {
      case 0:
        cell.textLabel?.text = "Meine Wetterstation"
        cell.detailTextLabel?.text = viewModel.currentUserWeatherStation
        cell.accessoryType = .disclosureIndicator
        return cell
      default: break
      }
    case 1: // section my waste address
        guard let switchCell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as? SettingsSwitchCell else { fatalError("Unable to dequeue Cell") }
        switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Meine Adresse"
                cell.detailTextLabel?.text = viewModel.wasteUserFullStreetAddress
                cell.accessoryType = .disclosureIndicator
                return cell
            case 1:
                switchCell.titleLabel?.text = self.viewModel.currentWasteUserAddress != nil ? "Dashboard aktivieren" : "Dashboard aktivieren (Verfügbar bei Aktiver Abfall Adresse)"
                switchCell.titleLabel?.numberOfLines = 2
                switchCell.onSwitch?.isOn = self.viewModel.currentWasteUserAddress == nil ? false: self.viewModel.isWasteDashboardEnabled
                switchCell.isUserInteractionEnabled = self.viewModel.currentWasteUserAddress != nil
                switchCell.titleLabel?.isEnabled = self.viewModel.currentWasteUserAddress != nil
                switchCell.onSwitch?.isEnabled = self.viewModel.currentWasteUserAddress != nil
                switchCell.backgroundColor = self.viewModel.currentWasteUserAddress != nil ? UIColor.white : UIColor.gray
                switchCell.action = { [weak self] sender in
                guard let `self` = self else { return }
                
                self.viewModel.setWasteDashboardEnabled(sender.isOn)
                }
                return switchCell
            default: break
        }
      switch indexPath.row {
      case 0:
        cell.textLabel?.text = "Meine Adresse"
        cell.detailTextLabel?.text = viewModel.wasteUserFullStreetAddress
        cell.accessoryType = .disclosureIndicator
        return cell
      
      default: break
      }// end switch case
    case 2: // section push
      guard let switchCell = tableView.dequeueReusableCell(withIdentifier: "switchCell", for: indexPath) as? SettingsSwitchCell else { fatalError("Unable to dequeue Cell") }
      switch indexPath.row {
      case 0: // row construction site
        switchCell.titleLabel?.text = "Baustellen"
        switchCell.onSwitch?.isOn = viewModel.constructionSitesIsEnabled
        switchCell.action = { [weak self] sender in
          guard let `self` = self else { return }
          
          self.viewModel.setMapConstructionSitesPush(notification: sender.isOn)
        }
        cell = switchCell
      case 1: // row press releases
        switchCell.titleLabel?.text = "Pressemitteilungen"
        switchCell.onSwitch?.isOn = self.viewModel.pressReleasesIsEnabled
        switchCell.action = { [weak self] sender in
          guard let `self` = self else { return }
          
          self.viewModel.setPressReleasesPush(notification: sender.isOn)
        }
        cell = switchCell
        
      case 2: // row waste
        switchCell.titleLabel?.text = self.viewModel.currentWasteUserAddress != nil ? "Abfall" : "Abfall (Verfügbar bei Aktiver Abfall Adresse)"
        switchCell.titleLabel?.numberOfLines = 2
        switchCell.onSwitch?.isOn = self.viewModel.currentWasteUserAddress == nil ? false: self.viewModel.wasteIsEnabled
        switchCell.isUserInteractionEnabled = self.viewModel.currentWasteUserAddress != nil
        switchCell.titleLabel?.isEnabled = self.viewModel.currentWasteUserAddress != nil
        switchCell.onSwitch?.isEnabled = self.viewModel.currentWasteUserAddress != nil
        switchCell.backgroundColor = self.viewModel.currentWasteUserAddress != nil ? UIColor.white : UIColor.gray
        switchCell.action = { sender in
          self.viewModel.setWasteReminder(notification: sender.isOn)
        }
        cell = switchCell
        
        /* Disabled module Corona
      case 2: // row corona stats
        switchCell.titleLabel?.text = "Coronastatistik"
        switchCell.onSwitch?.isOn = viewModel.coronaStatsIsEnabled
        switchCell.action = { [weak self] sender in
          guard let `self` = self else { return }
          let isOn = sender.isOn
          if isOn {
            self.viewModel.subscribeToChannel(PushManager.Keys.pushCategoryCoronaStats)
          } else {
            self.viewModel.unsubscribeFromChannel(PushManager.Keys.pushCategoryCoronaStats)
          }// end if
        }// end action closure
        cell = switchCell
         */
      default: break
      }// end switch case
    case 3: // section legal stuff
      switch indexPath.row {
      case 0: // row data privacy
        cell.textLabel?.text = "Datenschutz"
        cell.accessoryType = .disclosureIndicator
        return cell
      case 1: // row imprint
        cell.textLabel?.text = "Impressum"
        cell.accessoryType = .disclosureIndicator
        return cell
      default: break
      }// end switch case
    default: break
    }// end switch case
    
    return cell
  }
}

extension SettingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    if indexPath.section == 2 {
      return nil
    }
    return indexPath
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    viewModel.didSelectItem(at: indexPath)
  }
}
