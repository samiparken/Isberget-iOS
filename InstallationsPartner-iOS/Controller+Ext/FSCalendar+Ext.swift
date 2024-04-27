import Foundation
import UIKit
import FSCalendar

extension FSCalendar {
    
    func generateColorDotImage(date: [String: Int]) -> UIImage {
        
        let greenDot = #imageLiteral(resourceName: "dot-gron") // 30 X 30
        let yellowDot = #imageLiteral(resourceName: "dot-gul")  // 30 X 30
        let grayDot = #imageLiteral(resourceName: "dot-grey")
        let yellowNum = (date["booking"] ?? 0)
        let greenNum = (date["booked"] ?? 0)
        let grayNum = (date["done"] ?? 0)
        let totalNum = yellowNum + greenNum + grayNum

        let size = totalNum > 5 ? CGSize(width: 50, height: 20) : CGSize(width: 10 * totalNum, height: 10)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        var row: Int = 0
        var column: Int = 0
        
        if greenNum > 0 {
            for _ in 1...greenNum {
                greenDot.draw(in: CGRect(x: row * 10, y: column * 10, width:10, height: 10))
                column = column + ((row == 4) && (column == 0) ? 1 : 0)
                row = row == 4 ? 0 : row+1
            }
        }
        if yellowNum > 0 {
            for _ in 1...yellowNum {
                yellowDot.draw(in: CGRect(x: row * 10, y: column * 10, width:10, height: 10))
                column = column + ((row == 4) && (column == 0) ? 1 : 0)
                row = row == 4 ? 0 : row+1
            }
        }
        
        if grayNum > 0 {
            for _ in 1...grayNum {
                grayDot.draw(in: CGRect(x: row * 10, y: column * 10, width:10, height: 10))
                column = column + ((row == 4) && (column == 0) ? 1 : 0)
                row = row == 4 ? 0 : row+1
            }
        }

        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
