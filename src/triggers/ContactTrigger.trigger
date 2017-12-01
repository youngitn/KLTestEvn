trigger ContactTrigger on Contact (before insert, after update,before update, after insert) {
    new Triggers()
    //用户是否有编辑权限一定放在最前面，请不要移动代码位置
    .bind (Triggers.Evt.beforeUpdate, new ApprovalPermissionItemHandler())
    .manage(); 
}