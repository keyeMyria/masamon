//
//  MonthlySalaryShow.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/10/27.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit

class day_button {
    var year = 0
    var month = 0
    var day = 0
}

class MonthlySalaryShow: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    let shiftdb = ShiftDB()
    let shiftdetaildb = ShiftDetailDB()
    var shiftlist: NSMutableArray = []
    var onecourspicker: UIPickerView = UIPickerView()
    @IBOutlet weak var SaralyLabel: UILabel!
    
    let filemanager:FileManager = FileManager()

    let notificationCenter = NotificationCenter.default
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate //AppDelegateのインスタンスを取得
    let alertview = UIImageView()
    
    var currentnsdate = Date()        //MonthlySalaryShowがデータ表示している日付を管理
    
    let shiftgroupname = Utility().GetShiftGroupName()
    var shiftgroupnameUIPicker: UIPickerView = UIPickerView()

    var pickerviewtoolBar = UIToolbar()
    var pickerdoneButton = UIBarButtonItem()
    
    var shiftgroupnametextfield = UITextField()
    
    var CalenderLabel = UILabel()
    
    let shiftarray = [" 早番："," 中1："," 中2："," 中3："," 遅番："," その他："]

    var ShiftLabelArray: [[UILabel]] = []
    
    let Libralypath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0] as String
    var staffshiftcountflag = true
    var staffnamecountflag = true
    
    let pdfmethod = PDFmethod()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: 保守用コード
