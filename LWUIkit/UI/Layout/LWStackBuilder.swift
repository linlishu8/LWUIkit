//
//  LWStackBuilder.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  目标：快速构建【横/竖】堆叠视图，支持：
//   - spacing / alignment / distribution
//   - contentInsets（内边距）
//   - 分隔符（可开关、厚度/颜色/左右缩进）
//   - 自定义每个 item 之间的间距（setCustomSpacing）
//
//  用法：
//  ```swift
//  let builder = LWStackBuilder(axis: .vertical, spacing: LWDesignTokens.spacing.m)
//  builder.contentInsets = .all(16)
//  builder.separator.isEnabled = true
//  builder.separator.color = LWSemanticColors.separator
//  builder.addArranged(titleLabel)
//  builder.addArranged(bodyLabel)
//  builder.addSpacer() // 弹性占位（撑开剩余空间）
//  let stack = builder.build(in: view) // 自动添加到容器并铺满
//  ```
//

import UIKit

public final class LWStackBuilder {

    // MARK: Public Properties
    public let axis: NSLayoutConstraint.Axis
    public var spacing: CGFloat
    public var alignment: UIStackView.Alignment
    public var distribution: UIStackView.Distribution
    public var contentInsets: UIEdgeInsets = .zero

    public struct Separator {
        public var isEnabled: Bool = false
        public var thickness: CGFloat = 0.5
        public var color: UIColor = .separator
        public var leadingInset: CGFloat = 0
        public var trailingInset: CGFloat = 0
    }
    public var separator = Separator()

    // MARK: Private
    private var items: [UIView] = []
    private var customSpacings: [Int: CGFloat] = [:] // index 后的自定义间距

    // MARK: Init
    public init(axis: NSLayoutConstraint.Axis,
                spacing: CGFloat = 8,
                alignment: UIStackView.Alignment = .fill,
                distribution: UIStackView.Distribution = .fill) {
        self.axis = axis; self.spacing = spacing
        self.alignment = alignment; self.distribution = distribution
    }

    // MARK: API
    public func addArranged(_ view: UIView) {
        items.append(view)
    }

    /// 在当前堆叠后插入自定义间距（仅作用于 i 前与 i+1 之间）
    public func setCustomSpacing(_ spacing: CGFloat, after index: Int) {
        customSpacings[index] = spacing
    }

    /// 添加一个弹性空白（占位）
    public func addSpacer(minLength: CGFloat = 0) {
        let spacer = LWSpacer(axis: axis, minLength: minLength)
        items.append(spacer)
    }

    /// 构建并添加到容器；返回 stack 本体（UIStackView）
    @discardableResult
    public func build(in container: UIView) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: items)
        stack.axis = axis
        stack.spacing = spacing
        stack.alignment = alignment
        stack.distribution = distribution
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = contentInsets

        // 分隔符（只在普通视图之间插入，不包含 spacer）
        if separator.isEnabled {
            insertSeparators(in: stack)
        }

        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        // 自定义间距
        for (idx, sp) in customSpacings {
            if idx < items.count - 1 {
                stack.setCustomSpacing(sp, after: items[idx])
            }
        }
        return stack
    }

    // MARK: - Helpers
    private func insertSeparators(in stack: UIStackView) {
        guard items.count > 1 else { return }
        // 我们在视图之间插入一个“线条”视图：
        // 实现方式：将 items 重新打包成 [view, line, view, line, ...]
        var packed: [UIView] = []
        for (i, v) in items.enumerated() {
            packed.append(v)
            if i < items.count - 1, !(v is LWSpacer) {
                packed.append(makeSeparatorView())
            }
        }
        stack.arrangedSubviews.forEach { stack.removeArrangedSubview($0); $0.removeFromSuperview() }
        packed.forEach { stack.addArrangedSubview($0) }
    }

    private func makeSeparatorView() -> UIView {
        let line = UIView()
        line.backgroundColor = separator.color
        line.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            axis == .vertical
            ? line.heightAnchor.constraint(equalToConstant: separator.thickness)
            : line.widthAnchor.constraint(equalToConstant: separator.thickness)
        ])
        // 边距：使用一个容器包裹线条实现左右/上下内缩
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line)
        if axis == .vertical {
            NSLayoutConstraint.activate([
                line.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: separator.leadingInset),
                line.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -separator.trailingInset),
                line.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                line.topAnchor.constraint(equalTo: container.topAnchor, constant: separator.leadingInset),
                line.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -separator.trailingInset),
                line.centerXAnchor.constraint(equalTo: container.centerXAnchor)
            ])
        }
        return container
    }
}
