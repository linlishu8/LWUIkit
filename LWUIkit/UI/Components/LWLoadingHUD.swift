//
//  LWLoadingHUD.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：全局/局部加载提示（菊花 & 进度条），可选择是否阻断交互。
//
//  设计说明：
//  - 提供两种用法
//    1) 局部 HUD：`LWLoadingHUD.show(in:view)` / `hide(from:view)`
//    2) 全局 HUD：`LWLoadingHUD.showGlobal(...)` / `hideGlobal()`
//  - 遮罩类型：.none（不加遮罩，仅菊花）/.blockClear（透明遮罩，阻断触摸）/.blockDim（半透明暗色遮罩，阻断触摸）
//  - 进度：`update(progress:)` 支持 0...1，未调用则显示菊花；调用后切换圆环进度。
//
//  使用示例：
//  ```swift
//  // 局部
//  LWLoadingHUD.show(in: card, text: "加载中…", mask: .blockDim)
//  DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//      LWLoadingHUD.update(in: card, progress: 0.6)
//      LWLoadingHUD.hide(from: card)
//  }
//
//  // 全局
//  LWLoadingHUD.showGlobal(text: "请稍候")
//  LWLoadingHUD.hideGlobal()
//  ```
//

import UIKit

public final class LWLoadingHUD: UIView {

    // MARK: 遮罩类型
    public enum Mask {
        case none               // 不加遮罩（不阻断）
        case blockClear         // 透明遮罩（阻断）
        case blockDim(UIColor)  // 半透明遮罩（阻断，默认黑色 30%）
    }

    // MARK: 子视图
    private let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
    private let spinner = UIActivityIndicatorView(style: .large)
    private let ringLayer = CAShapeLayer()
    private let titleLabel = UILabel()

    private var progressMode = false

    // MARK: 构造
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = .clear

        // 卡片容器
        let container = UIView()
        container.layer.cornerRadius = 12
        container.layer.masksToBounds = true

        addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            container.centerXAnchor.constraint(equalTo: centerXAnchor),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 120)
        ])

        container.addSubview(blur)
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.frame = container.bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // 指示器
        spinner.hidesWhenStopped = true
        spinner.startAnimating()

        titleLabel.font = LWTypography.subbody.font()
        titleLabel.textColor = LWSemanticColors.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [spinner, titleLabel])
        stack.axis = .vertical; stack.alignment = .center; stack.spacing = 12
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -16)
        ])

        // 圆环进度（初始隐藏）
        ringLayer.strokeColor = LWSemanticColors.brandPrimary.cgColor
        ringLayer.fillColor = UIColor.clear.cgColor
        ringLayer.lineWidth = 4
        ringLayer.isHidden = true
        container.layer.addSublayer(ringLayer)

        // 自适应布局
        setNeedsLayout()
        layoutIfNeeded()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public override func layoutSubviews() {
        super.layoutSubviews()
        // 把圆环绘制在卡片中央
        guard let container = subviews.first else { return }
        let side: CGFloat = 44
        let centerPoint = CGPoint(x: container.bounds.midX, y: container.bounds.midY - 12)
        let rect = CGRect(x: centerPoint.x - side/2, y: centerPoint.y - side/2, width: side, height: side)
        let path = UIBezierPath(ovalIn: rect).cgPath
        ringLayer.path = path
    }

    // MARK: - API（实例）
    public func apply(mask: Mask) {
        switch mask {
        case .none:
            backgroundColor = .clear
            isUserInteractionEnabled = false
        case .blockClear:
            backgroundColor = UIColor.black.withAlphaComponent(0.01) // 不影响视觉，但阻断触摸
            isUserInteractionEnabled = true
        case .blockDim(let color):
            backgroundColor = color
            isUserInteractionEnabled = true
        }
    }
    public func set(text: String?) { titleLabel.text = text }
    public func set(progress: Float) {
        let p = CGFloat(max(0, min(1, progress)))
        progressMode = true
        spinner.stopAnimating()
        ringLayer.isHidden = false
        ringLayer.strokeEnd = p
    }

    // MARK: - 静态方法（局部 HUD）
    @discardableResult
    public static func show(in view: UIView, text: String? = nil, mask: Mask = .blockDim(UIColor.black.withAlphaComponent(0.3))) -> LWLoadingHUD {
        hide(from: view)
        let hud = LWLoadingHUD(frame: view.bounds)
        hud.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hud.apply(mask: mask)
        hud.set(text: text)
        view.addSubview(hud)
        return hud
    }
    public static func update(in view: UIView, progress: Float) {
        if let hud = view.subviews.compactMap({ $0 as? LWLoadingHUD }).first {
            hud.set(progress: progress)
        }
    }
    public static func hide(from view: UIView) {
        view.subviews.compactMap({ $0 as? LWLoadingHUD }).forEach { $0.removeFromSuperview() }
    }

    // MARK: - 全局 HUD（挂到 keyWindow）
    private static func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    @discardableResult
    public static func showGlobal(text: String? = nil, mask: Mask = .blockDim(UIColor.black.withAlphaComponent(0.3))) -> LWLoadingHUD? {
        guard let win = keyWindow() else { return nil }
        return show(in: win, text: text, mask: mask)
    }
    public static func updateGlobal(progress: Float) {
        guard let win = keyWindow() else { return }
        update(in: win, progress: progress)
    }
    public static func hideGlobal() {
        guard let win = keyWindow() else { return }
        hide(from: win)
    }
}
