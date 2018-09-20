import UIKit
import WebKit
import MediaPlayer


class MainViewController: UIViewController {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var scroll: UIScrollView!

    let bookName = Observable<String>("small")

    private lazy var initialVolume = AVAudioSession.sharedInstance().outputVolume
    private lazy var windowFrame = UIApplication.shared.keyWindow!.bounds

    override func viewDidLoad() {

        super.viewDidLoad()

        let volumeView = MPVolumeView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        volumeView.isHidden = false
        volumeView.alpha = 0.01
        view.addSubview(volumeView)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(MainViewController.volumeDidChange(notification:)),
                                               name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"),
                                               object: nil)

        bookName.addObserver(owner: self, callImmediately: true) { [weak self] bookName in

            self?.indicator.startAnimating()
            self?.stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

            DispatchQueue.global(qos: .userInitiated).async {
                if let path = Bundle.main.path(forResource: bookName, ofType: "epub"),
                    let book = try? FREpubParser().readEpub(epubPath: path, removeEpub: false, unzipPath: .none) {
                    let chapters = book.spine.spineReferences.compactMap { ChapterCellViewModel(withResource: $0.resource) }

                    DispatchQueue.main.async {
                        let views = chapters.map { $0.makeView() }
                        views.forEach { self?.stack.addArrangedSubview($0) }
                        self?.indicator.stopAnimating()
                    }
                }
            }
        }
    }

    @objc func volumeDidChange(notification: NSNotification) {

        if let volume = notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
            let shouldScrollDown: Bool
            if volume == initialVolume && volume > 0.8 {
                shouldScrollDown = false
            }
            else {
                if volume == initialVolume && volume < 0.1 {
                    shouldScrollDown = true
                }
                else {
                    shouldScrollDown = volume < initialVolume
                }
            }
            initialVolume = volume
            scrollPage(down: shouldScrollDown)
        }
    }

    private func scrollPage(down: Bool) {

        for view in stack.arrangedSubviews {
            let viewInWindowFrame = view.convert(view.frame, to: .none)
            if viewInWindowFrame.intersects(windowFrame) {
                let nextYPoint: CGFloat
                if down {
                    nextYPoint = view.frame.origin.y + view.frame.height
                }
                else {
                    nextYPoint = view.frame.origin.y
                }
                scroll.contentOffset = CGPoint(x: 0, y: nextYPoint)
                break
            }
        }
    }
}
