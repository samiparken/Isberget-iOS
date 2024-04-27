
import UIKit

class TimelineCell: UITableViewCell {

    @IBOutlet weak var hourLabel: UILabel!
    
    let selectedArea = UIView()
    let occupiedArea = UIView()
    
    var cellHeight: CGFloat?
    var cellWidth: CGFloat?
    var hour: Int?          // start from  0700
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        contentView.backgroundColor = UIColor.white
    }
        
    func setColorArea(startTime: Date, durationMin: Double, isOccupied: Bool = false) {

        let calendar = Calendar.current
        let offset = CGFloat(calendar.component(.minute, from: startTime)) / 60
        let lengthHour = CGFloat(durationMin/60)
        
        if !isOccupied {
            selectedArea.frame = CGRect(x: 50, y: cellHeight! * offset, width: 50, height: cellHeight! * lengthHour)
            selectedArea.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            selectedArea.layer.opacity = 0.8
            selectedArea.layer.cornerRadius = 10
            self.addSubview(selectedArea)
        } else {
            occupiedArea.frame = CGRect(x: 75, y: cellHeight! * offset, width: 25, height: cellHeight! * lengthHour)
            occupiedArea.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
            occupiedArea.layer.opacity = 0.3
            occupiedArea.layer.cornerRadius = 10
            self.addSubview(occupiedArea)
        }
    }
    
    func removeColorArea() {
        selectedArea.removeFromSuperview()
    }
    
    func occupiedArea(_ occupiedCells: [[String:Any]]) {
        let calendar =  Calendar.current
        for cell in occupiedCells {
            let startDate = cell["Start"] as! Date
            let duration =  cell["Duration"] as! Double
            let cellHour = calendar.component(.hour, from: startDate )
            print("cellHour: \(cellHour)")
            if hour != cellHour { continue }
            
            setColorArea(startTime: startDate, durationMin: duration, isOccupied: true)
        }
    }
    
    func removeOccupiedArea() {
        occupiedArea.removeFromSuperview()
    }

}
