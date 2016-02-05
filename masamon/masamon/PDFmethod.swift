//
//  PDFmethod.swift
//  masamon
//
//  Created by 岩見建汰 on 2016/01/08.
//  Copyright © 2016年 Kenta. All rights reserved.
//

import UIKit
import RealmSwift

class PDFmethod: UIViewController {
    
    let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate //AppDelegateのインスタンスを取得
    
    //PDF内にある年月とスタッフのシフトを全て抽出する
    func AllTextGet() -> Array<String>{
        
        var pdftextarray: [String] = []
        var lineIndex = 1
        
        let path: NSString
        //        path = NSBundle.mainBundle().pathForResource("sample4", ofType: "pdf")!
        path = DBmethod().FilePathTmpGet()
        
        let tet = TET()
        
        let document = tet.open_document(path as String, optlist: "")
        let page = tet.open_page(document, pagenumber: 1, optlist: "granularity=page")
        let pdftext = tet.get_text(page)
        
        tet.close_page(page)
        tet.close_document(document)
        
        //"平成"が出るまで1行ずつ読み飛ばしをする
        pdftext.enumerateLines{
            line, stop in
            
            let judgeheisei = line.substringToIndex(line.startIndex.successor().successor())
            
            if(judgeheisei == "平成"){
                pdftextarray.append(line)
                stop = true
            }
            
            lineIndex += 1
        }
        
        //"店長"が出るまで1行ずつ読み飛ばしをする
        var nowIndex = 1
        
        pdftext.enumerateLines{
            line, stop in
            
            if(nowIndex < lineIndex){      //平成を見つけた行まで進める
                nowIndex += 1
            }else{
                if((line.rangeOfString("店長")) != nil){
                    pdftextarray.append(line)
                    lineIndex = nowIndex
                    stop = true
                }else{
                    nowIndex += 1
                }
            }
        }
        
        //スタッフの行を読み取る
        nowIndex = 0
        var staffcount = 0
        
        pdftext.enumerateLines{
            line, stop in
            
            if(nowIndex < lineIndex){      //店長を見つけた行まで進める
                nowIndex += 1
            }else{
                let judgehtopcharacter = line.substringToIndex(line.startIndex.successor())
                
                if(Int(judgehtopcharacter) != nil){         //先頭文字が数値の場合のみ
                    pdftextarray.append(line)
                    staffcount += 1
                }
            }
        }
        
        return pdftextarray
    }
    
