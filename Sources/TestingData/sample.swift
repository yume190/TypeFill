//import UIKit
import Foundation
class UIViewController: NSObject {}
class UIButton: NSObject {}
let a = 1
class A: UIViewController {
    @IBOutlet open weak var btn1: UIButton!
    @IBOutlet final public weak var btn2: UIButton!
    @IBOutlet final internal weak var btn3: UIButton!
    @IBOutlet final fileprivate weak var btn4: UIButton!
    @IBOutlet final private weak var btn5: UIButton!
    @IBOutlet private final var btn6: UIButton!
    @IBAction private final func numberKeyIn(_ sender: UIButton) {}
    func test() {
        let `default` = 1
        let (aa, bb) = (1, 2)
        let aabb = aa + bb
        let ss: Int? = nil

        let abcdef: () -> Void = { [weak abcdefP1 = self] in

        }

        let abcdefg: () -> Void = { [weak self] in

        }

        if let cc = ss {
            print(cc)
        }

        guard let dd = ss else {
            return
        }

        do {
            try self.error()
            let a = A()
        } catch {
            print(error)
        }
    }

    func error() throws {
    }
}
