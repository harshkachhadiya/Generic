import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Reduce Errors
const reduceErrors = (errors) => {

    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter((error) => !!error)
            // Extract an error message
            .map((error) => {

                // UI API read errors
                if (error.body) {
                    if (error.body.duplicateResults && error.body.duplicateResults.length) {
                        return error.body.duplicateResults.map((err) => err.message);
                    }
                    else if (error.body.fieldErrors && Array.isArray(error.body.fieldErrors) && error.body.fieldErrors.length) {
                        return error.body.fieldErrors.map((err) => err.message);
                    }
                    else if (error.body.fieldErrors && Object.keys(error.body.fieldErrors).length) {
                        return Object.entries(error.body.fieldErrors).flatMap(([field, errs]) => errs.map((err) => field + ': ' + err.message));
                    }
                    else if (error.body.pageErrors && Array.isArray(error.body.pageErrors) && error.body.pageErrors.length) {
                        return error.body.pageErrors.map((err) => err.message);
                    }
                    else if (Array.isArray(error.body)) {
                        return error.body.map((err) => err.message);
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                }
                else if (error.detail) {
                    if (error.detail.output.fieldErrors && Object.keys(error.detail.output.fieldErrors).length) {
                        return Object.entries(error.detail.output.fieldErrors).map(([key, value]) => {
                            return value.map((err) => err.message);
                        });
                    }
                    else if (error.detail.detail && typeof error.detail.detail === 'string') {
                        return error.detail.detail;
                    }
                    else if (error.detail.message && typeof error.detail.message === 'string') {
                        return error.detail.message;
                    }
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }

                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter((message) => !!message)
    );
}

// Meant to concatenate a message with reduced errors / seperator value 
const joinErrors = (reducedErrors, seperator) => {
    if (!seperator) {
        seperator = ', ';
    }
    if (Array.isArray(reducedErrors)) {
        reducedErrors = reducedErrors.join(seperator);
    }
    return reducedErrors;
}

// Dispatch Toast Event
const dispatchToastEvent = (title, message, variant, mode = 'dismissable', messageData = []) => {
    dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
            messageData: messageData
        }),
    );
}

const dispatchToastError = (error) => {
    dispatchToastEvent('Error', joinErrors(reduceErrors(error)), 'error');
}

const dispatchToastGeneralError = (error) => {
    dispatchToastEvent('Error', 'There has been an issue; please consult your System Administrator', 'error');
}

const copyToClipboard = (text) => {
    navigator.clipboard.writeText(text)
        .then(() => {
            dispatchToastEvent('Success', 'Details copied successfully.', 'success');
        })
        .catch((error) => {
            dispatchToastError(error);
        });
}

const formatString = (value) => {
    return value ? value : '';
}

const formatNumber = (value, decimalPlaces = 2) => {
    return value
        ? Math.round((parseFloat(value) + Number.EPSILON) * Math.pow(10, decimalPlaces)) / Math.pow(10, decimalPlaces)
        : 0;
}

const formatCurrency = (value) => {
    return new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD',
    }).format(formatNumber(value));
}

const formatDateToDDMMYYYY = (date) => {
    if (date) {
        date = new Date(date);

        return `${String(date.getDate()).padStart(2, '0')}/${String(date.getMonth() + 1).padStart(2, '0')}/${date.getFullYear()}`;
    }

    return '';
}

const formatDateToMMDDYYYY = (date) => {
    if (date) {
        date = new Date(date);

        return `${String(date.getMonth() + 1).padStart(2, '0')}/${String(date.getDate()).padStart(2, '0')}/${date.getFullYear()}`;
    }

    return '';
}

const formatDateToYYYYMMDD = (date) => {
    return (new Date(date)).toISOString().slice(0, 10);
}

const dateAddDays = (date, noOfDays = 0) => {
    if (date) {
        date = new Date(date);

        return date.setDate(date.getDate() + noOfDays);
    }

    return '';
}

const dateAddMonths = (date, noOfMonths = 0) => {
    if (date) {
        date = new Date(date);

        return date.setMonth(date.getMonth() + noOfMonths);
    }

    return '';
}

export {
    reduceErrors,
    joinErrors,
    dispatchToastEvent,
    dispatchToastError,
    dispatchToastGeneralError,
    copyToClipboard,
    formatString,
    formatNumber,
    formatCurrency,
    formatDateToDDMMYYYY,
    formatDateToMMDDYYYY,
    formatDateToYYYYMMDD,
    dateAddDays,
    dateAddMonths
}