import SwiftUI
import StickyGridLayout

/// The SwiftUI counterpart of `DemoViewController`, built with `StickyGrid`.
@available(iOS 16.0, *)
struct CitiesGridView: View {
    private struct City {
        let name, country, population, timezone, currency: String
    }

    private let columnTitles = ["City", "Country", "Population", "Timezone", "Currency"]

    private let cities: [City] = [
        City(name: "Tokyo",            country: "Japan",         population: "37,400,068", timezone: "UTC+9",  currency: "JPY"),
        City(name: "São Paulo",        country: "Brazil",        population: "22,043,000", timezone: "UTC−3",  currency: "BRL"),
        City(name: "New York City",    country: "United States", population: "18,804,000", timezone: "UTC−5",  currency: "USD"),
        City(name: "Reykjavík",        country: "Iceland",       population: "131,136",    timezone: "UTC+0",  currency: "ISK"),
        City(name: "Ho Chi Minh City", country: "Vietnam",       population: "8,993,000",  timezone: "UTC+7",  currency: "VND"),
        City(name: "Cairo",            country: "Egypt",         population: "21,323,000", timezone: "UTC+2",  currency: "EGP"),
        City(name: "Zürich",           country: "Switzerland",   population: "1,435,000",  timezone: "UTC+1",  currency: "CHF"),
        City(name: "Kuala Lumpur",     country: "Malaysia",      population: "8,285,000",  timezone: "UTC+8",  currency: "MYR"),
        City(name: "Buenos Aires",     country: "Argentina",     population: "15,594,000", timezone: "UTC−3",  currency: "ARS"),
        City(name: "Wellington",       country: "New Zealand",   population: "418,500",    timezone: "UTC+12", currency: "NZD"),
    ]

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
