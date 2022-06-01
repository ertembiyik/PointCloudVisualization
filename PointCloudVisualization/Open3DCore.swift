//
//  Open3DCore.swift
//  PointCloudVisualization
//
//  Created by Ertem Biyik on 01.06.2022.
//

import Foundation
import Open3DSupport
import NumPySupport
import PythonSupport
import PythonKit
import LinkPython


final class Open3DCore {
    
    private var pcd: PythonObject?
    
    private var tstate: UnsafeMutableRawPointer?
    
    init() {
        PythonSupport.initialize()
        Open3DSupport.sitePackagesURL.insertPythonPath()
        NumPySupport.sitePackagesURL.insertPythonPath()
    }
    
    func makeTriangleMeshFrom(pointCloud urlPath: URL, completionHandler: @escaping (URL, Error?) -> Void) {
        
        let o3d = Python.import("open3d")
        
        let np = Python.import("numpy")
        
        DispatchQueue.global(qos: .background).async {
            
            let gstate = PyGILState_Ensure()
            
            defer {
                
                DispatchQueue.main.async {
                    guard let tstate = self.tstate else { fatalError() }
                    PyEval_RestoreThread(tstate)
                    self.tstate = nil
                }
                
                PyGILState_Release(gstate)
            }
            
            let pcd = o3d.io.read_point_cloud(urlPath.path)
            self.pcd = pcd
            
            print(pcd)
            
            // compute vertex normals
            //o3d.geometry.estimate_normals(pcd, o3d.geometry.KDTreeSearchParamHybrid(0.1, 30))
            
            pcd.estimate_normals()
            
            // computing the average distance for all the points to create a solid ball
            let distances = pcd.compute_nearest_neighbor_distance()
            let avg_dist = np.mean(distances)
            
            // creating the radius of the ball
            let radius = 0.1
            
            //let radii = [0.1, 0.01, 0.02, 0.04]
            // creating the triangle mesh from point cloud of ply file with the created ball radius
            let mesh = o3d.geometry.TriangleMesh.create_from_point_cloud_ball_pivoting(pcd, o3d.utility.DoubleVector([radius, radius * 2]))
            
            print(mesh)
            
            // downsampling the mesh to an acceptable number of triangles
            let dec_mesh = mesh.simplify_quadric_decimation(100000)

            // optimising the mesh
            dec_mesh.remove_degenerate_triangles()
            dec_mesh.remove_duplicated_triangles()
            dec_mesh.remove_duplicated_vertices()
            dec_mesh.remove_non_manifold_edges()

            print(dec_mesh)
            
            // creating and writing the generated mesh into .ply format to the pat
            let documentDirectory = URL(string: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])!.appendingPathComponent("bpa_mesh.ply").absoluteString
            
            let fileDirectory = URL(fileURLWithPath: documentDirectory)
            
            o3d.io.write_triangle_mesh(documentDirectory, dec_mesh)
            
            print("Creating triangle mesh is done")
            
            completionHandler(fileDirectory, nil)
        }
        tstate = PyEval_SaveThread()
        
        
    }
    
    
}

