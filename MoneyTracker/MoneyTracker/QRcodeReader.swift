//
//  QRcodeReader.swift
//  MoneyTracker
//
//  Created by 邱翊均 on 2024/5/1.
//

import SwiftUI
import AVFoundation

class QRScannerController: UIViewController {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?

    var delegate: AVCaptureMetadataOutputObjectsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            videoInput = try AVCaptureDeviceInput(device: captureDevice)

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }

        // Set the input device on the capture session.
        captureSession.addInput(videoInput)

        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)

        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [ .qr ]

        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)

        // Start video capture.
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }

    }

}

class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {

    @Binding var scanResult: String

    init(_ scanResult: Binding<String>) {
        self._scanResult = scanResult
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {

        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            scanResult = ""
            return
        }
        
        if metadataObjects.count == 2 {
            // Get the metadata object.
            let metadataObj = (metadataObjects[0] as! AVMetadataMachineReadableCodeObject, metadataObjects[1] as! AVMetadataMachineReadableCodeObject)

            if metadataObj.0.type == AVMetadataObject.ObjectType.qr,
               let result1 = metadataObj.0.stringValue, metadataObj.1.type == AVMetadataObject.ObjectType.qr,
               let result2 = metadataObj.1.stringValue {

                scanResult = result1 + "\n" + result2
                print(scanResult)

            }
        }

        
    }
}

struct QRScanner: UIViewControllerRepresentable {
    @Binding var result: String

    
    func makeUIViewController(context: Context) -> QRScannerController {
        let controller = QRScannerController()
        controller.delegate = context.coordinator

        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($result)
    }
}

struct receipt {
    var code: String
    var date: String
    var total: Int
    var detail: [(String, Int)]
}

func strToDetail(str: String) -> receipt {
    var returnValue = receipt(code: "", date: "", total: 0, detail: [])
    let data = str.split(separator: "\n")

    func substr(str: String, start: Int, end: Int) -> String {
        String(
            str[str.index(str.startIndex, offsetBy: start)..<str.index(str.startIndex, offsetBy: end)]
        )
        
    }
    for d in data {
        
        if String(d).starts(with: "**") { //**開頭
            var result = String(d)
            result.replace("**", with: "")
            //品名：數量：單價
            //回傳 -> 品名與總價
            let parseData = result.split(separator: ":")
            for i in stride(from: 0, to: parseData.count, by: 3) {
                if i+1 < parseData.count && i+2 < parseData.count {
                    
                    let item = parseData[i]
                    let price = (Int(parseData[i+1]) ?? 0) * (Int(parseData[i+2]) ?? 0)
                    
                    returnValue.detail.append((String(item), price))
                }
                
            }
            print(result)
        }
        else {
            //發票號碼 10
            //date 7
            //random code 4
            //8
            //total 8 -> base16
            //買方統編 8
            //賣方統編 8
            //加密 24
            //10:消費品筆數base10:消費品筆數base10:編碼 big5 0,UTF-8 1,Base64 2(定義後面資訊編碼):
            //品名：數量：單價
            let result = String(d)
            let parseData = result.split(separator: ":")
            let total = Int(substr(str: String(parseData[0]), start: 29, end: 37), radix: 16) ?? 0
            returnValue.total = total
            returnValue.code = substr(str: String(parseData[0]), start: 0, end: 10)
            returnValue.date = substr(str: String(parseData[0]), start: 10, end: 17)
            if Int(parseData[4]) == 1 {
                for i in stride(from: 5, to: parseData.count, by: 3) {
                    if i+1 < parseData.count && i+2 < parseData.count {
                        let item = parseData[i]
                        let price = (Int(parseData[i+1]) ?? 0) * (Int(parseData[i+2]) ?? 0)
                        returnValue.detail.append((String(item), price))
                    }
                    
                }
            }
        }
    }
    return returnValue
}

