//
//  LWCheckbox.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//

import UIKit

final class LWCheckbox: UIControl {
    /// 是否选中（KVO/事件外部可监听 .valueChanged）
    override var isSelected: Bool { didSet { updateUI() } }
    /// 文字
    var text: String? { didSet { titleLabel.text = text } }
    /// 样式
    var cornerRadius: CGFloat = 4 { didSet { box.layer.cornerRadius = cornerRadius } }

    private let box = UIView()
    private let mark = CAShapeLayer()
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setupUI() }

    private func setupUI() {
        isAccessibilityElement = true
        accessibilityTraits = [.button]

        box.layer.borderWidth = 1
        box.layer.cornerRadius = cornerRadius
        box.layer.cornerCurve = .continuous
        box.layer.borderColor = UIColor.separator.cgColor
        box.translatesAutoresizingMaskIntoConstraints = false
        addSubview(box)

        mark.fillColor = UIColor.systemBlue.cgColor
        mark.path = UIBezierPath(roundedRect: CGRect(x: 2, y: 2, width: 16, height: 16), cornerRadius: 3).cgPath
        mark.isHidden = true
        box.layer.addSublayer(mark)

        titleLabel.font = .systemFont(ofSize: 14)
        titleLabel.textColor = .secondaryLabel
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            box.widthAnchor.constraint(equalToConstant: 20),
            box.heightAnchor.constraint(equalToConstant: 20),
            box.leadingAnchor.constraint(equalTo: leadingAnchor),
            box.centerYAnchor.constraint(equalTo: centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: box.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggle)))
        updateUI()
    }

    @objc private func toggle() {
        isSelected.toggle()
        sendActions(for: .valueChanged)
        accessibilityValue = isSelected ? "选中" : "未选中"
    }

    private func updateUI() {
        mark.isHidden = !isSelected
        box.layer.borderColor = (isSelected ? UIColor.systemBlue : UIColor.separator).cgColor
    }
}

