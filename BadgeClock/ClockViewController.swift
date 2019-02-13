//
//  ClockViewController.swift
//  BadgeClock
//
//  Created by Wataru Inoue on 2017/06/21.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation

enum ActionIdentifier: String {
    case continueTimer
    case killTimer
}

class ClockViewController: UIViewController {
    
    var displaySwitch: RAMPaperSwitch! // 表示するかどうかのswitch
    let timeLabel = UILabel() // アプリ上で時刻(hh:mm)を表示
    let secondLabel = UILabel() // アプリ上で秒刻(ss)を表示
    let date2badgeFomatter = DateFormatter() // 現在時刻 -> "ss"にして、Badgeに表示
    let date2hhmmFomatter = DateFormatter() // 現在時刻 -> "hh:mm"にして、timeLabelに表示
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier(rawValue: 0)
    
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
        restartTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension ClockViewController {
    
    func initNotification() {
        // backgroundに移行した時に呼ばれるメソッド // backgroundは基本的に3分間
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.displayBadgeClock),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        
        // アプリがアクティブになった時に呼ばれるメソッド
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.restartTimer),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    func initInstances() {
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
        timeLabel.text = ""
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
        displaySwitch.isOn = true
        displaySwitch.isEnabled = true
        displaySwitch.addTarget(self, action: #selector(self.onClickSwicth(sender:)), for: UIControl.Event.valueChanged)
        
        secondLabel.frame = CGRect(x: 0, y: 0, width: dummyBadgeView.frame.size.width, height: dummyBadgeViewHeight - displaySwitch.frame.size.height)
        secondLabel.center.x = dummyBadgeView.frame.size.width / 2
        secondLabel.bounds.origin.y = dummyBadgeView.frame.origin.y - 2
        print("secondLabel.center:\(secondLabel.center)")
        secondLabel.text = ""
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
    
    @objc func onClickSwicth(sender: RAMPaperSwitch) {
        setStatus()
    }
    
    @objc func displayBadgeClock() {
        // この関数はbackgroundからしか呼ばない
        if displaySwitch.isOn {
            // スイッチがオンのときは、通知バッチに秒を表示
            setNotification()
            backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask {
                UIApplication.shared.endBackgroundTask(convertToUIBackgroundTaskIdentifier(self.backgroundTaskIdentifier.rawValue))
            }
        } else {
            // スイッチが切られていたら、通知バッチは非表示
            UIApplication.shared.applicationIconBadgeNumber = 0
            timer.invalidate()
        }
    }
    
    @objc func updateClock() {
        let nowPlus1sec = Date().addingTimeInterval(TimeInterval(1)) // 現在時刻に1secだけ先取りする
        let sec = Calendar.current.dateComponents([.second], from: nowPlus1sec).second ?? 0
        speach(text: String(sec))
        let str = date2badgeFomatter.string(from: nowPlus1sec)
        let timeStr = date2hhmmFomatter.string(from: nowPlus1sec)
        print("\(nowPlus1sec) ->  \(str)")
        if let numClock = Int(str) {
            UIApplication.shared.applicationIconBadgeNumber = numClock
            secondLabel.text = str
            timeLabel.text = timeStr
        }
    }
    
    @objc func restartTimer() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateClock), userInfo: nil, repeats: true)
    }
    
    func setStatus() {
        // スイッチに応じてstatusを更新
        print(displaySwitch.isOn)
        
        restartTimer()
        
        if displaySwitch.isOn {
            self.secondLabel.textColor = UIColor.white
        } else {
            self.secondLabel.textColor = UIColor.red
            // Pending(通知がまだ発火していない状態)のものを全て削除
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
}

// ローカル通知の設定: 3分後に再表示するか選択できる
extension ClockViewController {
    
    func setNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // 既に設定された通知の全削除

        // 通知自体の設定
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "まもなく秒読みを終了します", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "続けて表示するには再度アプリを開いてください", arguments: nil)
        content.sound = UNNotificationSound.default
        
        // 2分30秒後
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2 * 60 + 30, repeats: false)
        let request = UNNotificationRequest(identifier: "my-threeMinutes", content: content, trigger: trigger)
        
        // 通知を登録
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

    }
}

// 読み上げのメソッドの定義
extension ClockViewController: AVSpeechSynthesizerDelegate {
    func speach(text: String) {
        let avSpeechSynthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.8 //読み上げの速度
        avSpeechSynthesizer.delegate = self
        avSpeechSynthesizer.speak(utterance) //発話
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIBackgroundTaskIdentifier(_ input: Int) -> UIBackgroundTaskIdentifier {
	return UIBackgroundTaskIdentifier(rawValue: input)
}
