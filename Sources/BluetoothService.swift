//
//  File 2.swift
//  
//
//  Created by Juan Lie on 7/3/22.
//

import Foundation
import CoreBluetooth
import UIKit

extension BluetoothService :  CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Status is powered on")
        } else {
            print("Status is off")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name != nil {
            print(peripheral.name!)
            if peripheral.name!.lowercased() == "carro-ble-test-2" {
                blePeripheral = peripheral
                centralManager.stopScan()
                centralManager.connect(peripheral)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
}

extension BluetoothService : CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("A service is found")
        guard let services = peripheral.services else {
            print("Service error occurred")
            return
        }
        
        for service in services {
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([rxUUID, scUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    
        guard let characteristics = service.characteristics else {
            print("Characteristics don't exist")
            return
        }
        
        for characteristic in characteristics {
            if characteristic.uuid == rxUUID {
                rxCharacteristic = characteristic
            } else if characteristic.uuid == scUUID {
                peripheral.readValue(for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("A characteristic is found")
        guard let data = characteristic.value else {
            print("Characteristic error")
            return
        }
        
        if characteristic.uuid == scUUID {
            let crypto = CryptoService(aesKey: "asdfghjklqwertzu", aesIv: "qwertzuiopasdfgh")
            let decryptedString : String? = crypto.decrypt(data: data)
            if decryptedString != nil {
                print("Writing value...")
                peripheral.writeValue((decryptedString?.data(using: .utf8))! as Data, for: characteristic, type: .withResponse)
                print("Written")
            } else {
                print("Failed to decrypt. Disconnecting...")
            }
        }
    }
}

class BluetoothService : UIViewController {
    private var centralManager : CBCentralManager!
    private var blePeripheral : CBPeripheral!
    private var serviceUUID : CBUUID = CBUUID(string: "1fafc201-1fb5-459e-8fcc-c5c9c331914b")
    private var rxUUID : CBUUID = CBUUID(string: "6d68efe5-04b6-4a85-abc4-c2670b7bf7fd")
    private var rxCharacteristic : CBCharacteristic!
    private var scUUID : CBUUID = CBUUID(string: "38fa1994-8d3a-11ec-b909-0242ac120030")
    private var grantedAccess : Bool = false
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.global())
    }
    
//    @IBAction func connect(_ sender: Any) {
//        if centralManager.state == .poweredOn {
//            print("Scanning...")
//            centralManager.scanForPeripherals(withServices: nil, options: nil)
//        } else {
//            print("Scanning failed")
//        }
//    }
    
    func connect() {
        if centralManager.state == .poweredOn {
            print("Scanning...")
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Scanning failed")
        }
    }
    
    func writeToCharacteristic(command : String, characteristic : CBCharacteristic) {
        let crypto = CryptoService(aesKey: "asdfghjklqwertzu", aesIv: "qwertzuiopasdfgh")

        let encryptedBytes : [UInt8]? = crypto.encrypt(value: command)
        if encryptedBytes != nil {
            blePeripheral.writeValue(Data(bytes: encryptedBytes!, count: encryptedBytes!.count), for: rxCharacteristic, type: .withResponse)
        }
    }
    
//    @IBAction func lock(_ sender: Any) {
//        writeToCharacteristic(command: "Vehicle Lock.", characteristic: rxCharacteristic)
//    }
    
    func lock() {
        writeToCharacteristic(command: "Vehicle Lock.", characteristic: rxCharacteristic)
    }
    
//    @IBAction func unlock(_ sender: Any) {
//        writeToCharacteristic(command: "Vehicle Unlock.", characteristic: rxCharacteristic)
//    }
    
    func unlock() {
        writeToCharacteristic(command: "Vehicle Unlock.", characteristic: rxCharacteristic)
    }
}
