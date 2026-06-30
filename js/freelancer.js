/*!
 * Start Bootstrap - Freelancer Bootstrap Theme (http://startbootstrap.com)
 * Code licensed under the Apache License v2.0.
 * For details, see http://www.apache.org/licenses/LICENSE-2.0.
 */

// Floating label headings for the contact form
document.addEventListener('input', function(e) {
    var group = e.target.closest('.floating-label-form-group');
    if (!group) return;
    group.classList.toggle('floating-label-form-group-with-value', !!e.target.value);
});
document.addEventListener('focusin', function(e) {
    var group = e.target.closest('.floating-label-form-group');
    if (group) group.classList.add('floating-label-form-group-with-focus');
});
document.addEventListener('focusout', function(e) {
    var group = e.target.closest('.floating-label-form-group');
    if (group) group.classList.remove('floating-label-form-group-with-focus');
});

// Shrink navbar on scroll using a lightweight rAF-throttled handler.
(function() {
    var nav = document.querySelector('.navbar-fixed-top');
    if (!nav) {
        return;
    }

    var shrinkAt = 120;
    var resizeIdleMs = 140;
    var ticking = false;
    var resizeTimer = null;

    function updateNavbarState() {
        var scrolledPastThreshold = (window.pageYOffset || document.documentElement.scrollTop) >= shrinkAt;

        if (scrolledPastThreshold) {
            nav.classList.add('navbar-shrink');
        } else {
            nav.classList.remove('navbar-shrink');
        }
        ticking = false;
    }

    function onScroll() {
        if (ticking) {
            return;
        }
        ticking = true;
        window.requestAnimationFrame(updateNavbarState);
    }

    function onResize() {
        if (document.body) {
            document.body.classList.add('is-resizing');
        }

        if (resizeTimer) {
            window.clearTimeout(resizeTimer);
        }

        resizeTimer = window.setTimeout(function() {
            if (document.body) {
                document.body.classList.remove('is-resizing');
            }
            resizeTimer = null;
        }, resizeIdleMs);

        onScroll();
    }

    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', onResize);
    window.addEventListener('orientationchange', onResize);
    updateNavbarState();
})();

// Closes the Responsive Menu on Menu Item Click
document.querySelectorAll('.navbar-collapse ul li a').forEach(function(link) {
    link.addEventListener('click', function() {
        var toggler = document.querySelector('.navbar-toggler');
        if (toggler && getComputedStyle(toggler).display !== 'none') {
            toggler.click();
        }
    });
});

// Portfolio modal close policy:
// - Close on modal image click
// - Close on explicit close button (X)
// - Do not close on backdrop click or keyboard (Esc) [set via data-bs-* in HTML]
document.addEventListener('click', function(e) {
    var img = e.target.closest('.portfolio-modal .modal-body img');
    if (!img) return;
    var modal = img.closest('.modal');
    if (modal) bootstrap.Modal.getInstance(modal).hide();
});

