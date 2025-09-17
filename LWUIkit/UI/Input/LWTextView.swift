//
//  LWTextView.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：带内边距、占位、校验状态的 UITextView 封装。
//

import UIKit

open class LWTextView: UITextView {
    public var contentInsets: UIEdgeInsets = .init(top: 8, left: 10, bottom: 8, right: 10) {
        didSet { textContainerInset = contentInsets }
    }
    public var placeholder: String? { didSet { placeholderLabel.text = placeholder } }
    public var placeholderColor: UIColor = .secondaryLabel { didSet { placeholderLabel.textColor = placeholderColor } }
    public var placeholderFont: UIFont? { didSet { placeholderLabel.font = placeholderFont ?? font } }
    public var validationState: LWValidationState = .normal { didSet { applyValidationState() } }

    private let placeholderLabel = UILabel()
    private let borderLayer = CALayer()

    public override var text: String! { didSet { updatePlaceholderVisibility() } }
    public override var attributedText: NSAttributedString! { didSet { updatePlaceholderVisibility() } }
    public override var font: UIFont? { didSet { placeholderLabel.font = placeholderFont ?? font } }

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    public required init?(coder: NSCoder) { super.init(coder: coder); commonInit() }

    private func commonInit() {
        textContainerInset = contentInsets
        backgroundColor = .secondarySystemBackground
        layer.addSublayer(borderLayer)
        borderLayer.borderWidth = 1
        borderLayer.cornerRadius = 10
        borderLayer.masksToBounds = true

        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = placeholderFont ?? font ?? UIFont.preferredFont(forTextStyle: .body)
        placeholderLabel.numberOfLines = 0
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: contentInsets.top + 2),
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: contentInsets.left + 4),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -(contentInsets.right + 4))
        ])

        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeNotification), name: UITextView.textDidChangeNotification, object: self)
        applyValidationState()
        updatePlaceholderVisibility()
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    public override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = bounds
    }

    @objc private func textDidChangeNotification() { updatePlaceholderVisibility() }
    private func updatePlaceholderVisibility() { placeholderLabel.isHidden = !(text?.isEmpty ?? true) == false ? false : true; placeholderLabel.isHidden = !(text?.isEmpty ?? true) }

    private func applyValidationState() {
        switch validationState {
        case .normal: borderLayer.borderColor = LWValidationPalette.normalBorder.cgColor
        case .success: borderLayer.borderColor = LWValidationPalette.success.cgColor
        case .warning: borderLayer.borderColor = LWValidationPalette.warning.cgColor
        case .error: borderLayer.borderColor = LWValidationPalette.error.cgColor
        }
    }
}
