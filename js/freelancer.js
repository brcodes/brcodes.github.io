/*!
 * Start Bootstrap - Freelancer Bootstrap Theme (http://startbootstrap.com)
 * Code licensed under the Apache License v2.0.
 * For details, see http://www.apache.org/licenses/LICENSE-2.0.
 */

// jQuery for page scrolling feature - requires jQuery Easing plugin
$(function() {
    $('.page-scroll a').bind('click', function(event) {
        var $anchor = $(this);
        var $collapse = $('#bs-example-navbar-collapse-1');

        function doScroll() {
            var navbarHeight = $('.navbar-fixed-top').outerHeight() || 0;
            $('html, body').stop().animate({
                scrollTop: $($anchor.attr('href')).offset().top - navbarHeight
            }, 700, 'easeInOutExpo');
        }

        if ($collapse.hasClass('in')) {
            // Menu fully open — collapse it first, then scroll.
            $collapse.one('hidden.bs.collapse', doScroll);
            $collapse.collapse('hide');
        } else if ($collapse.hasClass('collapsing')) {
            // Bootstrap already started collapsing (removed 'in' before our
            // handler ran) — just wait for it to finish, then scroll.
            $collapse.one('hidden.bs.collapse', doScroll);
        } else {
            // Menu is closed — scroll immediately.
            doScroll();
        }

        event.preventDefault();
    });
});

// Floating label headings for the contact form
$(function() {
    $("body").on("input propertychange", ".floating-label-form-group", function(e) {
        $(this).toggleClass("floating-label-form-group-with-value", !! $(e.target).val());
    }).on("focus", ".floating-label-form-group", function() {
        $(this).addClass("floating-label-form-group-with-focus");
    }).on("blur", ".floating-label-form-group", function() {
        $(this).removeClass("floating-label-form-group-with-focus");
    });
});

// Highlight the top nav as scrolling occurs
$('body').scrollspy({
    target: '.navbar-fixed-top'
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
$('.navbar-collapse ul li a').click(function() {
    $('.navbar-toggle:visible').click();
});

// Portfolio modal close policy:
// - Close on modal image click
// - Close on explicit close button (X)
// - Do not close on backdrop click or keyboard (Esc)
$(function() {
    $('.portfolio-modal').modal({
        backdrop: 'static',
        keyboard: false,
        show: false
    });

    $(document).on('click', '.portfolio-modal .modal-body img', function() {
        $(this).closest('.modal').modal('hide');
    });
});

