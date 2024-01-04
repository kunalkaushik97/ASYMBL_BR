import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import generateTimesheetAsPDF from '@salesforce/apex/BR_AsymblTimesheetTriggerHelper.generateTimesheetAsPDF';
import generatePdfWarningNote from '@salesforce/label/c.BR_Generate_PDF_Warning_Note';
import warningLabel from '@salesforce/label/c.BR_Warning_Label';
import generatePDFButtonLabel from '@salesforce/label/c.BR_Generate_PDF_Button_Label';
import cancelButtonLabel from '@salesforce/label/c.BR_Cancel_Button_Label';

export default class GeneratePDFConfirmationModal extends LightningElement {
    @api recordId;
    @api objectApiName;

    label = {
        generatePdfWarningNote,
        warningLabel,
        generatePDFButtonLabel,
        cancelButtonLabel
    };
    
    handleSuccess() {
        generateTimesheetAsPDF({ recordId: this.recordId})
		.then(result => {
            console.log('1');
			this.closeAction();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Timesheet generated successfully',
                    variant: 'success'
                })
            );
		})
		.catch(error => {
            console.log('2');
			this.closeAction();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error,
                    variant: 'error'
                })
            );
		})
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}