    //スタッフのシフトを日にちごとに分けたArrayを返す
    func SplitDayShiftGet(var staffarray: Array<String>) -> (shiftarray: Array<String>, shiftcours: (Int,Int,Int)){
        
        //データを削除して初期化する
        appDelegate.errorstaffnamepdf.removeAll()
        appDelegate.errorshiftnamepdf.removeAll()
        
        var dayshiftarray: [String] = []        //1日ごとのシフトを記録
        
        //1クールが全部で何日間あるかを判断するため
        let shiftyearandmonth = CommonMethod().JudgeYearAndMonth(staffarray[0])
        
        let shiftnsdate = MonthlySalaryShow().DateSerial(CommonMethod().Changecalendar(shiftyearandmonth.year, calender: "JP"), month: shiftyearandmonth.startcoursmonth, day: 1)
        let c = NSCalendar.currentCalendar()
        let monthrange = c.rangeOfUnit([NSCalendarUnit.Day],  inUnit: [NSCalendarUnit.Month], forDate: shiftnsdate)
        
        //先に空要素を1クール分追加しておく
        for(var i = 0; i < monthrange.length; i++){
            dayshiftarray.append("")
        }
        
        //スタッフの人数分(配列の最後まで)繰り返す
        //        for(var i = 1; i < 2; i++){
        for(var i = 1; i < staffarray.count; i++){
            
            var staffname = ""
            var staffarraytmp = ""
            
            var shiftlocationarray: [[Int]] = []
            for(var i = 0; i < 6; i++){
                shiftlocationarray.append([])
            }
            
            //            var earlyshiftlocationarray: [Int] = []
            //            var center1shiftlocationarray: [Int] = []
            //            var center2shiftlocationarray: [Int] = []
            //            var center3shiftlocationarray: [Int] = []
            //            var lateshiftlocationarray: [Int] = []
            //            var holidayshiftlocationarray: [Int] = []       //公,夏,有の場所を記録
            //            var othershiftlocationarray: [Int] = []
            
            staffarray[i] = staffarray[i].stringByReplacingOccurrencesOfString(" ", withString: "")
            staffarray[i] = staffarray[i].stringByReplacingOccurrencesOfString("　", withString: "")
            
            //スタッフ名の抽出
            staffname = self.GetStaffName(staffarray[i], i: i)
            staffarraytmp = staffarray[i]
            print(staffname)
            //スキップされたスタッフは取り込みを行わない
            if(appDelegate.skipstaff.contains(staffname)){
                break
            }
            
            
            /*抽出したスタッフ名(マネージャーのMは除く)が1文字以下or4文字以上ならエラーとして記録
            　エラーでなければシフトの出現場所を配列に格納していく
            */
            let removem = staffname.stringByReplacingOccurrencesOfString("M", withString: "")
            if(removem.characters.count <= 1 || removem.characters.count >= 4){
                appDelegate.errorstaffnamepdf.append(staffarraytmp)
            }else{
                //スタッフ名を正しく認識しているがエラーとして記録されている場合は削除する
                for(var i = 0; i < appDelegate.errorstaffnamepdf.count; i++){
                    let errorstaffnametext = appDelegate.errorstaffnamepdf[i]
                    
                    if(errorstaffnametext.containsString(staffname)){
                        appDelegate.errorstaffnamepdf.removeAtIndex(i)
                        break
                    }
                }
                
                let staffarraytmpnsstring = staffarraytmp as NSString
                
                
                //シフト体制の分だけループを回し、各ループでスタッフ1人分のシフト出現場所を記録する
                for(var i = 0; i < DBmethod().DBRecordCount(ShiftSystemDB); i++){
                    let shiftname = DBmethod().ShiftSystemNameGet(i)
                    shiftlocationarray[shiftname.groupid] += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                    
                    //                    switch(shiftname.groupid){
                    //                    case 0:
                    //                        earlyshiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                    //
                    //                    case 1:
                    //                        center1shiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                    //
                    //                    case 2:
                    //                        center2shiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                    //
                    //                    case 3:
                    //                        center3shiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                    //
                    //                    case 4:
                    //                        lateshiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                    //
                    //                    case 5:
                    //                        othershiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                    //
                    //                    case 6:
                    //                        holidayshiftlocationarray += self.GetShiftPositionArray(staffarraytmpnsstring, shiftname: shiftname.name)
                    //
                    //                    default:
                    //                        break
                    //                    }
                }
            }
            
            //重複した要素を削除する
            for(var i = 0; i < shiftlocationarray.count; i++){
                shiftlocationarray[i] = self.GetRemoveOverlapElementArray(shiftlocationarray[i])
            }
            //            earlyshiftlocationarray = GetRemoveOverlapElementArray(earlyshiftlocationarray)
            //            center1shiftlocationarray = GetRemoveOverlapElementArray(center1shiftlocationarray)
            //            center2shiftlocationarray = GetRemoveOverlapElementArray(center2shiftlocationarray)
            //            center3shiftlocationarray = GetRemoveOverlapElementArray(center3shiftlocationarray)
            //            lateshiftlocationarray = GetRemoveOverlapElementArray(lateshiftlocationarray)
            //            holidayshiftlocationarray = GetRemoveOverlapElementArray(holidayshiftlocationarray)
            //            othershiftlocationarray = GetRemoveOverlapElementArray(othershiftlocationarray)
            
            
            //配列をまたがって重複している要素を削除する
            for(var i = 0; i < shiftlocationarray.count; i++){
                let AAA = self.GetRemoveOverlapElementAnotherArray(shiftlocationarray)
                shiftlocationarray[i] = AAA[i]
            }
            
            
            
            //            let removeresultarray = self.GetRemoveOverlapElementAnotherArray(earlyshiftlocationarray, center1: center1shiftlocationarray, center2: center2shiftlocationarray, center3: center3shiftlocationarray, late: lateshiftlocationarray, other: othershiftlocationarray)
            //            earlyshiftlocationarray = removeresultarray.removedearly
            //            center1shiftlocationarray = removeresultarray.removedcenter1
            //            center2shiftlocationarray = removeresultarray.removedcenter2
            //            center3shiftlocationarray = removeresultarray.removedcenter3
            //            lateshiftlocationarray = removeresultarray.removedlate
            //            othershiftlocationarray = removeresultarray.removedother
            
            
            //要素を昇順でソートする
            for(var i = 0; i < shiftlocationarray.count; i++){
                shiftlocationarray[i] = shiftlocationarray[i].sort()
            }
//            earlyshiftlocationarray = earlyshiftlocationarray.sort()
//            center1shiftlocationarray = center1shiftlocationarray.sort()
//            center2shiftlocationarray = center2shiftlocationarray.sort()
//            center3shiftlocationarray = center3shiftlocationarray.sort()
//            lateshiftlocationarray = lateshiftlocationarray.sort()
//            holidayshiftlocationarray = holidayshiftlocationarray.sort()
//            othershiftlocationarray = othershiftlocationarray.sort()
            
            
            //スタッフ名にシフト名が含まれている場合に、カウントされてしまうため要素を削除する
            let includeshiftnamearray = CommonMethod().IncludeShiftNameInStaffName(staffname)
            if(includeshiftnamearray.count != 0){
                
                for(var i = 0; i < includeshiftnamearray.count; i++){
                    shiftlocationarray[includeshiftnamearray[i]].removeAtIndex(0)
                }
                
//                for(var i = 0; i < includeshiftnamearray.count; i++){
//                    switch(includeshiftnamearray[i]){
//                    case 0:
//                        earlyshiftlocationarray.removeAtIndex(0)
//                        
//                    case 1:
//                        center1shiftlocationarray.removeAtIndex(0)
//                        
//                    case 2:
//                        center2shiftlocationarray.removeAtIndex(0)
//                        
//                    case 3:
//                        center3shiftlocationarray.removeAtIndex(0)
//                        
//                    case 4:
//                        lateshiftlocationarray.removeAtIndex(0)
//                        
//                    case 5:
//                        othershiftlocationarray.removeAtIndex(0)
//                        
//                    default: //case 999
//                        holidayshiftlocationarray.removeAtIndex(0)
//                    }
//                }
            }
            
            
            //1クール分のシフト文字以外のシフト名をカウントしてしまうので、範囲外の要素を削除する
            var index = staffarraytmp.startIndex
            var numeralcount = 0
            var removeflag = false
            
            while(index != staffarraytmp.endIndex.predecessor()){
                
                if(Int(String(staffarraytmp[index])) != nil){
                    numeralcount++
                }else{
                    numeralcount = 0
                }
                
                //数値の連続が5回以上なら数列として判断する
                if(numeralcount >= 5){
                    index = index.advancedBy(-4)
                    removeflag = true
                    break
                }
                
                index = index.successor()
            }
            
            
            if(removeflag){
                for(var i = 0; i < shiftlocationarray.count; i++){
                    shiftlocationarray[i] = self.RemoveElementThanPivotIndex(shiftlocationarray[i], pivotindex: index, text: staffarraytmp)
                }
//                earlyshiftlocationarray = self.RemoveElementThanPivotIndex(earlyshiftlocationarray, pivotindex: index, text: staffarraytmp)
//                center1shiftlocationarray = self.RemoveElementThanPivotIndex(center1shiftlocationarray, pivotindex: index, text: staffarraytmp)
//                center2shiftlocationarray = self.RemoveElementThanPivotIndex(center2shiftlocationarray, pivotindex: index, text: staffarraytmp)
//                center3shiftlocationarray = self.RemoveElementThanPivotIndex(center3shiftlocationarray, pivotindex: index, text: staffarraytmp)
//                lateshiftlocationarray = self.RemoveElementThanPivotIndex(lateshiftlocationarray, pivotindex: index, text: staffarraytmp)
//                othershiftlocationarray = self.RemoveElementThanPivotIndex(othershiftlocationarray, pivotindex: index, text: staffarraytmp)
//                holidayshiftlocationarray = self.RemoveElementThanPivotIndex(holidayshiftlocationarray, pivotindex: index, text: staffarraytmp)
            }
            
            
            //要素数を比較して正しくシフト体制を認識できているかチェックする
            var count = 0
            for(var i = 0; i < shiftlocationarray.count; i++){
                count += shiftlocationarray[i].count
            }
            
//            count = earlyshiftlocationarray.count + center1shiftlocationarray.count + center2shiftlocationarray.count + center3shiftlocationarray.count + lateshiftlocationarray.count + holidayshiftlocationarray.count + othershiftlocationarray.count
            
            //            print(earlyshiftlocationarray.count)
            //            print(center1shiftlocationarray.count)
            //            print(center2shiftlocationarray.count)
            //            print(center3shiftlocationarray.count)
            //            print(lateshiftlocationarray.count)
            //            print(othershiftlocationarray.count)
            //            print(holidayshiftlocationarray.count)
            
            if(count == monthrange.length){
                
                //正しく取り込めているが、シフト認識エラーとして記録されて残っている要素があれば削除する
                if let _ = appDelegate.errorshiftnamepdf[staffname] {
                    appDelegate.errorshiftnamepdf.removeValueForKey(staffname)
                }
                
                
                //各配列に識別子を追加する
                for(var i = 0; i < shiftlocationarray.count; i++){
                    shiftlocationarray[i].append(99999)
                }
//                earlyshiftlocationarray.append(99999)
//                center1shiftlocationarray.append(99999)
//                center2shiftlocationarray.append(99999)
//                center3shiftlocationarray.append(99999)
//                lateshiftlocationarray.append(99999)
//                holidayshiftlocationarray.append(99999)
//                othershiftlocationarray.append(99999)
                
                
                //日付分のループを開始
                for(var i = 0; i < monthrange.length; i++){
                    
                    //シフトの位置が一番小さい値とそのシフト区分を取得する
                    let dayshift = self.GetMinShiftPositionAndGroup(earlyshiftlocationarray[0], center1: center1shiftlocationarray[0], center2: center2shiftlocationarray[0], center3: center3shiftlocationarray[0], late: lateshiftlocationarray[0], holiday: holidayshiftlocationarray[0], other: othershiftlocationarray[0])
                    
                    //シフトの名前をテキストから取得する
                    let staffshift = self.GetShiftNameFromOneLineText(staffarraytmp, sg: dayshift.shiftgroup, sp: dayshift.shiftposition)
                    
                    switch(dayshift.shiftgroup){
                    case "早":
                        earlyshiftlocationarray.removeAtIndex(0)
                        
                    case "中1":
                        center1shiftlocationarray.removeAtIndex(0)
                        
                    case "中2":
                        center2shiftlocationarray.removeAtIndex(0)
                        
                    case "中3":
                        center3shiftlocationarray.removeAtIndex(0)
                        
                    case "遅":
                        lateshiftlocationarray.removeAtIndex(0)
                        
                    case "休":
                        holidayshiftlocationarray.removeAtIndex(0)
                        
                    case "他":
                        othershiftlocationarray.removeAtIndex(0)
                        
                    default:
                        break
                    }
                    
                    let holidayarray = DBmethod().ShiftSystemNameArrayGetByGroudid(6)
                    if(holidayarray.contains(staffshift) == false){
                        dayshiftarray[i] += staffname + ":" + staffshift + ","
                    }
                    
                }
                //認識できないシフト名があった場合
            }else{
                
                let successshiftnamearray = self.GetWillRemoveShiftName(earlyshiftlocationarray.count, center1: center1shiftlocationarray.count, center2: center2shiftlocationarray.count, center3: center3shiftlocationarray.count, late: lateshiftlocationarray.count, holiday: holidayshiftlocationarray.count, other: othershiftlocationarray.count)
                
                var messagetext = staffarraytmp
                
                for(var i = 0; i < successshiftnamearray.count; i++){
                    messagetext = self.GetRemoveSetShiftName(messagetext, shiftname: successshiftnamearray[i])
                }
                
                appDelegate.errorshiftnamepdf[staffname] = messagetext
            }
        }
        
        //        let file_name = "TEST.txt"
        //        let text = dayshiftarray[0]
        //
        //        if let dir : NSString = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true ).first {
        //
        //            let path_file_name = dir.stringByAppendingPathComponent(file_name)
        //
        //            do {
        //
        //                try text.writeToFile(path_file_name, atomically: false, encoding: NSUTF8StringEncoding )
        //
        //            } catch {
        //                //エラー処理
        //            }
        //        }
        
        return (dayshiftarray,shiftyearandmonth)
    }
    
    
    /*スタッフ1人分のテキストを受け取ってスタッフ名のみを返す関数
    stafftext => スタッフ名とシフトが記述されているテキスト
    i         => ループの回数(stafftextの先頭についている数値)
    */
    func GetStaffName(stafftext: String, i: Int) -> String{
        
        //もし、データベースに登録しているスタッフ名があった場合はそれを返す
        if(DBmethod().StaffNameArrayGet() != nil){
            let staffnamearray = DBmethod().StaffNameArrayGet()
            for(var i = 0; i < staffnamearray!.count; i++){
                if(stafftext.containsString(staffnamearray![i])){
                    return staffnamearray![i]
                }
            }
        }
        
        
        var staffname = ""
        var position = 0
        let holidaynamearray: [String] = DBmethod().ShiftSystemNameArrayGetByGroudid(6)
        var holidaynametopcharacter: [String] = []
        let shiftsystemnamearray: [String] = DBmethod().ShiftSystemNameArrayGet()
        var shiftsystemnametopcharacter: [String] = []
        
        //勤務シフト名の先頭文字だけを取り出すループ処理
        for(var i = 0; i < shiftsystemnamearray.count; i++){
            let startindex = shiftsystemnamearray[i].startIndex
            let shiftsystemnametmp = shiftsystemnamearray[i]
            let topcharactertmp = shiftsystemnametmp[startindex]
            
            shiftsystemnametopcharacter.append(String(topcharactertmp))
        }
        
        //休暇のシフト名の先頭文字だけを取り出すループ処理
        for(var i = 0; i < holidaynamearray.count; i++){
            let startindex = holidaynamearray[i].startIndex
            let holidaynametmp = holidaynamearray[i]
            let topcharactertmp = holidaynametmp[startindex]
            
            holidaynametopcharacter.append(String(topcharactertmp))
        }
        
        //スタッフ名の読み込みを開始する場所を決定
        if(i <= 9){
            position = 1
        }else{
            position = 2
        }
        
        //スタッフ名の抽出(シフト体制に含まれる文字が出るまで)
        var getcharacterstaffname = stafftext[stafftext.startIndex.advancedBy(position)]
        
        while(DBmethod().SearchShiftSystem(String(getcharacterstaffname)) == nil){
            let ABC = stafftext.startIndex.advancedBy(position)
            
            if(ABC == stafftext.endIndex.predecessor()){
                break
            }
            
            //勤務シフト体制にある文字が検出されたらループを抜けるパターン
            for(var i = 0; i < shiftsystemnametopcharacter.count; i++){
                if(String(getcharacterstaffname).containsString(shiftsystemnametopcharacter[i])){
                    return staffname
                }
            }
            
            //休暇シフト体制にある文字が検出されたらループを抜けるパターン
            for(var i = 0; i < holidaynametopcharacter.count; i++){
                if(String(getcharacterstaffname).containsString(holidaynametopcharacter[i])){
                    return staffname
                }
            }
            
            staffname = staffname + String(getcharacterstaffname)
            position += 1
            getcharacterstaffname = stafftext[stafftext.startIndex.advancedBy(position)]
        }
        
        return staffname
    }
    
