import Foundation
import UIKit

extension UILabel {
    func setDeliveryInfo(with shippingDateString: String?) {
     // job["ConfirmedShippingDate"]
        
        if shippingDateString != nil{
            let shippingDate = stringToDate(with: shippingDateString!)
            if shippingDate < Date() {
                self.text = "Levererat"
                self.textColor = #colorLiteral(red: 0.1589285409, green: 0.7207738505, blue: 0.3077968417, alpha: 1)
            } else {
                let shippingYMD = dateToString_ymd(with: shippingDate)
                self.text = "Leverans: " + shippingYMD
                self.textColor = #colorLiteral(red: 0.1528630555, green: 0.305911988, blue: 0.5881598592, alpha: 1)
            }
        } else {
            self.textColor = #colorLiteral(red: 0.924274087, green: 0.3933636844, blue: 0.276587218, alpha: 1)
            self.text = "Inget leveransdatum"
        }
    }
    
    func setTimeAgo(with dateString: String) {
        let createdDate = stringToDate(with: dateString)
        self.text = createdDate.timeAgoDisplay()
    }
}
