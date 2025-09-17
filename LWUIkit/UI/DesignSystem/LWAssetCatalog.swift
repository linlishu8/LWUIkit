//
//  LWAssetCatalog.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//

//  职责：集中管理资源访问入口（图标/插画/SF Symbols），统一命名与默认配置。
//  - 统一入口便于替换资源、做灰度、做本地化图（按需扩展）。
//

import UIKit

public enum LWAssetCatalog {

    // MARK: - 图片（来自 Assets.xcassets）
    public enum Images: String {
        // 在 Assets.xcassets 中添加同名图片即可
        case placeholder_avatar
        case placeholder_image
        case empty_box
        case error_cloud

        /// 取图；默认从 main bundle 取，也可传入具体 bundle
        public func image(in bundle: Bundle? = nil) -> UIImage? {
            UIImage(named: rawValue, in: bundle ?? .main, compatibleWith: nil)
        }
    }

    // MARK: - 矢量符号（SF Symbols）
    public enum Symbols: String {
        case chevron_right = "chevron.right"
        case chevron_left  = "chevron.left"
        case plus_circle   = "plus.circle.fill"
        case xmark_circle  = "xmark.circle.fill"
        case info_circle   = "info.circle"
        case exclamation   = "exclamationmark.triangle.fill"

        /// 取系统符号
        public func image(pointSize: CGFloat? = nil, weight: UIImage.SymbolWeight? = nil) -> UIImage? {
            if let ps = pointSize, let w = weight {
                let config = UIImage.SymbolConfiguration(pointSize: ps, weight: w)
                return UIImage(systemName: rawValue, withConfiguration: config)
            } else {
                return UIImage(systemName: rawValue)
            }
        }
    }

    // MARK: - 插画（可按业务域再细分命名空间）
    public enum Illustrations: String {
        case onboarding_1
        case onboarding_2
        case empty_search

        public func image(in bundle: Bundle? = nil) -> UIImage? {
            UIImage(named: rawValue, in: bundle ?? .main, compatibleWith: nil)
        }
    }
}
