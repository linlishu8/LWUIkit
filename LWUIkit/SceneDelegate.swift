//
//  SceneDelegate.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var nav: UINavigationController!
    private var coordinator: LWNavigationCoordinator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = scene as? UIWindowScene else { return }
        // 1) Window + 空导航控制器
        let window = UIWindow(windowScene: ws)
        let nav = UINavigationController()
        window.rootViewController = nav
        window.makeKeyAndVisible()
        self.window = window
        self.nav = nav
        
        // 2) 路由协调器
        self.coordinator = LWNavigationCoordinator(navigationController: nav)
        
        // 3) 注册路由（示例：登录、注册、协议）
        registerRoutes()
        
        // 4) 启动时跳到登录页（或根据登录态决定首页）
        _ = coordinator.navigate(to: "auth/login", style: .push(animated: false))
    }
    
    private func registerRoutes() {
        // 登录页（你自己的 VC，例如之前给你的 LWLoginViewController）
        coordinator.register("auth/login") { _ in
            return ThemeSwitchDemoViewController()
        }
        
        //            // 注册页举例
        //            coordinator.register("auth/register") { _ in
        //                return RegisterViewController()
        //            }
        //
        //            // 半屏选择器：国家区号（配合 LWSheet / iOS14 自动回退）
        //            coordinator.register("picker/country") { _ in
        //                // 用于 present/sheet 的路由通常返回要展示的 VC
        //                return LWCountryCodePickerController()
        //            }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

