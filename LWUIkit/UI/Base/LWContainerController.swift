//
//  LWContainerController.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：提供一个通用容器 VC，用于分页/嵌套/占位骨架。
//  - 基于 UIPageViewController 实现分页容器。
//  - 暴露简单的切页 API、索引监听、可添加头部（如 segment/tab）。
//
//  用法：
//  ```swift
//  let pages = [VC1(), VC2(), VC3()]
//  let container = LWContainerController(pages: pages, startIndex: 0)
//  navigationController?.pushViewController(container, animated: true)
//  ```
//

import UIKit

public protocol LWContainerControllerDelegate: AnyObject {
    func container(_ container: LWContainerController, didUpdate index: Int)
}

open class LWContainerController: LWBaseViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    public private(set) var pages: [UIViewController]
    public private(set) var currentIndex: Int

    private let pageVC: UIPageViewController

    public weak var delegate: LWContainerControllerDelegate?

    /// 可选头部视图（如 Segment/自定义 Tab），自动置于顶部
    public var headerView: UIView? {
        didSet { layoutHeaderIfNeeded() }
    }

    public init(pages: [UIViewController], startIndex: Int = 0) {
        self.pages = pages
        self.currentIndex = max(0, min(startIndex, pages.count - 1))
        self.pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        super.init(nibName: nil, bundle: nil)
    }
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    open override func setupUI() {
        // 嵌入 pageVC
        addChild(pageVC)
        contentView.addSubview(pageVC.view)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pageVC.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        pageVC.didMove(toParent: self)

        pageVC.dataSource = self
        pageVC.delegate = self

        if !pages.isEmpty {
            pageVC.setViewControllers([pages[currentIndex]], direction: .forward, animated: false, completion: nil)
        }
    }

    // MARK: - 头部布局
    private func layoutHeaderIfNeeded() {
        // 移除旧头部
        contentView.subviews.first(where: { $0.tag == 920_001 })?.removeFromSuperview()
        guard let header = headerView else { return }
        header.tag = 920_001
        contentView.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            header.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            header.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
        // 让 pageVC 下移到头部之下
        if let pv = pageVC.view {
            NSLayoutConstraint.deactivate(pv.constraints)
            NSLayoutConstraint.activate([
                pv.topAnchor.constraint(equalTo: header.bottomAnchor),
                pv.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                pv.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                pv.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
        }
    }

    // MARK: - 切页 API
    public func setPages(_ controllers: [UIViewController], startAt index: Int = 0, animated: Bool = false) {
        self.pages = controllers
        self.currentIndex = max(0, min(index, controllers.count - 1))
        if !controllers.isEmpty {
            pageVC.setViewControllers([controllers[currentIndex]], direction: .forward, animated: animated, completion: nil)
        }
    }
    public func scrollTo(index: Int, animated: Bool = true) {
        guard index != currentIndex, index >= 0, index < pages.count else { return }
        let direction: UIPageViewController.NavigationDirection = index > currentIndex ? .forward : .reverse
        currentIndex = index
        pageVC.setViewControllers([pages[index]], direction: direction, animated: animated, completion: nil)
        delegate?.container(self, didUpdate: index)
    }

    // MARK: - DataSource
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx - 1 >= 0 else { return nil }
        return pages[idx - 1]
    }
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let idx = pages.firstIndex(of: viewController), idx + 1 < pages.count else { return nil }
        return pages[idx + 1]
    }

    // MARK: - Delegate
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let vc = pageViewController.viewControllers?.first, let idx = pages.firstIndex(of: vc) else { return }
        currentIndex = idx
        delegate?.container(self, didUpdate: idx)
    }
}
