//
//  LWTimeProfiler.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：页面/任务耗时埋点（首帧、首屏、任意命名区段），便于定位卡顿点。
//  - 提供通用计时：begin(name:) / end(token:)；
//  - 提供页面追踪器 PageTracer：在 VC 生命周期阶段打点，输出「从 init → viewDidLoad → willAppear → didAppear → 首帧」等时长。
//  - 首帧通过 CADisplayLink 在下一帧回调标记。
//
//  注意：该工具仅在开发/测试环境使用，生产上报请按你司规范接入。
import UIKit

public struct LWProfileEvent {
    public let name: String
    public let duration: TimeInterval
    public let extra: [String: Any]?
}

public final class LWTimeProfiler {
    public static let shared = LWTimeProfiler()
    private init() {}

    // MARK: - 通用事件
    public final class Token {
        fileprivate let id = UUID()
        fileprivate let name: String
        fileprivate let start: CFTimeInterval
        fileprivate let extra: [String: Any]?
        fileprivate init(name: String, extra: [String: Any]?) {
            self.name = name; self.start = CACurrentMediaTime(); self.extra = extra
        }
    }

    @discardableResult
    public func begin(_ name: String, extra: [String: Any]? = nil) -> Token {
        return Token(name: name, extra: extra)
    }
    public func end(_ token: Token, log: Bool = true) -> LWProfileEvent {
        let d = CACurrentMediaTime() - token.start
        let ev = LWProfileEvent(name: token.name, duration: d, extra: token.extra)
        if log { print("⏱️ [LWTimeProfiler] \(ev.name): \(String(format: "%.2fms", d*1000)) \(ev.extra ?? [:])") }
        return ev
    }

    // MARK: - 页面追踪器（在 VC 内部组合使用）
    public final class PageTracer {
        private let name: String
        private var tInit: CFTimeInterval
        private var tViewDidLoad: CFTimeInterval?
        private var tWillAppear: CFTimeInterval?
        private var tDidAppear: CFTimeInterval?
        private var tFirstFrame: CFTimeInterval?
        private var link: CADisplayLink?

        public init(name: String) {
            self.name = name
            self.tInit = CACurrentMediaTime()
        }
        public func markViewDidLoad() { tViewDidLoad = CACurrentMediaTime() }
        public func markWillAppear() { tWillAppear = CACurrentMediaTime() }
        public func markDidAppear() {
            tDidAppear = CACurrentMediaTime()
            // 下一帧视图稳定后认为“首帧”
            link?.invalidate()
            link = CADisplayLink(target: self, selector: #selector(onNextFrame))
            link?.add(to: .main, forMode: .common)
        }
        @objc private func onNextFrame() {
            link?.invalidate(); link = nil
            tFirstFrame = CACurrentMediaTime()
            reportIfReady()
        }
        private func reportIfReady() {
            guard let tLoad = tViewDidLoad, let tWill = tWillAppear, let tDid = tDidAppear, let tFirst = tFirstFrame else { return }
            let ms = { (a: CFTimeInterval, b: CFTimeInterval) in String(format: "%.1fms", (b - a)*1000) }
            print("⏱️ [Page] \(name)"
                  + " | init→load \(ms(tInit, tLoad))"
                  + " | load→will \(ms(tLoad, tWill))"
                  + " | will→did \(ms(tWill, tDid))"
                  + " | did→first \(ms(tDid, tFirst))")
        }
    }
}
