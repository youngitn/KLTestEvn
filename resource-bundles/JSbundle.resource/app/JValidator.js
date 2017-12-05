(function($) {
    $.fn.formValidator = function(opts) {
        // default configuration
        var config = $.extend({}, {
            opt1: null
        }, opts);
        // main function
        function init(obj) {
            var dObj = $(obj),
                dValidateItems = dObj.find('input[id*=jq_validate]'),
                dSubmitBtn = dObj.find('input[id*=jq_vsubmit][type=submit]');
            var validator = {
                types: {},
                messages: [],
                config: {},
                validate: function(data) {
                    var i,
                        enmsg,
                        cnmsg,
                        type,
                        checker,
                        result_ok;
                    this.messages = [];
                    for (i in data) {
                        if (data.hasOwnProperty(i)) { //i == name
                            type = this.config[i]; //type == config[name] == isNonEmpty
                            checker = this.types[type]; //checker == types[isNonEmpty] == {}
                            //要檢測的條件不存在，無法檢測
                            if (!type) {
                                continue;
                            }
                            //要檢測的規則和錯誤訊息不存在，無法檢測，拋出異常
                            if (!checker) {
                                continue
                            }
                            //驗證
                            result_ok = checker.validate(data[i]);
                            if (!result_ok) {
                                enmsg = "Invalid value for *" + j$("label[for$='"+i+"']").html() + "*, " + checker.enErrMsg;
                                cnmsg = "無效的輸入值 *" + j$("label[for$='"+i+"']").html()  + "*, " + checker.cnErrMsg;
                                this.messages.push(cnmsg+'\n['+enmsg+']\n\n');
                            } 

                        }
                    }
                },
                hasErrors: function() {
                    var result = this.messages.length !== 0;
                    return result;
                }
            };
            validator.types.isNonEmpty = {
                validate: function(value) {
                    return value !== "";
                },
                enErrMsg: '.the value cannot be empty.',
                cnErrMsg: '這個欄位值不能為空.'
            };
            dSubmitBtn.click(function(e) {
                //e.preventDefault();
                var data = {};
                $.each(dValidateItems, function(i, val) {
                    data[$(val).attr('id')] = $(val).val();
                });
                $.each(dValidateItems, function(i, val) {
                    let v = $(val).data('validate');
                    if (v === undefined) {
                        v = "isNonEmpty";
                    }
                    validator.config[$(val).attr('id')] = v;
                });
                validator.validate(data);
                if (validator.hasErrors()) {
                    console.log(validator.messages.join('\n'));
                    alert(validator.messages.join('\n'));
                    return false;
                }
            });
        }
        // initialize every element
        this.each(function() {
            init($(this));
        });
        return this;
    };
    // start
    // $(function() {
    // 	$('.validateForm').formValidator();
    // });
})(jQuery);