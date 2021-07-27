/**
 * Created by erick on 7/27/2021.
 */

import { LightningElement, api, wire, track} from 'lwc';
import getPaymentsApex from '@salesforce/apex/ManagePaymentController.getPaymentsByContact';
import NAME_FIELD from '@salesforce/schema/Payment__c.Name';
import AMOUNT_FIELD from '@salesforce/schema/Payment__c.Amount__c';
import DATE_FIELD from '@salesforce/schema/Payment__c.Payment_Date__c';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const COLUMNS = [
        { label: NAME_FIELD.fieldApiName.label, fieldName: NAME_FIELD.fieldApiName, type: 'text' },
        { label: 'Last Name', fieldName: AMOUNT_FIELD.fieldApiName, type: 'currency', editable: true },
        { label: 'Total Payments Amount', fieldName: DATE_FIELD.fieldApiName, type: 'date', editable: true },

    ];

export default class SummaryContactPayments extends LightningElement {
     @api contactId;
     @api contactName;
     columns = COLUMNS;
     titleCard;
     paymentList = [];
     error;
     wiredContactsResult;
     paymentsDraftValues = [];

     @wire(getPaymentsApex, { contactId: '$contactId' })
     wiredPayments(result) {
         this.wiredContactsResult = result;
         this.titleCard = this.contactName + ' Payments';
         if (result.data) {
             this.paymentList = result.data;
             this.error = undefined;
         } else if (result.error) {
             this.error = result.error;
             this.paymentList = undefined;
         }
     }

     handleSave(event) {
         this.paymentsDraftValues = event.detail.draftValues;
         const recordInputs = this.paymentsDraftValues.slice().map(draft => {
             const fields = Object.assign({}, draft);
             return { fields };
         });
         const promises = recordInputs.map(recordInput => updateRecord(recordInput));
         Promise.all(promises).then(res => {
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'Success',
                     message: 'Records Updated Successfully!!',
                     variant: 'success'
                 })
             );
             this.paymentsDraftValues = [];
             return this.refreshTable();
         }).catch(error => {
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'Error',
                     message: 'An Error Occured!!',
                     variant: 'error'
                 })
             );
         }).finally(() => {
             this.paymentsDraftValues = [];
         });
     }

    async refreshTable() {
        await refreshApex(this.wiredContactsResult);
    }
}