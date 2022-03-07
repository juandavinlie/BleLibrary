//
//  CryptoService.swift
//  ble_app
//
//  Created by Juan Lie on 23/2/22.
//

import Foundation
import CryptoSwift

class CryptoService {
    let aesKey : String
    let aesIv : String
    let aes : AES!

    init(aesKey : String, aesIv : String) {
        self.aesKey = aesKey
        self.aesIv = aesIv
        do {
            self.aes = try AES(key: Array("asdfghjklqwertzu".utf8), blockMode: CBC(iv: Array("qwertzuiopasdfgh".utf8)), padding: .pkcs7)
            print("AES valid")
        } catch {
            self.aes = nil
            print("error")
        }
    }
    
    func encrypt(value : String) -> [UInt8]? {
        do {
            let valueBytes = value.bytes
            print(valueBytes)
            let encryptedBytes = try self.aes.encrypt(valueBytes)
            print(encryptedBytes.toHexString())
            print("Encrypted")
            return encryptedBytes
        } catch {
            print("Encryption failed")
            return nil
        }
    }
    
    func decrypt(data : Data) -> String? {
        do {
            let value : String? = String(data: data, encoding: .utf8)
            if value != nil {
                let valueBytes = stringToBytes(value!)
                let decryptedBytes = try aes.decrypt(valueBytes!)
                let decryptedData = Data(bytes: decryptedBytes, count: decryptedBytes.count)
                print("Decrypted")
                return String(data: decryptedData, encoding: .isoLatin1)
            } else {
                return nil
            }
        } catch {
            print("Decryption failed")
            return nil
        }
    }
    
    func stringToBytes(_ string: String) -> [UInt8]? {
        let length = string.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
}
