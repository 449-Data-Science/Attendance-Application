function resizeFrame() {
    if (!window.frameElement) return;
    var activeTab = document.querySelector('.tab-pane.active');
    var navbar = document.querySelector('.navbar');
    var navHeight = navbar ? navbar.offsetHeight : 0;
    var h = activeTab ? activeTab.scrollHeight + navHeight + 20 : document.body.scrollHeight;
    window.frameElement.style.height = h + 'px';
    window.frameElement.style.overflow = 'hidden';
    document.documentElement.style.overflow = 'hidden';
    document.body.style.overflow = 'hidden';
}

// On tab click
document.addEventListener('click', function(e) {
    var tab = e.target.closest('a[data-bs-toggle=\"tab\"], a[data-toggle=\"tab\"]');
    if (tab) {
        setTimeout(resizeFrame, 1000);
    }
});

// When any Shiny output finishes rendering, resize
$(document).on('shiny:value shiny:outputinvalidated', function() {
    setTimeout(resizeFrame, 1000);
});

// Watch for image/plot loads specifically
$(document).on('shiny:idle', function() {
    setTimeout(resizeFrame, 300);
});

setTimeout(resizeFrame, 2000);

// ---- Admin Panel -------------------------------------------------------------

// Pressing Enter in the password box signs in. Shiny debounces text inputs by
// ~250ms, so push the current value to the server first, then click the button.
$(document).on('keydown', '#password', function (e) {
    if (e.key !== 'Enter') return;
    e.preventDefault();
    if (window.Shiny && Shiny.setInputValue) {
        Shiny.setInputValue('password', this.value, { priority: 'event' });
    }
    $('#login').trigger('click');
});

// Eye button: show / hide the password.
$(document).on('click', '.pw-toggle', function () {
    var input = $('#password');
    var reveal = input.attr('type') === 'password';
    input.attr('type', reveal ? 'text' : 'password');
    $(this)
        .toggleClass('is-showing', reveal)
        .attr('aria-label', reveal ? 'Hide password' : 'Show password');
    input.trigger('focus');
});