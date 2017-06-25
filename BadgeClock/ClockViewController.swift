//
//  ClockViewController.swift
//  BadgeClock
//
//  Created by Wataru Inoue on 2017/06/21.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class ClockViewController: UIViewController {
    
    var displaySwitch: RAMPaperSwitch! // 表示するかどうかのswitch
    //    let dateFomatter = DateFormatter() // datePicker -> limitDate
    var dummyBadgeView: UIView!
    let timeLabel = UILabel()
    let secondLabel = UILabel()
    let date2badgeFomatter = DateFormatter() // 現在時刻 -> "ss"にして、Badgeに表示
    let date2hhmmFomatter = DateFormatter() // 現在時刻 -> "hh:mm"にして、timeLabelに表示
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = 0
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        initNotification()
        initView()
        initInstances()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppearが呼ばれました")
        restartDisplayBackgroundClock()
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
            selector: #selector(self.restartDisplayBackgroundClock),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
    }
    
    func initInstances() {
        
        self.tabBarItem.badgeColor = UIColor.red
        
        
        displaySwitch.isOn = true
        displaySwitch.isEnabled = true
        displaySwitch.addTarget(self, action: #selector(self.onClickSwicth(sender:)), for: UIControlEvents.valueChanged)
        
        date2badgeFomatter.dateFormat = "ss" // Badgeに表示するフォーマット
        date2badgeFomatter.timeZone = NSTimeZone.local
        
        date2hhmmFomatter.dateFormat = "hh:mm"
        date2hhmmFomatter.timeZone = NSTimeZone.local
        
        setStatus()
        
    }
    
    func initView() {
        /****** baseのview ******/
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        baseView.backgroundColor = UIColor(red: 111/255, green: 206/255, blue: 255/255, alpha: 1.0) //6fceff
        
        let dummyIconLength = baseView.frame.width
        let dummyBadgeViewHeight = dummyIconLength / 3
        
        timeLabel.frame = CGRect(x: 0, y: 0, width: dummyIconLength, height: dummyIconLength / 4)
        timeLabel.center = CGPoint(x: baseView.center.x, y: baseView.frame.size.height * 1/6)
        timeLabel.text = "12:34"
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: CGFloat(timeLabel.frame.size.height - 4))
        timeLabel.textColor = UIColor.black
        
        let dummyIconView = UIView(frame: CGRect(x: 0, y: 0, width: dummyIconLength, height: dummyIconLength))
        dummyIconView.center = CGPoint(x: baseView.center.x - dummyIconLength / 4 , y: baseView.center.y + dummyIconLength / 4)
        print("dummyIconView.center: \(dummyIconView.center)")
        dummyIconView.backgroundColor = UIColor(red: 0/255, green: 111/255, blue: 203/255, alpha: 1.0) // 006fcb
        dummyIconView.layer.cornerRadius = dummyBadgeViewHeight / 2
        
        let textOnIconLabel = UILabel(frame: CGRect(x: 0, y: 0, width: dummyIconLength / 3, height: dummyIconLength / 3))
        textOnIconLabel.center = CGPoint(x: dummyIconView.frame.size.width / 2, y: dummyIconView.frame.size.height / 2)
        textOnIconLabel.text = "秒"
        textOnIconLabel.textAlignment = .center
        textOnIconLabel.font = UIFont.systemFont(ofSize: CGFloat(textOnIconLabel.frame.size.height - 4))
        textOnIconLabel.textColor = UIColor.white
        
        let dummyBadgeView = UIView(frame: CGRect(x: 0, y: 0, width: dummyBadgeViewHeight * 1.6, height: dummyBadgeViewHeight))
        dummyBadgeView.center = CGPoint(x: dummyBadgeView.frame.origin.x + dummyIconLength , y: dummyBadgeView.frame.origin.y)
        print("dummyBadgeView.center:\(dummyBadgeView.center)")
        dummyBadgeView.backgroundColor = UIColor.white // スイッチがオフの時の背景色
        dummyBadgeView.layer.cornerRadius = dummyBadgeView.frame.size.height / 2
        
        displaySwitch = RAMPaperSwitch(view: dummyBadgeView, color: UIColor.red) // スイッチがオンの時の背景色
        displaySwitch.center = CGPoint(x: dummyBadgeView.frame.size.width / 2, y: dummyBadgeView.frame.size.height - displaySwitch.frame.size.height / 2 - 4) // (0, 0)だと画面の左上
        print("displaySwitch.center:\(displaySwitch.center)")
        
        secondLabel.frame = CGRect(x: 0, y: 0, width: dummyBadgeView.frame.size.width, height: dummyBadgeViewHeight - displaySwitch.frame.size.height)
        secondLabel.center.x = dummyBadgeView.frame.size.width / 2
        secondLabel.bounds.origin.y = dummyBadgeView.frame.origin.y - 2
        print("secondLabel.center:\(secondLabel.center)")
        secondLabel.text = "23"
        secondLabel.textAlignment = .center
        secondLabel.font = UIFont.systemFont(ofSize: CGFloat(secondLabel.frame.size.height - 8))
        secondLabel.textColor = UIColor.white
        
        /****** view の統合 ******/
        dummyBadgeView.addSubview(secondLabel)
        dummyBadgeView.addSubview(displaySwitch)
        dummyIconView.addSubview(textOnIconLabel)
        dummyIconView.addSubview(dummyBadgeView)
        baseView.addSubview(timeLabel)
        baseView.addSubview(dummyIconView)
        self.view.addSubview(baseView)
        
        
    }
    
    func onClickSwicth(sender: RAMPaperSwitch) {
        setStatus()
    }
    
    func displayBadgeClock() {
        if displaySwitch.isOn {
            // スイッチがオンのときは、通知バッチに秒を表示
            backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
                UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
            }
        } else {
            // スイッチが切られていたら、通知バッチは非表示
            UIApplication.shared.applicationIconBadgeNumber = 0
            timer.invalidate()
        }
    }
    
    func updateClock() {
        let nowPlus1sec = Date().addingTimeInterval(TimeInterval(1))
        let str = date2badgeFomatter.string(from: nowPlus1sec) // 1secだけ先取りする
        let timeStr = date2hhmmFomatter.string(from: nowPlus1sec) // 1secだけ先取りする
        print("\(nowPlus1sec) ->  \(str)")
        if let numClock = Int(str) {
            UIApplication.shared.applicationIconBadgeNumber = numClock
            secondLabel.text = str
            timeLabel.text = timeStr
        }
    }
    
    func restartDisplayBackgroundClock() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
    }
    
    func setStatus() {
        // スイッチに応じてstatusを更新
        print(displaySwitch.isOn)
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
        
        if timer.isValid == false {
            displayBadgeClock()
        }
        
        if displaySwitch.isOn {
            self.tabBarItem.badgeValue = "ON"
            self.secondLabel.textColor = UIColor.white
        } else {
            self.tabBarItem.badgeValue = nil
            self.secondLabel.textColor = UIColor.red
        }
    }
}

extension ClockViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
