//全域變數
const j$ = jQuery.noConflict();
const lookupId = 'j_id0:j_id15:form:Toastmaster';

//after load
j$(function() {
	//外觀樣式
    j$(".btn").removeClass('btn');
    j$(".dateInput").removeClass('dateInput');
    j$(".dateOnlyInput").removeClass('dateOnlyInput');
    j$("#tabs").tabs({
        beforeLoad: function(event, ui) {
            ui.jqXHR.fail(function() {
                ui.panel.html("Couldn't load this tab. We'll try to fix this as soon as possible. " + "If this wouldn't be a demo.");
            });
        }
    });
    
    // j$( "input[id$=Toastmaster]").on('click',function(){
    //     	var myWindow =  openLookup('/_ui/common/data/LookupPage?lkfm=j_id0:j_id15:form&lknm=j_id0:j_id15:form:Toastmaster&lktp=003','&lksrch=' + escapeUTF(getElementByIdCS('j_id0:j_id15:form:Toastmaster').value.substring(0, 80)));
    //     });
    //將input加入能夠選取連絡人功能 流程表單用      		
    createLookUpFiled(null, 'Toastmaster', 'lookupInput');
    createLookUpFiled(null, 'Note_Taker', 'lookupInput2');
    createLookUpFiled(null, 'Participant', 'lookupInput3');
    //init databale
    buildDialogEmpLookUp();
    //add event listener
    j$("#Toastmaster_lookupIcon").on("click", function() {
        addEventOnDatable('Toastmaster', 'input', false, false);
    });
    j$("#Note_Taker_lookupIcon").on("click", function() {
        addEventOnDatable('Note_Taker', 'input', false, false);
    });
    j$("#Participant_lookupIcon").on("click", function() {
        addEventOnDatable('Participant__c', 'textarea', true, false);
    });

    j$("input[id$='BegingTime__c'],input[id$='EndTime__c']").on('click', function() {
        ActivityFunction.showTimePicker(j$(this).attr('id'));
    });
    
});

function htmlencode(s) {
    var div = document.createElement('div');
    div.appendChild(document.createTextNode(s));
    return div.innerHTML;
}

function htmldecode(s) {
    var div = document.createElement('div');
    div.innerHTML = s;
    return div.innerText || div.textContent;
}
//讓一般的文字輸入也能出現連絡人選取視窗
function createLookUpFiled(formId, inputId, appendId) {
    let template = null;
    if (formId == null) {
        template = j$("<a>", {
            id: inputId + '_lookupIcon',
            html: j$("<img>", {
                src: "/img/s.gif",
                alt: "员工 對應 (新視窗)",
                class: "lookupIcon",
                onblur: "this.className = 'lookupIcon';",
                onfocus: "this.className = 'lookupIconOn';",
                onmouseout: "this.className = 'lookupIcon';this.className = 'lookupIcon';",
                onmouseover: "this.className = 'lookupIconOn';this.className = 'lookupIconOn';",
                title: "员工 對應 (新視窗)"
            })
        });
        j$('#' + appendId).append(template);
    } else {
        let lastStr = ["_lkid", "_lkold", "_lktp", "_lspf", "_lspfsub", "_mod"];
        let defVal = ["000000000000000", "null", "003", "0", "0", "0"];
        let i;
        for (i = 0; i <= 5; i++) {
            template = j$("<input>", {
                id: formId + ":" + inputId + lastStr[i],
                // html:$( "<div>", 
                // 		{ 	class: "bar", 
                // 			text: "bla" 
                // 		} )
                type: "hidden",
                name: formId + ":" + inputId + lastStr[i],
                value: defVal[i]
            });
            j$('#' + appendId).append(template);
        }
        template = null;
        template = j$("<a>", {
            id: formId + ":" + inputId + lastStr[i],
            html: j$("<img>", {
                src: "/img/s.gif",
                alt: "员工 對應 (新視窗)",
                class: "lookupIcon",
                onblur: "this.className = 'lookupIcon';",
                onfocus: "this.className = 'lookupIconOn';",
                onmouseout: "this.className = 'lookupIcon';this.className = 'lookupIcon';",
                onmouseover: "this.className = 'lookupIconOn';this.className = 'lookupIconOn';",
                title: "员工 對應 (新視窗)"
            }),
            href: "javascript:openLookup('/_ui/common/data/LookupPage?lkfm=" + formId + "&lknm=" + formId + ":" + inputId + "&lktp=003','&lksrch=' + escapeUTF(getElementByIdCS('" + formId + ":" + inputId + "').value.substring(0, 80)))",
            id: formId + ":" + inputId + "_lkwgt",
            onclick: "setLastMousePosition(event)",
            title: "员工 對應 (新視窗)"
        });
        j$('#' + appendId).append(template);
    }
    // j$('.lookupInput').attr(
    // 		{
    // 			onchange:"getElementByIdCS('"+formId+":"+inputId+"').value='';getElementByIdCS('"+formId+":"+inputId+"_mod').value='1';"	
    // 		}
    // 	);
}

