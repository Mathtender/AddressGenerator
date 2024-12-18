import Foundation
import BigInt
import CryptoKit
import CryptoSwift

struct PrivateKey {
    let data: Data
    let chainCode: Data
    
    init(seed: Data) {
        let hmacKey = "Bitcoin seed".data(using: .utf8)!
        let hmacResult = Self.hmacSha512(key: hmacKey, message: seed)

        let privateKey = hmacResult.prefix(32)
        let chainCode = hmacResult.suffix(32)
        
        self.data = privateKey
        self.chainCode = chainCode
    }
    
    init?(
        masterKey: PrivateKey,
        index: UInt32,
        hardened: Bool
    ) {
        if hardened {
            guard index >= 0x80000000 else {
                print("Hardened keys require index >= 0x80000000")
                return nil
            }
        } else {
            guard index < 0x80000000 else {
                print("Non-hardened keys require index < 0x80000000")
                return nil
            }
        }
        
        let indexData = withUnsafeBytes(of: index.bigEndian) { Data($0) }
        var message: Data
        
        if hardened {
            message = Data([0x00]) + masterKey.data + indexData
        } else {
            guard let publicKey = PublicKey(privateKey: masterKey, compressed: true) else {
                print("Failed to derive public key from private key.")
                return nil
            }
            message = publicKey.data + indexData
        }
        
        let hmacResult = Self.hmacSha512(key: masterKey.chainCode, message: message)
        let childPrivateKey = hmacResult.prefix(32)
        let childChainCode = hmacResult.suffix(32)
        
        guard let derivedKeyInt = BigInt(childPrivateKey.hex, radix: 16),
              let curveOrder = BigInt("FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141", radix: 16),
              derivedKeyInt < curveOrder else {
            print("Invalid derived private key.")
            return nil
        }

        self.data = Data(childPrivateKey)
        self.chainCode = Data(childChainCode)
    }
    
    private static func hmacSha512(key: Data, message: Data) -> Data {
        let keySymmetric = SymmetricKey(data: key)
        let hmac = CryptoKit.HMAC<SHA512>.authenticationCode(for: message, using: keySymmetric)
        return Data(hmac)
    }
}
