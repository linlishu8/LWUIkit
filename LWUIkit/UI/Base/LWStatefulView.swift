//
//  LWStatefulView.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：提供通用的「四态」视图容器：loading / empty / error / content
//  - 常用于列表页、异步加载页面。
//  - 提供默认视图（菊花、占位图/文案、错误提示+重试按钮），也支持替换自定义视图。
//
//  用法示例：
//  ```swift
//  let stateView = LWStatefulView()
//  view.addSubview(stateView)
//  stateView.translatesAutoresizingMaskIntoConstraints = false
//  stateView.lw_pinEdgesToSuperview(insets: .zero)
//
//  stateView.showLoading()
//  stateView.showEmpty(title: "暂无数据", subtitle: "稍后再试")
//  stateView.showError(title: "网络异常", subtitle: "请检查网络连接") { /* 重试 */ }
//  stateView.showContent(using: yourContentView)
//  ```
//

import UIKit

public final class LWStatefulView: UIView {

    public enum State {
        case loading
        case empty(title: String?, subtitle: String?, image: UIImage?)
        case error(title: String?, subtitle: String?, image: UIImage?, retry: (() -> Void)?)
        case content
    }

    // 子视图容器（content 容器由外部传入或延迟设置）
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let emptyView = LWMessageView()
    private let errorView = LWMessageView()
    private let contentContainer = UIView()

    public private(set) var currentState: State = .loading

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        bind()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI(); setupConstraints(); bind()
    }

    private func setupUI() {
        backgroundColor = LWSemanticColors.backgroundPrimary

        loadingView.hidesWhenStopped = true

        lw_addSubviews(loadingView, emptyView, errorView, contentContainer)
        [emptyView, errorView, contentContainer].forEach { $0.isHidden = true }
    }

    private func setupConstraints() {
        // loading 居中
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        // 其他铺满
        for v in [emptyView, errorView, contentContainer] {
            v.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: topAnchor),
                v.leadingAnchor.constraint(equalTo: leadingAnchor),
                v.trailingAnchor.constraint(equalTo: trailingAnchor),
                v.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }

    private func bind() {}

    // MARK: - API
    public func showLoading() {
        currentState = .loading
        loadingView.startAnimating()
        emptyView.isHidden = true
        errorView.isHidden = true
        contentContainer.isHidden = true
    }
    public func showEmpty(title: String? = "暂无数据", subtitle: String? = nil, image: UIImage? = LWAssetCatalog.Images.empty_box.image()) {
        currentState = .empty(title: title, subtitle: subtitle, image: image)
        loadingView.stopAnimating()
        emptyView.configure(title: title, subtitle: subtitle, image: image, actionTitle: nil, action: nil)
        emptyView.isHidden = false
        errorView.isHidden = true
        contentContainer.isHidden = true
    }
    public func showError(title: String? = "出错了", subtitle: String? = "请稍后再试",
                          image: UIImage? = LWAssetCatalog.Images.error_cloud.image(),
                          actionTitle: String? = "重试",
                          onRetry: (() -> Void)? = nil) {
        currentState = .error(title: title, subtitle: subtitle, image: image, retry: onRetry)
        loadingView.stopAnimating()
        errorView.configure(title: title, subtitle: subtitle, image: image, actionTitle: actionTitle, action: onRetry)
        emptyView.isHidden = true
        errorView.isHidden = false
        contentContainer.isHidden = true
    }
    /// 展示业务内容（传入你的内容视图；如需复用，可提前将内容 add 到 contentContainer）
    public func showContent(using view: UIView? = nil) {
        currentState = .content
        loadingView.stopAnimating()
        emptyView.isHidden = true
        errorView.isHidden = true
        contentContainer.isHidden = false

        if let v = view, v.superview != contentContainer {
            contentContainer.subviews.forEach { $0.removeFromSuperview() }
            contentContainer.addSubview(v)
            v.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: contentContainer.topAnchor),
                v.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
                v.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
                v.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
            ])
        }
    }
}

// MARK: - 简易提示视图（标题+副标题+图标+动作）
final class LWMessageView: UIView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subLabel = UILabel()
    private let actionButton = UIButton(type: .system)
    private var action: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        backgroundColor = .clear
        titleLabel.textAlignment = .center
        titleLabel.font = LWTypography.title2.font(weight: .semibold)

        subLabel.textAlignment = .center

        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel, subLabel, actionButton])
        stack.axis = .vertical
        stack.spacing = LWDesignTokens.spacing.m
        stack.alignment = .center
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .all(LWDesignTokens.spacing.l)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: LWDesignTokens.spacing.l),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -LWDesignTokens.spacing.l)
        ])

        actionButton.addTarget(self, action: #selector(onTap), for: .touchUpInside)
        actionButton.isHidden = true
    }

    func configure(title: String?, subtitle: String?, image: UIImage?, actionTitle: String?, action: (() -> Void)?) {
        titleLabel.text = title
        subLabel.text = subtitle
        imageView.image = image
        self.action = action
        if let at = actionTitle {
            actionButton.setTitle(at, for: .normal)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }

    @objc private func onTap() { action?() }
}
