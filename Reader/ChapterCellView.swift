import UIKit
import WebKit


class ChapterCellView: CommonView<ChapterCellViewModel>, WKNavigationDelegate {

    @IBOutlet weak var webViewHeight: NSLayoutConstraint!
    @IBOutlet weak var webView: WKWebView!

    override func awakeFromNib() {

        webView.navigationDelegate = self
        webView.scrollView.addObserver(self,
                                       forKeyPath: "contentSize",
                                       options: [.old, .new],
                                       context: .none)
    }

    deinit {

        webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {

        if object is UIScrollView, keyPath == "contentSize" {
            let old = change?[.oldKey] as? CGSize
            let new = change?[.newKey] as? CGSize

            if old?.height != new?.height {
                webViewHeight.constant = webView.scrollView.contentSize.height
            }
        }
    }

    private var observer: Observer<String?>?

    override func modelBinded(_ model: ChapterCellViewModel) {

        observer = model.webViewContent.addObserver(callImmediately: true) { [weak self] contentStr in
            self?.webView.loadHTMLString(contentStr ?? "", baseURL: model.baseUrl)
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        UIView.animate(withDuration: 0.3) {
            webView.alpha = 1
        }
    }
}


class ChapterCellViewModel: CommonViewModelImpl, CellViewModel {

    var indexPath: IndexPath?
    var onLayout: ((IndexPath?) -> Void)?

    fileprivate let webViewContent = Observable<String?>(.none)
    fileprivate let baseUrl: URL?

    private let resource: FRResource

    init(withResource resource: FRResource) {

        self.resource = resource
        baseUrl = URL(fileURLWithPath: resource.fullHref.deletingLastPathComponent)

        super.init()

        if let html = try? String(contentsOfFile: resource.fullHref, encoding: String.Encoding.utf8) {
            webViewContent.value = html
        }
    }

    override class func viewClass() -> UIView.Type {

        return ChapterCellView.self
    }
}
