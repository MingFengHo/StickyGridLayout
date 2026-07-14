//
//  StickyGrid.swift
//  StickyGridLayout
//
//  A SwiftUI wrapper over StickyGridLayout. Bridges a UICollectionView driven by
//  the layout and renders each cell's content with a SwiftUI view. The UIKit
//  layout itself still supports iOS 12+; only this SwiftUI entry point requires
//  iOS 16 (for UIHostingConfiguration).
//

#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
import UIKit

/// A spreadsheet-style grid with frozen header rows and columns, for SwiftUI.
///
/// Rows and columns are addressed by index; `content` builds the view for each
/// cell. Rows `0..<stickyRows` freeze to the top and columns `0..<stickyColumns`
/// to the left. Columns and rows self-size to their content by default.
///
/// ```swift
/// StickyGrid(rows: cities.count + 1, columns: 5) { row, column in
///     Text(value(row, column))
///         .padding(8)
/// }
/// ```
@available(iOS 16.0, tvOS 16.0, *)
public struct StickyGrid<Content: View>: UIViewRepresentable {

    private let rows: Int
    private let columns: Int
    private let stickyRows: Int
    private let stickyColumns: Int
    private let isSelfSizing: Bool
    private let estimatedColumnWidth: CGFloat
    private let estimatedRowHeight: CGFloat
    private let content: (Int, Int) -> Content

    public init(rows: Int,
                columns: Int,
                stickyRows: Int = 1,
                stickyColumns: Int = 1,
                isSelfSizing: Bool = true,
                estimatedColumnWidth: CGFloat = 100,
                estimatedRowHeight: CGFloat = 44,
                @ViewBuilder content: @escaping (_ row: Int, _ column: Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.stickyRows = stickyRows
        self.stickyColumns = stickyColumns
        self.isSelfSizing = isSelfSizing
        self.estimatedColumnWidth = estimatedColumnWidth
        self.estimatedRowHeight = estimatedRowHeight
        self.content = content
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(rows: rows, columns: columns, content: content)
    }

    public func makeUIView(context: Context) -> UICollectionView {
        let layout = StickyGridLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = context.coordinator
        collectionView.backgroundColor = .clear
        context.coordinator.collectionView = collectionView
        return collectionView
    }

    public func updateUIView(_ collectionView: UICollectionView, context: Context) {
        context.coordinator.rows = rows
        context.coordinator.columns = columns
        context.coordinator.content = content

        if let layout = collectionView.collectionViewLayout as? StickyGridLayout {
            layout.stickyRowCount = stickyRows
            layout.stickyColumnCount = stickyColumns
            layout.isSelfSizing = isSelfSizing
            layout.estimatedColumnWidth = estimatedColumnWidth
            layout.estimatedRowHeight = estimatedRowHeight
        }
        collectionView.reloadData()
    }

    public final class Coordinator: NSObject, UICollectionViewDataSource {
        var rows: Int
        var columns: Int
        var content: (Int, Int) -> Content
        weak var collectionView: UICollectionView?

        private lazy var registration = UICollectionView.CellRegistration<HostingGridCell, IndexPath> {
            [weak self] cell, indexPath, _ in
            guard let self = self else { return }
            cell.contentConfiguration = UIHostingConfiguration {
                self.content(indexPath.section, indexPath.item)
            }
            .margins(.all, 0)
        }

        init(rows: Int, columns: Int, content: @escaping (Int, Int) -> Content) {
            self.rows = rows
            self.columns = columns
            self.content = content
            super.init()
            _ = registration // create up front, never inside cellForItemAt
        }

        public func numberOfSections(in collectionView: UICollectionView) -> Int { rows }

        public func collectionView(_ collectionView: UICollectionView,
                                   numberOfItemsInSection section: Int) -> Int { columns }

        public func collectionView(_ collectionView: UICollectionView,
                                   cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: indexPath)
        }
    }
}

/// A cell that hosts SwiftUI content and reports its content **width** (not just
/// height) so self-sizing columns can grow to fit.
@available(iOS 16.0, tvOS 16.0, *)
final class HostingGridCell: UICollectionViewCell {
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        attributes.frame.size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return attributes
    }
}
#endif
