//
//  LWAppearance.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//

//  职责：集中配置 UIKit 组件外观（UINavigationBar/UITabBar/UITableView/UISearchBar…）
//  - 采用 iOS 13+ 的 *Appearance API*（iOS14+ 完全可用）
//  - 建议在 App 启动时调用一次 `LWAppearance.applyGlobal()`
//

import UIKit

public enum LWAppearance {

    /// 一次性全局应用（可在主题切换后再次调用以微调）
    public static func applyGlobal() {
        applyNavigationBar()
        applyTabBar()
        applyTableView()
        applySearchBar()
        applyToolBar()
        applyBarButtonItem()
    }

    /// UINavigationBar
    private static func applyNavigationBar() {
        let app = UINavigationBarAppearance()
        app.configureWithOpaqueBackground()
        app.backgroundColor = LWSemanticColors.surface
        app.shadowColor = LWSemanticColors.separator.withAlphaComponent(0.2)
        app.titleTextAttributes = [
            .foregroundColor: LWSemanticColors.textPrimary,
            .font: LWTypography.title2.font(weight: .semibold)
        ]
        app.largeTitleTextAttributes = [
            .foregroundColor: LWSemanticColors.textPrimary,
            .font: LWTypography.display.font()
        ]
        UINavigationBar.appearance().standardAppearance = app
        UINavigationBar.appearance().scrollEdgeAppearance = app
        UINavigationBar.appearance().compactAppearance = app
        UINavigationBar.appearance().tintColor = LWSemanticColors.brandPrimary
        UINavigationBar.appearance().isTranslucent = false
    }

    /// UITabBar
    private static func applyTabBar() {
        let app = UITabBarAppearance()
        app.configureWithOpaqueBackground()
        app.backgroundColor = LWSemanticColors.surface
        app.shadowColor = LWSemanticColors.separator.withAlphaComponent(0.2)
        app.stackedLayoutAppearance.selected.iconColor = LWSemanticColors.brandPrimary
        app.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: LWSemanticColors.brandPrimary]
        app.stackedLayoutAppearance.normal.iconColor = LWSemanticColors.textSecondary
        app.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: LWSemanticColors.textSecondary]
        UITabBar.appearance().standardAppearance = app
        if #available(iOS 15.0, *) { UITabBar.appearance().scrollEdgeAppearance = app }
        UITabBar.appearance().tintColor = LWSemanticColors.brandPrimary
        UITabBar.appearance().isTranslucent = false
    }

    /// UITableView / UICollectionView 背景与分割线
    private static func applyTableView() {
        UITableView.appearance().backgroundColor = LWSemanticColors.backgroundPrimary
        UITableView.appearance().separatorColor = LWSemanticColors.separator
        UITableViewCell.appearance().backgroundColor = LWSemanticColors.backgroundPrimary
        UICollectionView.appearance().backgroundColor = LWSemanticColors.backgroundPrimary
    }

    /// UISearchBar
    private static func applySearchBar() {
        UISearchBar.appearance().barTintColor = LWSemanticColors.surface
        UISearchBar.appearance().tintColor = LWSemanticColors.brandPrimary
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).textColor = LWSemanticColors.textPrimary
    }

    /// UIToolbar
    private static func applyToolBar() {
        let app = UIToolbarAppearance()
        app.configureWithOpaqueBackground()
        app.backgroundColor = LWSemanticColors.surface
        app.shadowColor = LWSemanticColors.separator.withAlphaComponent(0.2)
        UIToolbar.appearance().standardAppearance = app
        if #available(iOS 15.0, *) { UIToolbar.appearance().scrollEdgeAppearance = app }
        UIToolbar.appearance().tintColor = LWSemanticColors.brandPrimary
    }

    /// UIBarButtonItem
    private static func applyBarButtonItem() {
        UIBarButtonItem.appearance().tintColor = LWSemanticColors.brandPrimary
    }
}
