/**
 * Email validation real-time - format + check exists
 * Dùng cho form đăng ký và các form có input email
 */
(function () {
    var EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    var DEBOUNCE_MS = 400;

    function getBaseUrl() {
        var base = document.querySelector('base');
        return base ? base.href : (window.location.origin + window.location.pathname.replace(/\/[^/]*$/, '/'));
    }

    function checkEmailExists(email, callback) {
        if (!email || !email.trim()) {
            callback({ exists: false, status: 'invalid' });
            return;
        }
        var url = getBaseUrl() + 'api/check-email?email=' + encodeURIComponent(email.trim());
        var xhr = new XMLHttpRequest();
        xhr.open('GET', url, true);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === 4) {
                try {
                    var data = JSON.parse(xhr.responseText);
                    callback(data);
                } catch (e) {
                    callback({ exists: false, status: 'invalid' });
                }
            }
        };
        xhr.send();
    }

    function showError(inputId, errorId, message) {
        var input = document.getElementById(inputId);
        var errorEl = document.getElementById(errorId);
        if (input && errorEl) {
            errorEl.textContent = message || '';
            input.classList.toggle('is-invalid', !!message);
        }
    }

    function initEmailValidation(inputId, errorId, options) {
        options = options || {};
        var input = document.getElementById(inputId);
        var errorEl = document.getElementById(errorId);
        if (!input || !errorEl) return;

        var debounceTimer;
        var lastChecked = '';

        function validate() {
            var email = input.value.trim();
            if (!email) {
                showError(inputId, errorId, '');
                lastChecked = '';
                return;
            }

            if (!EMAIL_REGEX.test(email)) {
                showError(inputId, errorId, options.formatMessage || 'Email không đúng định dạng');
                lastChecked = email;
                return;
            }

            if (email === lastChecked) return;
            lastChecked = email;

            checkEmailExists(email, function (data) {
                if (data.status === 'invalid') {
                    showError(inputId, errorId, options.formatMessage || 'Email không đúng định dạng');
                } else if (data.exists) {
                    showError(inputId, errorId, options.existsMessage || 'Email đã được sử dụng');
                } else {
                    showError(inputId, errorId, '');
                }
            });
        }

        input.addEventListener('input', function () {
            clearTimeout(debounceTimer);
            var email = input.value.trim();
            if (!email) {
                showError(inputId, errorId, '');
                lastChecked = '';
                return;
            }
            if (!EMAIL_REGEX.test(email)) {
                showError(inputId, errorId, options.formatMessage || 'Email không đúng định dạng');
                lastChecked = email;
                return;
            }
            debounceTimer = setTimeout(validate, DEBOUNCE_MS);
        });

        input.addEventListener('blur', function () {
            clearTimeout(debounceTimer);
            validate();
        });
    }

    function hasEmailError(inputId, errorId) {
        var errorEl = document.getElementById(errorId);
        return errorEl && errorEl.textContent.trim() !== '';
    }

    window.initEmailValidation = initEmailValidation;
    window.showFormError = showError;
    window.hasEmailError = hasEmailError;
})();
