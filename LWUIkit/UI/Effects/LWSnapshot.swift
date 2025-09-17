//
//  LWSnapshot.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：视图截图 / 多分辨率导出（PNG/JPEG/PDF）。
//

import UIKit
import PDFKit

public enum LWSnapshot {

    // MARK: - 位图截图
    /// 将任意视图渲染为 UIImage（按指定 scale 与是否 afterScreenUpdates）
    public static func image(of view: UIView, scale: CGFloat = UIScreen.main.scale, afterScreenUpdates: Bool = true) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: view.bounds.size, format: UIGraphicsImageRendererFormat.default())
        return renderer.image { _ in
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: afterScreenUpdates)
        }.resized(byScale: scale / UIScreen.main.scale)
    }

    /// 导出 PNG 数据（可调整 scale）
    public static func pngData(of view: UIView, scale: CGFloat = UIScreen.main.scale) -> Data? {
        image(of: view, scale: scale).pngData()
    }

    /// 导出 JPEG 数据（quality: 0~1）
    public static func jpegData(of view: UIView, quality: CGFloat = 0.9, scale: CGFloat = UIScreen.main.scale) -> Data? {
        image(of: view, scale: scale).jpegData(compressionQuality: quality)
    }

    // MARK: - PDF 导出（单页）
    public static func pdfData(of view: UIView) -> Data {
        let pageBounds = CGRect(origin: .zero, size: view.bounds.size)
        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, pageBounds, nil)
        UIGraphicsBeginPDFPage()
        if let ctx = UIGraphicsGetCurrentContext() {
            view.layer.render(in: ctx)
        }
        UIGraphicsEndPDFContext()
        return data as Data
    }
}

// MARK: - 工具
private extension UIImage {
    func resized(byScale s: CGFloat) -> UIImage {
        guard s != 1, s > 0 else { return self }
        let newSize = CGSize(width: size.width * s, height: size.height * s)
        let fmt = UIGraphicsImageRendererFormat.default()
        fmt.scale = 1
        let img = UIGraphicsImageRenderer(size: newSize, format: fmt).image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
        return img
    }
}
