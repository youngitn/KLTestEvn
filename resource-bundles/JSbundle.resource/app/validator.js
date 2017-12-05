var validator = {
    types: {}, //所有的驗證規則皆會存放於此，稍後會個別定義
    messages: [], //個別驗證類型的錯誤訊息
    config: {}, //使用者資料各欄位需要被驗證的類型
    validate: function(data) { // 使用者資料 - 欄位:值
        var i,
            msg,
            type,
            checker,
            result_ok;
        this.messages = []; //清空所有的錯誤信息
        for (i in data) {
            if (data.hasOwnProperty(i)) { //判斷使用者欄位是否需要被驗證
                type = this.config[i]; //如果需要被驗證，則取出相對應的驗證規則
                checker = this.types[type];
                if (!type) {
                    continue; //如果驗證規則不存在，則不處理
                }
                if (!checker) { //要檢測的規則和錯誤訊息不存在，無法檢測，拋出異常
                    throw {
                        name: "ValidationError",
                        message: "No handler to validate type " + type
                    };
                }
                result_ok = checker.validate(data[i]); //驗證
                if (!result_ok) { //取得錯誤訊息
                    msg = "Invalid value for *" + i + "*, " + checker.instructions;
                    this.messages.push(msg);
                }
            }
        }
        return this.hasErrors();
    },
    //helper
    hasErrors: function() {
        return this.messages.length !== 0;
    }
};
//個別定義驗證規則
//欄位值不可為空
validator.types.isNonEmpty = {
    validate: function(value) {
        return value !== "";
    },
    instructions: "欄位值不可為空;the value cannot be empty"
};
//欄位值只能為數字
validator.types.isNumber = {
    validate: function(value) {
        return !isNaN(value);
    },
    instructions: "欄位值只能為數字;the value can only be a valid number, e.g. 1, 3.14 or 2010"
};
//欄位值是否為英數組合
validator.types.isAlphaNum = {
    validate: function(value) {
        return !/[^a-z0-9]/i.test(value);
    },
    instructions: "欄位值是否為英數組合;the value can only contain characters and numbers, no special symbols"
};
//欄位值是否為Email
validator.types.isEmail = {
    validate: function(value) {
        var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
        return re.test(value);
    },
    instructions: 'use valid email format, e.g. @'
};
//欄位值有最小長度限制，字串大小是否在最小範圍內，設定為3個characters以上(minSize)
validator.types.minSize = {
    validate: function(value) {
        return value.length >= 3;
    },
    instructions: 'min size is 3 characters'
};
//欄位值有最大長度限制，字串大小是否在最大範圍內，設定為10個characters以內(maxSize)
validator.types.maxSize = {
    validate: function(value) {
        return value.length <= 10;
    },
    instructions: 'max size is 10 characters'
};
//測試資料 依需求自己建立
var data = {
    first_name: 'Super',
    last_name: 'Man',
    age: 'unknown',
    username: 'o_O',
    email: 'example@gmail.com',
    confirm_email: 'invalid_email_sample',
    password: '12'
};
//定義測試資料每個欄位需要被驗證的類型 
//配合data物件屬性名稱與 types名稱屬性
validator.config = {
    first_name: 'isNonEmpty',
    last_name: 'maxSize',
    age: 'isNumber',
    username: 'isAlphaNum',
    email: 'isEmail',
    confirm_email: 'isEmail',
    password: 'minSize'
};
//若有錯誤，則console出錯誤訊息
validator.validate(data);
if (validator.hasErrors()) {
    console.log(validator.messages.join("\n"));
}