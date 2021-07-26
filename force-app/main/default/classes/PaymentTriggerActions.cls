/**
 * Created by erick on 7/25/2021.
 */

public with sharing class PaymentTriggerActions {

    @TestVisible private static final String SUM_PAYMENTS = 'sumPayments';
    @TestVisible private static final String LAST_PAYMENT = 'lastPayment';

    public void calculateTotalPaymentAmount(Map<Id, Payment__c> newPaymentsMap){
        Map<Id, Contact> contactsMapToUpdate = new Map<Id, Contact>();
        Map<Id, Project__c> projectsMapToUpdate = new Map<Id, Project__c>();
        for(Payment__c pay: newPaymentsMap.values()){
            if(pay.Project__c != null && !projectsMapToUpdate.containsKey(pay.Project__c)){
                projectsMapToUpdate.put(pay.Project__c, new Project__c(Id = pay.Project__c));
            }
            if(pay.Contact__c != null && !contactsMapToUpdate.containsKey(pay.Contact__c)){
                contactsMapToUpdate.put(pay.Contact__c, new Contact(Id = pay.Contact__c));
            }
        }
        if (!contactsMapToUpdate.isEmpty()){
            contactsMapToUpdate = getContactTotalPayments(contactsMapToUpdate);
            update contactsMapToUpdate.values();
        }
        if (!projectsMapToUpdate.isEmpty()){
            projectsMapToUpdate = getProjectTotalPayments(projectsMapToUpdate);
            update projectsMapToUpdate.values();
        }
    }

    private Map<Id, Project__c> getProjectTotalPayments(Map<Id, Project__c> projectsByIdsMap){
        Map<String, AggregateResult> aggResultsByProjectId = new Map<String, AggregateResult>();
        for(AggregateResult result: [SELECT SUM(Amount__c) sumPayments, Project__c project  FROM Payment__c WHERE Project__c IN: projectsByIdsMap.keySet() GROUP BY Project__c ]){
            aggResultsByProjectId.put((String) result.get('project') , result);
        }
        for(Project__c project: projectsByIdsMap.values()){
            if(aggResultsByProjectId.containsKey(project.Id) && aggResultsByProjectId.get(project.Id) != null){
                project.Total_Amount_of_Payments__c = Double.valueOf(aggResultsByProjectId.get(project.Id).get(SUM_PAYMENTS));
            } else {
                project.Total_Amount_of_Payments__c = 0;
            }
        }
        return projectsByIdsMap;
    }

    private Map<Id, Contact> getContactTotalPayments(Map<Id, Contact> contactsByIdsMap){
        Map<String, AggregateResult> aggResultsByContactId = new Map<String, AggregateResult>();
        for(AggregateResult result: [SELECT  MAX(Payment_Date__c) lastPayment, SUM(Amount__c) sumPayments, Contact__c contact  FROM Payment__c WHERE Contact__c IN: contactsByIdsMap.keySet() GROUP BY Contact__c ]){
            aggResultsByContactId.put((String) result.get('contact') , result);
        }
        for(Contact contact: contactsByIdsMap.values()){
            if(aggResultsByContactId.containsKey(contact.Id) && aggResultsByContactId.get(contact.Id) != null){
                contact.Last_Payment_Date__c = Date.valueOf(aggResultsByContactId.get(contact.Id).get(LAST_PAYMENT));
                contact.Total_Payments_Amount__c = Double.valueOf(aggResultsByContactId.get(contact.Id).get(SUM_PAYMENTS));
            } else {
                contact.Last_Payment_Date__c = null;
                contact.Total_Payments_Amount__c = 0;
            }
        }
        return contactsByIdsMap;
    }

}