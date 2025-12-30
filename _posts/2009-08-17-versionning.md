---
layout: post
title: versioning during release on pypi
categories: en
tags: python

---

Posted in plone, python on August 17, 2009 by toutpt
I often see lots of information about version numbers on release. I would like to explain it. For sure, there are lots of different use cases but here, I speak about code you are writing and want to package.

For me there are 4 parts:

* Major version number
* Feature version indice
* Current level of release
* Status of the release

Major version number is about layout or about backward compatibility. When you change that number it means you have totally changed most things or you have broken the layout because you have made a big mistake and you don't have another choice. For example Zope 2.X.X and Zope 3.X.X.

Feature version indice is all about features. For me this number is increased when you have added feature(s). For example, adding undo/redo to the software.

Current level of release is all about bug fixes. For example, an i18n broken reported by someone.

The status is a character or a word like beta, rc, etc., and is all about release status. The order is:

* alpha (a) often means only for developers, first calls for testing (try to install)
* beta (b) often it is used to call for testing (install and use it)
* candidate (c or rc) means no more bugs reported, just about packaging and last call for testing

I'm sure there are some formal papers around the Internet that explain this a lot better, but I was just wanting to explain my point of view.