Vue.component('test-ccomponent', {
    //props 要外部給值 做為介面用 
    //其名稱 在組件中可以直接拿來當變數用 
    //裡面就是外部給的數據
    props: ['contact'],//來自root的 data:contactMap
    data: function() {
        return {
            //empid:''//可定義data 但組件的data必須是用function的形式給
        }
    },
    computed: {
        empid: function() {
            return this.contact.get("陳 麗娟");
        }
    },
    template: '<input :value="empid"></input>'//這邊因為是指定給value 是一DOM屬性 所以必須用v-bind(:) 
});

Vue.component('test-ccomponent2', {
    template: '<div>A custom component2!</div>'
});