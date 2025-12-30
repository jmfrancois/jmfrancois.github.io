---
layout: post
title: Plone3 & Acceleo, the first step
categories: en
tags: eclipse plone

---


I have worked for a few hours on a simple Plone 2.5 code generator with Acceleo. It is available on the Acceleo SVN:

svn checkout svn://svn.forge.objectweb.org/svnroot/acceleo/trunk/modules/community/uml21/zope/plone/25/org.acceleo.module.pim.uml21.plone25/trunk

This code generator is not finished, but the approach is good enough to start the Plone 3 one. I would like here to explain the purpose of the Acceleo Generator for Plone3 i want to make.I will first explain the problems i have with ArchgenXML.

What i don’t like in AGX:

The license in each source file (I prefer just a license.txt file)
The billion tagged values (I have lost hours here)
The generated code itself doesn't look like the code I would have produced.
The command line
ArgoUML
All the hacks done every where to make the code compatible with two versions of Plone
You can't modify a line of generated code without losing it if you regenerate your code
What I like in AGX:

The way you use UML (copy the model, and then create a simple class diagram, it's done)
The i18nized schema generated with po files
The generated tests
It works on all well known OS (linux, macos, windows)
Lots of documentation
The user code slots are well thought out.
For sure I want to keep all these good points for the project. So here is an overview of what I want:

Easy to install and to use
Running on most OS known
Code template easy to customize (making multiple branches of my own templates)
Do not generate 100% of the code by working hours in your UML diagrams
Be able to take an existing UML and generate only what you want
Another point: generate something only if it saves your time. The best example I have is tagged values from AGX, like Searchable = 1. One tagged value for one line of code! A first piece of advice from Cédric Brun (Obeo) is to not fall into the modelization of the code itself. For example, creating a UML component to generate a Zope component (BrowserView, adapter, etc.). In that case you will lose a lot of time creating your UML diagram, and be obliged to add stereotypes (adapter, etc.). So to follow this advice, I have thought about the idea of using Component diagrams from UML, and I finally don't want to use it, because for me a UML component is not equal to a Zope component. A UML component can be more seen as an egg. I need to think a bit more about that point, but that could be a great aspect to Zope code generation.

Would we need to 'model' workflows and generate them according to a state diagram? Here the point is a bit more complex. In fact, you know that you need to create them to explain to your customers the need to specify workflows by UML. But the permission system in Zope is specific to it, and the state diagram is not supposed to support this (in AGX we use tagged values once more time). And since we use GenericSetup to specify workflows now, the time saved by creating the state diagram for your workflow is negative. So I think we will just generate the states, but not the associated permissions, which are often explained with the diagram in documentation. But I would like to generate the tests associated with workflows. There was a good conference at Naples on that point.

Next, do we force the use of stereotypes to generate stuff or do we do as with AGX, and so force the use of 'stub' stereotype to indicate to the generator that this class is not a content type to generate. I personally prefer the first option. In that way you can take an existing UML diagram, load the Plone 3 profile, and say this package is an egg, this class is an ATContentType.

Well, a good demo package to create is the case from Martin Aspeli's book.

Next time I will publish the UML from which I want Martin's code to be generated.