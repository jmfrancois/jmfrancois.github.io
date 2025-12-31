---
title: Look at my profile
categories: ["en"]
tags: ["plone"]
date: 2008-04-13
---

First of all, I would like to thank the people who wrote GenericSetup. I'm writing this post because I think profiles are not being used well. They are used like Extensions/Install.py scripts. So what is a profile, and how should it be used?

A profile is about the configuration of portals (portal_xxx inside the ZMI). In that way, I have started by asking myself "what does install/uninstall mean in Plone?" Some answers:

"It's about the Extensions/install.py scripts."
"Like on your computer, you install a software or a library."
Well, there is no sense to the word "install" in the world of Plone. We are talking about the configuration of tools. So CMFPlone/profiles/defaults contains a Plone default configuration. Right?

In that way, extending the default Plone configuration means changing it a bit, adding some directory views in portal_skins, for example.

What happens if you are "installing" 20 products to your configuration? Here it is! You have lost the configuration of your Plone project and will not be able to understand why this new product you are trying to install breaks your website.

Seeing this, I have proposed to add one single profile per project. In that way you control your entire Plone, and if you have a problem, you just have to apply this profile. But that also means you have to write it. Here is how I proceed:

* Install every product you need
* Export all steps
* Adding a new product/egg specially for your project
* Put the results of the exports in it
* Read it
* Add all constraints in it. For example, the order of layers inside skins.xml

This is done, you got it! There is no duplication of files, but integration of products inside Plone configuration (my work). Writing XML is boring? Write them faster by using my Eclipse templates ;)

The next point is about setup handlers. I hate products that add setup handlers just to say "hey, I know how to add a step." I always ask "what is a step for you?" So steps are not the way to call a Python script. If you are tempted to add a step, just use Extension/install.py to put your script. Adding a step makes sense only if you are adding a tool, and you want that tool to be configurable. So you don't add setuphandler.py but you write import/export.py for your tool, and then you add the step with import_step.xml.
Another problem is that the configuration of your Plone project can be different for a production server and a development local server. For example, the mailhost.xml file can be different. In that way, you can extend your profile with just a smaller profile that reconfigures what you need.

This is why I'm laughing when I hear "uninstall profile."

Finally, I don't understand why the portal_quickinstaller is now "aware" of extension profiles. That doesn't help to understand profiles. People will continue to write install/uninstall profiles. If anyone knows why, I'm ready to discuss it.