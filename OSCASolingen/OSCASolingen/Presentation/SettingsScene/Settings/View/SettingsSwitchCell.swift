//
//  SettingsSwitchCell.swift
//  OSCASolingen
//
//  Created by Mammut Nithammer on 20.06.22.
//

import Foundation
import UIKit

class SettingsSwitchCell: UITableViewCell {
  @IBOutlet var titleLabel: UILabel?
  @IBOutlet var onSwitch: UISwitch?
  
  var action: ((_ sender: UISwitch) -> Void)?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    // TODO: Set primary color to switch
    #warning("TODO: Set primary color to switch")
  }
  
  @IBAction func onSwitchChange(_ sender: UISwitch) {
    action?(sender)
  }
}
