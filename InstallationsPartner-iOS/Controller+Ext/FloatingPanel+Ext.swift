//
//  FloatingPanel+Ext.swift
//  InstallationsPartner-iOS
//
//  Created by Sam on 12/14/20.
//

import Foundation
import FloatingPanel

//MARK: - FloatingPanelLayout
class PanelLayout: FloatingPanelLayout {
    let position: FloatingPanelPosition = .bottom
    let initialState: FloatingPanelState = .tip
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
        return [
            .full: FloatingPanelLayoutAnchor(absoluteInset: 10.0, edge: .top, referenceGuide: .safeArea),
            .half: FloatingPanelLayoutAnchor(absoluteInset: 170.0, edge: .bottom, referenceGuide: .safeArea),
            .tip: FloatingPanelLayoutAnchor(absoluteInset: 55.0, edge: .bottom, referenceGuide: .safeArea),
        ]
    }
}

extension FloatingPanelController {
    func customStyle() {

        // Create a new appearance.
        let appearance = SurfaceAppearance()

        // Define shadows
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: 16)
        shadow.radius = 16
        shadow.spread = 8
        appearance.shadows = [shadow]

        // Define corner radius and background color
        appearance.cornerRadius = 10
        appearance.backgroundColor = .clear

        // Set the new appearance
        self.surfaceView.appearance = appearance
        
        // Set Layout
        self.layout = PanelLayout()
    }
}