function test() {
    j$(".datePicker").attr('display', false);
}

function addEventOnDatable(targetInputname, tagName, isMultiEmp, doTrigger) {
    j$("#lookupTable tbody").off("click", "td > a");
    //20180227 能夠按下某CELL取得其他CELL值
    //要用來抓contactId
    let ltt = j$('#lookupTable tbody');
    let targetDom = j$(tagName + "[id$=" + targetInputname + "]");
    ltt.on('click', 'td > a', function() {
        let cell = j$(this);
        //cell.data( cell.data() + 1 ).draw();
        targetDom.val();
        if (isMultiEmp) {
            if (!targetDom.val().includes(cell.text())) {
            	if(targetDom.val()=='' || targetDom.val() == null){
            		targetDom.val(cell.text() + '-' + cell.parent().next().text());
            	}else{
            		targetDom.val(targetDom.val() + ',' + cell.text() + '-' + cell.parent().next().text());
            	}
                
            } else {
                alert('該員工已新增過了.');
            }
        } else {
            targetDom.val(cell.text() + '-' + cell.parent().next().text());
            j$("#dialog-confirm").dialog("close");
        }
        if (doTrigger) {
            targetDom.change();
        }
    });
    j$("#dialog-confirm").dialog( "option", "position", { my: "right", at: "left bottom", of: targetDom } );
    j$("#dialog-confirm").dialog("open");
}

function buildDialogEmpLookUp() {
    // Apex直接進js
    //objList = jQuery.parseJSON('{!JSENCODE(objList)}');
    j$("#dialog-confirm").dialog({
        resizable: false,
        autoOpen: false,
        height: "auto",
        width: 400,
        modal: true
    });
    for (let i = objList.length - 1; i >= 0; i--) {
        console.log(objList[i].Contact_Name);
    }
    let t = j$('#lookupTable').DataTable({
        "data": objList,
        "language":languageConf,
        "columns": [{
            "data": "Contact_Name"
        }, {
            "data": "Contact_Code"
        }, {
            "data": "Department"
        }
        // , {
        //     "data": "profileImageUrl"
        // }
        , {
            "data": "id"
        }],
        "columnDefs": [{
            "title": "姓名",
            "targets": 0,
            "data": "Contact_Name",
            "render": function(data, type, row, meta) {
                return "<a>" + data + "</a>";
            }
        }, {
            "title": "員工編號",
            "targets": 1,
            "data": "Contact_Code",
            "render": function(data, type, row, meta) {
                return "" + data + "";
            }
        }, {
            "title": "部門",
            "targets": 2
        } 
        // ,{
        //     "title": "大頭貼",
        //     "targets": 3,
        //     "data": "profileImageUrl",
        //     "render": function(data, type, row, meta) {
        //         return "<img src=" + data + "></img>";
        //     }
        // }
        , {
            "targets": 3,
            "visible": false
        }]
    });
}