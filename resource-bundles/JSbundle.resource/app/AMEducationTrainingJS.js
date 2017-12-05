                var j$ = jQuery.noConflict();
                //2017/10/19
                j$(function() {
                    
                    vueJs();
                    // Handler for .ready() called.
                    var participants = j$("div[id$='participants']");
                    var ExTraining = j$("div[id$='ExternalTraining']");
                    var InTraining = j$("div[id$='InternalTraining']");
                    participants.hide();
                    j$("select[id$='pl_EducationTrainingType']").change(function() {
                        if (j$(this).val() == 'InternalTraining') {
                            participants.show();
                            ExTraining.hide();
                            InTraining.show();
                        } else if (j$(this).val() == 'ExternalTraining') {
                            participants.hide();
                            ExTraining.show();
                            InTraining.hide();
                            j$("input[id$='EducationTrainingExternalLecturerName']").removeAttr('disabled');
                        } else {
                            participants.hide();
                        }
                    });
                    j$("select[id$='pl_EducationTrainingLocationSelect']").change(function() {
                        //alert(j$(this).val());
                        if (j$(this).val() == '' && j$("select[id$='pl_EducationTrainingType']").val() == 'InternalTraining') {
                            alert('請填寫訓練地點欄位');
                            j$("input[id$='EducationTrainingLocation']").removeAttr('disabled');
                        } else {
                            j$("input[id$='EducationTrainingLocation']").attr('disabled', 'disabled');
                        }
                        return false;
                    });
                    j$("input[id$='EducationTrainingTransferDateTime']").attr('disabled', 'disabled');
                    j$("select[id$='pl_EducationTrainingExamination']").change(function() {
                        //alert(j$(this).val());
                        if (j$(this).val() == 'trainingTransfer') {
                            alert('請填寫轉訓時間');
                            j$("input[id$='EducationTrainingTransferDateTime']").removeAttr('disabled');
                        } else {
                            j$("input[id$='EducationTrainingTransferDateTime']").attr('disabled', 'disabled');
                        }
                        return false;
                    });
                    j$("input[id$='EducationTrainingExternalLecturerName']").attr('disabled', 'disabled');
                    j$("select[id$='pl_EducationTrainingInHouseLecturerHiring']").change(function() {
                        //alert(j$(this).val());
                        if (j$(this).val() == 'Internal') {
                            j$("input[id$='EducationTrainingExternalLecturerName']").attr('disabled', 'disabled');
                            j$("input[id$='EducationTrainingInHouseLecturerName']").removeAttr('disabled', 'disabled');
                            alert('請填寫內訓內聘講師姓名!');
                        } else if (j$(this).val() == 'External') {
                            j$("input[id$='EducationTrainingExternalLecturerName']").removeAttr('disabled');
                            j$("input[id$='EducationTrainingInHouseLecturerName']").attr('disabled', 'disabled');
                            alert('請填寫內訓外聘/外訓 講師名稱!');
                        }
                        return false;
                    });
                    j$("input[id$='doSave']").click(function() {
                        //alert('123');
                        if (j$("select[id$='pl_EducationTrainingLocationSelect']").val() == '' && j$("input[id$='EducationTrainingLocation']").val() == '' && j$("select[id$='pl_EducationTrainingType']").val() == 'InternalTraining') {
                            alert('請填寫訓練地點欄位!');
                            return false;
                        }
                    });
                    j$("input[id$='BegingTime__c']").on('focus', function() {
                        ActivityFunction.showTimePicker(j$(this).attr('id'));
                    });
                    j$("input[id$='EndTime__c']").on('focus', function() {
                        ActivityFunction.showTimePicker(j$(this).attr('id'));
                    });
                    //onfocus="ActivityFunction.saveStartTime('StartDateTime','StartDateTime_time');ActivityFunction.showTimePicker('StartDateTime_time')"
                });

                function deleteItemBankDetail(rowID) {
                    deleteRow(rowID);
                }

                function myJavascriptFunc() {
                    alert('Entered Javascript');
                    aaa();
                }

                function setNameValue(val, idx) {
                    alert(val + '-' + idx);
                    //j$("input[id$='nameValue']").val(val);
                }

                function onCompleteJSFunc() {
                    //alert('OK');
                    j$('#participantsTable').find('input[name^="j_id0"]');
                }

                function vueJs() {
                    //取dom 並給屬性
                    j$("input[id$='Applicant__c']").attr("v-model.lazy", "name");
                    //定義vue
                    var app5 = new Vue({
                        el: j$("div[id$='app-5']").get(0),
                        data: {
                            items: '',
                            name: '',
                            contactMap: new Map()
                        },
                        created: function() {
                            this.fetchData();
                        },
                        computed: {
                            empid: function() {
                                return this.contactMap.get(this.name);
                            }
                        },
                        methods: {
                            fetchData: function() {
                                var self = this;
                                self.items = contactjson;
                                var mapObj = new Map();
                                var a = 0;
                                for (var i = self.items.length - 1; i >= 0; i--) {
                                    mapObj.set(self.items[i].Name, self.items[i].Number__c);
                                    //console.log(self.items[i].Id);
                                }
                                //console.log('!!!!!!'+self.items[205].Id);
                                self.contactMap = mapObj;
                                //console.log(self.contactMap);
                                //alert(mapObj);
                            }
                        }
                    });
                }