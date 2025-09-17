//
//  LWViewDebugOverlay.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：点选控件显示 层级/约束/FPS 的调试浮层（开发版可开关）。
//  - 单击：拾取点下的最上层可见视图并高亮，显示 Class/Frame/层级路径/关联约束。
//  - 拖动：可移动信息面板位置。
//  - 提供 `show()` / `hide()` / `toggle()`。
//

import UIKit

public final class LWViewDebugOverlay: UIView {
    public static let shared = LWViewDebugOverlay()
    private init() { super.init(frame: .zero); setupUI() }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private let infoLabel = UITextView()
    private let highlight = CAShapeLayer()
    private let fpsBadge = LWFPSBadge()
    private var panStart: CGPoint = .zero

    // MARK: - 公共方法
    public func show() {
        guard self.superview == nil else { return }
        guard let win = LWViewDebugOverlay.keyWindow() else { return }
        frame = win.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        win.addSubview(self)
        fpsBadge.attach(to: self)
    }
    public func hide() {
        fpsBadge.detach()
        removeFromSuperview()
    }
    public func toggle() { superview == nil ? show() : hide() }

    // MARK: - UI
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.02) // 极浅，点击命中更好
        isUserInteractionEnabled = true

        // 信息面板
        infoLabel.isEditable = false
        infoLabel.isScrollEnabled = true
        infoLabel.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        infoLabel.textColor = .white
        infoLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        infoLabel.layer.cornerRadius = 8; infoLabel.layer.masksToBounds = true
        addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
            infoLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8),
            infoLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.9),
            infoLabel.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor, multiplier: 0.4)
        ])

        // 高亮层
        highlight.strokeColor = UIColor.systemYellow.cgColor
        highlight.fillColor = UIColor.systemYellow.withAlphaComponent(0.15).cgColor
        highlight.lineWidth = 1.0
        layer.addSublayer(highlight)

        // 手势
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        infoLabel.addGestureRecognizer(pan)
    }

    // MARK: - 事件
    @objc private func onTap(_ g: UITapGestureRecognizer) {
        let point = g.location(in: self)
        guard let target = hitTestView(at: point) else { infoLabel.text = "未命中视图"; highlight.path = nil; return }
        highlightView(target)
        infoLabel.text = buildInfo(for: target)
    }

    @objc private func onPan(_ g: UIPanGestureRecognizer) {
        let t = g.translation(in: self)
        if g.state == .began { panStart = infoLabel.center }
        infoLabel.center = CGPoint(x: panStart.x + t.x, y: panStart.y + t.y)
    }

    // MARK: - 高亮与拾取
    private func highlightView(_ v: UIView) {
        let rect = v.convert(v.bounds, to: self)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 4)
        highlight.path = path.cgPath
    }

    private func hitTestView(at p: CGPoint) -> UIView? {
        guard let win = LWViewDebugOverlay.keyWindow() else { return nil }
        // 从顶层递归找最上面的可见子视图
        let v = win.hitTest(p, with: nil)
        return v === self ? nil : v
    }

    private func buildInfo(for v: UIView) -> String {
        var lines: [String] = []
        lines.append("📦 Class: \(type(of: v))")
        let f = v.convert(v.bounds, to: self)
        lines.append(String(format: "🧭 Frame: x=%.1f y=%.1f w=%.1f h=%.1f", f.origin.x, f.origin.y, f.size.width, f.size.height))
        // 层级路径
        var path: [String] = [String(describing: type(of: v))]
        var cur = v.superview
        while let s = cur, s !== self {
            path.append(String(describing: type(of: s)))
            cur = s.superview
        }
        lines.append("👣 Hierarchy: " + path.joined(separator: " ⟵ "))
        // 相关约束
        let related = constraints(for: v)
        if related.isEmpty {
            lines.append("🔧 Constraints: none")
        } else {
            lines.append("🔧 Constraints (\(related.count)):\n" + related.prefix(12).joined(separator: "\n"))
            if related.count > 12 {
                lines.append("… 其余 \(related.count - 12) 条省略")
            }
        }
        return lines.joined(separator: "\n")
    }

    private func constraints(for v: UIView) -> [String] {
        var arr: [NSLayoutConstraint] = []
        func collect(from view: UIView) {
            let cs = view.constraints.filter { $0.firstItem as? UIView === v || $0.secondItem as? UIView === v }
            arr.append(contentsOf: cs)
            if let sp = view.superview { collect(from: sp) }
        }
        collect(from: v)
        return arr.map { c in
            let first = (c.firstItem as? UIView).map { String(describing: type(of: $0)) } ?? "nil"
            let second = (c.secondItem as? UIView).map { String(describing: type(of: $0)) } ?? "nil"
            return "· \(first).\(c.firstAttribute.rawValue) \(symbol(for: c.relation)) \(second).\(c.secondAttribute.rawValue) = \(c.constant) [\(Int(c.priority.rawValue))]"
        }
    }

    private func symbol(for r: NSLayoutConstraint.Relation) -> String {
        switch r { case .lessThanOrEqual: return "≤"; case .greaterThanOrEqual: return "≥"; default: return "=" }
    }

    private static func keyWindow() -> UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
