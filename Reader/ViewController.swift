import UIKit
import WebKit


class MainViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    let bookName = Observable<String>("small")
    private var tableCells: [ChapterCellViewModel]? {
        didSet {
            if let tableCells = tableCells {
                let section = TableSection(footerViewModel: .none,
                                           headerViewModel: .none,
                                           cells: tableCells,
                                           onSelect: .none)
                tableViewModel = TableViewModel(withModel: [section])
            }
        }
    }

    var tableViewModel = TableViewModel(withModel: []) {
        didSet {
            tableViewModel.bind(toTable: table)
            table.reloadData()
        }
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        let tableBounds = table.bounds

        bookName.addObserver(owner: self, callImmediately: true) { [weak self] bookName in

            self?.indicator.startAnimating()

            DispatchQueue.global(qos: .userInitiated).async {
                if let path = Bundle.main.path(forResource: bookName, ofType: "epub") {
                    if let book = try? FREpubParser().readEpub(epubPath: path, removeEpub: false, unzipPath: .none) {
//                        let chapters = [ChapterCellViewModel(withResource: book.spine.spineReferences[1].resource)]
                        let chapters = book.spine.spineReferences.compactMap { ChapterCellViewModel(withResource: $0.resource, bounds: tableBounds) }

                        DispatchQueue.main.async {
                            self?.indicator.stopAnimating()
                            self?.tableCells = chapters
                        }
                    }
                }
            }
        }
    }
}
