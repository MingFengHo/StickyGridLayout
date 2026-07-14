//
//  StickyGridLayoutDelegate.swift
//  StickyGridLayout
//

#if canImport(UIKit)
import UIKit

/// Supplies per-column widths and per-row heights to a `StickyGridLayout`.
///
/// Both methods are optional; anything you don't implement falls back to the
/// layout's `defaultColumnWidth` / `defaultRowHeight`.
public protocol StickyGridLayoutDelegate: AnyObject {
    /// Width for the column at `column` (an item index within a section/row).
    func stickyGridLayout(_ layout: StickyGridLayout, widthForColumn column: Int) -> CGFloat

    /// Height for the row at `row` (a section index).
    func stickyGridLayout(_ layout: StickyGridLayout, heightForRow row: Int) -> CGFloat
}

public extension StickyGridLayoutDelegate {
    func stickyGridLayout(_ layout: StickyGridLayout, widthForColumn column: Int) -> CGFloat {
        layout.defaultColumnWidth
    }

    func stickyGridLayout(_ layout: StickyGridLayout, heightForRow row: Int) -> CGFloat {
        layout.defaultRowHeight
    }
}
#endif
