/**
 * Created by erick on 7/27/2021.
 */

@IsTest
private class TestManagePaymentController {

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
    static void testGetContactWithPayments() {
        List<Contact> contactsResult;
        Test.startTest();
            contactsResult = ManagePaymentController.getContactWithPayments();
        Test.stopTest();
        System.assert(!contactsResult.isEmpty(), 'getContactWithPayments should be not empty');
    }

    @IsTest
    static void testPaymentsByContact() {
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        List<Payment__c> paymentResults;
        Test.startTest();
            paymentResults = ManagePaymentController.getPaymentsByContact(contact.Id);
        Test.stopTest();
        System.assert(!paymentResults.isEmpty(), 'PaymentsByContact should be not empty');
    }
}