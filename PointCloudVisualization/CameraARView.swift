//
//  CameraARView.swift
//  PointCloudVisualization
//
//  Created by Ertem Biyik on 01.06.2022.
//

import SwiftUI

struct CameraARView: View {
    
    @EnvironmentObject var viewModel: CameraARViewModel
    
    var body: some View {
        ARViewContainer()
            .overlay(alignment: .topTrailing) {
                Button {
                    viewModel.didTapCreateMeshObject = true
                } label: {
                    Text("Get Feature Points")
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .padding()
                }
            }
            .sheet(isPresented: $viewModel.showSheet, content: {
                ShareSheet(activityItems: viewModel.filesToShare)
            })
    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CameraARView()
    }
}
