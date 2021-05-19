#if canImport(UIKit)
import UIKit
import AVFoundation
import CocoaLumberjackSwift

public class QrCodeScanner: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView: UIView!
    var qrCodeReceiver: QrCodeReceiver?
    var baseView: UIView?
    let supportedBarCodes = [AVMetadataObject.ObjectType.qr]

    public func scan(_ baseView: UIView, _ receiver: QrCodeReceiver) {
        self.qrCodeReceiver = receiver
        checkPermission(baseView)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rotated),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    @objc
    func rotated() {
        if let videoPreviewLayer = videoPreviewLayer,
           let captureSession = captureSession,
           let baseView = baseView {
            videoPreviewLayer.removeFromSuperlayer()
            baseView.removeFromSuperview()
            captureSession.stopRunning()
            setup(baseView)
        }
    }

    func checkPermission(_ baseView: UIView) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.setup(baseView)
            }
        default:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if (granted) {
                    DispatchQueue.main.async {
                        self.setup(baseView)
                    }
                } else {
                    DDLogWarn("User has denied permission to use camera")
                    DispatchQueue.global(qos: .background).async {
                        self.qrCodeReceiver?.canceled()
                    }
                }
            }
        }
    }

    func setup(_ baseView: UIView) {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video),
              let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            DDLogWarn("Could not get AVCaptureDevice")
            DispatchQueue.global(qos: .background).async {
                self.qrCodeReceiver?.canceled()
            }
            return
        }
        captureSession = AVCaptureSession()
        if !captureSession.canAddInput(captureDeviceInput) {
            DDLogWarn("Could not start AVCaptureSession")
            DispatchQueue.global(qos: .background).async {
                self.qrCodeReceiver?.canceled()
            }
            return
        }
        captureSession.addInput(captureDeviceInput)
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)

        captureMetadataOutput.metadataObjectTypes = supportedBarCodes
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)

        let minRectLen = min(baseView.bounds.height, baseView.bounds.width)
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        let videoPreview = UIView()
        videoPreview.frame = CGRect(x: 0, y: 0, width: minRectLen, height: minRectLen)
        videoPreview.layer.addSublayer(videoPreviewLayer)
        videoPreviewLayer.frame = videoPreview.frame
        videoPreviewLayer.cornerRadius = 5

        if videoPreviewLayer.connection?.isVideoOrientationSupported ?? false {
            switch UIDevice.current.orientation {
                case .portraitUpsideDown:
                    videoPreviewLayer.connection?.videoOrientation = .portraitUpsideDown
                case .landscapeLeft:
                    videoPreviewLayer.connection?.videoOrientation = .landscapeRight
                case .landscapeRight:
                    videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
                default:
                    videoPreviewLayer.connection?.videoOrientation = .portrait
            }
        }

        qrCodeFrameView = UIView()
//        drawDetectionFrame()

        baseView.addSubview(videoPreview)
        baseView.addSubview(qrCodeFrameView)
        captureSession.startRunning()
    }

    @objc
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        DDLogInfo("Detected QRCode")
        guard let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue else {
                return
        }
        baseView?.removeFromSuperview()
        qrCodeFrameView.frame = readableObject.bounds
        captureSession.stopRunning()
        DDLogDebug("Detected QRCode with value \(stringValue)")
        videoPreviewLayer.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
        DispatchQueue.global(qos: .background).async {
            self.qrCodeReceiver?.onQrCodeResult(stringValue)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
 
}
#endif
