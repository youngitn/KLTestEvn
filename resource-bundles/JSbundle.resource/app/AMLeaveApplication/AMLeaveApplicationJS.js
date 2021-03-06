 const j$ = jQuery.noConflict();
 var openLookupPage = null;
 j$(function() {
     j$("select[id*=Approval_Status]").bind("change", function() {
         j$(this).val('D');
     });
     j$('#baseInfo input,#baseInfo select,.readOnly').attr({
         'readOnly': 'true',
         'onfocus': ''
     });
     //到職日存檔後會自動給值 這邊只需要抓值 轉換 即可
     let Take_Office_Date = j$('span[id $= Take_Office_Date]').children();
     if (Take_Office_Date.html().trim() != '') {
         let d = new Date(Take_Office_Date.html().trim());
         let mm = d.getMonth();
         if (mm == 12) {
             mm = 0;
         }
         j$('#Take_Office_Date_box').val(mm + 1 + '/' + d.getDate());
         Take_Office_Date.hide();
     }
     addButtonClass();
     ////////////////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////////////////
     ////////////////註冊 請假人員選擇的彈跳視窗事件  ///////////////////////
     ///////////////點擊請假人input open選擇視窗/////////////////////////////
     ////////////////////////////////////////////////////////////////////////
     // j$("input[id $= Employee]").on('click', function() {
     //     if (openLookupPage != null) {
     //         openLookupPage.close();
     //     }
     //     openLookupPage = window.open('/_ui/common/data/LookupPage?lkfm=j_id0:j_id13:form&lknm=j_id0:j_id13:form:Employee&lktp=' + getElementByIdCS('j_id0:j_id13:form:Employee_lktp').value + '&lksrch=' + escapeUTF(getElementByIdCS('j_id0:j_id3:form:Employee').value.substring(0, 80)), "_blank", "toolbar=yes,scrollbars=yes,resizable=yes,top=500,left=500,width=400,height=400");
     // });
     j$("input[id $= Employee]").on('click', function(event) {
         let a = j$("a[id $= Employee_lkwgt]");
         if (a.css('display') != 'none') {
             a.find('img').trigger('click');
         }
     });
     j$("input[id $= Agent]").on("click", function() {
         let a = j$("a[id $= Agent_lkwgt]");
         if (a.css('display') != 'none') {
             a.find('img').trigger('click');
         }
     });
     //當請假人input VALUE改變時 關閉人員選擇視窗  
     j$("input[id $= Employee]").on('change', function() {
         if (openLookupPage != null) {
             openLookupPage.close();
         }
         setTimeout(getEmpInfo, 500);
     });
     j$("input[id $= Agent]").on('change', function() {
         setTimeout(queryAgentExt, 500);
     });
     ////////////////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////////////////
 });

 function queryAgentExt() {
     let cId = j$("input[id $= Agent_lkid]").val();
     if (cId != '000000000000000' && cId != null && cId != '') {
         AMLeaveApplicationExtension.queryEmpId(cId, function(result, event) {
             if (event.status && result != null) {
                 JSON.parse(result.replace(/(&quot\;)/g, "\""), function(k, v) {
                     console.log(k + ',' + v);
                     if (k == 'Phone') {
                         if (v == null) {
                             alert('查詢不到代理人分機,請手動輸入!');
                             j$('input[id $= AgentExt]').val(null);
                         } else j$('input[id $= AgentExt]').val(v);
                     }
                 });
             }
         })
     }
 }
 //取得請假人資料 進入點
 function getEmpInfo() {
     let cId = j$("input[id $= Employee_lkid]").val();
     if (cId != '000000000000000' && cId != null && cId != '') {
         j$('form[id$=form]').block({
             message: '從SAP讀取資料中...'
         });
         queryVacation(cId);
         queryEmpId(cId);
         queryVacationTW(cId);
     }
 }
 //從controller取請假人的聯絡資料
 function queryEmpId(cId) {
     AMLeaveApplicationExtension.queryEmpId(cId, function(result, event) {
         if (event.status && result != null) {
             JSON.parse(result.replace(/(&quot\;)/g, "\""), function(k, v) {
                 console.log(k + ',' + v);
                 //到職日不須給值 單純顯示在sapn中即可
                 //實際上只要有儲存動作 這個欄位會套公式自己取得值 
                 if (k == 'Take_Office_Date') {
                     //因應個資法,到職日需隱藏年分
                     let vv = v != null ? v.trim() : v;
                     if (vv != null) {
                         let d = new Date(v);
                         j$('#Take_Office_Date_box').val((d.getMonth()) + 1 + '/' + d.getDate());
                     }
                     //j$('#Take_Office_Date_box').val();
                 }
                 if (k == 'Job_Title_Level') {
                     j$('input[id $= Job_Title_Level]').val(v != null ? v.trim() : v);
                 }
                 if (k == 'Applicant_position') {
                     j$('input[id $= Applicant_position]').val(v != null ? v.trim() : v);
                 }
             });
             // let empId = result;
             // j$('input[id $= Employee_Code]').val(empId);
             j$('form[id$=form]').unblock();
         }
     });
 }
 //將所有按鈕class風格統一   
 function addButtonClass() {
     j$("input[id$=btnDel],input[id$=btnAdd]").removeAttr('class').addClass("pure-button pure-button-primary pure-u-1-1");
 }

 //從SAP取請假資料
 function queryVacation(cId) {
     //let empId = j$('input[id $= Name]').val();
     //alert(empId);
     AMLeaveApplicationExtension.queryVacation(cId, function(result, event) {
         if (event.status && result != null) {
             JSON.parse(result.replace(/(&quot\;)/g, "\""), function(k, v) {
                 console.log(k + ',' + v);
                 //調休可用時數 
                 if (k == 'adjustable_vacation__c') {
                     j$('input[id $= Adjustable_vacation]').val(v != null ? v.trim() : v);
                 }
                 //目前特休可用時數
                 if (k == 'annual_leave__c') {
                     j$('input[id $= Annual_leave]').val(v != null ? v.trim() : v);
                 }
                 if (k == 'employee_code__c') {
                     j$('input[id $= Employee_Code]').val(v != null ? v.trim() : v);
                 }
                 //下年度特休可用時數
                 if (k == 'annual_leave1__c') {
                     //alert(v);
                     j$('input[id $= Annual_leave_Reset]').val(v != null ? v.trim() : v);
                 }
             });
         }
     });
 }
 //從SAP取請假狀態
 let queryTable_SAP;

 function queryVacationTW(cId) {
     //let empId = j$('input[id $= Name]').val();
     //alert(empId);
     j$('#queryTable_SAP_title').show();
     AMLeaveApplicationExtension.queryVacationTW(cId, function(result, event) {
         if (event.status && result != null) {
             //console.log(JSON.parse(j$.parseHTML(result)[0].data).content);
             if (j$.fn.dataTable.isDataTable('#queryTable_SAP')) {
                 queryTable_SAP.destroy();
             }
             queryTable_SAP = j$('#queryTable_SAP').DataTable({
                 responsive: true,
                 "language": languageConf,
                 "data": JSON.parse(j$.parseHTML(result)[0].data).content,
                 "columns": [{
                     "data": "main.typesofleave__c",
                     "defaultContent": "<i>空</i>"
                 }, {
                     "data": "main.start_date__c",
                     "defaultContent": "<i>空</i>"
                 }, {
                     "data": "main.start_time__c",
                     "defaultContent": "<i>空</i>"
                 }, {
                     "data": "main.end_date__c",
                     "defaultContent": "<i>空</i>"
                 }, {
                     "data": "main.end_time__c",
                     "defaultContent": "<i>空</i>"
                 }, {
                     "data": "main.hours__c",
                     "defaultContent": "<i>空</i>"
                 }],
                 "columnDefs": [{
                     "title": "假別",
                     "targets": 0
                 }, {
                     "title": "開始日期",
                     "targets": 1
                 }, {
                     "title": "開始時間",
                     "targets": 2,
                     "render": function(data, type, row, meta) {
                         if (data != null) return ("" + data).substring(0, 4) + "";
                         else return "空";
                     }
                 }, {
                     "title": "結束日期",
                     "targets": 3
                 }, {
                     "title": "結束時間",
                     "targets": 4,
                     "render": function(data, type, row, meta) {
                         if (data != null) return ("" + data).substring(0, 4) + "";
                         else return "空";
                     }
                 }, {
                     "title": "時數",
                     "targets": 5
                 }]
             });
         }
     });
 }

 function checkDay(self, type) {
     // let IsLeave3Days = j$('input[id$=IsLeave3Days]');
     // let mydate = new Date(self.val());
     // if (mydate.getDay() == 1) {
     //     alert('這個日期為禮拜一,如果請假天數含例假日超過三天,請確認是否勾選"連續休假天數是否三天以上(含例假/國定假日)"');
     // } else if (mydate.getDay() == 5) {
     //     alert('這個日期為禮拜五,如果請假天數含例假日超過三天,請確認是否勾選"連續休假天數是否三天以上(含例假/國定假日)"');
     // }
     // if (type == 'end') {
     //     let td = self.parents("td");
     //     let tr = j$(td.parents("tr").get(0));
     //     let sdate = new Date(tr.find('input[id$=Start_date]').val());
     //     let timeDiff = mydate.getTime() - sdate.getTime();
     //     let diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
     //     // alert(IsLeave3Days.attr('checked'));
     //     if ((diffDays + 1) >= 3 && !IsLeave3Days.prop("checked")) {
     //         alert('系統偵測到您的請假天數已達連續三日,請確認是否勾選"連續休假天數是否三天以上(含例假/國定假日)",以利正確審批.');
     //         //j$('input[id$=IsLeave3Days]').prop( "checked", true );
     //     } else if (timeDiff < 0) {
     //         alert('結束日期不得小於開始日期!');
     //     }
     //     console.log(timeDiff);
     // }
     // if (type == 'start') {
     //     let td = self.parents("td");
     //     let tr = j$(td.parents("tr").get(0));
     //     let edate = new Date(tr.find('input[id$=End_date]').val());
     //     let timeDiff = edate.getTime() - mydate.getTime();
     //     let diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
     //     // alert(IsLeave3Days.attr('checked'));
     //     if ((diffDays + 1) >= 3 && !IsLeave3Days.prop("checked")) {
     //         alert('系統偵測到您的請假天數已達連續三日,請確認是否勾選"連續休假天數是否三天以上(含例假/國定假日)",以利正確審批.');
     //         //j$('input[id$=IsLeave3Days]').prop( "checked", true );
     //     } else if (timeDiff < 0) {
     //         alert('結束日期不得小於開始日期!');
     //     }
     //     console.log(timeDiff);
     // }
 }
 

 