import CryptoSwift
import UIKit

public struct BleLibrary {
    private let blueService = BluetoothService()

    public init() {
        print("Initialised BleLibrary..")
    }
    
    public func connect(sender: UIButton!) {
        blueService.connect()
    }
}
