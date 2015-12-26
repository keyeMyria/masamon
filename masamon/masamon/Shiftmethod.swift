//
//  ShiftRegister.swift
//  masamon
//
//  Created by 岩見建汰 on 2015/12/06.
//  Copyright © 2015年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift

class Shiftmethod: UIViewController {
    
    //cellの列(日付が記載されている範囲)
    let cellrow = ["G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ"]
    let holiday = ["公","夏","有"]     //表に記載される休暇日
    let staffnumber = DBmethod().StaffNumberGet()
    let mark = "F"
    var number = 6

    //
    func ShiftDBOneCoursRegist(importname: String, importpath: String, update: Bool){
        let documentPath: String = NSBundle.mainBundle().pathForResource("bbb", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        var date = 11
        let staffcellposition = self.StaffCellPositionGet()     //スタッフの名前が記載されているセル場所 ex.)F8,F9
        var shiftdetailarray = List<ShiftDetailDB>()
        var shiftdetailrecordcount = DBmethod().DBRecordCount(ShiftDetailDB)
        
        //30日分繰り返すループ
        for(var i = 0; i < 30; i++){
            let shiftdb = ShiftDB()
            let shiftdetaildb = ShiftDetailDB()
            
            if(update){
                shiftdb.id = DBmethod().SearchShiftDB(importname).id        //取り込みが上書きの場合は使われているidをそのまま使う
                let existshiftdb = DBmethod().SearchShiftDB(importname)
                let newshiftdetaildb = ShiftDetailDB()

                newshiftdetaildb.id = existshiftdb.shiftdetail[i].id
                newshiftdetaildb.date = existshiftdb.shiftdetail[i].date
                newshiftdetaildb.staff = TheDayStaffAttendance(i, staffcellpositionarray: staffcellposition, worksheet: worksheet)
                newshiftdetaildb.shiftDBrelationship = DBmethod().SearchShiftDB(importname)
                
                DBmethod().AddandUpdate(newshiftdetaildb, update: true)
            }else{
                shiftdb.id = DBmethod().DBRecordCount(ShiftDetailDB)/30     //新規の場合はレコードの数を割ったidを使う
                shiftdb.shiftimportname = importname
                shiftdb.shiftimportpath = importpath
                shiftdb.salaly = 0
                
                shiftdetaildb.id = shiftdetailrecordcount
                shiftdetailrecordcount++
                shiftdetaildb.date = date
                shiftdetaildb.shiftDBrelationship = shiftdb
                shiftdetaildb.staff = TheDayStaffAttendance(i, staffcellpositionarray: staffcellposition, worksheet: worksheet)
                
                //シフトが11日〜来月10日のため日付のリセットを行うか判断
                if(date < 30){
                    date++
                }else{
                    date = 1
                }
                
                //すでに記録してあるListを取得して後ろに現在の記録を追加する
                for(var i = 0; i < shiftdetailarray.count; i++){
                    shiftdb.shiftdetail.append(shiftdetailarray[i])
                }
                shiftdb.shiftdetail.append(shiftdetaildb)
                
                let ID = shiftdb.id
                
                DBmethod().AddandUpdate(shiftdb, update: true)
                DBmethod().AddandUpdate(shiftdetaildb, update: true)
                
                shiftdetailarray = self.ShiftDBRelationArrayGet(ID)
            }
        }
    }
    
    //
    
    //表中にあるスタッフ名の場所を返す
    func StaffCellPositionGet() -> Array<String>{
        let documentPath: String = NSBundle.mainBundle().pathForResource("bbb", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        
        var array:[String] = []
        
        
        while(true){
            let Fcell: String = worksheet.cellForCellReference(mark+String(number)).stringValue()
            if(Fcell.isEmpty){       //セルが空なら進めるだけ
                number++
            }else{
                array.append(mark+String(number))
                number++
            }
            
            if(staffnumber == array.count){       //設定したスタッフ人数と取り込み数が一致したら
                break
            }
        }
        return array
    }
    
    //ShiftDBのリレーションシップ配列を返す
    func ShiftDBRelationArrayGet(id: Int) -> List<ShiftDetailDB>{
        var list = List<ShiftDetailDB>()
        let realm = try! Realm()
        
        list = realm.objects(ShiftDB).filter("id = %@", id)[0].shiftdetail
        
        return list
        
    }
    
    //入力したユーザ名の月給を計算して結果を返す
    func UserMonthlySalaryRegist(importname: String){
        var usershift:[String] = []
        
        let username = DBmethod().UserNameGet()
        let staffcellposition = self.StaffCellPositionGet()
        
        let documentPath: String = NSBundle.mainBundle().pathForResource("bbb", ofType: "xlsx")!
        let spreadsheet: BRAOfficeDocumentPackage = BRAOfficeDocumentPackage.open(documentPath)
        let worksheet: BRAWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
        
        var userposition = ""
        
        //F列からユーザ名と合致する箇所を探す
        for(var i = 0; i < staffnumber; i++){
            let nowcell: String = worksheet.cellForCellReference(staffcellposition[i]).stringValue()
            
            if(nowcell == username){
                userposition = staffcellposition[i]
                break
            }
        }
        
        //1クール分行う
        for(var i = 0; i < 30; i++){
            let replaceday = userposition.stringByReplacingOccurrencesOfString("F", withString: cellrow[i])
            let dayshift: String = worksheet.cellForCellReference(replaceday).stringValue()
            
            if(holiday.contains(dayshift) == false){      //holiday以外なら
                usershift.append(dayshift)
            }
        }
        
        //月給の計算をする
        var shiftsystem = ShiftSystem()
        var monthlysalary = 0.0
        let houlypayrecord = DBmethod().HourlyPayRecordGet()
        
        for(var i = 0; i < usershift.count; i++){
            
            shiftsystem = DBmethod().SearchShiftSystem(usershift[i])
            if(shiftsystem.endtime <= houlypayrecord[0].timeto){
                monthlysalary = monthlysalary + (shiftsystem.endtime - shiftsystem.starttime - 1) * Double(houlypayrecord[0].pay)
            }else{
                //22時以降の給与を先に計算
                let latertime = shiftsystem.endtime - houlypayrecord[0].timeto
                monthlysalary = monthlysalary + latertime * Double(houlypayrecord[1].pay)
                
                monthlysalary = monthlysalary + (shiftsystem.endtime - latertime - shiftsystem.starttime - 1) * Double(houlypayrecord[0].pay)
            }
        }
        
        //データベースへ記録上書き登録
        let newshiftdbsalalyadd = ShiftDB()                                 //月給を追加するための新規インスタンス
        let oldshiftdbsalalynone = DBmethod().SearchShiftDB(importname)     //月給がデフォルト値で登録されているShiftDBオブジェクト
        
        newshiftdbsalalyadd.id = oldshiftdbsalalynone.id
        
        for(var i = 0; i < oldshiftdbsalalynone.shiftdetail.count; i++){
            newshiftdbsalalyadd.shiftdetail.append(oldshiftdbsalalynone.shiftdetail[i])
        }
        
        newshiftdbsalalyadd.shiftimportname = oldshiftdbsalalynone.shiftimportname
        newshiftdbsalalyadd.shiftimportpath = oldshiftdbsalalynone.shiftimportpath
        newshiftdbsalalyadd.salaly = Int(monthlysalary)
        DBmethod().AddandUpdate(newshiftdbsalalyadd, update: true)
    }
    
    
    //その日のシフトを全員分調べて出勤者だけ列挙する。
    /*引数の説明。
    day                     => その日の日付
    staffcellpositionarray  =>スタッフのセル位置を配列で記録したもの
    worksheet               =>対象となるエクセルファイルのワークシート
    */
    func TheDayStaffAttendance(day: Int, staffcellpositionarray: Array<String>, worksheet: BRAWorksheet) -> String{
        
        var staffstring = ""
        
        for(var i = 0; i < staffnumber; i++){
            let nowstaff = staffcellpositionarray[i]
            let replaceday = nowstaff.stringByReplacingOccurrencesOfString("F", withString: cellrow[day])
            
            let dayshift: String = worksheet.cellForCellReference(replaceday).stringValue()
            let staffname: String = worksheet.cellForCellReference(nowstaff).stringValue()
            
            if(holiday.contains(dayshift) == false){       //Holiday以外なら記録
                staffstring = staffstring + staffname + ":" + dayshift + ","
            }
        }
        
        return staffstring
    }
}
