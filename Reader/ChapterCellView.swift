import UIKit
import WebKit


class ChapterCellView: CommonView<ChapterCellViewModel>, ReusableContentView {

    func prepareForReuse() {

        observer = nil
        webView.loadHTMLString("", baseURL: .none)
    }

    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!

//    override func awakeFromNib() {
//
//        webView.scrollView.addObserver(self,
//                                       forKeyPath: "contentSize",
//                                       options: [.old, .new],
//                                       context: .none)
//    }
//
//    deinit {
//
//        webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
//    }

//    override func observeValue(forKeyPath keyPath: String?,
//                               of object: Any?,
//                               change: [NSKeyValueChangeKey : Any]?,
//                               context: UnsafeMutableRawPointer?) {
//
//        if let scroll = object as? UIScrollView, keyPath == "contentSize" {
//            print("scroll.contentSize.height = \(scroll.contentSize.height)")
//            let old = change?[.oldKey] as? CGSize
//            let new = change?[.newKey] as? CGSize
//
//            if old?.height != new?.height {
//                setNeedsUpdateConstraints()
//                print("scroll.contentSize.height - changed to new \(new?.height)")
////                setNeedsLayout()
////                webViewHeight.constant = webView.scrollView.contentSize.height
//            }
//        }
//    }

    override func updateConstraints() {

        if let height = viewModel?.containerBounds.height {
            webViewHeight.constant = height
        }

        super.updateConstraints()

        print("scroll.contentSize updateConstraints")
    }

    private var observer: Observer<String?>?

    override func modelBinded(_ model: ChapterCellViewModel) {

        observer = model.webViewContent.addObserver(callImmediately: true) { [weak self] contentStr in
            self?.webView.loadHTMLString(contentStr ?? "", baseURL: model.baseUrl)
        }
    }
}


class ChapterCellViewModel: CommonViewModelImpl, CellViewModel {

    var indexPath: IndexPath?
    var onLayout: ((IndexPath?) -> Void)?

    fileprivate let containerBounds: CGRect

    fileprivate let webViewContent = Observable<String?>(.none)
    fileprivate let baseUrl: URL

    private let resource: FRResource

    init(withResource resource: FRResource, bounds: CGRect) {

        self.resource = resource
        baseUrl = URL(fileURLWithPath: resource.fullHref.deletingLastPathComponent)
        containerBounds = bounds

        super.init()

        if let html = try? String(contentsOfFile: resource.fullHref, encoding: String.Encoding.utf8) {
            webViewContent.value = html
        }
    }

    override class func viewClass() -> UIView.Type {

        return ChapterCellView.self
    }
}
