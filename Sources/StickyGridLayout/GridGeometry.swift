//
//  GridGeometry.swift
//  StickyGridLayout
//
//  The pure-Swift geometry core. It has no UIKit dependency, so all of the
//  sizing and freeze-pane pinning math can be unit-tested on any platform,
//  independently of a running UICollectionView.
//

import CoreGraphics

/// Immutable description of a spreadsheet-style grid: the width of every column,
/// the height of every row, and how many leading rows/columns are frozen.
///
/// The type owns two responsibilities:
/// 1. Turning per-column widths and per-row heights into absolute cell frames.
/// 2. Computing where a frozen ("sticky") cell should be pinned for a given
///    scroll offset, and the z-ordering that keeps frozen cells above the body.
public struct GridGeometry: Equatable {

    /// Width of each column, left to right.
    public let columnWidths: [CGFloat]

    /// Height of each row, top to bottom.
    public let rowHeights: [CGFloat]

    /// Number of leading rows pinned to the top. Clamped to `0...rowHeights.count`.
    public let stickyRowCount: Int

    /// Number of leading columns pinned to the left. Clamped to `0...columnWidths.count`.
    public let stickyColumnCount: Int

    /// The x-origin of each column (cumulative sum of the widths before it).
    public let columnXOffsets: [CGFloat]

    /// The y-origin of each row (cumulative sum of the heights before it).
    public let rowYOffsets: [CGFloat]

    /// Total scrollable size of the grid.
    public let contentSize: CGSize

    public init(columnWidths: [CGFloat],
                rowHeights: [CGFloat],
                stickyRowCount: Int = 1,
                stickyColumnCount: Int = 1) {
        self.columnWidths = columnWidths
        self.rowHeights = rowHeights
        self.stickyRowCount = Swift.max(0, Swift.min(stickyRowCount, rowHeights.count))
        self.stickyColumnCount = Swift.max(0, Swift.min(stickyColumnCount, columnWidths.count))

        var xOffsets: [CGFloat] = []
        xOffsets.reserveCapacity(columnWidths.count)
        var runningX: CGFloat = 0
        for width in columnWidths {
            xOffsets.append(runningX)
            runningX += width
        }

        var yOffsets: [CGFloat] = []
        yOffsets.reserveCapacity(rowHeights.count)
        var runningY: CGFloat = 0
        for height in rowHeights {
            yOffsets.append(runningY)
            runningY += height
        }

        self.columnXOffsets = xOffsets
        self.rowYOffsets = yOffsets
        self.contentSize = CGSize(width: runningX, height: runningY)
    }

    /// Whether `row` is one of the frozen header rows.
    public func isStickyRow(_ row: Int) -> Bool { row < stickyRowCount }

    /// Whether `column` is one of the frozen header columns.
    public func isStickyColumn(_ column: Int) -> Bool { column < stickyColumnCount }

    /// The frame a cell occupies when the grid is scrolled to the origin,
    /// ignoring any freezing.
    public func naturalFrame(row: Int, column: Int) -> CGRect {
        CGRect(x: columnXOffsets[column],
               y: rowYOffsets[row],
               width: columnWidths[column],
               height: rowHeights[row])
    }

    /// The frame a cell should occupy for the given scroll offset. Frozen rows
    /// are pinned to the top edge and frozen columns to the left edge, so a
    /// frozen cell keeps its position within its header block as the body moves.
    public func stickyFrame(row: Int, column: Int, contentOffset: CGPoint) -> CGRect {
        var frame = naturalFrame(row: row, column: column)
        if isStickyColumn(column) {
            frame.origin.x = contentOffset.x + columnXOffsets[column]
        }
        if isStickyRow(row) {
            frame.origin.y = contentOffset.y + rowYOffsets[row]
        }
        return frame
    }

    /// Z-ordering: the frozen corner sits above the frozen headers, which sit
    /// above the freely scrolling body.
    public func zIndex(row: Int, column: Int) -> Int {
        switch (isStickyRow(row), isStickyColumn(column)) {
        case (true, true):   return 2 // frozen corner
        case (true, false),
             (false, true):  return 1 // frozen header row or column
        case (false, false): return 0 // scrollable body
        }
    }
}
