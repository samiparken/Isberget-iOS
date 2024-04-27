import Foundation
import UIKit
import MapKit

extension MKMapView {
    
    func initAnnotations(type: String, isOn: Bool, date: Date = singletonData.blankDate) {
        if(isOn) {
            addAnnotations(type: type, date: date)
        }
    }
    
    func refreshAnnotations(type: String, isOn: Bool, date: Date = singletonData.blankDate) {
        
        self.removeAnnotations(type: type)
        if(isOn) { addAnnotations(type: type, date: date) }
    }
        
    func addAnnotations(type: String, date: Date = singletonData.blankDate) {
        var jobs = [[String:Any]]()
        var addressKey: String?
        var orderIdKey: String?
        
        switch type {
        case K.Annotation.unacceptedJob:
            jobs = filterJob( singletonData.getUnacceptedJobs )
            addressKey = "FullAdress"
            orderIdKey = "order_number_on_client"
        case K.Annotation.unbookedJob:
            jobs = filterJob( singletonData.getUnbookedJobs )
            addressKey = "FullAdress"
            orderIdKey = "order_number_on_client"
        case K.Annotation.bookingJob:
            jobs = filterJob( singletonData.getBookingJobs )
            addressKey = "Address"
            orderIdKey = "Order_number_on_client"
        case K.Annotation.bookedJob:
            jobs = filterJob( singletonData.getBookedJobs )
            addressKey = "Address"
            orderIdKey = "Order_number_on_client"
        case K.Annotation.doneJob:
            jobs = filterJob( singletonData.getDoneJobs )
            addressKey = "Address"
            orderIdKey = "Order_number_on_client"
        default: break
        }
                
        for job in jobs {

            let dateString = (job["Start"] as? String) ?? "2000-01-01T08:00:00.000"
            let jobDate = stringToDate(with: dateString)
            let defaultDate = singletonData.blankDate
            
            if ( defaultDate == date
                || type == K.Annotation.unacceptedJob
                || type == K.Annotation.unbookedJob
                || isSameDay(jobDate, date) ) {
                
                let lat = job["lat"] as! Double
                let lon = job["lng"] as! Double
                let coords = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coords
                annotation.title = type
                annotation.subtitle = String(job[orderIdKey!] as! Int)
                
                self.addAnnotation(annotation)
            }
        }
    }
    
    func removeAnnotations(type: String) {
        for annotation in self.annotations {
            if let title = annotation.title, title == type {
                self.removeAnnotation(annotation)
            }
        }
    }
    
    func removeAnnotationWithOrderNum(with orderNum: String) {
        for annotation in self.annotations {
            if let subtitle = annotation.subtitle, subtitle == orderNum {
                self.removeAnnotation(annotation)
                return
            }
        }
    }
}