    //受け取ったシフト体制の場所を配列にして返す関数
    func GetShiftPositionArray(staffarraysstring: NSString, shiftname: String) -> Array<Int>{
        var shiftnamelocation: [Int] = []
        var searchrange = NSMakeRange(0, staffarraysstring.length)
        var searchresult = staffarraysstring.rangeOfString(shiftname, options: NSStringCompareOptions.CaseInsensitiveSearch, range: searchrange)
        
        while(searchresult.location != NSNotFound){
            if(searchresult.location != NSNotFound){
                
                shiftnamelocation.append(searchresult.location)
                
                searchrange = NSMakeRange(searchresult.location + searchresult.length, staffarraysstring.length-(searchresult.location + searchresult.length))
                
                searchresult = staffarraysstring.rangeOfString(shiftname, options: NSStringCompareOptions.CaseInsensitiveSearch, range: searchrange)
            }
            searchrange = NSMakeRange(0, staffarraysstring.length)
        }
        
        return shiftnamelocation
    }
    
    //TODO: 文字数が多い順に動作をしていくようにすれば、Mとかカを手動で消す必要がなくなる？
    //指定したシフト体制を削除した文字列を返す関数
    func GetRemoveSetShiftName(staffarraysstring: NSString, shiftname: String) -> String{
        var removedshiftstring = ""
        
        removedshiftstring = staffarraysstring.stringByReplacingOccurrencesOfString(shiftname, withString: "")
        removedshiftstring = removedshiftstring.stringByReplacingOccurrencesOfString("M", withString: "")
        removedshiftstring = removedshiftstring.stringByReplacingOccurrencesOfString("カ", withString: "")
        
        return removedshiftstring
    }
    
