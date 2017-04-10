//
//  SwitchCell.swift
//  Yelp
//
//  Created by sideok you on 4/8/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate{
  @objc optional func switchCell(switchCell: SwitchCell, didChangedValue value: Bool)
}


class SwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
  
  weak var delegate: SwitchCellDelegate?
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
      
      onSwitch.addTarget(self, action: #selector(switchValueChanged), for: UIControlEvents.valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
  func switchValueChanged(){
    print("siwtch value changed")
    delegate?.switchCell?(switchCell: self, didChangedValue: onSwitch.isOn)
  }

}
