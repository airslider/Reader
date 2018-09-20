import UIKit
import Foundation


class Window: UIWindow {

    var onShake: (() -> Void)?

    override var canBecomeFirstResponder: Bool {

        return true
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {

        if event?.subtype == .motionShake {
            onShake?()
        }
        
        super.motionEnded(motion, with: event)
    }
}
