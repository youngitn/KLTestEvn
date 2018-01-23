 const j$ = jQuery.noConflict();
 var openLookupPage = null;
 
 j$(function() {
    j$('.dateFormat').hide();
    //先讓請假單一張單子只能填一種假別
     j$("input[id*=btnAdd]").hide();
     j$("input[id*=btnDel]").hide();
     j$("select[id*=Approval_Status]").bind("change", function() {
         j$(this).val('D');
     });
     j$('#baseInfo input,#baseInfo select,.readOnly').attr({
         'readOnly': 'true',
         'onfocus': ''
     });
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
     //當請假人input VALUE改變時 關閉人員選擇視窗	
     j$("input[id $= Employee]").on('change', function() {
          if (openLookupPage != null) {
             openLookupPage.close();
         }

         setTimeout(getEmpInfo, 500);
     });
     ////////////////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////////////////
     ////////////////////////////////////////////////////////////////////////
 });
 //取得請假人資料 進入點
 function getEmpInfo() {
     let cId = j$("input[id $= Employee_lkid]").val();
     if (cId != '000000000000000' && cId != null && cId != '') {
         j$('form[id$=form]').block({
             message: '從SAP讀取資料中...'
         });
         queryVacation(cId);
         queryEmpId(cId);
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
                     j$('span[id $= Take_Office_Date]').html(v != null ? v.trim() : v);
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
     })
 }
 //將所有按鈕class風格統一 	
 function addButtonClass() {
     j$("input[type=submit]").removeAttr('class').addClass("pure-button pure-button-primary pure-u-1-1");
     
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
                 //特休可用時數
                 if (k == 'annual_leave__c') {
                     j$('input[id $= Annual_leave]').val(v != null ? v.trim() : v);
                 }
                 if (k == 'employee_code__c') {
                     j$('input[id $= Employee_Code]').val(v != null ? v.trim() : v);
                 }
             });
         }
     });
 }