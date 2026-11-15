import UIKit

/// Choppy hides the system navigation bar (see `ChoppyScreen`), which also disables the
/// swipe-from-the-edge back gesture. This turns it back on whenever there is a screen to go back to.
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }
}
