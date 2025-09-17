//
//  LWRemoteImageView.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：简单远程图片加载视图 —— 占位、圆角、渐显；支持注入图片下载器（可接你的网络层）。
//
//  设计要点：
//  - `LWImageDownloading` 协议解耦下载实现；默认提供 `LWURLSessionImageDownloader`（内置内存缓存 + 取消）。
//  - Cell 复用友好：设置新 URL 时自动取消旧任务；`prepareForReuse()` 可手动调用。
//  - 渐显（仅对「非缓存命中」生效），默认 0.22s；可自定义。
//  - 提供占位图、圆角、内容模式等常用参数。
//
//  用法：
//  ```swift
//  LWRemoteImageView.defaultDownloader = LWURLSessionImageDownloader.shared // 或注入你自己的下载器
//  imageView.setImage(url: URL(string: "..."), placeholder: UIImage(named: "ph"))
//  imageView.cornerRadius = 12
//  imageView.fadeDuration = 0.25
//  ```
//

import UIKit

/// 下载任务的取消句柄（顶层类型，避免协议内嵌类型限制）
public final class LWImageCancelToken {
    public init() {}
}

// MARK: - 下载协议
public protocol LWImageDownloading: AnyObject {
    /// 返回是否命中缓存（用于决定是否做渐显动画）
    @discardableResult
    func downloadImage(with url: URL, completion: @escaping (Result<(UIImage, fromCache: Bool), Error>) -> Void) -> LWImageCancelToken
    func cancel(_ token: LWImageCancelToken)
}

// MARK: - 默认实现（URLSession + NSCache）
public final class LWURLSessionImageDownloader: LWImageDownloading {
    public static let shared = LWURLSessionImageDownloader()
    private init() {}

    private let cache = NSCache<NSURL, UIImage>()
    private var tasks: [ObjectIdentifier: URLSessionDataTask] = [:]
    private let lock = NSLock()

    @discardableResult
    public func downloadImage(with url: URL, completion: @escaping (Result<(UIImage, fromCache: Bool), Error>) -> Void) -> LWImageCancelToken {
        // 缓存命中
        if let img = cache.object(forKey: url as NSURL) {
            // 保持异步回调一致性
            DispatchQueue.main.async { completion(.success((img, true))) }
            return LWImageCancelToken()
        }
        // 真下载
        let token = LWImageCancelToken()
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, resp, err in
            defer {
                if let t = self?.tasks.removeValue(forKey: ObjectIdentifier(token)) {
                    t.cancel()
                }
            }
            if let err = err { DispatchQueue.main.async { completion(.failure(err)) }; return }
            guard let data = data, let img = UIImage(data: data) else {
                DispatchQueue.main.async { completion(.failure(NSError(domain: "LWImage", code: -1, userInfo: [NSLocalizedDescriptionKey: "图片解码失败"]))) }
                return
            }
            // 预解码（提升首次显示性能）
            let decoded = LWRemoteImageView.decode(image: img)
            self?.cache.setObject(decoded, forKey: url as NSURL)
            DispatchQueue.main.async { completion(.success((decoded, false))) }
        }
        lock.lock(); tasks[ObjectIdentifier(token)] = task; lock.unlock()
        task.resume()
        return token
    }

    public func cancel(_ token: LWImageCancelToken) {
        lock.lock(); defer { lock.unlock() }
        if let t = tasks.removeValue(forKey: ObjectIdentifier(token)) { t.cancel() }
    }
}

// MARK: - 远程图片视图
open class LWRemoteImageView: UIImageView {
    /// 全局默认下载器（可注入你的实现）
    public static var defaultDownloader: LWImageDownloading = LWURLSessionImageDownloader.shared

    /// 单实例可覆盖默认下载器
    public var downloader: LWImageDownloading = LWRemoteImageView.defaultDownloader

    /// 渐显时长（仅非缓存命中时生效）；设为 0 关闭
    public var fadeDuration: TimeInterval = 0.22

    /// 当前任务与 URL
    private var activeToken: LWImageCancelToken?
    private(set) public var currentURL: URL?

    /// 圆角便捷属性
    public var cornerRadius: CGFloat = 0 {
        didSet { layer.cornerRadius = cornerRadius; layer.masksToBounds = cornerRadius > 0 }
    }

    /// 是否显示菊花
    public var showsActivity: Bool = false {
        didSet { updateActivity() }
    }
    private var activity: UIActivityIndicatorView?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentMode = .scaleAspectFill
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = true
        contentMode = .scaleAspectFill
    }

    private func updateActivity() {
        if showsActivity {
            if activity == nil {
                let sp = UIActivityIndicatorView(style: .medium)
                sp.hidesWhenStopped = true
                addSubview(sp)
                sp.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    sp.centerXAnchor.constraint(equalTo: centerXAnchor),
                    sp.centerYAnchor.constraint(equalTo: centerYAnchor)
                ])
                activity = sp
            }
        } else {
            activity?.removeFromSuperview()
            activity = nil
        }
    }

    /// 设置远程图片（会自动取消旧任务）
    public func setImage(url: URL?, placeholder: UIImage? = nil) {
        // 取消旧任务
        if let token = activeToken {
            downloader.cancel(token)
            activeToken = nil
        }
        currentURL = url
        image = placeholder
        activity?.startAnimating()
        guard let url = url else { activity?.stopAnimating(); return }

        let token = downloader.downloadImage(with: url) { [weak self] result in
            guard let self = self, self.currentURL == url else { return } // 防止错位
            self.activity?.stopAnimating()
            switch result {
            case .success((let img, let fromCache)):
                if self.fadeDuration > 0 && !fromCache {
                    let transition = CATransition()
                    transition.type = .fade
                    transition.duration = self.fadeDuration
                    self.layer.add(transition, forKey: "lw.fade")
                }
                self.image = img
            case .failure:
                // 失败保持 placeholder，也可在此上报
                break
            }
        }
        activeToken = token
    }

    /// 复用前可手动调用，取消当前下载
    public func prepareForReuse() {
        if let token = activeToken {
            downloader.cancel(token)
            activeToken = nil
        }
        image = nil
        currentURL = nil
    }

    // 预解码（绘制到位图上下文，避免首次显示时卡顿）
    static func decode(image: UIImage) -> UIImage {
        guard let cg = image.cgImage else { return image }
        let size = CGSize(width: cg.width, height: cg.height)
        UIGraphicsBeginImageContextWithOptions(size, true, image.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let decoded = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return decoded
    }
}
