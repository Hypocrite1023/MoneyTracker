//
//  CameraView.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/23.
//

import AVFoundation
import Foundation
import SwiftUI

class CameraManager: NSObject, AVCapturePhotoCaptureDelegate, ObservableObject {
    static let current = CameraManager()
    let session = AVCaptureSession()
    private var backCamera: AVCaptureDeviceInput? {
        let camera = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
        if let camera {
            return try? AVCaptureDeviceInput(device: camera)
        }
        return nil
    }
    private let photoOutput = AVCapturePhotoOutput()
    
    override init() {
        super.init()
        if let backCamera {
            session.addInput(backCamera)
            session.addOutput(photoOutput)
        }
    }
    @State var photoData: Data? = nil
    
    
    func getPhotoData() -> Data? {
        return self.photoData
    }
    
    func getPreviewLayer() -> CALayer {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.name = "preview"
        layer.videoGravity = .resizeAspectFill
        return layer
    }
    
    func takePhoto() {
        if !session.isRunning {
            DispatchQueue.global().async {
                self.session.startRunning()
            }
//            session.startRunning()
            Thread.sleep(forTimeInterval: 0.3)
        }
        let setting = AVCapturePhotoSettings()
        setting.isAutoRedEyeReductionEnabled = true
        setting.flashMode = .auto
        photoOutput.capturePhoto(with: setting, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        session.stopRunning()
        if let data = photo.fileDataRepresentation() {
            let uiImage = UIImage(data: data)
            UIImageWriteToSavedPhotosAlbum(uiImage!, nil, nil, nil)
        }
    }
}
struct PreviewView: UIViewRepresentable {
    var previewLayer: CALayer
    var proxy: GeometryProxy
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.layer.addSublayer(previewLayer)
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        let previewLayer = uiView.layer.sublayers?.first {
            layer in
            layer.name == "preview"
        }
        if let previewLayer {
            previewLayer.frame = proxy.frame(in: .local)
        }
    }
    
    typealias UIViewType = UIView
}

struct CameraView: View {
    private let layer = CameraManager.current.getPreviewLayer()
    @Binding var showCamera: Bool
    var body: some View {
        GeometryReader { proxy in
            PreviewView(previewLayer: layer, proxy: proxy)
                .background(.blue.opacity(0.1))
        }
        .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height - 60)
        .overlay {
            HStack {
                Button("取消") {
                    showCamera.toggle()
                }
                .foregroundColor(.white)
                .padding(10)
                .background(.blue)
                Button("拍照") {
                    CameraManager.current.takePhoto()
                    showCamera.toggle()
                }
                .foregroundColor(.white)
                .padding(10)
                .background(.blue)
                
            }
        }
    }
}
