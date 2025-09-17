//
//  LWEmptyStateView.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：空数据/错误视图（插画 + 标题 + 副标题 + 按钮）
//  - 提供基类 `LWStateMessageBaseView`，子类：`LWEmptyStateView` / `LWErrorStateView`。
//  - 支持自定义插画、主/副标题、按钮文案与回调。
//

import UIKit

open class LWStateMessageBaseView: UIView {
    public let imageView = UIImageView()
    public let titleLabel = LWThemedLabel()
    public let subtitleLabel = LWThemedLabel()
    public let actionButton = LWThemedButton(type: .system)
    private var action: (() -> Void)?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    public required init?(coder: NSCoder) { super.init(coder: coder); setupUI(); setupConstraints() }

    private func setupUI() {
        backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        titleLabel.style = .primary
        titleLabel.font = LWTypography.title2.font(weight: .semibold)
        titleLabel.textAlignment = .center

        subtitleLabel.style = .secondary
        subtitleLabel.textAlignment = .center

        actionButton.style = .secondary
        actionButton.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        actionButton.isHidden = true

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, subtitleLabel, actionButton])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)
        ])
    }
    private func setupConstraints() {
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
    }

    public func configure(image: UIImage?, title: String?, subtitle: String?, actionTitle: String?, action: (() -> Void)?) {
        imageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
        self.action = action
        if let t = actionTitle {
            actionButton.isHidden = false
            actionButton.setTitle(t, for: .normal)
        } else {
            actionButton.isHidden = true
        }
    }

    @objc private func onTap() { action?() }
}

public final class LWEmptyStateView: LWStateMessageBaseView {}
public final class LWErrorStateView: LWStateMessageBaseView {}
