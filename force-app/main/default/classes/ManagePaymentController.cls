/**
 * Created by erick on 7/27/2021.
 */

public with sharing class ManagePaymentController {


    @AuraEnabled (cacheable=true)
    public static List<Contact> getContactWithPayments(){
        return [SELECT FirstName, LastName, Last_Payment_Date__c, Total_Payments_Amount__c, Name
                FROM Contact WHERE Total_Payments_Amount__c > 0 AND Last_Payment_Date__c != NULL];
    }

    @AuraEnabled (cacheable=true)
    public static List<Payment__c> getPaymentsByContact(String contactId){
        return [SELECT Name, Amount__c, Payment_Date__c
                FROM Payment__c WHERE Contact__c =: contactId ];
    }
}