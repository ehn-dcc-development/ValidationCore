import Foundation

public protocol QrCodeReceiver {

    func onQrCodeResult(_ result: String?)
    
    func canceled()

}
