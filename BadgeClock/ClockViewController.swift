//
//  ClockViewController.swift
//  BadgeClock
//
//  Created by Wataru Inoue on 2017/06/21.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class ClockViewController: UIViewController {
    
    let displaySwitch = UISwitch() // 表示するかどうかのswitch
    //    let dateFomatter = DateFormatter() // datePicker -> limitDate
    let date2badgeFomatter = DateFormatter() // 現在時刻 -> Badgeに表示
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = 0
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        initNotification()
        initInstances()
        initView()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        stopBackgroundClock()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ClockViewController {
    
    func initNotification() {
        // backgroundに移行した時に呼ばれるメソッド // backgroundは基本的に3分間
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.displayBadgeClock),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil
        )
        
        // アプリがアクティブになった時に呼ばれるメソッド
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.stopBackgroundClock),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
    }
    
    func initInstances() {
        
        self.tabBarItem.badgeColor = UIColor.red
        
        displaySwitch.isOn = false
        displaySwitch.addTarget(self, action: #selector(self.onClickSwicth(sender:)), for: UIControlEvents.valueChanged)
        
        date2badgeFomatter.dateFormat = "ss" // Badgeに表示するフォーマット
        date2badgeFomatter.timeZone = NSTimeZone.local
        
    }
    
    func initView() {
        /****** baseのview ******/
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        
        displaySwitch.layer.position = CGPoint(x: baseView.frame.width * 3 / 4, y: baseView.frame.height * 1 / 3)
        
        
        /****** view の統合 ******/
        baseView.addSubview(displaySwitch)
        self.view.addSubview(baseView)
    }
    
    func onClickSwicth(sender: UISwitch) {
        print(sender.isOn)
        
        if sender.isOn {
            self.tabBarItem.badgeValue = "ON"
        } else {
            self.tabBarItem.badgeValue = nil
        }
    }
    
    func displayBadgeClock() {
        if displaySwitch.isOn {
            backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
                UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
            }
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        } else {
            if timer.isValid {
                timer.invalidate()
            }
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
    
    func updateClock() {
        let str = date2badgeFomatter.string(from: Date().addingTimeInterval(TimeInterval(1))) // 1secだけ先取りする
        print("\(Date()) ->  \(str)")
        if let numClock = Int(str) {
            UIApplication.shared.applicationIconBadgeNumber = numClock
        }
    }
    
    func stopBackgroundClock() {
        if timer.isValid {
            timer.invalidate()
        }
    }
}
