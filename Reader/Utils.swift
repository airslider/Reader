import UIKit


extension UIWindow {

    func topViewController() -> UIViewController? {

        var topViewController = rootViewController

        while (topViewController?.presentedViewController != nil) {
            topViewController = topViewController?.presentedViewController!
        }
        return topViewController
    }
}


extension UIApplication {

    func topViewController() -> UIViewController? {

        return delegate?.window??.topViewController()
    }
}


extension UIView {

    func subviewsClear() {

        subviews.forEach { $0.removeFromSuperview() }
    }

    func addSubview(fromViewModel viewModel: CommonViewModel) {

        let view = viewModel.makeView(bindImmediately: true)
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.fillContainer()
    }

    func layoutAnimated(_ duration: TimeInterval = 0.5) {

        UIView.animate(withDuration: duration) {

            self.layoutIfNeeded()
        }
    }

    func controller() -> UIViewController {

        return ViewController(withView: self)
    }
}


class ViewController: UIViewController {

    private let rootView: UIView

    init(withView view: UIView) {

        rootView = view

        super.init(nibName: .none, bundle: .none)
    }

    override func loadView() {

        view = rootView
    }

    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}
