import UIKit


protocol Bindable {

    func bind(to model: CommonViewModel?)
}


protocol ViewProvider {

    func makeView(bindImmediately: Bool) -> UIView
}


protocol CommonViewModel {

    static func viewClass() -> UIView.Type
    func makeView(bindImmediately: Bool) -> UIView
}


protocol ScreenViewModel: CommonViewModel {

    var onClose: BlockSimpleBool? { get set }
}


class CommonViewModelImpl: NSObject, CommonViewModel {

    class func viewClass() -> UIView.Type {

        assert(false, "Must be overrided")
        return UIView.self
    }

    func makeView(bindImmediately: Bool = true) -> UIView {

        let view = type(of: self).loadView()
        if bindImmediately, let viewBindable = view as? Bindable {
            viewBindable.bind(to: self)
        }

        return view
    }

    static func loadView() -> UIView {

        let nibFileName = String(describing: self.viewClass())
        let nib = UINib(nibName: String(describing: nibFileName), bundle: .none)
        let view = nib.instantiate(withOwner: .none, options: .none).compactMap { $0 as? UIView }.first!
        ///if crash here, additional outlets exists in xib or view is not present in it
        return view
    }

    func push(toNavigationController navigationController: UINavigationController) {

        let view = self.makeView(bindImmediately: true)
        let controller = view.controller()
        navigationController.pushViewController(controller, animated: true)
        if var screenViewModel = self as? ScreenViewModel {
            screenViewModel.onClose = { animated in
                navigationController.popViewController(animated: animated)
            }
        }
    }
}


class CommonView<ViewModelType: CommonViewModel>: UIView, Bindable {

    var viewModel: ViewModelType? {

        return _viewModel as? ViewModelType
    }

    private var _viewModel: CommonViewModel?

    func bind(to viewModel: CommonViewModel?) {

        _viewModel = viewModel

        if let viewModel = viewModel as? ViewModelType {
            modelBinded(viewModel)
        }
    }

    func modelBinded(_ model: ViewModelType) { }
}


typealias BlockSimple = () -> Void
typealias BlockSimpleBool = (Bool) -> Void
typealias BlockSimpleError = (Error?) -> Void
typealias BlockWithCompletion = (BlockSimpleError?) -> Void
