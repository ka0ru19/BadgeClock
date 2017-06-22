//
//  DeviceSize.swift
//  BadgeClock
//
//  Created by Wataru Inoue on 2017/06/21.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

struct DeviceSize {
    
    //CGRectを取得
//    static func bounds() ->CGRect {
//        return UIScreen.main.bounds
//    }
//    
//    //画面の横サイズを取得
//    static func screenWidth() ->Int {
//        return Int(UIScreen.main.bounds.size.width)
//    }
//    
//    //画面の縦サイズを取得
//    static func screenHeight() ->Int {
//        return Int(UIScreen.main.bounds.size.height)
//    }
//    
//    static func statusBarHeight() -> CGFloat {
//        return UIApplication.shared.statusBarFrame.height
//    }
//    
//    static func navBarHeight(navigationController: UINavigationController) -> CGFloat {
//        return navigationController.navigationBar.frame.size.height
//    }
//    
    static func tabBarHeight(tabBarController: UITabBarController) -> CGFloat {
        return tabBarController.tabBar.frame.size.height
    }
    
}
