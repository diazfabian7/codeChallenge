/**
 * Created by erick on 7/25/2021.
 */

public with sharing class PaymentTriggerHandler {

    public void onAfterInsert(Map<Id, Payment__c> newPaymentsMap){
        new PaymentTriggerActions().calculateTotalPaymentAmount(newPaymentsMap);
    }

    public void onAfterUpdate(Map<Id, Payment__c> updatedPaymentsMap, Map<Id, Payment__c> oldPaymentsMap){
        new PaymentTriggerActions().calculateTotalPaymentAmount(updatedPaymentsMap);
    }

    public void onAfterDelete(Map<Id, Payment__c> oldPaymentsMap){
        new PaymentTriggerActions().calculateTotalPaymentAmount(oldPaymentsMap);
    }
}