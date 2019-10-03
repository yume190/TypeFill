import UIKit
let a = 1
class A: UIViewController {
    @IBOutlet open weak var btn1: UIButton!
    @IBOutlet public weak var btn2: UIButton!
    @IBOutlet internal weak var btn3: UIButton!
    @IBOutlet fileprivate weak var btn4: UIButton!
    @IBOutlet private weak var btn5: UIButton!
    @IBOutlet var btn6: UIButton!
    @IBAction func numberKeyIn(_ sender: UIButton) {}
    func test() {
        let `default` = 1
        let (aa, bb) = (1, 2)
        let ss: Int? = nil

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