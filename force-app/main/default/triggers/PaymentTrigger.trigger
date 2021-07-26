/**
 * Created by erick on 7/25/2021.
 */

trigger PaymentTrigger on Payment__c (before insert, before update, before delete, after insert, after update, after delete) {

    PaymentTriggerHandler handler = new PaymentTriggerHandler();

    if(Trigger.isBefore){
        if(Trigger.isInsert) {

        } else if(Trigger.isUpdate) {

        } else if(Trigger.isDelete) {

        }
    } else if (Trigger.isAfter) {
        if(Trigger.isInsert) {
            handler.onAfterInsert(Trigger.newMap);
        } else if(Trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        } else if(Trigger.isDelete) {
            handler.onAfterDelete(Trigger.oldMap);
        }
    }
}