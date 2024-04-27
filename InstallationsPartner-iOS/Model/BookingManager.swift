import Foundation

class BookingManager {
    
    func calculateOccupiedCell(id: Int, _ targetDate: Date) -> [[String:Any]] {
        
        var result = [[String:Any]]() // [ startTime : duration ]
        
        let idString = String(id)
        
        let allJobs = singletonData.getBookedJobs
        
        let myJobs = allJobs.filter{ ($0["ResourceId"] as! String) == idString }
        
        for job in myJobs {
            
            let startString = job["Start"] as! String
            let endString = job["End"] as! String
            
            let startDate = stringToDate(with: startString)
            let endDate = stringToDate(with: endString)
            
            if !isSameDay(startDate, targetDate) { continue }
            
            let duration = (endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970) / 60

            result.append(["Start" : startDate,
                           "Duration" : duration])
        }
        return result
    }
}