//        let maintenance = Maintenance()
//        maintenance.FileRemove()
//        maintenance.DBAdd()
//        maintenance.DBUpdate()
//        maintenance.DBDelete()
        
        
        
        self.setupShiftLabel()      //シフトを表示するラベルを設置する
        
        self.setupTapGesture()      //タップを検出するジェスチャーを追加
        
        self.setupdayofweekLabel()  //日曜日〜土曜日までのラベルを設置する
        
        self.SetupDayButton(0)      //1週間分の日付を表示するボタンを設置する
        
        //シフトグループを選択するpickerview
        shiftgroupnameUIPicker.frame = CGRect(x: 0,y: 0,width: self.view.bounds.width/2+20, height: 200.0)
        shiftgroupnameUIPicker.delegate = self
        shiftgroupnameUIPicker.dataSource = self
        shiftgroupnameUIPicker.tag = 2
        
        //pickerviewに表示するツールバー
        pickerviewtoolBar.barStyle = UIBarStyle.default
        pickerviewtoolBar.isTranslucent = true
        pickerviewtoolBar.sizeToFit()
        
        pickerdoneButton = UIBarButtonItem(title: "完了", style: UIBarButtonItemStyle.plain, target: self, action: #selector(MonthlySalaryShow.donePicker(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        pickerviewtoolBar.setItems([flexSpace,pickerdoneButton], animated: false)
        pickerviewtoolBar.isUserInteractionEnabled = true
        
        
        currentnsdate = Date()
        
        let today = Date()
        
        //前日、今日、翌日のラベルにデータをセットする
        let daycontrol = [-1,0,1]
        for i in 0..<ShiftLabelArray.count {
            //control[i]分だけ日付を操作したnsdateを作成する
            let calendar = Calendar.current
            let daycontroled_nsdate = (calendar as NSCalendar).date(byAdding: .day, value: daycontrol[i], to: today, options: [])
            let daycontroled_splitday = Utility().ReturnYearMonthDayWeekday(daycontroled_nsdate!)

            self.ShowAllData(Utility().Changecalendar(daycontroled_splitday.year, calender: "A.D"), m: daycontroled_splitday.month, d: daycontroled_splitday.day, arraynumber: i)
        }
        
        let date = Utility().ReturnYearMonthDayWeekday(today)
        //日付を表示するラベルの初期設定
        CalenderLabel.frame = CGRect(x: 8, y: 240, width: 359, height: 33)
        CalenderLabel.backgroundColor = UIColor.clear
        CalenderLabel.textColor = UIColor.white
        CalenderLabel.textAlignment = NSTextAlignment.center
        self.SetCalenderLabel(date.year, month: date.month, day: date.day, weekday: date.weekday)

        self.view.addSubview(CalenderLabel)
        
        Timer.scheduledTimer(timeInterval: 1.0,target:self,selector:#selector(MonthlySalaryShow.FileSaveSuccessfulAlertShow),
                                               userInfo: nil, repeats: true);
        
        //アプリがアクティブになったとき
        notificationCenter.addObserver(self,selector: #selector(MonthlySalaryShow.MonthlySalaryShowViewActived),name:NSNotification.Name.UIApplicationDidBecomeActive,object: nil)
        
        //PickerViewの追加
        onecourspicker.frame = CGRect(x: -20,y: 35,width: self.view.bounds.width/2+20, height: 150.0)
        onecourspicker.delegate = self
        onecourspicker.dataSource = self
        onecourspicker.tag = 1
        self.view.addSubview(onecourspicker)
        
        //NSArrayへの追加
        if DBmethod().DBRecordCount(ShiftDB.self) != 0 {
            for i in (0 ... DBmethod().DBRecordCount(ShiftDB.self)-1).reversed(){
                shiftlist.add(DBmethod().ShiftDBGet(i))
            }
            
            //pickerviewのデフォルト表示
            SaralyLabel.text = self.GetCommaSalalyString(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB.self)-1))
        }
    }
    
    /**
     pickerview,label,シフトの表示を更新する
     
     - parameter animated:
     */
    override func viewDidAppear(_ animated: Bool) {
        
        shiftlist.removeAllObjects()
        if DBmethod().DBRecordCount(ShiftDB.self) != 0 {
            for i in (0 ... DBmethod().DBRecordCount(ShiftDB.self)-1).reversed(){
                shiftlist.add(DBmethod().ShiftDBGet(i))
            }
            
            //pickerviewのデフォルト表示
            SaralyLabel.text = self.GetCommaSalalyString(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB.self)-1))
        }else{
            SaralyLabel.text = ""
        }
        
        onecourspicker.reloadAllComponents()
        
        let today = self.currentnsdate
        let date = Utility().ReturnYearMonthDayWeekday(today)         //日付を西暦,月,日,曜日に分けて取得
        self.ShowAllData(Utility().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day, arraynumber: 1)           //データ表示へ分けた日付を渡す
        self.SetCalenderLabel(date.year, month: date.month, day: date.day, weekday: date.weekday)
        
        appDelegate.screennumber = 0
    }
    

    /**
     バックグラウンドで保存しながらプログレスを表示する
     */
    func savedata() {
        
        if self.appDelegate.filename.contains(".xlsx") {
            //新規シフトがあるか確認する
            XLSXmethod().CheckShift()
            
            //スタッフ名にシフト文字が含まれていたら記録する
            XLSXmethod().CheckStaffName()
            
            //新規シフト認識エラーがない場合は月給計算を行う
            if self.appDelegate.errorshiftnamexlsx.count == 0 {
                XLSXmethod().ShiftDBOneCoursRegist(self.appDelegate.filename, importpath: self.Libralypath+"/"+self.appDelegate.filename, update: self.appDelegate.update)
                XLSXmethod().UserMonthlySalaryRegist(self.appDelegate.filename)
            }
                    
            /*pickerview,label,シフトの表示を更新する*/
            self.shiftlist.removeAllObjects()
            if DBmethod().DBRecordCount(ShiftDB.self) != 0 {
                for i in (0 ... DBmethod().DBRecordCount(ShiftDB.self)-1).reversed(){
                    self.shiftlist.add(DBmethod().ShiftDBGet(i))
                }
                self.SaralyLabel.text = self.GetCommaSalalyString(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB.self)-1))
            }
            
            self.onecourspicker.reloadAllComponents()
                    
            let today = self.currentnsdate
            let date = Utility().ReturnYearMonthDayWeekday(today)
            self.ShowAllData(Utility().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day, arraynumber: 1)
            self.SetCalenderLabel(date.year, month: date.month, day: date.day, weekday: date.weekday)
                    
            if self.appDelegate.errorshiftnamexlsx.count != 0 {  //新規シフト名がある場合
                if self.staffshiftcountflag {
                    self.appDelegate.errorshiftnamefastcount = self.appDelegate.errorshiftnamexlsx.count
                    self.staffshiftcountflag = false
                }
                self.StaffShiftErrorAlertShowXLSX()
            }
        }else{ //取り込みがPDFの場合
            //スタッフが登録されていない場合はエラーアラートを出す
            if DBmethod().DBRecordCount(StaffNameDB.self) == 0 {
                let alert: UIAlertController = UIAlertController(title: "取り込みエラー", message: "スタッフを1名以上登録してください", preferredStyle:  UIAlertControllerStyle.alert)
                let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:
                    {
                        (action:UIAlertAction!) -> Void in
                        //ファイルの削除
                        let libralypath = self.Libralypath + "/"
                        let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出
                        
                        //コピーしたファイルの削除
                        do{
                            try self.filemanager.removeItem(atPath: libralypath + filename)
                            DBmethod().InitRecordInboxFileCountDB()
                        }catch{
                            print(error)
                        }
                    })
                
                alert.addAction(defaultAction)
                
                present(alert, animated: true, completion: nil)
            }else {
                //PDF内のデータを取得して未登録のシフト名をチェック
                self.pdfmethod.RunPDFmethod()
                
                if self.appDelegate.unknownshiftname.count != 0 {  //シフト認識エラーがある場合
                    self.StaffShiftErrorAlertShowPDF()
                    
                    //未登録のシフト名がない場合はデータベースへ書き込みを行う
                } else {
                    self.pdfmethod.RegistDataBase(self.appDelegate.update, importname: self.appDelegate.filename, importpath: self.Libralypath+"/"+self.appDelegate.filename)
                    self.pdfmethod.UserMonthlySalaryRegist(self.appDelegate.filename)
                }
                
                /*pickerview,label,シフトの表示を更新する*/
                self.shiftlist.removeAllObjects()
                if DBmethod().DBRecordCount(ShiftDB.self) != 0 {
                    for i in (0 ... DBmethod().DBRecordCount(ShiftDB.self)-1).reversed(){
                        self.shiftlist.add(DBmethod().ShiftDBGet(i))
                    }
                    self.SaralyLabel.text = self.GetCommaSalalyString(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB.self)-1))
                }
                
                self.onecourspicker.reloadAllComponents()
                
                let today = self.currentnsdate
                let date = Utility().ReturnYearMonthDayWeekday(today)
                self.ShowAllData(Utility().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day, arraynumber: 1)
                self.SetCalenderLabel(date.year, month: date.month, day: date.day, weekday: date.weekday)
            }
        }
    }
    
    /**
     PDFでシフト認識エラーがある場合に表示してデータ入力をさせるためのアラート
     */
    func StaffShiftErrorAlertShowPDF(){
        var flag = false
        
        let alert:UIAlertController = UIAlertController(title:"\(appDelegate.unknownshiftname[0])が未登録です",
                                                        message:"シフトのグループを選択してください",
                                                        preferredStyle: UIAlertControllerStyle.alert)
        
        let addAction:UIAlertAction = UIAlertAction(title: "追加",
                                                    style: UIAlertActionStyle.default,
                                                    handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                                                        if textFields != nil {
                                                            for textField:UITextField in textFields! {
                                                                
                                                                if textField.text == "" {
                                                                    flag = false
                                                                    break
                                                                }else{
                                                                    flag = true
                                                                }
                                                            }
                                                            
                                                            if flag {   //テキストフィールドに値が全て入っている場合
                                                                
                                                                let newrecord = Utility().CreateShiftSystemDBRecord(DBmethod().DBRecordCount(ShiftSystemDB.self),shiftname: textFields![0].text!, shiftgroup: textFields![1].text!)
                                                                DBmethod().AddandUpdate(newrecord, update: true)
                                                                
                                                                self.savedata()
                                                            }else{
                                                                self.StaffShiftErrorAlertShowPDF()
                                                            }
                                                        }
        })
        
        let skipAction:UIAlertAction = UIAlertAction(title: "スキップ",
                                                     style: UIAlertActionStyle.destructive,
                                                     handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        self.appDelegate.skipshiftname = self.appDelegate.unknownshiftname[0]
                                                        self.savedata()
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.cancel) { (UIAlertAction) in
            //ファイルの削除
            let libralypath = self.Libralypath + "/"
            let filename = DBmethod().FilePathTmpGet().lastPathComponent    //ファイル名の抽出

            //コピーしたファイルの削除
            do{
                try self.filemanager.removeItem(atPath: libralypath + filename)
                DBmethod().InitRecordInboxFileCountDB()
                DBmethod().InitRecordFilePathTmpDB()
            }catch{
                print(error)
            }
        }
        
        alert.addAction(addAction)
        alert.addAction(skipAction)
        alert.addAction(cancelAction)
        
        //シフト名入力用のtextfieldを追加
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.text = self.appDelegate.unknownshiftname[0]
            text.returnKeyType = .next
            text.tag = 0
            text.delegate = self
        })
        
        //シフトグループの選択内容を入れるテキストフィールドを追加
        alert.addTextField(configurationHandler: configurationshiftgroupnameTextField)
                
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /**
     XLSXで新規シフト体制名が含まれていた場合に表示するアラート
     */
    func StaffShiftErrorAlertShowXLSX(){
        let errorshiftnamexlsxarray = self.appDelegate.errorshiftnamexlsx
        var flag = false
        let donecount = appDelegate.errorshiftnamefastcount - appDelegate.errorshiftnamexlsx.count
        
        let alert:UIAlertController = UIAlertController(title:"\(donecount+1)/\(appDelegate.errorshiftnamefastcount)個" + "\n" + errorshiftnamexlsxarray[0]+"のシフトに関する情報を入力して下さい",
                                                        message: "<シフトの名前> \n 例) 出勤 \n",
                                                        preferredStyle: UIAlertControllerStyle.alert)
        
        let addAction:UIAlertAction = UIAlertAction(title: "追加",
                                                    style: UIAlertActionStyle.default,
                                                    handler:{
                                                        (action:UIAlertAction!) -> Void in
                                                        let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
                                                        if textFields != nil {
                                                            
                                                            for textField:UITextField in textFields! {
                                                                if textField.text == "" {
                                                                    flag = false
                                                                    break
                                                                }else{
                                                                    flag = true
                                                                }
                                                            }
                                                            
                                                            if flag {   //テキストフィールドに値が全て入っている場合
                                                                
                                                                let newrecord = Utility().CreateShiftSystemDBRecord(DBmethod().DBRecordCount(ShiftSystemDB.self),shiftname: textFields![0].text!, shiftgroup: textFields![1].text!)
                                                                DBmethod().AddandUpdate(newrecord, update: true)
                                                                
                                                                self.savedata()
                                                            }else{
                                                                self.StaffShiftErrorAlertShowXLSX()
                                                            }
                                                        }
        })
        
        alert.addAction(addAction)
        
        //シフト名入力用のtextfieldを追加
        alert.addTextField(configurationHandler: {(text:UITextField!) -> Void in
            text.placeholder = "シフトの名前を入力"
            text.returnKeyType = .next
            text.tag = 0
            text.delegate = self
        })
        
        //シフトグループの選択内容を入れるテキストフィールドを追加
        alert.addTextField(configurationHandler: configurationshiftgroupnameTextField)
        
        self.present(alert, animated: true, completion: nil)
    }
    

    /**
     アラートに表示するテキストフィールドのreturnkeyをタップした時に動作
     
     - parameter textField: returnkeyをタップしたtextField
     
     - returns: returnkeyの有効・無効
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField.text?.isEmpty) != nil {
            
            //シフト名,シフトグループ名の場所にカーソルがある時はボタンを有効にする
            switch(textField.tag){
            case 0:
                return true
            default:
                return false
            }
        }else{
            return false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /**
     pickerviewの表示設定を行う
     
     - parameter pickerView: 対象となるpickerView
     - parameter row:        行
     - parameter component:  列
     
     - returns: pickerViewに表示する文字列
     */
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        if pickerView.tag == 1 {
            let attributedString = NSAttributedString(string: shiftlist[row] as! String, attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
            return attributedString
        }else {
            let attributedString = NSAttributedString(string: shiftgroupname[row] , attributes: [NSAttributedStringKey.foregroundColor : UIColor.black])
            return attributedString
        }
    }
    

    /**
     pickerViewの表示列を設定
     
     - parameter pickerView: シフトグループを選択させるpickerView
     
     - returns: 表示する列の数
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //表示個数
    /**
     pickerViewに表示する行数
     
     - parameter pickerView: 対象となるpickerView
     - parameter component:  対象となるpickerViewの列指定
     
     - returns: 表示する行数
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 1 {
            return shiftlist.count
        }else {
            pickerdoneButton.tag = 2
            return shiftgroupname.count
        }
    }

    /**
     pickerViewを選択した際に動作
     
     - parameter pickerView: 選択したpickerView
     - parameter row:        行
     - parameter component:  列
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.tag == 1 {            //取り込んだシフト
            if DBmethod().DBRecordCount(ShiftDB.self) != 0 {         //レコードが0のときは何もしない
                SaralyLabel.text = self.GetCommaSalalyString(DBmethod().ShiftDBSaralyGet(DBmethod().DBRecordCount(ShiftDB.self)-1-row))
            }
            
        }else if pickerView.tag == 2 {      //シフトグループ選択
            shiftgroupnametextfield.text = shiftgroupname[row]
            pickerdoneButton.tag = 2
            shiftgroupselectrow = row
        }
    }
    

    /**
     月給表示画面が表示(アプリがアクティブ)されたら動作
     ファイルがコピーされていたらimport画面へ遷移させる
     */
    @objc func MonthlySalaryShowViewActived(){
        
        //ファイル数のカウント
        let filemanager:FileManager = FileManager()
        let files = filemanager.enumerator(atPath: NSHomeDirectory() + "/Documents/Inbox")
        var filecount = 0
        while let _ = files?.nextObject() {
            filecount += 1
        }
        
        if DBmethod().InboxFileCountsGet() < filecount {   //ファイル数が増えていたら(新規でダウンロードしていたら)
            //ファイルの数をデータベースへ記録
            let InboxFileCountRecord = InboxFileCountDB()
            InboxFileCountRecord.id = 0
            InboxFileCountRecord.counts = 1
            DBmethod().AddandUpdate(InboxFileCountRecord,update: true)
            
            let targetViewController = self.storyboard!.instantiateViewController(withIdentifier: "ShiftImport")
            self.present( targetViewController, animated: true, completion: nil)
        }else{
            
        }
    }
    
    /**
     ファイルの保存が行われていたらsavedata()を実行する
     */
    @objc func FileSaveSuccessfulAlertShow(){
        if appDelegate.filesavealert {
            self.savedata()
            appDelegate.filesavealert = false
        }
    }
    

    /**
     受け取った文字列をシフト体制に分別して返す
     
     - parameter staff: 1日分のスタッフ名とシフト体制名が記述された文字列
     
     - returns: シフト体制ごと(早,中1,2,3,遅,その他)に分けてスタッフ名を格納した1次元配列
     */
    func SplitStaffShift(_ staff: String) -> Array<String>{
        var staffshiftarray: [String] = ["","","","","",""]         //早番,中1,中2,中3,遅,その他
        let endindex = staff.endIndex       //文字列の最後の場所
        var nowindex = staff.startIndex     //文字列の現在地
        
        while(nowindex != endindex){
            var staffname = ""
            var staffshift = ""
            
            while(staff[nowindex] != ":"){                            //スタッフ名を抽出するループ
                staffname = staffname + String(staff[nowindex])
                nowindex = staff.index(after: nowindex)
            }
            
            nowindex = staff.index(after: nowindex)
            
            while(staff[nowindex] != ","){                            //シフトを抽出するループ
                staffshift = staffshift + String(staff[nowindex])
                nowindex = staff.index(after: nowindex)
            }
            
            if DBmethod().SearchShiftSystem(staffshift) == nil {     //シフト体制になかったらその他に分類
                staffshiftarray[5] = staffshiftarray[5] + staffname + "(\(staffshift))" + "、"
            }else{
                let shiftsystemresult = DBmethod().SearchShiftSystem(staffshift)
                switch(shiftsystemresult![0].groupid){
                case 0:
                    staffshiftarray[0] = staffshiftarray[0] + staffname + "、"
                case 1:
                    staffshiftarray[1] = staffshiftarray[1] + staffname + "、"
                case 2:
                    staffshiftarray[2] = staffshiftarray[2] + staffname + "、"
                case 3:
                    staffshiftarray[3] = staffshiftarray[3] + staffname + "、"
                case 4:
                    staffshiftarray[4] = staffshiftarray[4] + staffname + "、"
                case 5:
                    staffshiftarray[5] = staffshiftarray[5] + staffname + "(\(staffshift))" + "、"
                default:
                    break
                }
            }
            
            nowindex = staff.index(after: nowindex)
        }
        
        //最後の文字を削除するための処理
        for i in 0 ..< staffshiftarray.count{
            if staffshiftarray[i] != "" {
                var str = staffshiftarray[i]
                let endPoint = str.characters.count - 1
                str = str.substring(to: str.characters.index(str.startIndex, offsetBy: endPoint))
                staffshiftarray[i] = str
            }
        }
        
        return staffshiftarray
    }
    

    /**
     金額をコンマ付きの文字列として返す関数
     
     - parameter salaly: 月給
     
     - returns: コンマ付きの文字列
     */
    func GetCommaSalalyString(_ salaly: Int) -> String{
        
        var tmp = String(salaly)
        var index = tmp.characters.index(before: tmp.endIndex)
        var i = 1
        
        while(tmp.startIndex != index){
            
            if i % 3 == 0 {
                tmp.insert(",", at: index)
            }
            
            i += 1
            index = tmp.index(before: index)
        }
        
        return tmp
    }
    
    /**
     受け取った日付のデータ表示を行う
     
     - parameter y:           和暦
     - parameter m:           月
     - parameter d:           日
     - parameter arraynumber: 日付を表示するラベルのindex(0:前日 1:今日 2:翌日)
     */
    func ShowAllData(_ y: Int, m: Int, d: Int, arraynumber: Int){
        
        let fontsize:CGFloat = 14
        
        if DBmethod().TheDayStaffGet(y, month: m, date: d) == nil {
            let whiteAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.hex("BEBEBE", alpha: 1.0),NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontsize)]
            
            for i in 0..<ShiftLabelArray[arraynumber].count {
                ShiftLabelArray[arraynumber][i].attributedText = NSMutableAttributedString(string: shiftarray[i] + "No Data", attributes: whiteAttribute)
            }
            
        }else{
            let shiftdetaidb = DBmethod().TheDayStaffGet(y, month: m, date: d)
            var splitedstaffarray = self.SplitStaffShift(shiftdetaidb![0].staff)
            
            //スタッフ名がない場合にメッセージを代入するためのループ
            for i in 0 ..< splitedstaffarray.count{
                if splitedstaffarray[i] == "" {
                    splitedstaffarray[i] = "該当スタッフなし"
                }
            }
            
            //テキストビューにスタッフ名を羅列するためのループ
            for i in 0 ..< splitedstaffarray.count{
                var myString = NSMutableAttributedString()
                if (splitedstaffarray[i].range(of: DBmethod().UserNameGet())) != nil {
                    
                    let textviewnsstring = (shiftarray[i] + splitedstaffarray[i]) as NSString
                    let usernamelocation = textviewnsstring.range(of: DBmethod().UserNameGet()).location
                    let usernamelength = textviewnsstring.range(of: DBmethod().UserNameGet()).length
                    let myAttribute = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontsize+3) ]
                    let whiteAttribute = [ NSAttributedStringKey.foregroundColor: UIColor.white]
                    
                    myString = NSMutableAttributedString(string: shiftarray[i] + splitedstaffarray[i], attributes: myAttribute )
                    
                    let myRange = NSRange(location: usernamelocation, length: usernamelength)                                       //ユーザ名のRange
                    let myRange2 = NSRange(location: 0, length: usernamelocation)                                                   //シフト体制のRange
                    
                    //ユーザ名が文字列の最後でない場合
                    if textviewnsstring.length != (usernamelocation+usernamelength) {
                        let userposition = usernamelocation+usernamelength
                        let myRange3 = NSRange(location: (usernamelocation+usernamelength), length: (textviewnsstring.length-userposition))  //ユーザ名より後ろのRange
                        myString.addAttributes(whiteAttribute, range: myRange3)
                    }
                    
                    myString.addAttributes(whiteAttribute, range: myRange2)
                    myString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.hex("ff33ff", alpha: 1.0), range: myRange)                //ユーザ名強調表示
                    
                    ShiftLabelArray[arraynumber][i].attributedText = myString
                    
                }else{      //ユーザ名が含まれていない場合の表示
                    let myAttribute = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontsize) ]
                    let myRange = NSRange(location: 0, length: (shiftarray[i] + splitedstaffarray[i]).characters.count)
                    
                    myString = NSMutableAttributedString(string: shiftarray[i] + splitedstaffarray[i], attributes: myAttribute )
                    myString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.hex("BEBEBE", alpha: 1.0), range: myRange)
                    
                    ShiftLabelArray[arraynumber][i].attributedText = myString
                }
            }
        }
    }
    

    /**
     受け取った曜日の数字を実際の曜日に変換する
     
     - parameter weekday: 曜日を表す数値
     
     - returns: 月火水木金土日のいずれかの文字列
     */
    func ReturnWeekday(_ weekday: Int) ->String{
        switch(weekday){
        case 1:
            return "日"
        case 2:
            return "月"
        case 3:
            return "火"
        case 4:
            return "水"
        case 5:
            return "木"
        case 6:
            return "金"
        case 7:
            return "土"
        default:
            return ""
        }
    }
        

    /**
     ツールバーの完了ボタンを押した時に動作
     
     - parameter sender: ツールバーのボタン
     */
    @objc func donePicker(_ sender:UIButton){
        
        if sender.tag == 2 {            //シフトグループの完了ボタン
            shiftgroupnametextfield.resignFirstResponder()
        }
    }
    

    /**
     シフトのグループを入れるテキストフィールドの設定
     
     - parameter textField: 対象となるtextField
     */
    func configurationshiftgroupnameTextField(_ textField: UITextField!){
        textField.inputView = self.shiftgroupnameUIPicker
        textField.inputAccessoryView = self.pickerviewtoolBar
        textField.tag = 1
        textField.delegate = self
        shiftgroupnametextfield = textField
    }
    
    //シフトグループの選択箇所を記録する変数
    var shiftgroupselectrow = 0

    /**
     textfieldがタップされた時に動作
     
     - parameter textField: タップされたtextField
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField.tag == 1 {
            shiftgroupnameUIPicker.selectRow(shiftgroupselectrow, inComponent: 0, animated: true)
            textField.text = shiftgroupname[shiftgroupselectrow]
        }
    }
    
    /**
     シェイクジェスチャーを有効にする
     
     - returns: 有効:true, 無効:false
     */
    override var canBecomeFirstResponder : Bool {
        return true
    }
    

    /**
     曜日ラベルを表示する
     */
    func setupdayofweekLabel(){
        //曜日ラベルの配置
        let monthName:[String] = ["日","月","火","水","木","金","土"]
        let calendarLabelIntervalX = 15;
        let calendarLabelX         = 50;
        let calendarLabelY         = 170;
        let calendarLabelWidth     = 45;
        let calendarLabelHeight    = 25;
        
        for i in 0...6{
            
            //ラベルを作成
            let calendarBaseLabel: UILabel = UILabel()
            
            //X座標の値をCGFloat型へ変換して設定
            calendarBaseLabel.frame = CGRect(
                x: CGFloat(calendarLabelIntervalX + calendarLabelX * (i % 7)),
                y: CGFloat(calendarLabelY),
                width: CGFloat(calendarLabelWidth),
                height: CGFloat(calendarLabelHeight)
            )
            
            //日曜日の場合は赤色を指定
            if i == 0 {
                
                //RGBカラーの設定は小数値をCGFloat型にしてあげる
                calendarBaseLabel.textColor = UIColor(
                    red: CGFloat(1.0), green: CGFloat(0.0), blue: CGFloat(0.0), alpha: CGFloat(1.0)
                )
                
                //土曜日の場合は青色を指定
            }else if i == 6 {
                
                //RGBカラーの設定は小数値をCGFloat型にしてあげる
                calendarBaseLabel.textColor = UIColor(
                    red: CGFloat(0.0), green: CGFloat(0.0), blue: CGFloat(1.0), alpha: CGFloat(1.0)
                )
                
                //平日の場合は灰色を指定
            }else{
                
                //既に用意されている配色パターンの場合
                calendarBaseLabel.textColor = UIColor.white
                
            }
            
            //曜日ラベルの配置
            calendarBaseLabel.text = String(monthName[i] as NSString)
            calendarBaseLabel.textAlignment = NSTextAlignment.center
            calendarBaseLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            self.view.addSubview(calendarBaseLabel)
        }
    }
    
    var daybuttonarray:[day_button] = []
    var buttonobjectarray: [UIButton] = []
    
    /**
     1週間分の日付を表示したボタンを設置する
     
     - parameter judgeswipe: 1なら日付を進めるスワイプ，-1なら日付を戻すスワイプ
     */
    func SetupDayButton(_ judgeswipe: Int){
        
        //todayと一致するボタンタイトルがある場合は常に文字を白表示にする
        let totayNSDate = Date()
        let todaysplitday = Utility().ReturnYearMonthDayWeekday(totayNSDate) //日付を西暦,月,日,曜日に分けて取得
        
        self.RemoveButtonObjects()
        
        //ボタンのタイトルを日付から計算して生成する
        let currentsplitdate = Utility().ReturnYearMonthDayWeekday(currentnsdate)
        self.SetDayArray(currentnsdate,pivotweekday:currentsplitdate.weekday)      //buttontilearrayへ値を格納する
        
        for i in 0...6{
            
            //配置場所の定義
            let positionX   = 15 + 50 * (i % 7)
            let positionY   = 195
            let buttonSize = 40;
            
            //ボタンをつくる
            let button: UIButton = UIButton()
            button.frame = CGRect(
                x: CGFloat(positionX),
                y: CGFloat(positionY),
                width: CGFloat(buttonSize),
                height: CGFloat(buttonSize)
            );
            
            //ボタンのデザインを決定する
            button.backgroundColor = UIColor.clear
            button.setTitleColor(UIColor.gray, for: UIControlState())
            button.titleLabel!.font = UIFont.systemFont(ofSize: 19)
            button.layer.cornerRadius = CGFloat(buttonSize/2)
            button.tag = daybuttonarray[i].day
            
            button.setTitle(String(daybuttonarray[i].day), for: UIControlState())
            
            //currentnsdateと一致するボタンがある場合
            if currentsplitdate.year == daybuttonarray[i].year && currentsplitdate.month == daybuttonarray[i].month && currentsplitdate.day == daybuttonarray[i].day {
                button.backgroundColor = UIColor.hex("FF8E92", alpha: 1.0)
                button.setTitleColor(UIColor.white, for: UIControlState())
            }
            
            //今日の年月日と一致するボタンがある場合は文字色を白にする
            if todaysplitday.year == daybuttonarray[i].year && todaysplitday.month ==  daybuttonarray[i].month && todaysplitday.day == daybuttonarray[i].day {
                button.setTitleColor(UIColor.white, for: UIControlState())
            }
            
            //配置したボタンに押した際のアクションを設定する
            button.addTarget(self, action: #selector(MonthlySalaryShow.TapDayButton(_:)), for: .touchUpInside)
            
            //ボタンを配置する
            self.view.addSubview(button)
            self.view.bringSubview(toFront: button)
            
            //土曜日を表示中に、日付を進めるスワイプが発生したら
            if judgeswipe == 1 && currentsplitdate.weekday == 1 {
                
                self.AnimationDayButton(button, beforeposition: positionX+300, afterpositon: positionX, positionY: positionY, buttonsize: buttonSize)
                
                //日曜日を表示中に、日付を戻すスワイプが発生したら
            }else if judgeswipe == -1 && currentsplitdate.weekday == 7 {
                self.AnimationDayButton(button, beforeposition: positionX-300, afterpositon: positionX, positionY: positionY, buttonsize: buttonSize)
            }
            
            //タップをして今日に移動する際に、アニメーションを行う
            if tapanimationbuttonflag {
                if judgeswipe == 1 && tapanimationbuttonflag {
                    self.AnimationDayButton(button, beforeposition: positionX+300, afterpositon: positionX, positionY: positionY, buttonsize: buttonSize)
                }else if judgeswipe == -1 && tapanimationbuttonflag {
                    self.AnimationDayButton(button, beforeposition: positionX-300, afterpositon: positionX, positionY: positionY, buttonsize: buttonSize)
                }
            }
            
            buttonobjectarray.append(button)
        }
        
        tapanimationbuttonflag = false
    }
    

    /**
     日付ボタンをタップした際に動作
     
     - parameter sender: タップしたUIButton
     */
    @objc func TapDayButton(_ sender: UIButton){
        let currentsplitday = Utility().ReturnYearMonthDayWeekday(currentnsdate) //日付を西暦,月,日,曜日に分けて取得
        
        //タップした日付ボタンと表示中の日付の配列位置を比較
        var tagindex = 0
        var currentdayindex = 0
        var tagindex_foundflag = false
        var currentdayindex_foundflag = false
        for i in 0..<daybuttonarray.count {
            if daybuttonarray[i].day == sender.tag {
                tagindex = i
                tagindex_foundflag = true
            }
            
            if daybuttonarray[i].day == currentsplitday.day {
                currentdayindex = i
                currentdayindex_foundflag = true
            }
            
            if tagindex_foundflag && currentdayindex_foundflag {
                break
            }
        }
        
        self.DayControl(tagindex-currentdayindex)
        let currentnsdatesplit = Utility().ReturnYearMonthDayWeekday(currentnsdate)

        //今日の日付より大きい日付(翌日以降)のボタンがタップされた場合
        if tagindex - currentdayindex > 0 {
            self.AnimationCalenderLabel(20)
            self.ShowAllData(Utility().Changecalendar(currentnsdatesplit.year, calender: "A.D"), m: currentnsdatesplit.month, d: currentnsdatesplit.day, arraynumber: 2)
            self.AnimationShiftLabelCompletion(shiftlabel_x[0], mainposition: shiftlabel_x[0], nextpositon: shiftlabel_x[1])
        
        //今日の日付より小さい日付(前日以降)のボタンがタップされた場合
        }else if tagindex - currentdayindex < 0 {
            self.AnimationCalenderLabel(-4)
            self.ShowAllData(Utility().Changecalendar(currentnsdatesplit.year, calender: "A.D"), m: currentnsdatesplit.month, d: currentnsdatesplit.day, arraynumber: 0)
            self.AnimationShiftLabelCompletion(shiftlabel_x[1], mainposition: shiftlabel_x[2], nextpositon: shiftlabel_x[2])
        
        //今日の日付と同じボタンがタップされた場合
        }else{
            self.AnimationCalenderLabel(8)
        }
    }
    

    /**
     左右のスワイプと長押しのジェスチャー検知を設定する
     */
    func setupTapGesture() {
        // 右方向へのスワイプ
        let gestureToRight = UISwipeGestureRecognizer(target: self, action: #selector(MonthlySalaryShow.prevday))
        gestureToRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(gestureToRight)
        
        // 左方向へのスワイプ
        let gestureToLeft = UISwipeGestureRecognizer(target: self, action: #selector(MonthlySalaryShow.nextday))
        gestureToLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(gestureToLeft)
        
        //長押し
        let myLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(MonthlySalaryShow.today))
        myLongPressGesture.minimumPressDuration = 0.6
        myLongPressGesture.allowableMovement = 150
        self.view.addGestureRecognizer(myLongPressGesture)
    }
    
    var tapanimationbuttonflag = false      //タップをした際にbuttontilearray内に今日の日付が含まれているかを記録
    

    /**
     日付を表示しているLabelに対してアニメーションを行う
     
     - parameter beforeposition: 移動前のx座標
     */
    func AnimationCalenderLabel(_ beforeposition: CGFloat) {
        CalenderLabel.alpha = 0.0
        CalenderLabel.frame = CGRect(x: beforeposition, y: 240, width: 359, height: 33)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.CalenderLabel.frame = CGRect(x: 8, y: 240, width: 359, height: 33)
            self.CalenderLabel.alpha = 1.0
        }) 
    }
    

    /**
     日付を表示しているLabelに日付の内容をセットする
     
     - parameter year:    年
     - parameter month:   月
     - parameter day:     日
     - parameter weekday: 曜日(数値)
     */
    func SetCalenderLabel(_ year: Int, month: Int, day: Int, weekday: Int){
        CalenderLabel.text = "\(year)年\(month)月\(day)日 \(self.ReturnWeekday(weekday))曜日"
    }
    

    /**
     日付を表示するボタンのアニメーションを行うメソッド
     
     - parameter button:         アニメーションを行うボタン
     - parameter beforeposition: 移動前のx座標
     - parameter afterpositon:   移動後のx座標
     - parameter positionY:      ボタンのy座標(変化なし)
     - parameter buttonsize:     ボタンのサイズ(変化なし)
     */
    func AnimationDayButton(_ button: UIButton, beforeposition: Int, afterpositon: Int, positionY: Int, buttonsize: Int){
        button.frame = CGRect(
            x: CGFloat(beforeposition),
            y: CGFloat(positionY),
            width: CGFloat(buttonsize),
            height: CGFloat(buttonsize)
        );
        
        UIView.animate(withDuration: 0.3, animations: {
            button.frame = CGRect(
                x: CGFloat(afterpositon),
                y: CGFloat(positionY),
                width: CGFloat(buttonsize),
                height: CGFloat(buttonsize)
            );
        })
    }
    

    /**
     シフトを表示しているラベルをアニメーションした後に、初期位置に戻す関数
     
     - parameter prevposition: 前日のシフトを表示しているラベルのx座標
     - parameter mainposition: 今日のシフトを表示しているラベルのx座標
     - parameter nextpositon:  翌日のシフトを表示しているラベルのx座標
     */
    func AnimationShiftLabelCompletion(_ prevposition: Int, mainposition: Int, nextpositon: Int){
        let positionarray = [prevposition,mainposition,nextpositon]
        var y: CGFloat = 0
        var w: CGFloat = 0
        var h: CGFloat = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            for i in 0..<self.ShiftLabelArray.count {
                for j in 0..<self.ShiftLabelArray[i].count {
                    y = self.ShiftLabelArray[i][j].frame.origin.y
                    w = self.ShiftLabelArray[i][j].frame.size.width
                    h = self.ShiftLabelArray[i][j].frame.size.height
                    self.ShiftLabelArray[i][j].frame = CGRect(x: CGFloat(positionarray[i]), y: y, width: w, height: h)
                }
            }

            }, completion: {
                (value: Bool) in

                //配置場所をユーザが気づかないように瞬時に戻す
                for i in 0..<self.ShiftLabelArray.count {
                    for j in 0..<self.ShiftLabelArray[i].count {
                        y = self.ShiftLabelArray[i][j].frame.origin.y
                        w = self.ShiftLabelArray[i][j].frame.size.width
                        h = self.ShiftLabelArray[i][j].frame.size.height
                        self.ShiftLabelArray[i][j].frame = CGRect(x: CGFloat(self.shiftlabel_x[i]), y: y, width: w, height: h)
                    }
                }
                
                //配置を元に戻すと同時に表示内容も更新する
                let daycontrol = [-1,0,1]
                for i in 0..<self.ShiftLabelArray.count {
                    //control[i]分だけ日付を操作したnsdateを作成する
                    let calendar = Calendar.current
                    let daycontroled_nsdate = (calendar as NSCalendar).date(byAdding: .day, value: daycontrol[i], to: self.currentnsdate, options: [])
                    let daycontroled_splitday = Utility().ReturnYearMonthDayWeekday(daycontroled_nsdate!)

                    self.ShowAllData(Utility().Changecalendar(daycontroled_splitday.year, calender: "A.D"), m: daycontroled_splitday.month, d: daycontroled_splitday.day, arraynumber: i)
                }
        })
    }
    
    
    
    let shiftlabel_h = [65,35,35,35,65,65]
    let shiftlabel_line = [3,1,1,1,3,3]
    let shiftlabel_x = [-360,8,375]
    /**
     シフトを表示するラベル(前日,今日,翌日)を設置する
     */
    func setupShiftLabel(){
        let space = 7
        
        //2次元配列の初期化
        for i in 0...2 {
            var startheight = 275+space
            ShiftLabelArray.append([])
            
            for j in 0..<shiftlabel_line.count {
                let label = UILabel()
                label.frame = CGRect(x: CGFloat(shiftlabel_x[i]), y: CGFloat(startheight + j*space), width: 359, height: CGFloat(shiftlabel_h[j]))
                label.backgroundColor = UIColor.hex("4C4C4C", alpha: 1.0)
                label.numberOfLines = shiftlabel_line[j]
                
                ShiftLabelArray[i].append(label)
                self.view.addSubview(label)

                startheight += shiftlabel_h[j]
            }
        }
    }
    
    /**
     翌日に移動する関数
     */
    @objc func nextday(){
        self.DayControl(1)

        //日付表示ラベルを画面右側からアニメーション表示させる
        self.AnimationCalenderLabel(20)
        self.AnimationShiftLabelCompletion(shiftlabel_x[0], mainposition: shiftlabel_x[0], nextpositon: shiftlabel_x[1])
    }
    
    /**
     前日に移動する関数
     */
    @objc func prevday(){
        self.DayControl(-1)

        //日付表示ラベルを画面左側からアニメーション表示させる
        self.AnimationCalenderLabel(-4)
        self.AnimationShiftLabelCompletion(shiftlabel_x[1], mainposition: shiftlabel_x[2], nextpositon: shiftlabel_x[2])
    }
    
    /**
     今日に移動する関数
     
     - parameter sender: 長押しのジェスチャー
     */
    @objc func today(_ sender: UILongPressGestureRecognizer){
        
        if sender.state == UIGestureRecognizerState.began {
            
            let today = Date()
            let date = Utility().ReturnYearMonthDayWeekday(today)
            self.SetCalenderLabel(date.year, month: date.month, day: date.day, weekday: date.weekday)
            
            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let compareunit = (calendar as NSCalendar).compare(currentnsdate, to: today, toUnitGranularity: .day)
            
            currentnsdate = today
            
            var containflag = false
            for i in 0..<daybuttonarray.count {
                if daybuttonarray[i].year == date.year && daybuttonarray[i].month == date.month && daybuttonarray[i].day == date.day {
                    containflag = false
                    break
                }else {
                    containflag = true
                }
            }
            
            tapanimationbuttonflag = containflag
            
            //現在表示している日付と今日の日付を比較して、アニメーションを切り替えて表示する
            if compareunit == .orderedAscending {           //currentnsdateが今日より小さい(前の日付)場合
                self.ShowAllData(Utility().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day, arraynumber: 2)
                self.AnimationCalenderLabel(20)
                self.SetupDayButton(1)
                self.AnimationShiftLabelCompletion(shiftlabel_x[0], mainposition: shiftlabel_x[0], nextpositon: shiftlabel_x[1])
                
            }else if compareunit == .orderedDescending{     //currentnsdateが今日より大きい(後の日付)場合
                self.ShowAllData(Utility().Changecalendar(date.year, calender: "A.D"), m: date.month, d: date.day, arraynumber: 0)
                self.AnimationCalenderLabel(-4)
                self.SetupDayButton(-1)
                self.AnimationShiftLabelCompletion(shiftlabel_x[1], mainposition: shiftlabel_x[2], nextpositon: shiftlabel_x[2])
                
            }else{                                          //日付が同じ場合
                self.AnimationCalenderLabel(8)
                self.SetupDayButton(0)
            }
        }
    }

    

    /**
     何日進めるかの値を受け取って日付を操作する
     
     - parameter control: 進める日付の日数
     */
    func DayControl(_ control: Int){
        //control分だけ日付を操作したnsdateを作成する
        let calendar = Calendar.current
        let daycontroled_nsdate = (calendar as NSCalendar).date(byAdding: .day, value: control, to: self.currentnsdate, options: [])
        
        currentnsdate = daycontroled_nsdate!

        let currentnsdatesplit = Utility().ReturnYearMonthDayWeekday(currentnsdate)
        
        //日付を表示しているラベルの内容を変更する
        self.SetCalenderLabel(currentnsdatesplit.year, month: currentnsdatesplit.month, day: currentnsdatesplit.day, weekday: currentnsdatesplit.weekday)

        self.SetupDayButton(control)
    }
    

    /**
     1週間分の日付を配列へ格納する
     
     - parameter pivotnsdate:  今日のnsdate
     - parameter pivotweekday: 今日の曜日を表す数値
     */
    func SetDayArray(_ pivotnsdate: Date, pivotweekday: Int){
        var j = 0                   //日付を増やすための変数
        
        let nsdatesplit = Utility().ReturnYearMonthDayWeekday(pivotnsdate)
        
        //今日の日付から日曜日までの日付を追加する
        for i in (1..<pivotweekday).reversed() {
            let tmp_daybutton = day_button()
            
            let newnsdate = Utility().CreateNSDate(nsdatesplit.year, month: nsdatesplit.month, day: nsdatesplit.day-i)
            let newnsdatesplit = Utility().ReturnYearMonthDayWeekday(newnsdate)
            
            tmp_daybutton.year = newnsdatesplit.year
            tmp_daybutton.month = newnsdatesplit.month
            tmp_daybutton.day = newnsdatesplit.day
            daybuttonarray.append(tmp_daybutton)
        }
        
        //今日の日付から土曜日までの日付を追加する
        for _ in pivotweekday...7 {
            let tmp_daybutton = day_button()
            
            let newnsdate = Utility().CreateNSDate(nsdatesplit.year, month: nsdatesplit.month, day: nsdatesplit.day+j)
            j += 1
            let newnsdatesplit = Utility().ReturnYearMonthDayWeekday(newnsdate)
            
            tmp_daybutton.year = newnsdatesplit.year
            tmp_daybutton.month = newnsdatesplit.month
            tmp_daybutton.day = newnsdatesplit.day
            
            daybuttonarray.append(tmp_daybutton)
        }
    }
    

    /**
     1週間分の日付を表示しているボタンオブジェクトを削除する
     */
    func RemoveButtonObjects(){
        
        for i in 0..<buttonobjectarray.count {
            buttonobjectarray[i].removeFromSuperview()
        }
        
        self.daybuttonarray.removeAll()
    }
}

