import Foundation

public final class Generator {
    
    public init() {}
    
    public func generateMnemonic() -> String {
        return BIP39.generateMnemonic()
    }
    
    public func generateAddresses(
        mnemonic: String,
        hardenedCount: Int = 1,
        nonHardenedCount: Int = 0
    ) -> [String] {
        guard hardenedCount + nonHardenedCount > 0 else {
            return []
        }
        
        guard let seed = BIP39.generateSeed(from: mnemonic) else {
            print("Error creating seed")
            return []
        }
        
        let masterKey = PrivateKey(seed: seed)
        
        var privateKeys = [PrivateKey]()
        for index in 0..<hardenedCount {
            guard let derivedKey = PrivateKey(
                masterKey: masterKey,
                index: UInt32(index),
                hardened: false
            ) else {
                print("Error creating derived key")
                continue
            }
            
            privateKeys.append(derivedKey)
        }
        for index in 0..<nonHardenedCount {
            guard let derivedKey = PrivateKey(
                masterKey: masterKey,
                index: 0x80000000 + UInt32(index),
                hardened: true
            ) else {
                print("Error creating derived key")
                continue
            }
            
            privateKeys.append(derivedKey)
        }
        
        var addresses = [Address]()
        for privateKey in privateKeys {
            guard let publicKey = PublicKey(privateKey: privateKey, compressed: true) else {
                print("Error creating public key")
                continue
            }
            
            let address = Address(publicKey: publicKey)
            
            addresses.append(address)
        }
        
        return addresses.map { $0.value }
    }
}
