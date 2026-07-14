import UIKit
import StickyGridLayout

/// A world-cities data table. Column widths and row heights are **self-sizing**:
/// each column grows to fit its longest cell (the "City" column is far wider
/// than "Timezone"), while the header row and the city-name column stay frozen.
final class DemoViewController: UIViewController {

    private struct City {
        let name, country, population, timezone, currency: String
    }

    private let columnTitles = ["City", "Country", "Population", "Timezone", "Currency"]

    private let cities: [City] = [
        City(name: "Tokyo",            country: "Japan",         population: "37,400,068", timezone: "UTC+9", currency: "JPY"),
        City(name: "São Paulo",        country: "Brazil",        population: "22,043,000", timezone: "UTC−3", currency: "BRL"),
        City(name: "New York City",    country: "United States", population: "18,804,000", timezone: "UTC−5", currency: "USD"),
        City(name: "Reykjavík",        country: "Iceland",       population: "131,136",    timezone: "UTC+0", currency: "ISK"),
        City(name: "Ho Chi Minh City", country: "Vietnam",       population: "8,993,000",  timezone: "UTC+7", currency: "VND"),
        City(name: "Cairo",            country: "Egypt",         population: "21,323,000", timezone: "UTC+2", currency: "EGP"),
        City(name: "Zürich",           country: "Switzerland",   population: "1,435,000",  timezone: "UTC+1", currency: "CHF"),
        City(name: "Kuala Lumpur",     country: "Malaysia",      population: "8,285,000",  timezone: "UTC+8", currency: "MYR"),
        City(name: "Lagos",            country: "Nigeria",       population: "15,388,000", timezone: "UTC+1", currency: "NGN"),
        City(name: "Buenos Aires",     country: "Argentina",     population: "15,594,000", timezone: "UTC−3", currency: "ARS"),
        City(name: "Copenhagen",       country: "Denmark",       population: "1,346,000",  timezone: "UTC+1", currency: "DKK"),
        City(name: "Wellington",       country: "New Zealand",   population: "418,500",    timezone: "UTC+12", currency: "NZD"),
    ]

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
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
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
