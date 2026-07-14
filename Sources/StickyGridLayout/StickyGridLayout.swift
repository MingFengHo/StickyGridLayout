//
//  StickyGridLayout.swift
//  StickyGridLayout
//
//  A spreadsheet-style UICollectionViewLayout with frozen header rows and
//  columns. The layout is a thin UIKit adapter over `GridGeometry`, which holds
//  all of the sizing and pinning math.
//
//  Data-source mapping: each **section is a row**, each **item is a column**.
//  Rows `0..<stickyRowCount` freeze to the top; columns `0..<stickyColumnCount`
//  freeze to the left.
//

#if canImport(UIKit)
import UIKit

public final class StickyGridLayout: UICollectionViewLayout {

    /// Provides per-column widths and per-row heights. Optional — without it the
    /// grid uses `defaultColumnWidth` / `defaultRowHeight` for every cell.
    public weak var delegate: StickyGridLayoutDelegate?

    /// Number of leading rows frozen to the top edge. Default `1`.
    public var stickyRowCount: Int = 1 { didSet { invalidateLayout() } }

    /// Number of leading columns frozen to the left edge. Default `1`.
    public var stickyColumnCount: Int = 1 { didSet { invalidateLayout() } }

    /// Column width used when the delegate is absent or returns nothing.
    public var defaultColumnWidth: CGFloat = 100 { didSet { invalidateLayout() } }

    /// Row height used when the delegate is absent or returns nothing.
    public var defaultRowHeight: CGFloat = 44 { didSet { invalidateLayout() } }

    private var geometry: GridGeometry?
    private var attributes: [[UICollectionViewLayoutAttributes]] = []

    // MARK: - Layout lifecycle

    public override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }

        // Rebuild frames only when the data or configuration changed. On a plain
        // scroll (bounds change) the cache survives and we merely re-pin the
        // frozen cells — so scrolling stays cheap regardless of grid size.
        if geometry == nil {
            buildGeometryAndAttributes(collectionView)
        }
        pinStickyCells(to: collectionView.contentOffset)
    }

    public override var collectionViewContentSize: CGSize {
        geometry?.contentSize ?? .zero
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.section < attributes.count,
              indexPath.item < attributes[indexPath.section].count else { return nil }
        return attributes[indexPath.section][indexPath.item]
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        attributes.flatMap { $0 }.filter { $0.frame.intersects(rect) }
    }

    // MARK: - Invalidation

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Re-pin frozen cells on every scroll.
        true
    }

    public override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        if context.invalidateEverything || context.invalidateDataSourceCounts {
            geometry = nil
            attributes = []
        }
        super.invalidateLayout(with: context)
    }

    // MARK: - Building

    private func buildGeometryAndAttributes(_ collectionView: UICollectionView) {
        let rowCount = collectionView.numberOfSections
        guard rowCount > 0 else {
            geometry = GridGeometry(columnWidths: [], rowHeights: [])
            attributes = []
            return
        }

        var columnCount = 0
        for section in 0..<rowCount {
            columnCount = max(columnCount, collectionView.numberOfItems(inSection: section))
        }

        let widths = (0..<columnCount).map { column in
            delegate?.stickyGridLayout(self, widthForColumn: column) ?? defaultColumnWidth
        }
        let heights = (0..<rowCount).map { row in
            delegate?.stickyGridLayout(self, heightForRow: row) ?? defaultRowHeight
        }

        let geometry = GridGeometry(columnWidths: widths,
                                    rowHeights: heights,
                                    stickyRowCount: stickyRowCount,
                                    stickyColumnCount: stickyColumnCount)
        self.geometry = geometry

        attributes = (0..<rowCount).map { section in
            (0..<collectionView.numberOfItems(inSection: section)).map { item in
                let indexPath = IndexPath(item: item, section: section)
                let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attribute.frame = geometry.naturalFrame(row: section, column: item)
                attribute.zIndex = geometry.zIndex(row: section, column: item)
                return attribute
            }
        }
    }

    private func pinStickyCells(to contentOffset: CGPoint) {
        guard let geometry = geometry else { return }
        for section in 0..<attributes.count {
            for attribute in attributes[section] {
                let column = attribute.indexPath.item
                guard geometry.isStickyRow(section) || geometry.isStickyColumn(column) else { continue }
                attribute.frame = geometry.stickyFrame(row: section, column: column, contentOffset: contentOffset)
            }
        }
    }
}
#endif
