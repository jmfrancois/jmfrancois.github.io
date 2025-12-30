---
layout: post
title: Private Pypi setup
categories: en
tags: python

---

I have succeeded in setting up a full private PyPI. So I want to share this.

First you need to install a Plone on a server with [Plone software center](http://pypi.python.org/pypi/Products.PloneSoftwareCenter). Our system administrators have set up DNS to this Plone with Apache + HTTP auth + SSL (https) and have given me one login/password.

Next you need to add a new software center to the content of your site. You can also change the base workflow of a project to be approved by default.

The final step for the server is to add a user at the root of Zope with the same user/password as HTTP auth

Now you are ready for the next step: set up your environment on your computer. You need to add HTTP auth ability to buildout and collective.dist. For this:

* configure the pypirc file like described on plone.org
* Add lovely.buildouthttp extension to your buildout
* Add `.buildout` folder to your home directory if it doesn't already exist
* Add `.buildout/.httpauth` with realm, https://yourdomain, user, password
I have been looking for the 'realm' of my server for 2 hours. So what is a realm? Thanks to Tarek who has taken time to answer me on IRC:

    toupt the realm is the domain the server sends back when you do a challenge
    for instance zope sends "Zope"
    trac sends "trac"
    etc

I have Apache httpd as server, so is it "Apache"? The documentation of lovely.buildouthttp says "My domain" but it still doesn't work. Finally I have found the realm. It was 'Members Only Area'. This is the default Apache realm. This is a good thing to know.

A contribution: add documentation to lovely.buildouthttp, collective.dist and software center. The realm and the user in Zope trick were not easy to find.

The benefits of a private pypi:

* Release private eggs for customers
* Test some eggs before release on pypi and plone.org (fix rest for example)
* Release your last commit on collective to use it now in production
* Learn release process of an egg