# TypeFill

----

A little cli tool to help you fill your variables type, and add `private final` attribute to `IBAction` and `IBOutlet`.

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

# typefill doc --single-file RELATIVE/PATH/sample.swift -- /ABSOLUTE/PATH/sample.swift
typefill doc --single-file example/sample.swift -- /PATH/TO/example/sample.swift
typefill doc -- -workspace PATH/TO/YOUR.xcworkspace -scheme YOUR_SCHEME
typefill doc --spm --spm-module Target
```

## The Support Part & Todolist

- [x] typefill variables like `let a = 1` or `var a = "1"`.
- [x] typefill keyword like `let ``default`` = 1`.
- [x] add `private final` attribute to `IBAction/IBOutlet` by using `--ibaction/--iboutlet`.
- [ ] not support `guard let` and `if let`.
- [ ] not support variables in `do {} catch {}`.
- [ ] not support typefill single file when you using XCode 11. (can't get the `typeName` by request `source.request.cursorinfo`)

## Ref

 * [SourceKitten](https://github.com/jpsim/SourceKitten/tree/swift-5.1)
 * [SwiftSupport](https://github.com/apple/swift/blob/master/tools/SourceKit/docs/SwiftSupport.txt)
 * [Protocol](https://github.com/apple/swift/blob/master/tools/SourceKit/docs/Protocol.md)

## License

MIT licensed.