    //受け取った数値の中で一番小さい値とシフト区分を返す関数
    func GetMinShiftPositionAndGroup(early: Int, center1: Int, center2: Int, center3: Int, late: Int, holiday: Int, other: Int) -> (shiftgroup: String, shiftposition: Int){
        var sg = ""
        var sp = 0
        
        let dict: [String:Int] = ["早":early, "中1":center1, "中2":center2, "中3":center3, "遅": late, "休":holiday, "他":other]
        
        var values : Array = Array(dict.values)
        values = values.sort()
        
        for (key, value) in dict {
            
            if(values[0] == value){
                sg = key
                sp = value
                break
            }
        }
        
        return (sg, sp)
    }
    
    //受け取ったスタッフ1行分のテキストと位置情報からシフト名を取り出す関数
    func GetShiftNameFromOneLineText(text: String, sg: String, var sp: Int) -> String{
        
        var result = ""
        var shiftnamearray: [String] = []
        var character = text[text.startIndex.advancedBy(sp)]
        
        //シフト区分によって比較対象にする配列の内容を変える処理
        switch(sg){
        case "早":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(0)
            for(var i = 0; i < dbarray.count; i++){
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "中1":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(1)
            for(var i = 0; i < dbarray.count; i++){
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "中2":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(2)
            for(var i = 0; i < dbarray.count; i++){
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "中3":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(3)
            for(var i = 0; i < dbarray.count; i++){
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "遅":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(4)
            for(var i = 0; i < dbarray.count; i++){
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "他":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(5)
            for(var i = 0; i < dbarray.count; i++){
                shiftnamearray.append(dbarray[i].name)
            }
            
        case "休":
            let dbarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(6)
            for(var i = 0; i < dbarray.count; i++){
                shiftnamearray.append(dbarray[i].name)
            }
            
        default:
            break
        }
        
        for(var i = 0; i < shiftnamearray.count; i++){
            
            let tmp = shiftnamearray[i]
            var dbindex = tmp.startIndex
            
            while(dbindex != shiftnamearray[i].endIndex){
                
                if(tmp[dbindex] == character){
                    result += String(tmp[dbindex])
                    dbindex = dbindex.successor()
                    sp++
                    character = text[text.startIndex.advancedBy(sp)]
                }else{
                    result = ""
                    break
                }
            }
            
            if(result.characters.count == tmp.characters.count){
                return result
            }
        }
        
        return result
    }
    
    //受け取った配列の重複要素を削除した配列を返す
    func GetRemoveOverlapElementArray(array: Array<Int>) -> Array<Int>{
        let set = NSOrderedSet(array: array)
        let result = set.array as! [Int]
        
        return result
    }
    
    //各配列の要素数を受け取り、要素数が1以上のシフトグループのシフト文字を配列にして返す
    func GetWillRemoveShiftName(early: Int, center1: Int, center2: Int, center3: Int, late: Int, holiday: Int, other: Int) -> Array<String>{
        var array: [String] = []
        
        if(early != 0){
            let earlyshiftarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(0)
            for(var i = 0; i < earlyshiftarray.count; i++){
                array.append(earlyshiftarray[i].name)
            }
        }
        
        if(center1 != 0){
            let center1shiftarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(1)
            for(var i = 0; i < center1shiftarray.count; i++){
                array.append(center1shiftarray[i].name)
            }
        }
        
        if(center2 != 0){
            let center2shiftarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(2)
            for(var i = 0; i < center2shiftarray.count; i++){
                array.append(center2shiftarray[i].name)
            }
        }
        
        if(center3 != 0){
            let center3shiftarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(3)
            for(var i = 0; i < center3shiftarray.count; i++){
                array.append(center3shiftarray[i].name)
            }
        }
        
        if(late != 0){
            let lateshiftarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(4)
            for(var i = 0; i < lateshiftarray.count; i++){
                array.append(lateshiftarray[i].name)
            }
        }
        
        
        //その他を示す文字を追加
        if(other != 0){
            let othershiftarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(5)
            for(var i = 0; i < othershiftarray.count; i++){
                array.append(othershiftarray[i].name)
            }
        }
        
        //休暇を示す文字を追加
        if(holiday != 0){
            let holidayshiftarray = DBmethod().ShiftSystemRecordArrayGetByGroudid(6)
            for(var i = 0; i < holidayshiftarray.count; i++){
                array.append(holidayshiftarray[i].name)
            }
        }
        
        return array
    }
    
    
    //配列をまたがって重複している要素を削除する関数
    func GetRemoveOverlapElementAnotherArray(array: [[Int]]) -> ([Array<Int>]){
        
        var dict: [Int:Array<Int>] = [0:array[0], 1:array[1], 2:array[2], 3:array[3], 4: array[4], 5:array[5]]
        
        let shiftsystemarray = DBmethod().ShiftSystemAllRecordGet()
        
        for(var i = 0; i < DBmethod().DBRecordCount(ShiftSystemDB); i++){
            
            let Record = DBmethod().ShiftSystemNameGet(i)
            
            for(var j = 0; j < shiftsystemarray.count; j++){
                
                if(shiftsystemarray[j].groupid != Record.groupid){
                    if(shiftsystemarray[j].name.characters.count > Record.name.characters.count){
                        if(shiftsystemarray[j].name.containsString(Record.name)){
                            let result = self.RemoveIntersectArrayToArray(dict[Record.groupid]!, comparisonarray: dict[shiftsystemarray[j].groupid]!)
                            dict.updateValue(result, forKey: Record.groupid)
                        }
                    }else{
                        if(Record.name.containsString(shiftsystemarray[j].name)){
                            let result = self.RemoveIntersectArrayToArray(dict[shiftsystemarray[j].groupid]!, comparisonarray: dict[Record.groupid]!)
                            dict.updateValue(result, forKey: shiftsystemarray[j].groupid)
                        }
                    }
                }
            }
        }
        
        var results: [Array<Int>] = []
        for(var i = 0; i < array.count; i++){
            results.append(dict[i]!)
        }
        
        return results
    }
    
    
    /*受け取った配列同士の重複を調べて処理後の配列を返す関数
    removedarray    => 文字数が少なく、要素が削除される側の配列
    comparisonarray => 文字数が多く、要素の削除のための比較用になる配列
    */
    func RemoveIntersectArrayToArray(var removedarray: Array<Int>, comparisonarray: Array<Int>) -> Array<Int>{
        
        let setarray = Set(removedarray).intersect(comparisonarray)
        
        for(var i = 0; i < setarray.count; i++){
            removedarray.removeObject(setarray[setarray.startIndex.advancedBy(i)])
        }
        
        return removedarray
    }
    
    //受け取ったpivotindexよりも大きいindexの要素は削除する関数
    func RemoveElementThanPivotIndex(var array: Array<Int>, pivotindex: String.CharacterView.Index, text: String) -> Array<Int>{
        
        let index = text.startIndex
        var removeelement: [Int] = []
        
        for(var i = 0; i < array.count; i++){
            if(index.advancedBy(array[i]) >= pivotindex){
                removeelement.append(array[i])
            }
        }
        
        for(var i = 0; i < removeelement.count; i++){
            array.removeObject(removeelement[i])
        }
        
        return array
    }
    
    //データベースへ記録する関数
    func RegistDataBase(shiftarray: Array<String>, shiftcours: (y: Int,sm: Int,em: Int), importname: String, importpath: String, update: Bool){
        
        var date = 11
        var flag = 0
        var shiftdetailarray = List<ShiftDetailDB>()
        
        let shiftnsdate = MonthlySalaryShow().DateSerial(CommonMethod().Changecalendar(shiftcours.y, calender: "JP"), month: shiftcours.sm, day: 1)
        let c = NSCalendar.currentCalendar()
        let monthrange = c.rangeOfUnit([NSCalendarUnit.Day],  inUnit: [NSCalendarUnit.Month], forDate: shiftnsdate)
        
        var shiftdetaildbrecordcount = DBmethod().DBRecordCount(ShiftDetailDB)
        
        if(appDelegate.errorshiftnamepdf.count == 0){
            
            for(var i = 0; i < shiftarray.count; i++){
                let shiftdbrecord = ShiftDB()
                let shiftdetaildbrecord = ShiftDetailDB()
                
                if(update){
                    let existshiftdb = DBmethod().SearchShiftDB(importname)
                    
                    shiftdbrecord.id = existshiftdb.id        //取り込みが上書きの場合は使われているidをそのまま使う
                    shiftdbrecord.year = existshiftdb.year
                    shiftdbrecord.month = existshiftdb.month
                    
                    shiftdetaildbrecord.id = existshiftdb.shiftdetail[i].id
                    shiftdetaildbrecord.day = existshiftdb.shiftdetail[i].day
                    
                    //開始月が12月の場合は昨年の12月で記録されるようにする
                    if(shiftcours.sm == 12 && flag == 0){
                        shiftdetaildbrecord.year = shiftcours.y - 1
                    }else{
                        shiftdetaildbrecord.year = shiftcours.y
                    }
                    
                    switch(flag){
                    case 0:         //11日〜30(31)日までの場合
                        shiftdetaildbrecord.month = shiftcours.sm
                        date++
                        
                        if(date > monthrange.length){
                            date = 1
                            flag = 1
                        }
                        
                    case 1:         //1日〜10日までの場合
                        shiftdetaildbrecord.month = shiftcours.em
                        date++
                        
                    default:
                        break
                    }
                    
                    
                    shiftdetaildbrecord.staff = shiftarray[i]
                    shiftdetaildbrecord.shiftDBrelationship = DBmethod().SearchShiftDB(importname)
                    
                    //エラーがない時のみ記録を行う
                    if(appDelegate.errorshiftnamepdf.count == 0){
                        print(String(shiftdetaildbrecord.year) + "  " + String(shiftdetaildbrecord.month))
                        
                        DBmethod().AddandUpdate(shiftdetaildbrecord, update: true)
                    }
                    
                }else{
                    
                    shiftdbrecord.id = DBmethod().DBRecordCount(ShiftDetailDB)/monthrange.length
                    
                    shiftdbrecord.year = 0
                    shiftdbrecord.month = 0
                    shiftdbrecord.shiftimportname = importname
                    shiftdbrecord.shiftimportpath = importpath
                    shiftdbrecord.salaly = 0
                    
                    shiftdetaildbrecord.id = shiftdetaildbrecordcount
                    shiftdetaildbrecordcount++
                    
                    //開始月が12月の場合は昨年の12月で記録されるようにする
                    if(shiftcours.sm == 12 && flag == 0){
                        shiftdetaildbrecord.year = shiftcours.y - 1
                    }else{
                        shiftdetaildbrecord.year = shiftcours.y
                    }
                    
                    shiftdetaildbrecord.day = date
                    
                    switch(flag){
                    case 0:         //11日〜30(31)日までの場合
                        shiftdetaildbrecord.month = shiftcours.sm
                        date++
                        
                        if(date > monthrange.length){
                            date = 1
                            flag = 1
                        }
                        
                    case 1:         //1日〜10日までの場合
                        shiftdetaildbrecord.month = shiftcours.em
                        date++
                        
                    default:
                        break
                    }
                    
                    shiftdetaildbrecord.staff = shiftarray[i]
                    shiftdetaildbrecord.shiftDBrelationship = shiftdbrecord
                    
                    //すでに記録してあるListを取得して後ろに現在の記録を追加する
                    for(var i = 0; i < shiftdetailarray.count; i++){
                        shiftdbrecord.shiftdetail.append(shiftdetailarray[i])
                    }
                    shiftdbrecord.shiftdetail.append(shiftdetaildbrecord)
                    
                    let ID = shiftdbrecord.id
                    
                    //エラーがない場合のみ記録を行う
                    if(appDelegate.errorstaffnamepdf.count == 0 && appDelegate.errorshiftnamepdf.count == 0){
                        DBmethod().AddandUpdate(shiftdbrecord, update: true)
                        DBmethod().AddandUpdate(shiftdetaildbrecord, update: true)
                        shiftdetailarray = CommonMethod().ShiftDBRelationArrayGet(ID)
                    }
                }
                
            }
        }
    }
    
    //入力したユーザ名の月給を計算して結果を記録する
    func UserMonthlySalaryRegist(shiftarray: Array<String>, shiftcours: (y: Int,sm: Int,em: Int), importname: String){
        var usershift:[String] = []
        
        let username = DBmethod().UserNameGet()
        let holiday = DBmethod().ShiftSystemNameArrayGetByGroudid(6)      //休暇のシフト体制を取得
        
        //1クール分行う
        for(var i = 0; i < shiftarray.count; i++){
            
            var dayshift = ""
            
            let nsstring = shiftarray[i] as NSString
            
            if(nsstring.containsString(username)){
                let userlocation = nsstring.rangeOfString(username).location
                
                var index = shiftarray[i].startIndex.advancedBy(userlocation + username.characters.count + 1)
                
                while(String(shiftarray[i][index]) != ","){
                    dayshift += String(shiftarray[i][index])
                    index = index.successor()
                }
                
                if(holiday.contains(dayshift) == false){      //holiday以外なら
                    usershift.append(dayshift)
                }
            }
        }
        
        //月給の計算をする
        var monthlysalary = 0.0
        let houlypayrecord = DBmethod().HourlyPayRecordGet()
        
        for(var i = 0; i < usershift.count; i++){
            
            let shiftsystem = DBmethod().SearchShiftSystem(usershift[i])
            if(shiftsystem![0].endtime <= houlypayrecord[0].timeto){
                monthlysalary = monthlysalary + (shiftsystem![0].endtime - shiftsystem![0].starttime - 1) * Double(houlypayrecord[0].pay)
            }else{
                //22時以降の給与を先に計算
                let latertime = shiftsystem![0].endtime - houlypayrecord[0].timeto
                monthlysalary = monthlysalary + latertime * Double(houlypayrecord[1].pay)
                
                monthlysalary = monthlysalary + (shiftsystem![0].endtime - latertime - shiftsystem![0].starttime - 1) * Double(houlypayrecord[0].pay)
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
        newshiftdbsalalyadd.year = shiftcours.y
        newshiftdbsalalyadd.month = shiftcours.em
        
        DBmethod().AddandUpdate(newshiftdbsalalyadd, update: true)
    }
    
}

