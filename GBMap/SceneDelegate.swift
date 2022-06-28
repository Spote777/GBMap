//
//  SceneDelegate.swift
//  GBMap
//
//  Created by Павел Заруцков on 11.06.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    var notificationManager = NotificationManager.instance
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        notificationManager.notificationCenter()
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.window?.alpha = 1
            }
        }
        notificationManager.refreshBadgeNumber(badge: 0)
    }
    
    
    func sceneWillResignActive(_ scene: UIScene) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                self.window?.alpha = 0.2
            }
            self.notificationManager.scheduleNotification()
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        
    }
}
