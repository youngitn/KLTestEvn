 j$( function() {
                let nameDom = j$( "input[id$=queryApplicantName]");
                let nunDom = j$( "#queryApplicantNum");
                let queryTable;
                nameDom.val(j$( "input[id$=baseApplicantName]" ).val());
                nunDom.val(j$( "input[id$=baseApplicantNum]" ).val());
                
                j$("input[id$=queryApplicantName]").on('change',function(){
                    if (j$(this).val() != ''){
                        j$('body').block({
                          message: '處理中...'
                        });
                      setTimeout(getEmpid, 1500);
                    }
                    
                    
                });
                j$("#doQuery").on('click', function(event) {
                    event.preventDefault();

                    let queryApplicantNum = nunDom.val();
                    // if (queryApplicantNum == '' || queryApplicantNum == null){
                    //   alert('工號不可為空');
                    //   return false;
                    // }
                    let sQueryDate        = j$( "input[id$=sQueryDate]" ).val();
                    let eQueryDate        = j$( "input[id$=eQueryDate]" ).val();
                    let queryAplStatus    = j$( "select[id$=queryAplStatus]" ).val();
                    let queryTypesOfLeave = j$( "select[id$=queryTypesOfLeave]" ).val();
                    
                    
                    LeaveQueryController.doQuery(sQueryDate,eQueryDate,queryAplStatus,queryTypesOfLeave,queryApplicantNum,function(result, event) {
                        if (event.status) {
                            
                            //var o = JSON.parse(result);
                            console.log(JSON.parse(j$.parseHTML(result)[0].textContent));
                            let TypesOfLeaveMap = getSelectTypesOfLeave();
                            let Approval_StatusMap =getSelectApproval_Status();
                            if ( j$.fn.dataTable.isDataTable( '#queryTable' ) ) {
                                   queryTable.destroy();
                                }
                                queryTable = j$('#queryTable').DataTable( {
                                responsive: true,
                                "language":languageConf,
                                "data": JSON.parse(j$.parseHTML(result)[0].textContent),
                                "columns": [
                                              { "data": "LeaveManage__c", "defaultContent": "<i>空</i>" },
                                              { "data": "TypesOfLeave__c", "defaultContent": "<i>空</i>" },
                                              { "data": "Leave_reason__c" , "defaultContent": "<i>空</i>"},
                                              { "data": "Start_date__c" , "defaultContent": "<i>空</i>"},
                                              { "data": "End_date__c" , "defaultContent": "<i>空</i>"},
                                              { "data": "LeaveManage__r.Approval_Status__c" , "defaultContent": "<i>空</i>"}
                                            ],
                                            "columnDefs": [
                                              { "title": "單號", "targets": 0 ,
                                                "data": "profileImageUrl", 
                                                "render": function ( data, type, row, meta )
                                                            {return "<input value='瀏覽' type='button' class='pure-button pure-button-primary' onClick=\"window.open('/"+data+"');j$(this).removeAttr('class').addClass('pure-button pure-button-primary');\"/>";}
                                              },
                                              { "title": "假別", "targets": 1 , "render": function ( data, type, row, meta )
                                                            {return TypesOfLeaveMap.get(data);} },
                                              { "title": "事由", "targets": 2 },
                                              { "title": "起日", "targets": 3 },
                                              { "title": "訖日", "targets": 4 },
                                              { "title": "審批狀態", "targets": 5  , "render": function ( data, type, row, meta )
                                                            {return Approval_StatusMap.get(data);} }
                                            ]
                                  
                              } );
                            //end dataTable
                            
                            
                        }
                    });

                   
                 
                });
               


              } );
              function sleep(d){
                for(var t = Date.now();Date.now() - t <= d;);
              }
              function getSelectTypesOfLeave(){
                let conceptName = new Map();
                let queryTypesOfLeaveOpt = j$( "select[id$=queryTypesOfLeave]" ).find("option");
                j$.each(queryTypesOfLeaveOpt, function( index, value ) {
                    conceptName.set(j$(value).val(),j$(value).html());
                    
                  });
                
                
                 console.log(conceptName);
                 return conceptName;
              }
              function getEmpid(){
                let cId = j$("input[id $= queryApplicantName_lkid]").val();
                    //alert(j$("input[id $= queryApplicantName_lkid]").val());
                    LeaveQueryController.getEmpId(cId, function(result, event) {
                       if (event.status && result != null) {
                            
                           
                               j$( "#queryApplicantNum").val(result);
                           
                                                        
                       }else{
                         alert('錯誤發生');
                       }
                       j$('body').unblock();

                   })

              }
              function getSelectApproval_Status(){
                let conceptName = new Map();
                let queryTypesOfLeaveOpt = j$( "select[id$=queryAplStatus]" ).find("option");
                j$.each(queryTypesOfLeaveOpt, function( index, value ) {
                    conceptName.set(j$(value).val(),j$(value).html());
                    
                  });
                
                
                 console.log(conceptName);
                 return conceptName;
              }