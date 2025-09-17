//
//  LWFPSMeter.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：FPS 监测（CADisplayLink）
//  - 支持回调与内置悬浮标签视图显示。
//

import UIKit

public final class LWFPSMeter {
    public static let shared = LWFPSMeter()
    private init() {}

    private var link: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var frames: Int = 0

    /// 每次更新时回调当前 FPS（近似值）
    public var onUpdate: ((Int) -> Void)?

    /// 开始监测
    public func start() {
        guard link == nil else { return }
        lastTimestamp = 0; frames = 0
        let l = CADisplayLink(target: self, selector: #selector(tick(_:)))
        if #available(iOS 15.0, *) { l.preferredFrameRateRange = .init(minimum: 30, maximum: 120, preferred: 60) }
        l.add(to: .main, forMode: .common)
        link = l
    }
    /// 停止监测
    public func stop() {
        link?.invalidate(); link = nil
        onUpdate = nil
    }

    @objc private func tick(_ l: CADisplayLink) {
        if lastTimestamp == 0 { lastTimestamp = l.timestamp; return }
        frames += 1
        let delta = l.timestamp - lastTimestamp
        if delta >= 1.0 {
            let fps = Int(round(Double(frames) / delta))
            onUpdate?(fps)
            frames = 0; lastTimestamp = l.timestamp
        }
    }
}

// MARK: - 内置悬浮标签
public final class LWFPSBadge: UILabel {
    private var observing = false
    public override init(frame: CGRect) {
        super.init(frame: frame)
        text = "FPS"
        font = .monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        textAlignment = .center
        textColor = .white
        backgroundColor = UIColor.black.withAlphaComponent(0.75)
        layer.cornerRadius = 6; layer.masksToBounds = true
        numberOfLines = 1
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: 54).isActive = true
        heightAnchor.constraint(equalToConstant: 22).isActive = true
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func attach(to view: UIView) {
        guard superview !== view else { return }
        view.addSubview(self)
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
        if !observing {
            observing = true
            LWFPSMeter.shared.onUpdate = { [weak self] fps in
                guard let self = self else { return }
                self.text = "FPS \(fps)"
                // 根据帧率变色
                let g = min(max(Double(fps) / 60.0, 0), 1)
                self.backgroundColor = UIColor(hue: CGFloat(0.33 * g), saturation: 0.8, brightness: 0.35, alpha: 0.9)
            }
        }
        LWFPSMeter.shared.start()
    }

    public func detach() {
        removeFromSuperview()
        observing = false
        LWFPSMeter.shared.stop()
    }
}
