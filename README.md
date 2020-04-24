# README

[![Coverage Status](https://coveralls.io/repos/github/shawn-higgins1/Shopify-fall2019-code-challenge/badge.svg?branch=master)](https://coveralls.io/github/shawn-higgins1/Shopify-fall2019-code-challenge?branch=master)

[![Build Status](https://travis-ci.com/shawn-higgins1/Image_Browser.svg?branch=master)](https://travis-ci.com/shawn-higgins1/Image_Browser)

This application serves as an image repository that allows users to upload
and manage their images.

You can run this application just like any other rails 6 application. However, you
need to have postregsql installed even in development because sqlite was running
into issue with active storage. For postgresql create a db called imagebrowser_development and specify your postgresql user credentials in the .env file. To create the .env file just copy and rename the sampl.env file and fill in the applicable values. You also need to make sure you have imagemagick installed with support
for all the file types you plan on supporting.
