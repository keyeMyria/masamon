//
//  HourlyWageSetting.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/28.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import Eureka

class HourlyWageSetting: FormViewController {
    
//    @IBOutlet weak var TimeFrom1: UITextField!
//    @IBOutlet weak var TimeTo1: UITextField!
//    @IBOutlet weak var TimeFrom2: UITextField!
//    @IBOutlet weak var TimeTo2: UITextField!
//    @IBOutlet weak var Salaly1: UITextField!
//    @IBOutlet weak var Salaly2: UITextField!
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegateのインスタンスを取得

    var timeUIPicker: UIPickerView = UIPickerView()
    
    let time = Utility().GetTime()
    let wavyline: [String] = ["〜"]
    var textfieldrowfrom1 = 8
    var textfieldrowto1 = 42
    var textfieldrowfrom2 = 42
    var textfieldrowto2 = 8
    
    let saveimage = UIImage(named: "../images/save.png")
    let savebutton   = UIButton()
    
    let catinfo: [[Int]] = [[70,620,80],[326,470,80]]
    
    let frameborder: [Int] = [90,280]
    
    let clock: [Int] = [115,300]
    let yen: [Int] = [175,360]
    
    var txtActiveField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        
        CreateForm()
        
//        SetText()
      
        //区切るための枠線を追加
//        for i in 0 ..< 2{
//            let frameborderline = UIView()
//            frameborderline.frame = CGRect(x: 0, y: CGFloat(frameborder[i]), width: self.view.frame.width, height: 135)
//            frameborderline.backgroundColor = UIColor.clear
//            frameborderline.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4).cgColor
//            frameborderline.layer.borderWidth = 2
//            frameborderline.layer.cornerRadius = 30
//            self.view.addSubview(frameborderline)
//            self.view.sendSubview(toBack: frameborderline)
//        }

        //時計アイコンの設置
//        for i in 0 ..< 2{
//            let clockicon = UIImageView()
//            clockicon.image = UIImage(named: "../images/clock.png")
//            clockicon.frame = CGRect(x: 24, y: CGFloat(clock[i]), width: 42, height: 40)
//            self.view.addSubview(clockicon)
//        }
        
        //円アイコンの設置
//        for i in 0 ..< 2{
//            let yenicon = UIImageView()
//            yenicon.image = UIImage(named: "../images/yen.png")
//            yenicon.frame = CGRect(x: 24, y: CGFloat(yen[i]), width: 42, height: 40)
//            self.view.addSubview(yenicon)
//        }
        
        //セーブボタンの追加
//        savebutton.tag = 0
//        savebutton.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
//        savebutton.layer.position = CGPoint(x: self.view.frame.width/2, y:500)
//        savebutton.setImage(saveimage, for: UIControlState())
//        savebutton.addTarget(self, action: #selector(HourlyWageSetting.SaveButtontapped(_:)), for:.touchUpInside)
//        self.view.addSubview(savebutton)
        
//        TimeFrom1.delegate = self
//        TimeTo1.delegate = self
//        TimeFrom2.delegate = self
//        TimeTo2.delegate = self
//        Salaly1.delegate = self
//        Salaly2.delegate = self
        
//        TimeFrom1.tag = 1
//        TimeTo1.tag = 1
//        TimeFrom2.tag = 2
//        TimeTo2.tag = 2
//        Salaly1.tag = 3
//        Salaly2.tag = 4
        
//        timeUIPicker.tag = 1
        
        //Toolbarの作成
//        let pickertoolBar = UIToolbar()
//        pickertoolBar.barStyle = UIBarStyle.default
//        pickertoolBar.isTranslucent = true
//        pickertoolBar.sizeToFit()
//        let numberpadtoolBar = UIToolbar()
//        numberpadtoolBar.barStyle = UIBarStyle.default
//        numberpadtoolBar.isTranslucent = true
//        numberpadtoolBar.sizeToFit()
        
        //Toolbarにつけるボタンの作成
//        let pickerdoneButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.plain, target: self, action: #selector(HourlyWageSetting.TapButton(_:)))
//        let pickercancelButton = UIBarButtonItem(title: "キャンセル", style: UIBarButtonItemStyle.plain, target: self, action: #selector(HourlyWageSetting.TapButton(_:)))
//        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
//        let salalyButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.plain, target: self, action: #selector(HourlyWageSetting.TapButton(_:)))
        
//        pickerdoneButton.tag = 10
//        pickercancelButton.tag = 11
//        salalyButton.tag = 30
        
