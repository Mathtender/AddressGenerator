import Foundation
import CommonCrypto
import CryptoKit
import CryptoSwift

struct BIP39 {
    private static let wordList: [String] = {
        guard let url = Bundle.module.url(forResource: "words", withExtension: "txt"),
              let content = try? String(contentsOf: url, encoding: .utf8) else {
            fatalError("BIP-39 wordlist not found.")
        }
        return content.components(separatedBy: .newlines)
    }()
    
    private static func generateEntropy(length: Int) -> Data {
        let asciiCharacters = (33...126).map { Character(UnicodeScalar($0)!) } // Printable ASCII characters
        let randomString = String((0..<length).map { _ in asciiCharacters.randomElement()! })

        let data = Data(randomString.utf8)
        let hash = SHA256.hash(data: data)

        return Data(hash.prefix(16))
    }
    
    private static func addChecksum(to entropy: Data) -> String {
        let hash = SHA256.hash(data: entropy)
        let hashBits = String(hash.map { String($0, radix: 2).leftPadded(to: 8) }.joined())
        let entropyBits = String(entropy.map { String($0, radix: 2).leftPadded(to: 8) }.joined())
        let checksumLength = entropy.count * 8 / 32
        
        return entropyBits + hashBits.prefix(checksumLength)
    }
    
    private static func splitIntoSegments(binaryString: String) -> [Int] {
        let segmentLength = 11
        
        return stride(from: 0, to: binaryString.count, by: segmentLength).compactMap { start in
            let startIndex = binaryString.index(binaryString.startIndex, offsetBy: start)
            let endIndex = binaryString.index(startIndex, offsetBy: min(segmentLength, binaryString.count - start))
            return Int(binaryString[startIndex..<endIndex], radix: 2)
        }
    }
    
    private static func mapToMnemonic(segments: [Int], wordList: [String]) -> [String] {
        return segments.map { wordList[$0] }
    }

    static func generateMnemonic() -> String {
        let entropy = generateEntropy(length: 16)
        let binaryString = addChecksum(to: entropy)
        let segments = splitIntoSegments(binaryString: binaryString)
        let mnemonicWords = mapToMnemonic(segments: segments, wordList: wordList)
        
        return mnemonicWords.joined(separator: " ")
    }
    
    static func mnemonicToEntropy(_ mnemonic: String) -> Data? {
        let words = mnemonic.lowercased().split(separator: " ").map { String($0) }
        
        guard words.count == 12 else {
            print("Invalid number of words in the mnemonic.")
            return nil
        }
        
        let indices = words.compactMap { wordList.firstIndex(of: $0) }
        
        guard indices.count == words.count else {
            print("Mnemonic contains invalid words.")
            return nil
        }
        
        let binaryString = indices
            .map { String($0, radix: 2).leftPadded(to: 11) }
            .joined()
        
        let entropyLength = (binaryString.count * 32) / 33
        let checksumLength = binaryString.count - entropyLength
        
        let entropyBits = binaryString.prefix(entropyLength)
        let checksumBits = binaryString.suffix(checksumLength)
        
        guard let entropy = Data(bits: String(entropyBits)) else {
            print("Failed to convert entropy bits to data.")
            return nil
        }
        
        let calculatedChecksum = entropy.sha256Bits.prefix(checksumLength)
        guard calculatedChecksum == checksumBits else {
            print("Checksum does not match.")
            return nil
        }
        
        return entropy
    }
    
    static func entropyToSeed(entropy: Data) -> Data? {
        let salt = "mnemonic"
        
        let seed = try! PKCS5.PBKDF2(password: entropy.bytes, salt: salt.data(using: .utf8)!.bytes, iterations: 2048, keyLength: 64)
        let seedValue = try! seed()
        let seedData = Data(seedValue)
        
        return seedData
    }
    
    static func generateSeed(from mnemonic: String) -> Data? {
        let normalizedMnemonic = mnemonic.folding(options: .diacriticInsensitive, locale: .current)
        let salt = "mnemonic"
        
        guard let mnemonicData = normalizedMnemonic.data(using: .utf8),
              let saltData = salt.data(using: .utf8) else {
            print("Error converting mnemonic or salt to data.")
            return nil
        }
        
        do {
            let seed = try PKCS5.PBKDF2(
                password: Array(mnemonicData),
                salt: Array(saltData),
                iterations: 2048,
                keyLength: 64,
                variant: .sha2(.sha512)
            ).calculate()
            
            return Data(seed)
        } catch {
            print("Error generating seed: \(error)")
            return nil
        }
    }
}
