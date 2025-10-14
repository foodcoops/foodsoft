// Shared validation utilities for form inputs
class ValidationUtils {
    /**
     * Sets up custom validation messages while keeping browser validation active
     * @param {jQuery} form$ - The form element
     */
    static setupCustomValidation(form$) {
        if (form$.length === 0) return;

        // Keep HTML5 validation active but override messages
        // Don't set novalidate - we want the browser to prevent submission

        // Set up custom validation for quantity inputs only
        form$.find('input[type="number"].goa-quantity').each((_, input) => {
            const input$ = $(input);

            // Set up event handlers for custom validation messages
            input$.on('invalid.customValidation', (e) => {
                e.preventDefault(); // Prevent browser validation popup

                // Apply our custom validation and show message in popover
                ValidationUtils.validateNumericInput(input$, {
                    showInSpanOnly: true // Don't use setCustomValidity for display
                });
            });
        });
    }
    /**
     * Validates a numeric input and sets custom validation messages
     * @param {jQuery} input$ - The input element to validate
     * @param {Object} options - Validation options
     * @returns {boolean} - Whether the input is valid
     */
    static validateNumericInput(input$, options = {}) {
        if (input$.length === 0) return true;

        const inputElement = input$[0];
        const rawValue = input$.val().trim().replace(',', '.');
        const inputValue = parseFloat(rawValue);

        let customMessage = '';

        // Only validate if we have a valid number
        if (rawValue !== '' && !isNaN(inputValue)) {
            // Quantity field validation only
            customMessage = ValidationUtils.validateQuantityField(input$, inputValue);
        }

        // Show validation message in error span (avoid popover conflicts)
        ValidationUtils.showValidationMessage(input$, customMessage);

        // Update visual error span if it exists (keep for backward compatibility)
        if (options.errorSpan$ && options.errorSpan$.length > 0) {
            if (customMessage) {
                options.errorSpan$.text(customMessage).show();
            } else {
                options.errorSpan$.hide();
            }
        }

        // Set custom validation message for browser validation
        // This will be used by the browser to prevent form submission
        if (!options.showInSpanOnly) {
            inputElement.setCustomValidity(customMessage);
        }

        // Return validation state
        return customMessage === '';
    }

    /**
     * Validates a quantity field
     * @param {jQuery} input$ - The quantity input element
     * @param {number} inputValue - The parsed input value
     * @returns {string} - Error message or empty string if valid
     */
    static validateQuantityField(input$, inputValue) {
        // Get validation constraints from HTML attributes
        const maxValue = input$.attr('max') ? parseFloat(input$.attr('max')) : null;
        const minValue = parseFloat(input$.attr('min')) || 0;
        const stepValue = parseFloat(input$.attr('step')) || 1;

        // Check maximum quantity first (highest priority)
        if (maxValue !== null && inputValue > maxValue) {
            return I18n.t('errors.maximum_quantity_error', { max: maxValue });
        }
        // Check minimum value
        else if (inputValue < minValue) {
            return I18n.t('errors.step_error', { min: minValue, granularity: stepValue });
        }
        // Check step/granularity (allow for floating point precision issues)
        else if (stepValue > 0) {
            const remainder = ((inputValue - minValue) % stepValue);
            if (Math.abs(remainder) > 0.0001 && Math.abs(remainder - stepValue) > 0.0001) {
                return I18n.t('errors.step_error', { min: minValue, granularity: stepValue });
            }
        }

        return '';
    }

    /**
     * Shows or hides validation message using error spans (avoids popover conflicts)
     * @param {jQuery} input$ - The input element
     * @param {string} message - The validation message (empty to hide)
     */
    static showValidationMessage(input$, message) {
        if (input$.length === 0) return;

        // Find the error span for this input
        const errorSpan$ = input$.closest('.group-order-input').find('.numeric-step-error');

        if (message) {
            // Show error message in span and add error styling
            if (errorSpan$.length > 0) {
                errorSpan$.text(message).show();
            }
            input$.addClass('validation-error');
        } else {
            // Hide error message and remove styling
            if (errorSpan$.length > 0) {
                errorSpan$.hide();
            }
            input$.removeClass('validation-error');
        }
    }

    /**
     * Hides all validation messages
     */
    static hideAllValidationMessages() {
        $('.validation-error').removeClass('validation-error');
        $('.numeric-step-error').hide();
    }



    /**
     * Sets up validation for a form input
     * @param {jQuery} input$ - The input element
     * @param {Object} options - Validation options
     */
    static setupInputValidation(input$, options = {}) {
        if (input$.length === 0) return;

        // Only set up event handlers, don't trigger validation immediately
        // to avoid recursion when called from existing event handlers
        input$.on('invalid.validationUtils', (e) => {
            e.preventDefault();
            e.stopPropagation();
            ValidationUtils.validateNumericInput(input$, options);
            return false;
        });
    }
}