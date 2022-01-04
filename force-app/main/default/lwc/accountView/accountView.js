import getAccounts from '@salesforce/apex/AccountsContoller.getAccounts';
import { LightningElement, track, wire } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import Phone_FIELD from '@salesforce/schema/Account.Phone';
import Revenue_FIELD from '@salesforce/schema/Account.AnnualRevenue';
import saveAccounts from '@salesforce/apex/AccountsContoller.saveAccounts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class AccountView extends LightningElement {
    toggleSaveLabel = 'Save'
    error = '';
    @track accRecords;
    @track refreshAccounts;
    @track deleteAccounts = [];

    @wire(getAccounts)
    accounts(result) {
        if (result.data) {
            this.refreshAccounts = result;
            this.accRecords = [];
            result.data.forEach((element, index) => {
                let accountObject = {};
                accountObject.Id = element.Id;
                accountObject.Name = element.Name;
                accountObject.Phone = element.Phone
                accountObject.key = index;
                accountObject.isNew = false;
                accountObject.AnnualRevenue = element.AnnualRevenue;
                this.accRecords.push(accountObject);
            });
        } else {
            this.error = JSON.stringify(result.error);
        }
    }

    addRow() {
        const len = this.accRecords.length + this.deleteAccounts.length;
        this.accRecords = [...this.accRecords, { Name: NAME_FIELD, Phone: Phone_FIELD, AnnualRevenue: Revenue_FIELD, key: len, isNew:true }]
    }

    removeRow(event) {
        const indexPos = parseInt(event.currentTarget.name);
        let remList = [];

        remList = [...this.accRecords];
        let removed = remList.splice(indexPos, 1);
        this.accRecords = remList;
        console.log(JSON.stringify(this.accRecords));
        let final = this.deleteAccounts.concat(removed);
        this.deleteAccounts = final.filter(ele => (ele.Id !== undefined));
    }

    handleNameChange(event) {
        let foundelement = this.accRecords.find(ele => ele.key == event.target.dataset.id);
        foundelement.Name = event.target.value;
        foundelement.isNew = true;
    }

    accountTempRecords() {
        this.accRecords = [];
        this.accRecords = this.refreshAccounts.data.map(a => Object.assign({}, a));
        console.log(' ==> ' + JSON.stringify(this.originalAccounts));
    }

    handlePhoneChange(event) {
        let foundelement = this.accRecords.find(ele => ele.key == event.target.dataset.id);
        foundelement.Phone = event.target.value;
        foundelement.isNew = true;
        
    }

    handleWebsiteChange(event) {
        let foundelement = this.accRecords.find(ele => ele.key == event.target.dataset.id);
        foundelement.AnnualRevenue = event.target.value;
        foundelement.isNew = true;
    }

    handleSave() {
        const allValid = [...this.template.querySelectorAll(`lightning-input`)].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (!allValid) {
            return;
        }

        this.toggleSaveLabel = 'Saving...'
        let toSaveList = this.accRecords.filter( ele => ele.isNew === true)
        console.log(' Final Save ==> ' + JSON.stringify(toSaveList));
        console.log(' Final Delete ==> ' + JSON.stringify(this.deleteAccounts));

        saveAccounts({ accList: toSaveList,  deleteAcc: this.deleteAccounts })
            .then(() => {
                this.toggleSaveLabel = 'Saved';
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: `Records saved succesfully!`,
                        variant: 'success',
                    }),
                )

                this.deleteAccounts = [];
                this.error = undefined;
                return refreshApex(this.refreshAccounts);
            })
            .catch(error => {
                this.error = error;
                this.record = undefined;
                console.log("Error in Save call back:", JSON.stringify(this.error));
            })
            .finally(() => {
                setTimeout(() => {
                    this.toggleSaveLabel = 'Save';
                }, 3000);
            });
    }

}