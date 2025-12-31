---
title: My point of BrowserView
categories: ["en"]
tags: ["plone"]
date: 2008-04-13
---

Since Plone 2.5 has been released, there is a good way to separate logic and presentation from templates, but the use of BrowserView is not used in the same way by developers. I'm trying here to explain my point of view about that component.

A very good presentation of BrowserView is already done by Optilude.

According to my point of view and the MVC pattern, a BrowserView is just a controller. Its role is to prepare data to be displayed, or to trigger a process. Most of the time I'm querying the portal_catalog, redirecting the user, adding status messages, etc.

I like the way portlets are done in Plone 2.5. For me it's the best example of how to use BrowserView.

The other use case of BrowserView is to render the attached template and insert a "view" instance in it. This is a kind of "implicit" behavior that I hate in Zope 2. So you can call it directly by the URL. I don't understand that choice, but Plone 3 uses it in that way. And that does not let you reuse the logic code inside the BrowserView in another template. Controllers are known to be reusable throughout the entire software. So please, use the BrowserView component like a controller.