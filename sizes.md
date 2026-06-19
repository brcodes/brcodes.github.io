# Page Size Modes (Largest → Smallest)

8 distinct layout modes, defined by CSS media query breakpoints in `_includes/css/main.css`.

---

- **Mode 1 — Large Desktop (≥ 1200px)**
  Navbar expands tall on page load and animates to a shorter "shrink" state on scroll (JS-driven). Portfolio grid is 3 columns. Portfolio caption title uses the largest `2.8em` scale.

- **Mode 2 — Medium Desktop (992px – 1199px)**
  Navbar is permanently compact (shrink-size, no expand/animate). 3-column portfolio grid. Caption title drops to `2.33em`. Footer columns stack (≤ 991px stacking kicks in at the upper edge of this range).

- **Mode 3 — Small Desktop / Large Tablet (960px – 991px)**
  Still 3-column portfolio grid. Navbar container drops side padding and removes margins to stop nav items from bunching. Caption title `2.28em` (slightly tighter than mode 2).

- **Mode 4 — Tablet (768px – 959px)**
  Portfolio switches to **2 columns**. Desktop-style horizontal navbar (not hamburger), kept compact. Navbar container padding still reduced (768–991 rule). Caption title grows to `2.66em` (wider cells, fewer items per row). Footer columns start stacking.

- **Mode 5 — Large Phablet (700px – 767px)**
  Below Bootstrap's 768px threshold: hamburger/mobile navbar appears. Section vertical padding shrinks (75px vs 100px). All section headings switch to fixed mobile `px` sizes. Profile pic, hero name, and skills text use mobile CSS variables. Portfolio remains **2 columns** (≥ 640px rule still applies). Caption title `2.33em`.

- **Mode 6 — Medium Phablet (640px – 699px)**
  Still **2-column** portfolio grid. Scroll-to-top button is hidden (`display: none`). Caption title is at its smallest 2-column value: `2.18em`. All mobile navbar/heading rules from mode 5 continue.

- **Mode 7 — Large Phone (480px – 639px)**
  Portfolio drops to **single column**. Scroll-to-top button becomes visible (`display: block`). Caption title `2.33em`. All mobile section/heading rules apply.

- **Mode 8 — Small Phone (< 480px)**
  Single-column portfolio. Caption title at its smallest: `2.23em`. All mobile rules from above apply. This is the baseline/smallest visual state.
