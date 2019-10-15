# README

[![Coverage Status](https://coveralls.io/repos/github/shawn-higgins1/Shopify-fall2019-code-challenge/badge.svg?branch=master)](https://coveralls.io/github/shawn-higgins1/Shopify-fall2019-code-challenge?branch=master)

[![Build Status](https://travis-ci.com/shawn-higgins1/Shopify-fall2019-code-challenge.svg?branch=master)](https://travis-ci.com/shawn-higgins1/Shopify-fall2019-code-challenge)

This is my solution for the Fall 2019 Shopify Coding Challenge
This application serves as an image repository that allows users to upload
and manage their images.

You can run this application just like any other rails 6 application. However, you
need to have postregsql installed even in development because sqlite was running
into issue with active storage. You also need to install imagemagick with support
for all the files you plan on uploading