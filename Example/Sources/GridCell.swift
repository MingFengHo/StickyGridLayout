import UIKit

/// A single spreadsheet cell: a centered label with a hairline border.
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
        label.font = .systemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.separator.cgColor
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
            label.font = .semiboldSystemFont(ofSize: 15)
        case .body:
            contentView.backgroundColor = .systemBackground
            label.textColor = .label
            label.font = .systemFont(ofSize: 15)
        }
    }
}

private extension UIFont {
    static func semiboldSystemFont(ofSize size: CGFloat) -> UIFont {
        .systemFont(ofSize: size, weight: .semibold)
    }
}