        //Toolbarへボタンの追加
//        pickertoolBar.setItems([pickercancelButton,flexSpace,pickerdoneButton], animated: false)
//        pickertoolBar.isUserInteractionEnabled = true
//        numberpadtoolBar.setItems([flexSpace,salalyButton], animated: false)
//        numberpadtoolBar.isUserInteractionEnabled = true
        
        //PickerViewの追加
//        timeUIPicker.frame = CGRect(x: 0,y: 0,width: self.view.bounds.width/2+20, height: 260.0)
//        timeUIPicker.delegate = self
//        timeUIPicker.dataSource = self
        
//        Salaly1.keyboardType = .numberPad
//        Salaly2.keyboardType = .numberPad
//        Salaly1.inputAccessoryView = numberpadtoolBar
//        Salaly2.inputAccessoryView = numberpadtoolBar
        
//        TimeFrom1.inputView = timeUIPicker
//        TimeFrom1.inputAccessoryView = pickertoolBar
//        TimeTo1.inputView = timeUIPicker
//        TimeTo1.inputAccessoryView = pickertoolBar
//        TimeFrom2.inputView = timeUIPicker
//        TimeFrom2.inputAccessoryView = pickertoolBar
//        TimeTo2.inputView = timeUIPicker
//        TimeTo2.inputAccessoryView = pickertoolBar
    }
    
    func CreateForm() {
        let RuleRequired_M = "必須項目です"
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        var default_daytime_s = time[0]
        var default_daytime_e = time[0]
        var default_daytime_wage = 0
        var default_nighttime_s = time[0]
        var default_nighttime_e = time[0]
        var default_nighttime_wage = 0
    
        if DBmethod().DBRecordCount(HourlyPayDB.self) != 0 {
            //TODO: レコードが既に登録されている場合の処理
        }

        form +++ Section("日中")
            <<< PickerInputRow<String>(""){
                $0.title = "開始時間"
                $0.options = time
                $0.value = default_daytime_s
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "daytime_s"
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = RuleRequired_M
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
                
            <<< PickerInputRow<String>(""){
                $0.title = "終了時間"
                $0.options = time
                $0.value = default_daytime_e
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "daytime_e"
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = RuleRequired_M
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
            <<< IntRow(){
                $0.title = "時給"
                $0.value = default_daytime_wage
                $0.tag = "daytime_wage"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = RuleRequired_M
                            $0.cell.height = { 30 }
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
        form +++ Section(header: "深夜", footer: "値を全て入力しないと値が保存されません")
            <<< PickerInputRow<String>(""){
                $0.title = "開始時間"
                $0.options = time
                $0.value = default_nighttime_s
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "nighttime_s"
                }
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = RuleRequired_M
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }
            
            <<< PickerInputRow<String>(""){
                $0.title = "終了時間"
                $0.options = time
                $0.value = default_nighttime_e
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                $0.tag = "nighttime_e"
                }
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = RuleRequired_M
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
            }
            
            <<< IntRow(){
                $0.title = "時給"
                $0.value = default_nighttime_wage
                $0.tag = "nighttime_wage"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .onRowValidationChanged { cell, row in
                    let rowIndex = row.indexPath!.row
                    while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                        row.section?.remove(at: rowIndex + 1)
                    }
                    if !row.isValid {
                        for (index, _) in row.validationErrors.map({ $0.msg }).enumerated() {
                            let labelRow = LabelRow() {
                                $0.title = RuleRequired_M
                                $0.cell.height = { 30 }
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        var validate_err_count = 0
        for row in form.allRows {
            validate_err_count += row.validate().count
        }
        
        if validate_err_count == 0 {
            let daytime_s = form.values()["daytime_s"] as! String
            let daytime_e = form.values()["daytime_e"] as! String
            let daytime_wage = form.values()["daytime_wage"] as! Int
            let nighttime_s = form.values()["nighttime_s"] as! String
            let nighttime_e = form.values()["nighttime_e"] as! String
            let nighttime_wage = form.values()["nighttime_wage"] as! Int
            
            let hourlypayrecord_daytime = HourlyPayDB()
            let hourlypayrecord_nighttime = HourlyPayDB()
            hourlypayrecord_daytime.id = 1
            hourlypayrecord_daytime.timefrom = Double(time.index(of: daytime_s)!) - (Double(time.index(of: daytime_s)!)*0.5) + 1.0
            hourlypayrecord_daytime.timeto = Double(time.index(of: daytime_e)!)-(Double(time.index(of: daytime_e)!)*0.5) + 1.0
            hourlypayrecord_daytime.pay = daytime_wage
            hourlypayrecord_nighttime.id = 2
            hourlypayrecord_nighttime.timefrom = Double(time.index(of: nighttime_s)!)-(Double(time.index(of: nighttime_s)!)*0.5) + 1.0
            hourlypayrecord_nighttime.timeto = Double(time.index(of: nighttime_e)!)-(Double(time.index(of: nighttime_e)!)*0.5) + 1.0
            hourlypayrecord_nighttime.pay = nighttime_wage

            DBmethod().AddandUpdate(hourlypayrecord_daytime,update: true)
            DBmethod().AddandUpdate(hourlypayrecord_nighttime,update: true)
        }else {
            present(Utility().GetStandardAlert(title: "エラー", message: "入力されていない項目があるため保存できませんでした", b_title: "OK"),animated: false, completion: nil)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //表示列
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 3
//    }
    
    //表示個数
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if component == 0 {
//            return time.count
//        }else if component == 1 {
//            return wavyline.count
//        }else{
//            return time.count
//        }
//    }
    
    //表示内容
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//
//        if component == 0 {
//            return time[row]
//        }else if component == 1 {
//            return wavyline[row]
//        }else{
//            return time[row]
//        }
//    }
    
    //選択時
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//
//        if component == 0 {
//            if selecttextfieldtag == 1 {
//                TimeFrom1.text = time[row]
//                textfieldrowfrom1 = row
//            }else{
//                TimeFrom2.text = time[row]
//                textfieldrowfrom2 = row
//            }
//        }else if component == 2 {
//            if selecttextfieldtag == 1 {
//                TimeTo1.text = time[row]
//                textfieldrowto1 = row
//            }else{
//                TimeTo2.text = time[row]
//                textfieldrowto2 = row
//            }
//        }
//    }
    
    //幅を変更
//    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        return 80
//    }
//    //高さを変更
//    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
//        return 50
//    }
    
    //pickerviewやツールバー上のボタン動作
//    func TapButton(_ sender: UIButton){
//
//        if selecttextfieldtag == 1 {            //日中のテキストフィールドが選択されている状態
//            switch(sender.tag){
//            case 10:    //Doneボタン
//                break
////                TimeFrom1.text = time[textfieldrowfrom1]
////                TimeTo1.text = time[textfieldrowto1]
////                TimeFrom1.resignFirstResponder()
////                TimeTo1.resignFirstResponder()
//
//            case 11:    //Cancelボタン
//                textfieldrowfrom1 = 8
//                textfieldrowto1 = 42
//
////                TimeFrom1.text = ""
////                TimeTo1.text = ""
////                TimeFrom1.resignFirstResponder()
////                TimeTo1.resignFirstResponder()
//
//            default:
//                break
//            }
//        }else if selecttextfieldtag == 2 {      //深夜のテキストフィールドが選択されている状態
//            switch(sender.tag){
//            case 10:    //Doneボタン
//                break
////                TimeFrom2.text = time[textfieldrowfrom2]
////                TimeTo2.text = time[textfieldrowto2]
////                TimeFrom2.resignFirstResponder()
////                TimeTo2.resignFirstResponder()
//
//            case 11:    //Cancelボタン
//                textfieldrowfrom2 = 42
//                textfieldrowto2 = 8
//
////                TimeFrom2.text = ""
////                TimeTo2.text = ""
////                TimeFrom2.resignFirstResponder()
////                TimeTo2.resignFirstResponder()
//
//            default:
//                break
//            }
//
//        }else if selecttextfieldtag == 3 {      //日中の時給テキストフィールドが選択されている
////            Salaly1.resignFirstResponder()
//        }else if selecttextfieldtag == 4 {      //深夜の時給テキストフィールドが選択されている
////            Salaly2.resignFirstResponder()
//        }
//    }
    
//    var selecttextfieldtag = 0
//    //textfieldがタップされた時
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        selecttextfieldtag = textField.tag
//        if textField.tag == 1 {
//            timeUIPicker.selectRow(textfieldrowfrom1, inComponent: 0, animated: true)
//            timeUIPicker.selectRow(textfieldrowto1, inComponent: 2, animated: true)
////            TimeFrom1.text = time[textfieldrowfrom1]
////            TimeTo1.text = time[textfieldrowto1]
//        }else if textField.tag == 2 {
//            timeUIPicker.selectRow(textfieldrowfrom2, inComponent: 0, animated: true)
//            timeUIPicker.selectRow(textfieldrowto2, inComponent: 2, animated: true)
////            TimeFrom2.text = time[textfieldrowfrom2]
////            TimeTo2.text = time[textfieldrowto2]
//        }
//    }
    
    //セーブボタンを押した時
    func SaveButtontapped(_ sender: UIButton){
        
//        if TimeFrom1.text?.isEmpty == true || TimeTo1.text?.isEmpty == true || TimeFrom2.text?.isEmpty == true || TimeTo2.text?.isEmpty == true || Salaly1.text?.isEmpty == true || Salaly2.text?.isEmpty == true {
//
//            let alertController = UIAlertController(title: "ニャ!!", message: "項目を埋めてから押すニャ", preferredStyle: .alert)
//
//            let defaultAction = UIAlertAction(title: "ニャーさんに土下座する", style: .default, handler: nil)
//            alertController.addAction(defaultAction)
//
//            present(alertController, animated: true, completion: nil)
//        }else{
//            let hourlypayrecord1 = HourlyPayDB()
//            let hourlypayrecord2 = HourlyPayDB()
//            hourlypayrecord1.id = 1
//            hourlypayrecord1.timefrom = Double(time.index(of: TimeFrom1.text!)!)-(Double(time.index(of: TimeFrom1.text!)!)*0.5) + 1.0
//            hourlypayrecord1.timeto = Double(time.index(of: TimeTo1.text!)!)-(Double(time.index(of: TimeTo1.text!)!)*0.5) + 1.0
//            hourlypayrecord1.pay = Int(Salaly1.text!)!
//            hourlypayrecord2.id = 2
//            hourlypayrecord2.timefrom = Double(time.index(of: TimeFrom2.text!)!)-(Double(time.index(of: TimeFrom2.text!)!)*0.5) + 1.0
//            hourlypayrecord2.timeto = Double(time.index(of: TimeTo2.text!)!)-(Double(time.index(of: TimeTo2.text!)!)*0.5) + 1.0
//            hourlypayrecord2.pay = Int(Salaly2.text!)!
//
//            DBmethod().AddandUpdate(hourlypayrecord1,update: true)
//            DBmethod().AddandUpdate(hourlypayrecord2,update: true)
//
//            let alertController = UIAlertController(title: "保存完了", message: "設定情報の登録に成功しました", preferredStyle: .alert)
//
//            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//            alertController.addAction(defaultAction)
//
//            present(alertController, animated: true, completion: nil)
//        }
    }
    
    //テキストフィールドが入力状態になった際に動作
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        txtActiveField = textField
//        return true
//    }
    //リターンキーを押した時に動作
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        view.endEditing(true)
//        return true
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
//        SetText()
    }
    
    func SetText(){
        //既に登録されていたら登録内容を表示する
        if DBmethod().DBRecordCount(HourlyPayDB.self) == 0 {
//            TimeFrom1.placeholder = "no data"
//            TimeFrom2.placeholder = "no data"
//            TimeTo1.placeholder = "no data"
//            TimeTo2.placeholder = "no data"
//            Salaly1.placeholder = "no data"
//            Salaly2.placeholder = "no data"
            
        }else{
            
            let hourlypayarray = DBmethod().HourlyPayRecordGet()
            
//            TimeFrom1.text = time[Int(hourlypayarray[0].timefrom * 2) - 2]
//            TimeTo1.text = time[Int(hourlypayarray[0].timeto * 2) - 2]
//            TimeFrom2.text = time[Int(hourlypayarray[1].timefrom * 2) - 2]
//            TimeTo2.text = time[Int(hourlypayarray[1].timeto * 2) - 2]
//            Salaly1.text = String(hourlypayarray[0].pay)
//            Salaly2.text = String(hourlypayarray[1].pay)
        }
    }
}
