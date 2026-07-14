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

    /// Provides per-column widths and per-row heights in fixed-size mode.
    /// Ignored when `isSelfSizing` is `true`.
    public weak var delegate: StickyGridLayoutDelegate?

    /// Number of leading rows frozen to the top edge. Default `1`.
    public var stickyRowCount: Int = 1 { didSet { invalidateLayout() } }

    /// Number of leading columns frozen to the left edge. Default `1`.
    public var stickyColumnCount: Int = 1 { didSet { invalidateLayout() } }

    /// Column width used in fixed mode when the delegate returns nothing.
    public var defaultColumnWidth: CGFloat = 100 { didSet { invalidateLayout() } }

    /// Row height used in fixed mode when the delegate returns nothing.
    public var defaultRowHeight: CGFloat = 44 { didSet { invalidateLayout() } }

    /// When `true`, each column widens and each row grows to fit the largest
    /// cell it contains, measured through Auto Layout. Columns and rows start at
    /// `estimatedColumnWidth` / `estimatedRowHeight` and only grow — so give a
    /// realistic estimate to minimize layout shifts as cells scroll into view.
    ///
    /// Cells must be self-sizing: their content needs Auto Layout constraints
    /// that fully define width and height (e.g. a label pinned to all four
    /// edges of `contentView`).
    public var isSelfSizing: Bool = false { didSet { invalidateLayout() } }

    /// Starting column width in self-sizing mode. Default `100`.
    public var estimatedColumnWidth: CGFloat = 100 { didSet { invalidateLayout() } }

    /// Starting row height in self-sizing mode. Default `44`.
    public var estimatedRowHeight: CGFloat = 44 { didSet { invalidateLayout() } }

    private var geometry: GridGeometry?
    private var attributes: [[UICollectionViewLayoutAttributes]] = []

    // Largest measured content size per column/row, in self-sizing mode.
    private var measuredColumnWidths: [Int: CGFloat] = [:]
    private var measuredRowHeights: [Int: CGFloat] = [:]
    private var needsRebuild = false

    private func currentColumnWidth(_ column: Int) -> CGFloat {
        max(estimatedColumnWidth, measuredColumnWidths[column] ?? 0)
    }

    private func currentRowHeight(_ row: Int) -> CGFloat {
        max(estimatedRowHeight, measuredRowHeights[row] ?? 0)
    }

    // MARK: - Layout lifecycle

    public override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }

        // Rebuild frames only when the data, configuration, or a measured size
        // changed. On a plain scroll (bounds change) the cache survives and we
        // merely re-pin the frozen cells — so scrolling stays cheap.
        if geometry == nil || needsRebuild {
            buildGeometryAndAttributes(collectionView)
            needsRebuild = false
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
            measuredColumnWidths = [:]
            measuredRowHeights = [:]
            needsRebuild = false
        }
        super.invalidateLayout(with: context)
    }

    // MARK: - Self-sizing

    public override func shouldInvalidateLayout(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> Bool {
        guard isSelfSizing else { return false }
        let epsilon: CGFloat = 0.5
        let column = preferredAttributes.indexPath.item
        let row = preferredAttributes.indexPath.section
        return preferredAttributes.size.width > currentColumnWidth(column) + epsilon
            || preferredAttributes.size.height > currentRowHeight(row) + epsilon
    }

    public override func invalidationContext(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forPreferredLayoutAttributes: preferredAttributes,
                                                withOriginalAttributes: originalAttributes)
        let column = preferredAttributes.indexPath.item
        let row = preferredAttributes.indexPath.section
        measuredColumnWidths[column] = max(measuredColumnWidths[column] ?? 0, preferredAttributes.size.width)
        measuredRowHeights[row] = max(measuredRowHeights[row] ?? 0, preferredAttributes.size.height)
        // Flag a rebuild (don't nil geometry here — that would make the guards
        // for the other cells in this same measurement batch bail out and drop
        // their sizes). prepare() rebuilds once, after the batch, so a wider
        // column shifts every later column and a taller row grows full-width.
        needsRebuild = true
        return context
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

        let widths: [CGFloat]
        let heights: [CGFloat]
        if isSelfSizing {
            widths = (0..<columnCount).map { max(estimatedColumnWidth, measuredColumnWidths[$0] ?? 0) }
            heights = (0..<rowCount).map { max(estimatedRowHeight, measuredRowHeights[$0] ?? 0) }
        } else {
            widths = (0..<columnCount).map { column in
                delegate?.stickyGridLayout(self, widthForColumn: column) ?? defaultColumnWidth
            }
            heights = (0..<rowCount).map { row in
                delegate?.stickyGridLayout(self, heightForRow: row) ?? defaultRowHeight
            }
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
