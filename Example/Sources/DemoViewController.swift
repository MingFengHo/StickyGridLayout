import UIKit
import StickyGridLayout

/// A weekly timetable that is wider and taller than the screen, so both the
/// header row (weekdays) and the header column (time slots) stay frozen while
/// the body scrolls in both directions.
final class DemoViewController: UIViewController {

    private let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let timeSlots = (9...20).map { String(format: "%02d:00", $0) }

    // section = row, item = column  (StickyGridLayout's mapping)
    private var rowCount: Int { timeSlots.count + 1 }     // +1 header row
    private var columnCount: Int { weekdays.count + 1 }   // +1 header column

    private lazy var layout: StickyGridLayout = {
        let layout = StickyGridLayout()
        layout.stickyRowCount = 1
        layout.stickyColumnCount = 1
        layout.delegate = self
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.dataSource = self
        cv.register(GridCell.self, forCellWithReuseIdentifier: GridCell.reuseID)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "StickyGridLayout"
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension DemoViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { rowCount }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        columnCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridCell.reuseID,
                                                      for: indexPath) as! GridCell
        let row = indexPath.section
        let column = indexPath.item

        let isHeaderRow = row == 0
        let isHeaderColumn = column == 0

        let text: String
        let style: GridCell.Style
        switch (isHeaderRow, isHeaderColumn) {
        case (true, true):
            text = ""
            style = .corner
        case (true, false):
            text = weekdays[column - 1]
            style = .header
        case (false, true):
            text = timeSlots[row - 1]
            style = .header
        case (false, false):
            text = "\(weekdays[column - 1].prefix(1))\(row)"
            style = .body
        }
        cell.configure(text: text, style: style)
        return cell
    }
}

extension DemoViewController: StickyGridLayoutDelegate {
    func stickyGridLayout(_ layout: StickyGridLayout, widthForColumn column: Int) -> CGFloat {
        column == 0 ? 70 : 100   // narrow time-slot column, wide day columns
    }

    func stickyGridLayout(_ layout: StickyGridLayout, heightForRow row: Int) -> CGFloat {
        row == 0 ? 52 : 64       // taller header row
    }
}
