import UIKit
import OSCAEssentials
import OSCAPressReleasesUI
import OSCAWeatherUI
import OSCAMapUI
import OSCAWasteUI
import OSCAContactUI
import OSCADefectUI
import OSCAMobilityUI
import OSCACoworkingUI
import OSCAPublicTransportUI
import OSCAJobsUI
import MatomoTracker
import OSCAEnvironmentUI

extension OSCAMatomoTracker {
    public func initTracker(_ matomoLogEnabled: Bool = false) {
        self.matomoLogEnabled = matomoLogEnabled
        if let matomoUrl = AppDI.Environment.matomoUrl, let matomoSiteId = AppDI.Environment.matomoSiteId, AppDI.Environment.matomoEnabled == true {
            tracker = MatomoTracker(
                siteId: matomoSiteId,
                baseURL: URL(string: matomoUrl)!
            )
            logMatomo("Tracker initialzed. Url: \(matomoUrl) - siteId: \(matomoSiteId)")
        } else {
            logMatomo("Tracker could not be initialzed.")
        }
    }
    
    public func trackNavigation(_ viewController: UIViewController, _ appear: Bool = false) {
        if let path = resolveControllerPath(viewController, appear) {
            trackPath(path)
        } else {
            logMatomo("Ignoring - \(type(of: viewController))")
        }
    }
    
    func resolveControllerPath(_ viewController: UIViewController, _ appear: Bool) -> [String]? {
        let type = type(of: viewController)
        if (type == CityViewController.self) {
            return appear ? ["home"] : nil
        }
        if (type == ServiceListViewController.self) {
            return appear ? ["service"] : nil
        }
        if (type == SettingsViewController.self) {
            return appear ? ["settings"] : nil
        }
        if (type == TownhallViewController.self) {
            return appear ? ["townhall"] : nil
        }
        if (type == OSCAWeatherStationViewController.self) {
            return ["sensorstation"]
        }
        if (type == OSCAWeatherStationSelectionViewController.self) {
            return ["sensorstation","selection"]
        }
        if (type == OSCAMapViewController.self) {
            return ["poi"]
        }
        if (type == OSCAAppointmentsViewController.self) {
            return ["appointments"]
        }
        if (type == OSCAWasteViewController.self) {
            return ["waste"]
        }
        if (type == OSCAContactFormViewController.self) {
            return ["contact"]
        }
        if (type == OSCADefectFormViewController.self) {
            return ["defect"]
        }
        if (type == OSCAMobilityMainViewController.self) {
            return ["mobilitymonitor"]
        }
        if (type == OSCACoworkingFormViewController.self) {
            return ["coworking"]
        }
        if (type == OSCAPublicTransportViewController.self) {
            return ["transport"]
        }
        if (type == OSCAJobsMainViewController.self) {
            return ["jobs"]
        }
        if (type == OSCAEnvironmentMainViewController.self) {
            return ["environment"]
        }
        return nil
    }
}
