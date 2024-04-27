import Foundation
import UIKit

//MARK: - heatPumpCell

protocol heatPumpCellDelegate {
    func deleteCell(at row: Int)
    func updateHeatPumpText(at row: Int, text: String)
}
class heatPumpCell: UITableViewCell {
    var delegate: heatPumpCellDelegate?

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var heatPumpTextField: UITextField!
    @IBOutlet weak var textFieldView: UIStackView!
    
    var row: Int = 0
    
    func initView() {
        switch row {
            case 0...2: closeButton.isHidden = true
            default: return
        }
    }
        
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.delegate?.deleteCell(at: row)
    }
    
    @IBAction func heatPumpEditingDidEnd(_ sender: Any) {
        self.delegate?.updateHeatPumpText(at: row, text: heatPumpTextField.text!)
    }
}


//MARK: - heatPumpAddCell
protocol heatPumpAddCellDelegate {
    func addInnedel(at row: Int)
    func addUtedel(at row: Int)
}
class heatPumpAddCell: UITableViewCell {
    var delegate: heatPumpAddCellDelegate?
    var row: Int = 3
    
    @IBAction func addInnedelButtonPressed(_ sender: Any) {
        self.delegate?.addInnedel(at: row)
    }
    
    @IBAction func addUtedelButtonPressed(_ sender: Any) {
        self.delegate?.addUtedel(at: row)
    }
}

//MARK: - yesNoCell
protocol yesNoCellDelegate {
    func updateCheckList(_ at: Int, _ value: Int)
}
class yesNoCell: UITableViewCell {
    var delegate: yesNoCellDelegate?
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var noLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var yesLabel: UILabel!

    var row: Int?
    var value = -1
    
    @IBAction func noButtonPressed(_ sender: Any) {
        value = 0
        
        noButton.setImage(UIImage(systemName: "dot.circle"), for: .normal)
        noButton.tintColor = #colorLiteral(red: 0.08834790438, green: 0.2386234403, blue: 0.4872178435, alpha: 1)
        noLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        yesButton.setImage(UIImage(systemName: "circle"), for: .normal)
        yesButton.tintColor = #colorLiteral(red: 0.6705358028, green: 0.670617938, blue: 0.6705077291, alpha: 1)
        yesLabel.textColor = #colorLiteral(red: 0.6705358028, green: 0.670617938, blue: 0.6705077291, alpha: 1)
        
        self.delegate?.updateCheckList(row!, 0)
    }
    @IBAction func yesButtonPressed(_ sender: Any) {
        value = 1

        noButton.setImage(UIImage(systemName: "circle"), for: .normal)
        noButton.tintColor = #colorLiteral(red: 0.6705358028, green: 0.670617938, blue: 0.6705077291, alpha: 1)
        noLabel.textColor = #colorLiteral(red: 0.6705358028, green: 0.670617938, blue: 0.6705077291, alpha: 1)

        yesButton.setImage(UIImage(systemName: "dot.circle"), for: .normal)
        yesButton.tintColor = #colorLiteral(red: 0.08834790438, green: 0.2386234403, blue: 0.4872178435, alpha: 1)
        yesLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

        self.delegate?.updateCheckList(row!, 1)
    }
}

//MARK: - answerCell

protocol answerCellDelegate {
    func updateCheckList(_ at: Int, _ value: String)
}
class answerCell: UITableViewCell {
    var delegate: answerCellDelegate?

    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    
    var row: Int?
    
    @IBAction func answerEditingDidEnd(_ sender: Any) {
        self.delegate?.updateCheckList(row!, answerTextField.text!)
    }
}

