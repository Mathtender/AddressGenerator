import Foundation
import secp256k1

struct PublicKey {
    
    let data: Data
    
    init?(privateKey: PrivateKey, compressed: Bool) {
        guard privateKey.data.count == 32 else {
            print("Invalid private. Expected 32 bytes.")
            return nil
        }

        guard let context = secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN)) else {
            print("Failed to create secp256k1 context.")
            return nil
        }

        defer {
            secp256k1_context_destroy(context)
        }

        var privateKeyValue = [UInt8](repeating: 0, count: 32)
        privateKey.data.copyBytes(to: &privateKeyValue, count: privateKeyValue.count)

        var publicKey = secp256k1_pubkey()

        let result = privateKeyValue.withUnsafeBufferPointer { privateKeyPointer in
            secp256k1_ec_pubkey_create(context, &publicKey, privateKeyPointer.baseAddress!)
        }

        guard result == 1 else {
            print("Failed to generate public key.")
            return nil
        }

        let outputLength = compressed ? 33 : 65
        var serializedPublicKey = [UInt8](repeating: 0, count: outputLength)
        var outputLengthMutable = outputLength

        let serializeFlag = compressed ? UInt32(SECP256K1_EC_COMPRESSED) : UInt32(SECP256K1_EC_UNCOMPRESSED)
        let serializeResult = secp256k1_ec_pubkey_serialize(
            context,
            &serializedPublicKey,
            &outputLengthMutable,
            &publicKey,
            serializeFlag
        )

        guard serializeResult == 1 else {
            print("Failed to serialize public key.")
            return nil
        }

        data = Data(serializedPublicKey.prefix(outputLengthMutable))
    }
}
