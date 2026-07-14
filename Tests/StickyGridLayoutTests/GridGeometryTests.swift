import XCTest
@testable import StickyGridLayout

final class GridGeometryTests: XCTestCase {

    private func makeGeometry(stickyRows: Int = 1, stickyColumns: Int = 1) -> GridGeometry {
        GridGeometry(columnWidths: [100, 80, 80, 80],
                     rowHeights: [60, 44, 44, 44, 44],
                     stickyRowCount: stickyRows,
                     stickyColumnCount: stickyColumns)
    }

    func testColumnOffsetsAreCumulative() {
        let geometry = makeGeometry()
        XCTAssertEqual(geometry.columnXOffsets, [0, 100, 180, 260])
    }

    func testRowOffsetsAreCumulative() {
        let geometry = makeGeometry()
        XCTAssertEqual(geometry.rowYOffsets, [0, 60, 104, 148, 192])
    }

    func testContentSizeIsSumOfWidthsAndHeights() {
        let geometry = makeGeometry()
        XCTAssertEqual(geometry.contentSize, CGSize(width: 340, height: 236))
    }

    func testStickyCountsAreClampedToBounds() {
        let geometry = GridGeometry(columnWidths: [50, 50],
                                    rowHeights: [50],
                                    stickyRowCount: 9,
                                    stickyColumnCount: 9)
        XCTAssertEqual(geometry.stickyRowCount, 1)
        XCTAssertEqual(geometry.stickyColumnCount, 2)
    }

    func testStickyDetection() {
        let geometry = makeGeometry(stickyRows: 1, stickyColumns: 1)
        XCTAssertTrue(geometry.isStickyRow(0))
        XCTAssertFalse(geometry.isStickyRow(1))
        XCTAssertTrue(geometry.isStickyColumn(0))
        XCTAssertFalse(geometry.isStickyColumn(1))
    }

    func testNaturalFrameIgnoresScroll() {
        let geometry = makeGeometry()
        XCTAssertEqual(geometry.naturalFrame(row: 1, column: 1),
                       CGRect(x: 100, y: 60, width: 80, height: 44))
    }

    func testFrozenColumnPinsToLeftEdge() {
        let geometry = makeGeometry()
        let offset = CGPoint(x: 200, y: 150)
        // A body cell in the frozen first column keeps its x glued to the offset.
        let frame = geometry.stickyFrame(row: 3, column: 0, contentOffset: offset)
        XCTAssertEqual(frame.origin.x, 200)          // pinned: offset.x + columnXOffsets[0]
        XCTAssertEqual(frame.origin.y, 148)          // free: natural row offset
    }

    func testFrozenRowPinsToTopEdge() {
        let geometry = makeGeometry()
        let offset = CGPoint(x: 200, y: 150)
        let frame = geometry.stickyFrame(row: 0, column: 2, contentOffset: offset)
        XCTAssertEqual(frame.origin.x, 180)          // free: natural column offset
        XCTAssertEqual(frame.origin.y, 150)          // pinned: offset.y + rowYOffsets[0]
    }

    func testFrozenCornerPinsBothAxes() {
        let geometry = makeGeometry()
        let offset = CGPoint(x: 200, y: 150)
        let frame = geometry.stickyFrame(row: 0, column: 0, contentOffset: offset)
        XCTAssertEqual(frame.origin, CGPoint(x: 200, y: 150))
    }

    func testZIndexOrdersCornerAboveHeadersAboveBody() {
        let geometry = makeGeometry()
        XCTAssertEqual(geometry.zIndex(row: 0, column: 0), 2) // corner
        XCTAssertEqual(geometry.zIndex(row: 0, column: 3), 1) // header row
        XCTAssertEqual(geometry.zIndex(row: 4, column: 0), 1) // header column
        XCTAssertEqual(geometry.zIndex(row: 4, column: 3), 0) // body
    }

    func testMultipleFrozenRowsAndColumns() {
        let geometry = makeGeometry(stickyRows: 2, stickyColumns: 2)
        let offset = CGPoint(x: 300, y: 200)
        // Second frozen row keeps its natural offset within the frozen block.
        let secondHeaderRow = geometry.stickyFrame(row: 1, column: 3, contentOffset: offset)
        XCTAssertEqual(secondHeaderRow.origin.y, 200 + 60) // offset.y + rowYOffsets[1]
        // Second frozen column likewise.
        let secondHeaderColumn = geometry.stickyFrame(row: 4, column: 1, contentOffset: offset)
        XCTAssertEqual(secondHeaderColumn.origin.x, 300 + 100) // offset.x + columnXOffsets[1]
    }

    func testEmptyGrid() {
        let geometry = GridGeometry(columnWidths: [], rowHeights: [])
        XCTAssertEqual(geometry.contentSize, .zero)
        XCTAssertEqual(geometry.stickyRowCount, 0)
        XCTAssertEqual(geometry.stickyColumnCount, 0)
    }
}
