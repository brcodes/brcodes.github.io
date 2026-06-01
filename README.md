Freelancer Jekyll theme  
=========================

Jekyll theme based on [Freelancer bootstrap theme ](http://startbootstrap.com/template-overviews/freelancer/)

## How to use
 - Place a image in `/img/portfolio/`
 - Replace `your-email@domain.com` in `_config.yml` with your email address. Refer to [formspree](http://formspree.io/) for more information.
 - Create posts to display your projects. Use the follow as an example:
```txt
---
layout: default
modal-id: 1
date: 2020-01-18
img: cabin.png
alt: image-alt
project-date: January 2020
client: The Client
category: Web Development
description: The description of the project

---
```

## Demo
View this jekyll theme in action [here](https://jeromelachaud.com/freelancer-theme)

## Screenshot
![screenshot](https://raw.githubusercontent.com/jeromelachaud/freelancer-theme/master/screenshot.png)

## Deploy on GitHub Pages
This repository includes a GitHub Actions workflow that builds and deploys the site to GitHub Pages.

1. Push this repo to GitHub.
1. In GitHub, open **Settings > Pages**.
1. Under **Build and deployment**, set **Source** to **GitHub Actions**.
1. In `_config.yml`, set:

```yml
url: "https://<username>.github.io"
baseurl: "" # user site
# baseurl: "/<repo-name>" # project site
```

1. Push to `main` or `master` and wait for the workflow to finish.

Notes:
- The default contact option in this theme is static form submission (`contact: static`), which works on GitHub Pages.
- PHP mail handlers in `/mail` are not executed by GitHub Pages.

---------
For more details, read the [documentation](http://jekyllrb.com/)
