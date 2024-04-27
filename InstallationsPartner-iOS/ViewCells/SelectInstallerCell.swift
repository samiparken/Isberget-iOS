import Foundation
import UIKit

protocol SelectInstallerCellDelegate {
    func updateInstallerList(at row: Int, on: Bool)
}

class SelectInstallerCell: UITableViewCell {
    var delegate: SelectInstallerCellDelegate?
    
    @IBOutlet weak var installerButton: UIButton!

    var row: Int = 0
    var on: Bool = true
    
    func setOn() {
        on = true
        let mediumConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .medium)
        let largeBoldCheck = UIImage(systemName: "checkmark.square", withConfiguration: mediumConfig)
        installerButton.setImage(largeBoldCheck, for: .normal)
        installerButton.tintColor = #colorLiteral(red: 0.08946422487, green: 0.238609314, blue: 0.4872150421, alpha: 1)
        installerButton.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
    }
    
    func setOff() {
        on = false
        let mediumConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .medium)
        let largeBoldCheck = UIImage(systemName: "square", withConfiguration: mediumConfig)
        installerButton.setImage(largeBoldCheck, for: .normal)
        installerButton.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        installerButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
    }
    
    func setText(with text: String) {
        installerButton.setTitle("  \(text)", for: .normal)
    }
    
    @IBAction func installerButtonPressed(_ sender: Any) {
        if on {
            setOff()
            self.delegate?.updateInstallerList(at: row, on: false)
        } else {
            setOn()
            self.delegate?.updateInstallerList(at: row, on: true)
        }
    }
}

