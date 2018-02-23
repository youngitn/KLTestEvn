j$(function() {
    let nameDom = j$("input[id$=queryApplicantName]");
    let nunDom = j$("#queryApplicantNum");
    let queryTable;
    nameDom.val(j$("input[id$=baseApplicantName]").val());
    nunDom.val(j$("input[id$=baseApplicantNum]").val());
    j$("input[id$=queryApplicantName]").on('change', function() {
        if (j$(this).val() != '') {
            j$('body').block({
                message: '處理中...'
            });
            setTimeout(getEmpid, 1500);
        }
    });
    j$("#doQuery").on('click', function(event) {
        event.preventDefault();
        let sQueryDate = j$("input[id$=sQueryDate]").val();
        let eQueryDate = j$("input[id$=eQueryDate]").val();
        let Query_Toastmaster__c = j$("input[id$=Query_Toastmaster__c]").val();
        let Query_Note_Taker__c = j$("input[id$=Query_Note_Taker__c]").val();
        let Query_Meeting_Subject__c = j$("input[id$=Query_Meeting_Subject__c]").val();
        let soqlStr = "SELECT id,Toastmaster__c,Note_Taker__c,Meeting_Subject__c,Meeting_Date__c FROM KL_Systems__c WHERE recordTypeId='" + recordTypeId + "'";
        var map = new Map(),
            object = {};
        createJsonItem(map, 'sQueryDate', sQueryDate);
        createJsonItem(map, 'eQueryDate', eQueryDate);
        if (sQueryDate == null || sQueryDate == '') {
            sQueryDate = "1990-01-01";
        }
        if (eQueryDate == null || eQueryDate == '') {
            eQueryDate = "2100-01-01";
        }
        soqlStr += ' and Meeting_Date__c >= ' + sQueryDate + ' and Meeting_Date__c <= ' + eQueryDate;
        createJsonItem(map, 'Toastmaster__c', Query_Toastmaster__c);
        if (Query_Toastmaster__c != '') {
            soqlStr += " and Toastmaster__c ='" + Query_Toastmaster__c + "' ";
        }
        createJsonItem(map, 'Note_Taker__c', Query_Note_Taker__c);
        if (Query_Note_Taker__c != '') {
            soqlStr += " and Note_Taker__c ='" + Query_Note_Taker__c + "' ";
        }
        createJsonItem(map, 'Meeting_Subject__c', Query_Meeting_Subject__c);
        if (Query_Meeting_Subject__c != '') {
            soqlStr += " and Meeting_Subject__c ='" + Query_Meeting_Subject__c + "' ";
        }
        //給物件名稱 提供後台SOQL用
        createJsonItem(map, 'sobjName', 'KL_Systems__c');
        createJsonItem(map, 'recordTypeId', recordTypeId);
        createJsonItem(map, 'SOQL', soqlStr);
        map.forEach((value, key) => {
            var keys = key.split('.'),
                last = keys.pop();
            keys.reduce((r, a) => r[a] = r[a] || {}, object)[last] = value;
        });
        console.log(object);
        QueryController.doQuery(JSON.stringify(object), function(result, event) {
            if (event.status) {
                //var o = JSON.parse(result);
                console.log(JSON.parse(j$.parseHTML(result)[0].textContent));
                //return false;
                //console.log(JSON.parse(j$.parseHTML(result)[0].textContent));
                //let TypesOfLeaveMap = getSelectTypesOfLeave();
                //let Approval_StatusMap =getSelectApproval_Status();
                if (j$.fn.dataTable.isDataTable('#queryTable')) {
                    queryTable.destroy();
                }
                queryTable = j$('#queryTable').DataTable({
                    responsive: true,
                    "language": languageConf,
                    "data": JSON.parse(j$.parseHTML(result)[0].textContent),
                    "columns": [{
                        "data": "Id",
                        "defaultContent": "<i>空</i>"
                    }, {
                        "data": "Meeting_Subject__c",
                        "defaultContent": "<i>空</i>"
                    }, {
                        "data": "Meeting_Date__c",
                        "defaultContent": "<i>空</i>"
                    }, {
                        "data": "Toastmaster__c",
                        "defaultContent": "<i>空</i>"
                    }, {
                        "data": "Note_Taker__c",
                        "defaultContent": "<i>空</i>"
                    }],
                    "columnDefs": [{
                        "title": "單號",
                        "targets": 0,
                        "data": "profileImageUrl",
                        "render": function(data, type, row, meta) {
                            return "<input value='瀏覽' type='button' class='pure-button pure-button-primary pure-u-1 pure-u-md-2-5 pure-u-xl-1-5' onClick=\"window.open('/" + data + "');j$(this).removeAttr('class').addClass('pure-button pure-button-primary');\"/>";
                        },
                        'createdCell': function(td, cellData, rowData, row, col) {
                            j$(td).attr('data-th', '單號');
                        }
                    }, {
                        "title": "主題",
                        "targets": 1,
                        'createdCell': function(td, cellData, rowData, row, col) {
                            j$(td).attr('data-th', '主題');
                        }
                    }, {
                        "title": "日期",
                        "targets": 2,
                        'createdCell': function(td, cellData, rowData, row, col) {
                            j$(td).attr('data-th', '日期');
                        }
                    }, {
                        "title": "主持人",
                        "targets": 3,
                        'createdCell': function(td, cellData, rowData, row, col) {
                            j$(td).attr('data-th', '主持人');
                        }
                    }, {
                        "title": "記錄人",
                        "targets": 4,
                        'createdCell': function(td, cellData, rowData, row, col) {
                            j$(td).attr('data-th', '記錄人');
                        }
                    }]
                });
                //end dataTable
            }
        });
    });
});

function createJsonItem(aliases, propName, value) {
    aliases.set(propName, value);
}

function sleep(d) {
    for (var t = Date.now(); Date.now() - t <= d;);
}

function getSelectTypesOfLeave() {
    let conceptName = new Map();
    let queryTypesOfLeaveOpt = j$("select[id$=queryTypesOfLeave]").find("option");
    j$.each(queryTypesOfLeaveOpt, function(index, value) {
        conceptName.set(j$(value).val(), j$(value).html());
    });
    console.log(conceptName);
    return conceptName;
}

function getEmpid() {
    let cId = j$("input[id $= queryApplicantName_lkid]").val();
    //alert(j$("input[id $= queryApplicantName_lkid]").val());
    LeaveQueryController.getEmpId(cId, function(result, event) {
        if (event.status && result != null) {
            j$("#queryApplicantNum").val(result);
        } else {
            alert('錯誤發生');
        }
        j$('body').unblock();
    })
}

function getSelectApproval_Status() {
    let conceptName = new Map();
    let queryTypesOfLeaveOpt = j$("select[id$=queryAplStatus]").find("option");
    j$.each(queryTypesOfLeaveOpt, function(index, value) {
        conceptName.set(j$(value).val(), j$(value).html());
    });
    console.log(conceptName);
    return conceptName;
}