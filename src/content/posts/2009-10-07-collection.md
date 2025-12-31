---
title: Collection and related items
categories: ["en"]
tags: ["plone"]
date: 2009-10-07
---

Today I have worked on Collection (ATTopic). I have discovered a great feature.

You can use related items to choose first results. It can be very useful to manage a home page. First results are the most important items because they are the most read.

So choosing first items is important and at the same time making the page content change with the website activity is just great!

At the time of writing this post, this feature has a bug: If criteria match related items, they just appear twice. I have reported that bug with a test and a patch here: https://dev.plone.org/plone/ticket/9591. I hope it will be accepted.

It is not finished yet. You can use archetypes.referencebrowserwidget to add order handling to related items. It adds up and down arrows on each related item. So you can move up and down each one of them like in folder listing with items.