//
//  CameraARViewModel.swift
//  PointCloudVisualization
//
//  Created by Ertem Biyik on 01.06.2022.
//

import SwiftUI
import Open3DSupport
import NumPySupport
import PythonSupport
import PythonKit
import SceneKit
import LinkPython
import ARKit

class CameraARViewModel: ObservableObject {
    
    @Published var showSheet = false
    
    @Published var didTapCreateMeshObject = false
    
    var featurePoints = [vector_float3]()
    
    private let o3dCore = Open3DCore()
    
    var filesToShare = [Any]()
    
    func createPlyFile() -> URL {
        
        var featurePointsString: String = ""
        
        featurePoints.forEach({ point in
            featurePointsString += "\(point.x) \(point.y) \(point.z)\n"
        })
        
        let fileContents =  """
                ply
                format ascii 1.0
                comment PCL generated
                element vertex \(featurePoints.count)
                property float x
                property float y
                property float z
                end_header
                \(featurePointsString)
                """
        
        let fileName = "point-cloud.ply"
        
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("no directory found while creating point cloud ply file")
        }
        
        let path = URL(fileURLWithPath: directory.absoluteString).appendingPathComponent(fileName)
        
        do {
            try fileContents.write(to: path, atomically: true, encoding: .utf8)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        
        return path
    }
    
    func createMesh(from worldMap: ARWorldMap) {
        
        let inputFileURL = createPlyFile()
        
        filesToShare.append(inputFileURL)
        
        o3dCore.makeTriangleMeshFrom(pointCloud: inputFileURL) { [weak self] url, error in
            guard error == nil, let self = self else { return }
            
            self.filesToShare.append(url)
            
            DispatchQueue.main.async {
                self.showSheet = true
                
                self.didTapCreateMeshObject = false
            }
        }
    }
}

