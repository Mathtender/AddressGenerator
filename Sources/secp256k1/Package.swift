// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "secp256k1",
    products: [
        .library(
            name: "secp256k1",
            targets: ["secp256k1"]
        ),
    ],
    targets: [
        .target(
            name: "libsecp256k1",
            path: "./secp256k1/Classes",
            exclude: [
                "exporter"
            ],
            sources: [
                ".",
                "secp256k1/src",
                "secp256k1/include",
                "secp256k1/contrib",
                "secp256k1/src/modules/ecdh",
                "secp256k1/src/modules/recovery"
            ],
            publicHeadersPath: "secp256k1/include",
            cSettings: [
                .headerSearchPath("secp256k1/src"),
            ]
        ),
        .target(
            name: "secp256k1",
            dependencies: ["libsecp256k1"],
            path: "./secp256k1/Classes/exporter",
            sources: ["."])
    ]
)
