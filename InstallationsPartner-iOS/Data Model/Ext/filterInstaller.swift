
import Foundation

func filterJob(_ jobs: [[String: Any]]) -> [[String: Any]] {
    var result = [[String:Any]]()
    
    for job in jobs {
                
        // Booking & Booked & Done
        if let targetId = (job["ResourceId"] as? String) ?? nil {
            for id in singletonData.onInstallersId {
                if ( Int(targetId) == id ) && filterDeliveryDate(job) {
                    result.append(job)
                    break
                }
            }
        } else {
            // Unaccepted & unbooked
            if filterDeliveryDate(job) {
                result.append(job)
            }
        }
    }
    
    return result
}

func filterDeliveryDate(_ job: [String: Any]) -> Bool {
    let deliveryInfo = (job["ConfirmedShippingDate"] as? String) ?? nil

    if (deliveryInfo == nil) {
        return singletonData.isOn_noDeliveryDate
    }
    
    let deliveryDate = stringToDate(with: deliveryInfo!)
    if deliveryDate < Date() {
        return singletonData.isOn_delivered
    } else {
        return singletonData.isOn_deliveryDate
    }
}
