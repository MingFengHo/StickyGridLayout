import SwiftUI
import StickyGridLayout

/// The SwiftUI counterpart of `DemoViewController`, built with `StickyGrid`.
@available(iOS 16.0, *)
struct CitiesGridView: View {
    private let columnTitles = CityData.columnTitles
    private let cities = CityData.all

    var body: some View {
        StickyGrid(rows: cities.count + 1,
                   columns: columnTitles.count,
                   stickyRows: 1,
                   stickyColumns: 1,
                   estimatedColumnWidth: 90) { row, column in
            cell(row: row, column: column)
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func cell(row: Int, column: Int) -> some View {
        let isCorner = row == 0 && column == 0
        let isHeader = row == 0 || column == 0
        Text(text(row: row, column: column))
            .font(.system(size: 15, weight: isHeader ? .semibold : .regular))
            .foregroundStyle(isCorner ? Color.white : Color.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(background(isCorner: isCorner, isHeader: isHeader))
            .overlay(Rectangle().strokeBorder(Color(.separator), lineWidth: 0.5))
    }

    private func background(isCorner: Bool, isHeader: Bool) -> Color {
        if isCorner { return .indigo }
        if isHeader { return Color(.secondarySystemBackground) }
        return Color(.systemBackground)
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
