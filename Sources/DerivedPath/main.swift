import Foundation
import Derived

let paths = CommandLine.arguments.dropFirst()
guard !paths.isEmpty else {
    print("請輸入至少一個 path")
    exit(0)
}

paths.forEach { path in
    print("""
    \(path) -> \(DerivedPath(path)?.path() ?? "Not Found")
    """)
}
