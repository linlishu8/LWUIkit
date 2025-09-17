//
//  LWLayout.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  目标：提供一组轻量级 Auto Layout DSL，覆盖常见布局场景：pin/center/size/stack。
//  设计：
//   - 所有 API 都不强制激活，默认会激活，开发者可通过参数控制返回未激活的约束自行管理。
//   - 返回约束数组，方便链式设置优先级/激活/保存。
//   - 完全基于原生 anchors/NSLayoutConstraint，无三方依赖。
//
//  使用示例：
//  ```swift
//  let card = UIView(); let title = UILabel()
//  view.lw_addSubviews(card)
//  card.lw_pinEdgesToSuperview(insets: .all(16))
//  card.lw_size(height: 120)
//  title.font = LWTypography.title2.font()
//  card.lw_addSubviews(title)
//  title.lw_pin(.centerX, to: .centerX, of: card)
//  title.lw_pin(.centerY, to: .centerY, of: card)
//  ```
//

import UIKit

// MARK: - 锚点与边枚举
public enum LWEdge { case top, leading, trailing, bottom }
public enum LWAxes { case horizontal, vertical, both }

// MARK: - Pin（相对定位）
public extension UIView {

    /// 将当前视图四边贴紧到父视图（或指定容器）
    @discardableResult
    func lw_pinEdgesToSuperview(insets: UIEdgeInsets = .zero,
                                to container: UIView? = nil,
                                activate: Bool = true) -> [NSLayoutConstraint] {
        guard let superview = container ?? self.superview else {
            assertionFailure("lw_pinEdgesToSuperview: 没有父视图"); return []
        }
        translatesAutoresizingMaskIntoConstraints = false
        let cs = [
            topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
        ]
        if activate { NSLayoutConstraint.activate(cs) }
        return cs
    }

    /// 将指定边贴到目标视图的对应边
    @discardableResult
    func lw_pin(_ edge: LWEdge,
                to targetEdge: LWEdge,
                of target: UIView,
                constant: CGFloat = 0,
                activate: Bool = true) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let c: NSLayoutConstraint
        switch (edge, targetEdge) {
        case (.top, .top): c = topAnchor.constraint(equalTo: target.topAnchor, constant: constant)
        case (.leading, .leading): c = leadingAnchor.constraint(equalTo: target.leadingAnchor, constant: constant)
        case (.trailing, .trailing): c = trailingAnchor.constraint(equalTo: target.trailingAnchor, constant: -constant)
        case (.bottom, .bottom): c = bottomAnchor.constraint(equalTo: target.bottomAnchor, constant: -constant)
        default:
            // 允许运动学“对齐”组合：如 top 到 bottom（排布用）
            switch edge {
            case .top:
                c = topAnchor.constraint(equalTo: (targetEdge == .bottom ? target.bottomAnchor : target.topAnchor), constant: constant)
            case .leading:
                c = leadingAnchor.constraint(equalTo: (targetEdge == .trailing ? target.trailingAnchor : target.leadingAnchor), constant: constant)
            case .trailing:
                c = trailingAnchor.constraint(equalTo: (targetEdge == .leading ? target.leadingAnchor : target.trailingAnchor), constant: -constant)
            case .bottom:
                c = bottomAnchor.constraint(equalTo: (targetEdge == .top ? target.topAnchor : target.bottomAnchor), constant: -constant)
            }
        }
        if activate { c.isActive = true }
        return c
    }
}

// MARK: - Center（居中）
public extension UIView {
    /// 在容器内水平/垂直/双向居中
    @discardableResult
    func lw_center(in container: UIView? = nil,
                   axes: LWAxes = .both,
                   offset: UIOffset = .zero,
                   activate: Bool = true) -> [NSLayoutConstraint] {
        let v = container ?? superview
        guard let v else { assertionFailure("lw_center: 无容器"); return [] }
        translatesAutoresizingMaskIntoConstraints = false
        var cs: [NSLayoutConstraint] = []
        if axes == .horizontal || axes == .both {
            cs.append(centerXAnchor.constraint(equalTo: v.centerXAnchor, constant: offset.horizontal))
        }
        if axes == .vertical || axes == .both {
            cs.append(centerYAnchor.constraint(equalTo: v.centerYAnchor, constant: offset.vertical))
        }
        if activate { NSLayoutConstraint.activate(cs) }
        return cs
    }
}

// MARK: - Size（尺寸/比例）
public extension UIView {
    /// 固定宽高（某一方向可传 nil）
    @discardableResult
    func lw_size(width: CGFloat? = nil,
                 height: CGFloat? = nil,
                 relation: NSLayoutConstraint.Relation = .equal,
                 activate: Bool = true) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        var cs: [NSLayoutConstraint] = []
        if let w = width {
            let c = widthAnchor.constraint(relation, toConstant: w)
            cs.append(c)
        }
        if let h = height {
            let c = heightAnchor.constraint(relation, toConstant: h)
            cs.append(c)
        }
        if activate { NSLayoutConstraint.activate(cs) }
        return cs
    }

    /// 等比约束（width/height 二选一，或两者都已知时做校验）
    @discardableResult
    func lw_aspectRatio(_ ratio: CGFloat, activate: Bool = true) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let c = widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio)
        if activate { c.isActive = true }
        return c
    }
}

// MARK: - Stack（快速堆叠：简单版）
// 更高级能力见 LWStackBuilder（支持内边距/分隔符/对齐）
public extension UIView {
    /// 横向堆叠：返回 UIStackView（已添加到容器并铺满，如需可进一步自定义）
    @discardableResult
    func lw_hStack(_ views: [UIView],
                   spacing: CGFloat = 8,
                   alignment: UIStackView.Alignment = .fill,
                   distribution: UIStackView.Distribution = .fill,
                   insets: UIEdgeInsets = .zero) -> UIStackView {
        let sv = UIStackView(arrangedSubviews: views)
        sv.axis = .horizontal
        sv.spacing = spacing
        sv.alignment = alignment
        sv.distribution = distribution
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = insets
        sv.topAnchor.constraint(equalTo: topAnchor).isActive = true
        sv.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        sv.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        return sv
    }

    /// 纵向堆叠：返回 UIStackView
    @discardableResult
    func lw_vStack(_ views: [UIView],
                   spacing: CGFloat = 8,
                   alignment: UIStackView.Alignment = .fill,
                   distribution: UIStackView.Distribution = .fill,
                   insets: UIEdgeInsets = .zero) -> UIStackView {
        let sv = UIStackView(arrangedSubviews: views)
        sv.axis = .vertical
        sv.spacing = spacing
        sv.alignment = alignment
        sv.distribution = distribution
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = insets
        sv.topAnchor.constraint(equalTo: topAnchor).isActive = true
        sv.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        sv.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        return sv
    }
}

private extension NSLayoutDimension {
    func constraint(_ relation: NSLayoutConstraint.Relation, toConstant c: CGFloat) -> NSLayoutConstraint {
        switch relation {
        case .equal:              return constraint(equalToConstant: c)
        case .lessThanOrEqual:    return constraint(lessThanOrEqualToConstant: c)
        case .greaterThanOrEqual: return constraint(greaterThanOrEqualToConstant: c)
        @unknown default:         return constraint(equalToConstant: c)
        }
    }
}
