//
//  TimerViewController.swift
//  BadgeClock
//
//  Created by Wataru Inoue on 2017/06/29.
//  Copyright © 2017年 Wataru Inoue. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    
    let label = UILabel()
    let pickerView = UIPickerView()
    
    var timer = Timer()
    var count: Int = 0
    
    let dateList = [[Int](0 ..< 24), [Int](0 ..< 60), [Int](0 ..< 60)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        initInstances()
        initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension TimerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return dateList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dateList[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.bounds.width / 4
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let rowLabel = UILabel()
        rowLabel.textAlignment = .center
        rowLabel.text = String(dateList[component][row])
        
        return rowLabel
    }
}

extension TimerViewController {
    func initInstances() {
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    func initView() {
        /****** baseのview ******/
        let baseView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        baseView.backgroundColor = UIColor(red: 111/255, green: 206/255, blue: 255/255, alpha: 1.0) //6fceff
        
        label.frame = CGRect(x: 0, y: 0, width: baseView.frame.size.width, height: 30)
        label.center = CGPoint(x: baseView.center.x, y: baseView.frame.size.height * 1/6)
        label.text = ""
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: CGFloat(label.frame.size.height - 4))
        label.textColor = UIColor.black
        
        pickerView.frame = CGRect(x: 0, y: 0, width: baseView.frame.size.width, height: 200)
        let y = baseView.bottomY - self.tabBarController!.tabBar.frame.size.height - pickerView.frame.height / 2
        pickerView.center = CGPoint(x: baseView.center.x, y: y)
        pickerView.backgroundColor = UIColor.green
        
        //「時間」のラベルを追加
        let marginLeft = pickerView.bounds.width/4/2/2
        let hLabel = UILabel()
        hLabel.text = "時間"
        hLabel.sizeToFit()
        hLabel.frame = CGRect(x: marginLeft + pickerView.bounds.width/4 - hLabel.bounds.width/2,
                              y: pickerView.bounds.height/2 - (hLabel.bounds.height/2),
                              width: hLabel.bounds.width, height: hLabel.bounds.height)
        pickerView.addSubview(hLabel)
        
        //「分」のラベルを追加
        let mLabel = UILabel()
        mLabel.text = "分"
        mLabel.sizeToFit()
        mLabel.frame = CGRect(x: marginLeft + pickerView.bounds.width*2/4 - mLabel.bounds.width/2,
                              y:pickerView.bounds.height/2 - (mLabel.bounds.height/2),
                              width:mLabel.bounds.width, height:mLabel.bounds.height)
        
        
        pickerView.addSubview(mLabel)
        
        
        //「秒」のラベルを追加
        let sLabel = UILabel()
        sLabel.text = "秒"
        sLabel.sizeToFit()
        sLabel.frame = CGRect(x: marginLeft + pickerView.bounds.width*3/4 - sLabel.bounds.width/2,
                              y: pickerView.bounds.height/2 - (sLabel.bounds.height/2),
                              width:  sLabel.bounds.width, height: sLabel.bounds.height)
        pickerView.addSubview(sLabel)
        
        /****** view の統合 ******/
        baseView.addSubview(label)
        baseView.addSubview(pickerView)
        self.view.addSubview(baseView)
    }
    
}
