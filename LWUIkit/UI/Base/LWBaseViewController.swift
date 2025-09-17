//
//  LWBaseViewController.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：统一页面骨架：
//   - 提供 contentView（承载业务 UI）、stateView（承载 loading/empty/error/content）
//   - 统一导航栏/状态栏策略（可覆盖），主题切换时自动刷新
//   - 埋点钩子（viewDidAppear / viewWillDisappear）
//

import UIKit

open class LWBaseViewController: UIViewController {

    /// 统一承载业务内容的容器（默认被 stateView 覆盖显示）
    public let contentView = UIView()
    /// 四态容器（可直接 showLoading/showEmpty/showError/showContent）
    public let stateView = LWStatefulView()

    private var lw_traitRegistrationBox: Any?

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LWSemanticColors.backgroundPrimary

        // 布局：stateView 覆盖全部区域，contentView 填充在 stateView.contentContainer 内
        view.addSubview(stateView)
        stateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stateView.topAnchor.constraint(equalTo: view.topAnchor),
            stateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // 默认展示内容：把 contentView 放入 stateView 作为 content
        stateView.showContent(using: contentView)

        // 主题通知
        NotificationCenter.default.addObserver(self, selector: #selector(onThemeChanged), name: .LWThemeDidChange, object: nil)

        if #available(iOS 17.0, *) {
            lw_traitRegistrationBox = registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (vc: LWBaseViewController, _) in
                vc.applyTheme()
            }
        }

        setupUI()
        setupConstraints()
        bind()
        applyTheme()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: - 三段式（子类覆盖）
    open func setupUI() {}
    open func setupConstraints() {}
    open func bind() {}

    // MARK: - 外观与主题
    /// 子类可覆盖以自定义主题应用（导航栏、背景色等）
    open func applyTheme() {
        view.backgroundColor = LWSemanticColors.backgroundPrimary
        navigationController?.navigationBar.tintColor = LWSemanticColors.brandPrimary
    }

    // 统一状态栏样式（可按主题调整）
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default // 或根据主题定制
    }

    @objc private func onThemeChanged() { applyTheme() }

    // iOS < 17 的 trait 变化兜底
    @available(iOS, introduced: 8.0, deprecated: 17.0)
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 17.0, *) {
            return
        } else {
            super.traitCollectionDidChange(previousTraitCollection)
            if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
                applyTheme()
            }
        }
    }

    // MARK: - 埋点钩子（子类覆盖）
    open func onPageAppear() {}
    open func onPageDisappear() {}

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated); onPageAppear()
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated); onPageDisappear()
    }
}
