//
//  AppDelegate.swift
//  PointCloudVisualization
//
//  Created by Ertem Biyik on 01.06.2022.
//

import SwiftUI

@main
struct PointCloudVisualizationApp: App {
    
    let model = CameraARViewModel()
    
    var body: some Scene {
        WindowGroup {
            CameraARView().environmentObject(model)
        }
    }
}
