import Foundation
import AVFoundation

public class QrCodeScanner: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView: UIView!
    var qrCodeReceiver: QrCodeReceiver?
    var viewController: UIViewController?
    var qrPrompt: String?
    var baseView: UIView!
    let supportedBarCodes = [AVMetadataObject.ObjectType.qr]

    public func scan(_ viewController: UIViewController, _ qrPrompt: String, _ receiver: QrCodeReceiver) {
        self.qrCodeReceiver = receiver
        self.viewController = viewController
        self.qrPrompt = qrPrompt
        checkPermission(viewController, qrPrompt)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rotated),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    @objc
    func rotated() {
        if viewController != nil && qrPrompt != nil && videoPreviewLayer != nil && baseView != nil && captureSession !=
            nil {
            videoPreviewLayer.removeFromSuperlayer()
            baseView.removeFromSuperview()
            captureSession.stopRunning()
            setup(viewController!, qrPrompt!)
        }
    }

    func checkPermission(_ viewController: UIViewController, _ qrPrompt: String) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.setup(viewController, qrPrompt)
            }
        default:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if (granted) {
                    DispatchQueue.main.async {
                        self.setup(viewController, qrPrompt)
                    }
                } else {
                    print("User has denied permission to use camera")
                    DispatchQueue.global(qos: .background).async {
                        self.qrCodeReceiver?.canceled()
                    }
                }
            }
        }
    }

    func setup(_ viewController: UIViewController, _ qrPrompt: String) {
        guard let captureDevice = AVCaptureDevice.default(for: AVMediaType.video),
              let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Could not get AVCaptureDevice")
            DispatchQueue.global(qos: .background).async {
                self.qrCodeReceiver?.canceled()
            }
            return
        }
        self.baseView = UIView()
        baseView.frame = viewController.view.frame
        captureSession = AVCaptureSession()
        if !captureSession.canAddInput(captureDeviceInput) {
            print("Could not start AVCaptureSession")
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

        // let isLandscape = UIDevice.current.orientation.isLandscape
        let minRectLen = min(UIScreen.main.bounds.width * 0.8, UIScreen.main.bounds.height * 0.8)
        let padding = min(UIScreen.main.bounds.width * 0.05, UIScreen.main.bounds.height * 0.05)
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        let videoPreview = UIView()
        videoPreview.frame = CGRect(x: padding, y: padding, width: minRectLen, height: minRectLen)
        videoPreview.layer.addSublayer(videoPreviewLayer)
        videoPreviewLayer.frame = videoPreview.frame

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
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2

        let promptLabel = UILabel()
        promptLabel.numberOfLines = 0
        promptLabel.lineBreakMode = .byWordWrapping
        promptLabel.textAlignment = .center
        promptLabel.text = qrPrompt
        promptLabel.frame = CGRect(
            x: padding,
            y: videoPreview.center.y + minRectLen / 2 + padding * 2,
            width: baseView.frame.width,
            height: 50)
        promptLabel.sizeToFit()

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Abbrechen", for: .normal)
        closeButton.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        closeButton.frame = CGRect(
            x: padding,
            y: promptLabel.center.y + padding,
            width: baseView.frame.width / 2,
            height: 50)
        closeButton.sizeToFit()
        closeButton.center.x = promptLabel.center.x

        baseView.addSubview(videoPreview)
        baseView.addSubview(closeButton)
        baseView.addSubview(qrCodeFrameView)
        baseView.addSubview(promptLabel)
        baseView.backgroundColor = .white
        viewController.view.addSubview(baseView)

        captureSession.startRunning()
    }

    @objc
    public func buttonAction(_ sender: UIButton!) {
        videoPreviewLayer.removeFromSuperlayer()
        baseView.removeFromSuperview()
        captureSession.stopRunning()
        NotificationCenter.default.removeObserver(self)
        DispatchQueue.global(qos: .background).async {
            self.qrCodeReceiver?.canceled()
        }
    }

    @objc
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject],
                               from connection: AVCaptureConnection) {
        print("Detected QRCode")
        guard let metadataObject = metadataObjects.first,
            let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = readableObject.stringValue else {
                return
        }
        baseView.removeFromSuperview()
        qrCodeFrameView.frame = readableObject.bounds
        captureSession.stopRunning()
        print("Detected QRCode with value \(stringValue)")
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
