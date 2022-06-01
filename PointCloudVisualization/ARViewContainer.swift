//
//  ARViewContainer.swift
//  PointCloudVisualization
//
//  Created by Ertem Biyik on 01.06.2022.
//

import SwiftUI
import RealityKit
import ARKit

struct ARViewContainer: UIViewRepresentable {
    
    @EnvironmentObject var viewModel: CameraARViewModel
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        arView.session.delegate = context.coordinator
        
        context.coordinator.arView = arView
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        
        if viewModel.didTapCreateMeshObject {
            uiView.session.getCurrentWorldMap { worldMap, error in
                guard error == nil, let worldMap = worldMap else { return }
                
                
                uiView.session.pause()
                
                viewModel.createMesh(from: worldMap)
                
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
        
        // MARK: - Properties
        private let arViewContainer: ARViewContainer
        
        weak var arView: ARView?
        
        private var lastScheduledFeaturePoints: [simd_float3] = []
        
        init( _ arViewContainer: ARViewContainer) {
            self.arViewContainer = arViewContainer
        }
        
        // MARK: - Methods
        
        
        // MARK: - ARSessionDelegate Methods
        func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
            
        }
        
        func session(_ session: ARSession, didUpdate frame: ARFrame) {
            guard let points = frame.rawFeaturePoints?.points else { return }
            
            if points != lastScheduledFeaturePoints {
                lastScheduledFeaturePoints = points
                arViewContainer.viewModel.featurePoints.append(contentsOf: points)
            }
            
        }
    }
}
