/*!
 * Start Bootstrap - Freelancer Bootstrap Theme (http://startbootstrap.com)
 * Code licensed under the Apache License v2.0.
 * For details, see http://www.apache.org/licenses/LICENSE-2.0.
 */

// jQuery for page scrolling feature - requires jQuery Easing plugin
$(function() {
    // Patch ScrollSpy.activate once so it can be frozen during programmatic
    // scrolls — prevents intermediate sections being highlighted mid-jump.
    var ScrollSpy = $.fn.scrollspy.Constructor;
    var _origActivate = ScrollSpy.prototype.activate;
    var _scrollspyFrozen = false;
    ScrollSpy.prototype.activate = function(target) {
        if (_scrollspyFrozen) { return; }
        _origActivate.call(this, target);
    };

    $('.page-scroll a').bind('click', function(event) {
        var $anchor = $(this);
        var $collapse = $('#bs-example-navbar-collapse-1');

        function doScroll() {
            var navbarHeight = $('.navbar-fixed-top').outerHeight() || 0;

            // Immediately show the target as active and freeze scrollspy so
            // passing through intermediate sections doesn't flicker highlights.
            $('.navbar-nav>li').removeClass('active');
            $anchor.closest('li').addClass('active');
            _scrollspyFrozen = true;

            $('html, body').stop().animate({
                scrollTop: $($anchor.attr('href')).offset().top - navbarHeight
            }, 700, 'easeInOutExpo', function() {
                _scrollspyFrozen = false;
            });
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

// Scrollspy: offset matches live navbar height so active item switches the
// moment a section reaches the navbar bottom edge.
(function() {
    function applyScrollspy() {
        $('body').scrollspy({
            target: '.navbar-fixed-top',
            offset: ($('.navbar-fixed-top').outerHeight() || 60) + 1
        });
    }
    applyScrollspy();

    // Debounced resize keeps the offset accurate across navbar shrink/grow
    // without hammering scrollspy on every pixel of resize.
    var _spyResizeTimer = null;
    $(window).on('resize', function() {
        clearTimeout(_spyResizeTimer);
        _spyResizeTimer = setTimeout(function() {
            applyScrollspy();
            $('body').scrollspy('refresh');
        }, 150);
    });
}());

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

