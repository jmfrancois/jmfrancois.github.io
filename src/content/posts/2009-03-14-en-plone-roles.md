---
title: Plone and local roles, too quiet.
categories: ["en"]
tags: ["plone"]
date: 2009-03-14
---

I have worked hard on testing/debugging an already developed specific app that handle local roles in a Plone site. I was sure that local roles was just manageable throw a permission but i have finally read the code that handle local roles and understand things:

* you can only add a role to somebody if you have the permission “Change local roles”
* you can only add a role to somebody if you this role in that context
* role are quiet on error (if you don’t have the role you are trying to add, you will not have any log)
* if you have manager role you can do what ever you want (don’t do your tests in manager !!! )
* else candidate local roles are only yours without ‘Anonymous’, ‘Authenticated’ and ‘Shared’
* local roles are stored in a dict called __ac_local_roles__ on the context

After one day of work with local roles, i think the most painful part is to don’t have log, even in debug mode. When a process is called to do a job and it do half of it, i think it has to said something.

But local roles are an essential part of Plone that i really like.

PS: i have discover to late a good module to display local roles in Plone: [zopyx.plone.cassandra](http://pypi.python.org/pypi/zopyx.plone.cassandra).