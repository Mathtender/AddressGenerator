import Foundation
import BigInt

final class Base58Encoder {

    private static let alphabet = [UInt8]("123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".utf8)
    private static let zero = BigUInt(0)
    private static let radix = BigUInt(alphabet.count)
    
    public static func base58Encode(_ bytes: [UInt8]) -> String {
        var answer: [UInt8] = []
        var integerBytes = BigUInt(Data(bytes))
        
        while integerBytes > 0 {
            let (quotient, remainder) = integerBytes.quotientAndRemainder(dividingBy: radix)
            answer.insert(alphabet[Int(remainder)], at: 0)
            integerBytes = quotient
        }
        
        let prefix = Array(bytes.prefix { $0 == 0 }).map { _ in alphabet[0] }
        answer.insert(contentsOf: prefix, at: 0)
        
        return String(bytes: answer, encoding: String.Encoding.utf8)!
    }
}
