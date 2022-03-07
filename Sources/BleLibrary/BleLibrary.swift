import CryptoSwift

public struct BleLibrary {
    private let blueService = BluetoothService()

    public init() {
        print("Initialised BleLibrary..")
    }
    
    public func connect() {
        blueService.connect()
    }
}
