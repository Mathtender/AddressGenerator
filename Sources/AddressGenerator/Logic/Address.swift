import Foundation
import CryptoKit

struct Address {
    
    let value: String
    
    init(publicKey: PublicKey) {
        let pubKeyHash = Self.publicKeyHash(from: publicKey.data)
        let networkPrefix = Data([0x00])
        let prefixedPubKeyHash = networkPrefix + pubKeyHash
        let checksum = Self.computeChecksum(prefixedPubKeyHash)
        let addressData = prefixedPubKeyHash + checksum
        
        value = Base58Encoder.base58Encode(addressData.bytes)
    }
    
    private static func ripemd160(_ data: Data) -> Data {
        var ripemd160 = RIPEMD160()
        ripemd160.update(data: data)
        return ripemd160.finalize()
    }
    
    private static func sha256(_ data: Data) -> Data {
        return Data(SHA256.hash(data: data))
    }
    
    private static func publicKeyHash(from publicKey: Data) -> Data {
        let sha256Hash = sha256(publicKey)
        let ripemd160Hash = ripemd160(sha256Hash)
        return ripemd160Hash
    }
    
    private static func computeChecksum(_ data: Data) -> Data {
        let doubleSHA256 = sha256(sha256(data))
        return doubleSHA256.prefix(4)
    }
}
