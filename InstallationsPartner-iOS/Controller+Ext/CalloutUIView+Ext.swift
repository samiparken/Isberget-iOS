import Foundation
import UIKit

extension MapCalloutUIView {
    
    func customStyle(viewType: String) {
        self.viewType = viewType
        
        if self.viewType == K.JobAccept.type {
            self.bookingButton.isHidden = true
        }
        
        // Adjust Appearance
        self.mainView.layer.cornerRadius = 8
        self.mainView.layer.shadowColor = UIColor.darkGray.cgColor
        self.mainView.layer.shadowRadius = 4
        self.mainView.layer.shadowOpacity = 0.5
        self.mainView.layer.shadowOffset = CGSize(width:0, height:0)
                
        // Adjust Frame
        let uiViewWidth = singletonData.screenWidth! - 60
        let uiViewHeight = CGFloat(210)
        self.frame = CGRect(x: (singletonData.screenWidth!/2) - (uiViewWidth/2),
                            y: (singletonData.mapViewHeight!/2) - uiViewHeight - 70,
                                   width: uiViewWidth,
                                   height: uiViewHeight)
    }
}
