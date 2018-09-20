import UIKit


typealias CellSelectBlock = (CommonViewModel) -> Void


protocol SectionViewModel {

    var cells: [CellViewModel] { get }
    var onSelect: CellSelectBlock? { get }
    var headerViewModel: CommonViewModel? { get }
    var footerViewModel: CommonViewModel? { get }
}


struct TableSection: SectionViewModel {

    var footerViewModel: CommonViewModel?
    var headerViewModel: CommonViewModel?
    let cells: [CellViewModel]
    let onSelect: CellSelectBlock?
}


protocol CellViewModel: ViewProvider, CommonViewModel {

    var reuseIdentifier: String { get }
    var indexPath: IndexPath? { get set }
    var onLayout: ((IndexPath?) -> Void)? { get set }
}


extension CellViewModel {

    var reuseIdentifier: String {
        get {
            return String(describing: type(of: self))
        }
    }
}


enum CellPosition {

    case last, first, middle, alone, reuse
}


protocol CellPositionRequired {

    var cellPosition: CellPosition? { get set }
}


class TableViewModel: NSObject {

    fileprivate var sections: [SectionViewModel]
    fileprivate var registeredIdentifiers: Set<String> = []

    private weak var table: UITableView?

    func bind(toTable table: UITableView) {

        self.table = table

        table.dataSource = self
        table.delegate = self

        let layoutBlock: (IndexPath?) -> Void = { [weak self] indexPath in
            if let indexPath = indexPath {
                if let visible = self?.table?.indexPathsForVisibleRows, visible.contains(indexPath) {
                    self?.table?.reloadRows(at: [indexPath], with: .none)
                }
            }
        }

        sections.forEach { section in
            section.cells.forEach { cell in
                var cell = cell
                cell.onLayout = layoutBlock
            }
        }
    }

    init(withModel sections: [SectionViewModel]) {

        self.sections = sections
    }

    func reload(withItems sections: [SectionViewModel]) {

        self.sections = sections
        table?.reloadData()
    }
}


extension TableViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let section = sections[indexPath.section]
        let model = section.cells[indexPath.row]
        section.onSelect?(model)
    }
}


extension TableViewModel: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {

        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return sections[section].cells.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let section = sections[indexPath.section]
        var cellViewModel = section.cells[(indexPath.row)]
        let reuseIdentifier = cellViewModel.reuseIdentifier

        if !registeredIdentifiers.contains(reuseIdentifier) {
            registeredIdentifiers.insert(reuseIdentifier)
            tableView.register(TableCell.self, forCellReuseIdentifier: reuseIdentifier)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! TableCell
        if cell.content == nil {
            cell.content = cellViewModel.makeView(bindImmediately: false)
        }

        if var cellPositionConsumer = cellViewModel as? CellPositionRequired {
            cellPositionConsumer.cellPosition = cellPosition(forIndexPath: indexPath)
        }

        cellViewModel.indexPath = indexPath
        (cell.content as? Bindable)?.bind(to: cellViewModel)

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        return sections[section].headerViewModel?.makeView(bindImmediately: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        return sections[section].headerViewModel == nil ? 0 : UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        return sections[section].footerViewModel == nil ? 0 : UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        return sections[section].footerViewModel?.makeView(bindImmediately: true)
    }
}


extension TableViewModel {

    func cellPosition(forIndexPath indexPath: IndexPath) -> CellPosition {

        let section = sections[indexPath.section]
        if indexPath.row == 0 {

            if section.cells.count == 1 {
                return .alone
            }
            else {
                return .first
            }
        }
        else {
            if indexPath.row == section.cells.count - 1 {
                return .last
            }
            else {
                return .middle
            }
        }
    }
}


class SpaceFillerViewModel: CommonViewModel {

    private let height: CGFloat

    init(withHeight height: CGFloat) {

        self.height = height
    }

    func makeView(bindImmediately: Bool) -> UIView {

        let view = UIView(frame: .zero)
        view.addHeight(height)
        view.backgroundColor = .clear
        return view
    }

    static func viewClass() -> UIView.Type {

        return UIView.self
    }
}


protocol ReusableContentView {

    func prepareForReuse()
}


class TableCell: UITableViewCell {

    var content: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let content = self.content {
                content.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(content)
                content.fillContainer()
            }
        }
    }

    override func prepareForReuse() {

        super.prepareForReuse()

        (content as? ReusableContentView)?.prepareForReuse()
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.clipsToBounds = false
        self.backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

}
