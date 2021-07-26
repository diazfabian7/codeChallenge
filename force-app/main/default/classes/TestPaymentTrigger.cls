/**
 * Created by erick on 7/25/2021.
 */

@IsTest
private class TestPaymentTrigger {

    @TestSetup
    static void createData(){
        //With more time we can develop a data factory class to reuse the code
        Contact contactObj = new Contact(FirstName = 'Contact', LastName = 'LastName');
        insert contactObj;
        Project__c projectObj = new Project__c(Name = 'ProjectOne');
        insert projectObj;
        List<Payment__c> paymentsToInsert = new List<Payment__c>();
        for(Integer i = 0; i < 5; i++){
            paymentsToInsert.add(new Payment__c(Contact__c = contactObj.Id, Payment_Date__c = Date.today().addDays(i), Project__c = projectObj.Id, Amount__c = 1000+i));
        }
        insert paymentsToInsert;
    }

    @IsTest
    static void calculateTotalPaymentAmountOnInsert() {
        Contact contact = [SELECT FirstName FROM Contact LIMIT 1];
        Project__c project = [SELECT Name, Total_Amount_of_Payments__c FROM Project__c LIMIT 1];
        Date lastPaymentDate = Date.today().addDays(20);
        Double paymentAmount = 5000;
        Payment__c paymentCreated = new Payment__c(Contact__c = contact.Id, Payment_Date__c = lastPaymentDate, Project__c = project.Id, Amount__c = paymentAmount);
        Test.startTest();
            insert paymentCreated;
        Test.stopTest();
        project = [SELECT Name, Total_Amount_of_Payments__c FROM Project__c WHERE Id =: project.Id];
        List<AggregateResult> aggregateResults = [SELECT MAX(Payment_Date__c) lastPayment, SUM(Amount__c) sumPayments, Contact__c, Project__c  FROM Payment__c WHERE Contact__c =: contact.Id GROUP BY Contact__c, Project__c];
        System.assertEquals(Double.valueOf(aggregateResults[0].get('sumPayments')), project.Total_Amount_of_Payments__c, 'Total_Amount_of_Payments__c must be updated with the Payments amount sum');
    }

    @IsTest
    static void calculateTotalPaymentAmountOnUpdate() {
        Contact contact = [SELECT FirstName FROM Contact LIMIT 1];
        Project__c project = [SELECT Name, Total_Amount_of_Payments__c FROM Project__c LIMIT 1];
        List<Payment__c> payments = [SELECT Project__c FROM Payment__c WHERE Project__c =: project.Id AND Contact__c =: contact.Id];
        Date lastPaymentDate = Date.today().addDays(20);
        payments[2].Payment_Date__c = lastPaymentDate;
        Test.startTest();
            update payments[2];
        Test.stopTest();
        project = [SELECT Name, Total_Amount_of_Payments__c FROM Project__c WHERE Id =: project.Id];
        contact = [SELECT FirstName, Last_Payment_Date__c FROM Contact WHERE Id =: contact.Id];
        List<AggregateResult> aggregateResults = [SELECT MAX(Payment_Date__c) lastPayment, SUM(Amount__c) sumPayments, Contact__c, Project__c  FROM Payment__c WHERE Contact__c =: contact.Id GROUP BY Contact__c, Project__c];
        System.assertEquals(Double.valueOf(aggregateResults[0].get(PaymentTriggerActions.SUM_PAYMENTS)), project.Total_Amount_of_Payments__c, 'Total_Amount_of_Payments__c must be updated with the Payments amount sum');
        System.assertEquals(lastPaymentDate , contact.Last_Payment_Date__c, 'Last_Payment_Date__c must be equals to ' + lastPaymentDate);
    }

    @IsTest
    static void calculateTotalPaymentAmountDelete() {
        Project__c project = [SELECT Id, Total_Amount_of_Payments__c FROM Project__c LIMIT 1];
        List<Payment__c> payments = [SELECT Project__c FROM Payment__c WHERE Project__c =: project.Id];
        Test.startTest();
            delete payments;
        Test.stopTest();
        project = [SELECT Total_Amount_of_Payments__c FROM Project__c WHERE Id =: project.Id];
        System.assertEquals(project.Total_Amount_of_Payments__c, 0, 'Total_Amount_of_Payments__c must be 0 because of all project payments were deleted');
    }
}