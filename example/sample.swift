import UIKit

let a: Int = 1

class A: UIViewController {
    @IBOutlet final open weak var btn1: UIButton!
    @IBOutlet final public weak var btn2: UIButton!
    @IBOutlet final internal weak var btn3: UIButton!
    @IBOutlet final fileprivate weak var btn4: UIButton!
    @IBOutlet final private weak var btn5: UIButton!
    @IBOutlet private final var btn6: UIButton!
    @IBAction private final func numberKeyIn(_ sender: UIButton) {
    }
}

