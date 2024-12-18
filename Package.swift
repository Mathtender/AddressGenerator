// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AddressGenerator",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "AddressGenerator",
            targets: ["AddressGenerator"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.3"),
        .package(url: "https://github.com/attaswift/BigInt.git", from: "5.5.1"),
        .package(url: "https://github.com/Boilertalk/secp256k1.swift.git", from: "0.1.7")
    ],
    targets: [
        .target(
            name: "AddressGenerator",
            dependencies: [
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "BigInt", package: "BigInt"),
                .product(name: "secp256k1", package: "secp256k1.swift")
            ],
            resources: [
                .process("words.txt")
            ]
        ),
    ]
)
