import UIKit
import SwiftUI
import StickyGridLayout

/// A world-cities data table. Column widths and row heights are **self-sizing**:
/// each column grows to fit its longest cell (the "City" column is far wider
/// than "Timezone"), while the header row and the city-name column stay frozen.
final class DemoViewController: UIViewController {

    private let columnTitles = CityData.columnTitles
    private let cities = CityData.all

    // section = row, item = column
    private var rowCount: Int { cities.count + 1 }   // +1 header row
    private var columnCount: Int { columnTitles.count }

    private lazy var layout: StickyGridLayout = {
        let layout = StickyGridLayout()
        layout.stickyRowCount = 1
        layout.stickyColumnCount = 1
        layout.isSelfSizing = true          // columns/rows size to their content
        layout.estimatedColumnWidth = 90
        layout.estimatedRowHeight = 44
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
        if #available(iOS 16.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "SwiftUI", style: .plain, target: self, action: #selector(showSwiftUIDemo))
        }
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @available(iOS 16.0, *)
    @objc private func showSwiftUIDemo() {
        let host = UIHostingController(rootView: CitiesGridView())
        host.title = "StickyGrid (SwiftUI)"
        navigationController?.pushViewController(host, animated: true)
    }

    private func text(row: Int, column: Int) -> String {
        if row == 0 { return columnTitles[column] }
        let city = cities[row - 1]
        switch column {
        case 0:  return city.name
        case 1:  return city.country
        case 2:  return city.population
        case 3:  return city.timezone
        default: return city.currency
        }
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

        let style: GridCell.Style
        switch (row == 0, column == 0) {
        case (true, true):   style = .corner
        case (true, false),
             (false, true):  style = .header
        case (false, false): style = .body
        }
        cell.configure(text: text(row: row, column: column), style: style)
        return cell
    }
}
