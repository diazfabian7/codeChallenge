/**
 * Created by erick on 7/27/2021.
 */

import { LightningElement, wire } from 'lwc';
import getContactsApex from '@salesforce/apex/ManagePaymentController.getContactWithPayments';
import FIRST_NAME_FIELD from '@salesforce/schema/Contact.FirstName';
import LAST_NAME_FIELD from '@salesforce/schema/Contact.LastName';
import PAYMENTS_FIELD from '@salesforce/schema/Contact.Total_Payments_Amount__c';
import LAST_PAYMENT_FIELD from '@salesforce/schema/Contact.Last_Payment_Date__c';

const COLUMNS = [
        { label: 'First Name', fieldName: FIRST_NAME_FIELD.fieldApiName, type: 'text' },
        { label: 'Last Name', fieldName: LAST_NAME_FIELD.fieldApiName, type: 'text' },
        { label: 'Total Payments Amount', fieldName: PAYMENTS_FIELD.fieldApiName, type: 'currency' },
        { label: 'Last Payment Date', fieldName: LAST_PAYMENT_FIELD.fieldApiName, type: 'text' },
        {label: 'View', type: 'button', initialWidth: 155, typeAttributes: { label: 'View Summary', name: 'view_summary', title: 'Click to View Summary'}},
    ];

export default class ManagePaymentContainer extends LightningElement {
    columns = COLUMNS;
    contacts;
    error;
    contactSelected;

    @wire(getContactsApex)
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contacts = undefined;
        }
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'view_summary':
                console.log('row ', row.Id);
                this.contactSelected = row;
                //contactname = row.Name;
                break;
            default:
        }
    }
}