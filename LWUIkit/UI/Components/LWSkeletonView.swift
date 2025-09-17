//
//  LWSkeletonView.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：骨架屏（Shimmer）
//  - 使用 CAGradientLayer 实现线性渐变动画。
//  - 可作为独立占位视图使用，也可覆盖在任意 view 上（见 UIView 扩展）。
//
//  用法示例：
//  ```swift
//  // 1) 直接作为占位条
//  let sk = LWSkeletonView(cornerRadius: 8)
//  sk.startShimmer()
//
//  // 2) 覆盖在某个视图上
//  someView.lw_showSkeleton(cornerRadius: 8)
//  someView.lw_hideSkeleton()
//  ```
//

import UIKit

public final class LWSkeletonView: UIView {
    private let gradient = CAGradientLayer()
    private var isAnimating = false
    public var cornerRadius: CGFloat {
        didSet { layer.cornerRadius = cornerRadius; layer.masksToBounds = true }
    }

    public init(cornerRadius: CGFloat = 6) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true

        backgroundColor = LWSemanticColors.separator.withAlphaComponent(0.25)

        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.colors = [
            LWSemanticColors.separator.withAlphaComponent(0.15).cgColor,
            LWSemanticColors.separator.withAlphaComponent(0.30).cgColor,
            LWSemanticColors.separator.withAlphaComponent(0.15).cgColor
        ]
        gradient.locations = [0.0, 0.25, 0.5]
        layer.addSublayer(gradient)
    }
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds.insetBy(dx: -bounds.width, dy: 0) // 更宽用于动画滑动
    }

    public func startShimmer() {
        guard !isAnimating else { return }
        isAnimating = true
        let anim = CABasicAnimation(keyPath: "locations")
        anim.fromValue = [-1.0, -0.5, 0.0]
        anim.toValue   = [1.0, 1.5, 2.0]
        anim.duration = 1.2
        anim.repeatCount = .infinity
        gradient.add(anim, forKey: "lw.shimmer")
    }
    public func stopShimmer() {
        isAnimating = false
        gradient.removeAnimation(forKey: "lw.shimmer")
    }
}

// 覆盖到任意视图：添加/移除骨架层
public extension UIView {
    private struct LW_SkeletonKeys { static var overlayTag = 0x0A11_57EA }

    func lw_showSkeleton(cornerRadius: CGFloat = 6) {
        lw_hideSkeleton()
        let overlay = LWSkeletonView(cornerRadius: cornerRadius)
        overlay.tag = LW_SkeletonKeys.overlayTag
        addSubview(overlay)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: topAnchor),
            overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        overlay.startShimmer()
    }
    func lw_hideSkeleton() {
        subviews.filter { $0.tag == LW_SkeletonKeys.overlayTag }.forEach {
            ($0 as? LWSkeletonView)?.stopShimmer()
            $0.removeFromSuperview()
        }
    }
}
