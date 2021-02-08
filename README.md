# TypeFill

----

A little cli tool to help you fill your `variables type`.

And add `private final` attribute to `@IBAction`, `@IBOutlet`, and `@objc`.(Rewriting ...)

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
typefill single --filePath /ABSOLUTE/PATH/sample.swift --sdk macosx

typefill spm --moduleName TypeFillKit

typefill workspace -workspace PATH/TO/YOUR.xcworkspace -scheme YOUR_SCHEME
```

## The Support Part & Todolist

- [x] typefill variables like `let a = 1` or `var a = "1"`.
- [x] typefill keyword like `let ``default`` = 1`.
- [x] typefill `guard let` and `if let`.
- [x] typefill some colsure input.
    - `{ a, b in }`
    - `{ (a, b) in }`
- [ ] typefill binding tuple `let (aa, bb) = (1, 2)`
- [ ] add `private final` attribute to `@IBAction/@IBOutlet/@objc` by using `--ibaction/--iboutlet/--objc`.(Rewriting)

## Ref

 * [SourceKitten](https://github.com/jpsim/SourceKitten/tree/swift-5.1)
 * [SwiftSupport](https://github.com/apple/swift/blob/master/tools/SourceKit/docs/SwiftSupport.txt)
 * [Protocol](https://github.com/apple/swift/blob/master/tools/SourceKit/docs/Protocol.md)
 * [Accessors](https://github.com/apple/swift/blob/2c9def8e74ede41f09c431dab5422bb0f8cc6adb/tools/SourceKit/lib/SwiftLang/SwiftEditor.cpp#L1101-L1105)
 * [Attributes](https://github.com/apple/swift/blob/0a92b1cda36706b5e0bd30c172a24391aa524309/tools/SourceKit/lib/SwiftLang/SwiftLangSupport.cpp#L65-L81)

## License

MIT licensed.
