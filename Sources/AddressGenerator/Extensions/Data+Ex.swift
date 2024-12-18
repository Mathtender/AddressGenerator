import Foundation
import CommonCrypto

extension Data {
    var hex: String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    var sha256Bits: String {
        let hash = sha256()
        return hash.reduce("") { $0 + String($1, radix: 2).leftPadded(to: 8) }
    }
    
    func sha256() -> Data {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        self.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(self.count), &hash)
        }
        return Data(hash)
    }
    
    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hex.index(hex.startIndex, offsetBy: i * 2)
            let k = hex.index(j, offsetBy: 2)
            let bytes = hex[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }

    init?(bits: String) {
        var bytes = [UInt8]()
        var currentByte = 0
        var bitCount = 0
        
        for bit in bits {
            guard let bitValue = Int(String(bit)) else { return nil }
            currentByte = (currentByte << 1) | bitValue
            bitCount += 1
            if bitCount == 8 {
                bytes.append(UInt8(currentByte))
                currentByte = 0
                bitCount = 0
            }
        }
        
        if bitCount > 0 {
            bytes.append(UInt8(currentByte << (8 - bitCount)))
        }
        
        self.init(bytes)
    }
}
