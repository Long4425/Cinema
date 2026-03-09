(function () {
    function hideMessages() {
        document.querySelectorAll('.cinema-msg').forEach(function (el) {
            setTimeout(function () {
                el.style.transition = 'opacity 0.3s';
                el.style.opacity = '0';
                setTimeout(function () {
                    el.remove();
                }, 300);
            }, 3000);
        });
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', hideMessages);
    } else {
        hideMessages();
    }
})();
