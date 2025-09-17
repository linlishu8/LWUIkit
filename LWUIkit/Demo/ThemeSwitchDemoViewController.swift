//
//  ThemeSwitchDemoViewController.swift
//  LWUIkitThemeDemo
//
//  修正点：
//  - 使用 LWThemeValues.backgroundPrimary / backgroundSecondary（而非 .surface 与类型推断）。
//  - 文本颜色不直接用 lw_bind（UIView 扩展无法绑定 UILabel.textColor），用通知回调重取。
//  - LWTypography 的 API 是 font(weight:compatibleWith:)，修正外部参数名。
//  - Button 样式不写在 extension 里（方法作用域内），改为局部常量 style。
//

import UIKit

final class ThemeSwitchDemoViewController: UIViewController {

    private let brandSegment = UISegmentedControl(items: ["Ocean", "Forest", "Scarlet", "Grape"])
    private let modeSegment  = UISegmentedControl(items: ["System", "Light", "Dark"])

    private let card = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel  = UILabel()
    private let primaryBtn = UIButton(type: .system)

    private var themeToken: NSObjectProtocol?
    private var sizeToken: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Theme Switch Demo"
        view.backgroundColor = .systemBackground

        [brandSegment, modeSegment, card, titleLabel, bodyLabel, primaryBtn].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        view.addSubview(brandSegment)
        view.addSubview(modeSegment)
        view.addSubview(card)
        card.addSubview(titleLabel)
        card.addSubview(bodyLabel)
        view.addSubview(primaryBtn)

        NSLayoutConstraint.activate([
            brandSegment.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            brandSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            modeSegment.topAnchor.constraint(equalTo: brandSegment.bottomAnchor, constant: 12),
            modeSegment.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            card.topAnchor.constraint(equalTo: modeSegment.bottomAnchor, constant: 20),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),

            primaryBtn.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 24),
            primaryBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            primaryBtn.heightAnchor.constraint(equalToConstant: 44),
            primaryBtn.widthAnchor.constraint(greaterThanOrEqualToConstant: 160),
        ])

        // 初始文案
        titleLabel.text = "演示：4 套品牌主题 + 3 种模式"
        titleLabel.numberOfLines = 0
        bodyLabel.text = "切换上面的品牌/模式，卡片与按钮会跟随主题刷新。"
        bodyLabel.numberOfLines = 0
        primaryBtn.setTitle("Primary Button", for: .normal)

        // 初次着色 & 圆角
        card.layer.cornerRadius = 16
        applyColors()

        // 监听主题变化：品牌盘 / 浅深变化时刷新颜色与字体
        themeToken = NotificationCenter.default.addObserver(
            forName: .LWThemeDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            self?.applyColors()
            self?.applyFonts()
        }

        // 字体：同时监听动态字体大小变化
        sizeToken = NotificationCenter.default.addObserver(
            forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            self?.applyFonts()
        }

        // 按钮样式（注册式样式对象）
        let primaryStyle = LWThemeRegistry.Button { btn in
            btn.layer.cornerRadius = 12
            btn.backgroundColor = LWSemanticColors.primaryFill
            btn.setTitleColor(LWSemanticColors.onPrimary, for: .normal)
            btn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 18)
        }
        primaryBtn.lw_apply(primaryStyle)

        // 字体（取当前 traitCollection）
        applyFonts()

        // 交互
        brandSegment.selectedSegmentIndex = 0
        modeSegment.selectedSegmentIndex  = 0
        brandSegment.addTarget(self, action: #selector(onBrandChanged), for: .valueChanged)
        modeSegment.addTarget(self, action: #selector(onModeChanged), for: .valueChanged)
    }

    private func applyColors() {
        // 若你的语义色里没有 backgroundSecondary，可改为 surface
        view.backgroundColor = LWSemanticColors.backgroundPrimary
        card.backgroundColor = LWSemanticColors.backgroundSecondary
        titleLabel.textColor = LWSemanticColors.textPrimary
        bodyLabel.textColor  = LWSemanticColors.textSecondary
    }

    private func applyFonts() {
        titleLabel.font = LWTypography.title2.font(weight: .semibold, compatibleWith: view.traitCollection)
        bodyLabel.font  = LWTypography.body.font(compatibleWith: view.traitCollection)
    }

    @objc private func onBrandChanged() {
        let brand: DemoBrand
        switch brandSegment.selectedSegmentIndex {
        case 0: brand = .ocean
        case 1: brand = .forest
        case 2: brand = .scarlet
        default: brand = .grape
        }
        let pal = DemoPalettes.of(brand)
        LWThemeManager.shared.switchTo(style: .custom(palette: pal), applyToWindows: false)
        LWAppearance.applyGlobal() // 可选
    }

    @objc private func onModeChanged() {
        switch modeSegment.selectedSegmentIndex {
        case 0: LWThemeManager.shared.switchTo(style: .system, applyToWindows: true)
        case 1: LWThemeManager.shared.switchTo(style: .light,  applyToWindows: true)
        default: LWThemeManager.shared.switchTo(style: .dark,   applyToWindows: true)
        }
        LWAppearance.applyGlobal()
    }
}
