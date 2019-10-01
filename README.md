# TypeFill

----

## Installation

---

### make

``` sh
brew install make
make install
```

### Swift Package Manager

``` sh
swift build -c release
cp .build/release/typefill /usr/local/bin
```

### mint

``` sh
brew install mint
mint install yume190/TypeFill
```

### Usage

``` sh
typefill doc --single-file example/sample.swift -- /PATH/TO/example/sample.swift
typefill doc -- -workspace PATH/TO/YOUR.xcworkspace -scheme YOUR_SCHEME
typefill doc --spm --spm-module Target
```

## Ref

 * [SourceKitten](https://github.com/jpsim/SourceKitten/tree/swift-5.1)
 * [SwiftSupport](https://github.com/apple/swift/blob/master/tools/SourceKit/docs/SwiftSupport.txt)
 * [Protocol](https://github.com/apple/swift/blob/master/tools/SourceKit/docs/Protocol.md)