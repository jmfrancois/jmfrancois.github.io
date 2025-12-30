---
layout: post
title: JMeter, improving performance of a Plone web site
categories: en
tags: plone

---

Last week I made a rush to improve the performance of a Plone-based website. For performance testing, I have used JMeter.

JMeter is really nice to use. Just launch its proxy, plug your browser into it, and do your test. Next, you save it as XML and you can edit the test. So you can log in (it supports cookies), you can create content (with a once logic controller), consult content, and stress your server.

What I have learned:

* Do not use `brains` or any object in templates, or you will not be able to cache your logic code in ramcache. Use dicts that contain all strings ready to be displayed in the templates.
* How to use the ram cache
* I can store acl_users in ramcache, and I have been surprised to see the difference. On 5 tabs hitted, I have hit the cache 278 times …
* Archetypes is damnably slow (about one second to set some attributes of an object in a btree and reindexIt)
* CMFPlone.utils.createObjectByType does a reindexObject
* Do not add any index to the portal_catalog, use the binding done by archetype_tool to be able to use other indexes. I'm adding about one catalog tool per custom content type.
* A query on the portal_catalog can take one second if you have, for example, a list of 100 paths (query['path'] = ['/first/path', '/second/path']) and more than 100,000 entries.

I have learned many other things during the last week, but now I'm using stress tests during development.