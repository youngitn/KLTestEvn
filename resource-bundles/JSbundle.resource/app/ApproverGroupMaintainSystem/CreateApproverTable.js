// register the grid component
j$(function() {
    Vue.component('demo-grid', {
        template: '#grid-template',
        props: {
            data: Array,
            columns: Array,
            filterKey: String,
        },
        //所有在 ClickLoadApproverGroup()這個方法裡面的資料
        //都丟進去了,所以不需要再定義新的元件屬性來放.
        data: function() {
            var sortOrders = {}
            this.columns.forEach(function(key) {
                sortOrders[key] = 1
            })
            return {
                sortKey: '',
                sortOrders: sortOrders
            }
        },
        computed: {
            filteredData: function() {
                var sortKey = this.sortKey
                var filterKey = this.filterKey && this.filterKey.toLowerCase()
                var order = this.sortOrders[sortKey] || 1
                var data = this.data
                if (filterKey) {
                    data = data.filter(function(row) {
                        return Object.keys(row).some(function(key) {
                            return String(row[key]).toLowerCase().indexOf(filterKey) > -1
                        })
                    })
                }
                if (sortKey) {
                    data = data.slice().sort(function(a, b) {
                        a = a[sortKey]
                        b = b[sortKey]
                        return (a === b ? 0 : a > b ? 1 : -1) * order
                    })
                }
                return data
            }
        },
        filters: {
            capitalize: function(str) {
                return str.charAt(0).toUpperCase() + str.slice(1)
            }
        },
        methods: {
            sortBy: function(key) {
                this.sortKey = key
                this.sortOrders[key] = this.sortOrders[key] * -1
            }
        }
    })
   
    new Vue({
        el: '#demo',
        data: {
            is_show_load_button: false,
            ApproverGroup: [],
            searchQuery: '',
            ApproverGroupId:[],
            gridColumns: ['Name', 'Approval_Personnel__c', 'peopleName']
        },
        mounted: function() {
            var t = this;
            setTimeout(function() {
                t.is_show_load_button = true;
            }, 1000);
        },
        methods: {
            ClickLoadApproverGroup: function() {
                var ct = new ApproverGroupObj.Organizational__c();
                var t = this;
                t.ApproverGroup = [];
                ct.retrieve({
                    where: {
                        RecordTypeId: {
                            eq: '012O00000005teIIAQ'
                        }
                    },
                    limit: 100
                }, function(error_, records_) {
                    if (error_ != null) {
                        alert(error_.message);
                        return;
                    }
                    if (records_.length == 0) {
                        alert('row = 0');
                    } else {
                        records_.forEach(function(r_) {

                            t.ApproverGroup.push({
                                Name: r_.get('Name'),
                                Approval_Personnel__c: r_.get('Approval_Personnel__c'),
                                peopleName: cmap[r_.get('Approval_Personnel__c')].Name,
                                ApproverGroupId : r_.get('Id')
                                
                            });
                        });
                    }
                });
                //this.is_show_load_button = false;
            },
            ClickConvenienceStore: function(convenience_store_) {
                alert(convenience_store_.location_name);
            }
        }
    });
});