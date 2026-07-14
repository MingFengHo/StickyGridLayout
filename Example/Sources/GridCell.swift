import UIKit

/// A single spreadsheet cell: a centered label with a hairline border.
///
/// The label is pinned to all four edges of `contentView` with padding, so the
/// cell reports a content-driven size to `StickyGridLayout` when self-sizing is
/// enabled — while still filling a fixed frame in fixed-size mode.
final class GridCell: UICollectionViewCell {
    static let reuseID = "GridCell"

    enum Style {
        case corner   // frozen top-left
        case header   // frozen row or column
        case body     // scrolling body
    }

    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 15)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// A cell self-sizes its *height* by default but keeps the layout's width.
    /// Compute the compressed size so the cell also reports its content **width**,
    /// letting StickyGridLayout widen the column to fit.
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        attributes.frame.size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return attributes
    }

    func configure(text: String, style: Style) {
        label.text = text
        switch style {
        case .corner:
            contentView.backgroundColor = .systemIndigo
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 15)
        case .header:
            contentView.backgroundColor = .secondarySystemBackground
            label.textColor = .label
            label.font = .systemFont(ofSize: 15, weight: .semibold)
        case .body:
            contentView.backgroundColor = .systemBackground
            label.textColor = .label
            label.font = .systemFont(ofSize: 15)
        }
    }
}
