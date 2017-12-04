window.onload = function() {
    var app = new Vue({
        el: '#app',
        data: {
            message: 'Hello WIPDeveloper Readers from Vue.js!',
            empid: '',
            name: ''
        }
    })
    // $watch 是一个实例方法
    app.$watch('empid', function(newValue, oldValue) {
        // 这个回调将在 `vm.a` 改变后调用
        app.name = '123';
    })
    var app2 = new Vue({
        el: '#app-2',
        data: {
            message: '页面加载于 ' + new Date().toLocaleString()
        }
    });
    var vm = new Vue({
        el: '#example',
        data: {
            message: 'Hello',
            selected: 'A',
            options: [{
                text: 'One',
                value: 'A'
            }, {
                text: 'Two',
                value: 'B'
            }, {
                text: 'Three',
                value: 'C'
            }]
        },
        computed: {
            // 计算属性的 getter
            reversedMessage: function() {
                // `this` 指向 vm 实例
                return this.message.split('').reverse().join('')
            }
        }
    })
    // 注册
    var data = {
        message: 'Hello',
        selected: 'A',
        options: [{
            text: 'One',
            value: 'A'
        }, {
            text: 'Two',
            value: 'B'
        }, {
            text: 'Three',
            value: 'C'
        }]
    };
    Vue.component('my-component', {
        template: '<select v-model="selected">' + '<option v-bind:value="option.value" v-for="option in options">' + '{{ option.text }}' + '</option>' + '</select>',
        data: function() {
            return data;
        }
    });
    new Vue({
        el: '#example'
    });

   



}