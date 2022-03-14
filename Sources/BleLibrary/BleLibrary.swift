import CryptoSwift
import UIKit

public struct BleLibrary {
    private var blueService : BluetoothService

    public init() {
        blueService = BluetoothService()
        print("Initialised BleLibrary..")
    }
    
    public func connect() {
        blueService.connect()
    }
}
