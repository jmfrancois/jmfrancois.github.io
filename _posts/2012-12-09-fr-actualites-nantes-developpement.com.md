---
layout: post
title:  Nantes Métropole Développement
categories: fr
tags: réalisation plone
---

C'est en juillet 2010 que j'avais annoncé la nouvelle version du site Internet

[nantes-developpement](http://www.nantes-developpement.com).

Ce projet utilisant beaucoup de modules, je vous fais profiter de ce choix:


* [collective.addthis](https://pypi.python.org/pypi/collective.addthis)

* [collective.picnik](https://pypi.python.org/pypi/collective.picknik)
* [collective.sugarcrm](https://pypi.python.org/pypi/collective.sugarcrm)
* [collective.configviews](https://pypi.python.org/pypi/collective.configviews)
* [collective.gallery](https://pypi.python.org/pypi/collective.gallery)
* [collective.dewplayer](https://pypi.python.org/pypi/collective.dewplayer)
* [collective.portlet.contact](https://pypi.python.org/pypi/collective.portlet.contact)
* [collective.portlet.feedmixer](https://pypi.python.org/pypi/collective.portlet.feedmixer)
* [collective.googleanalytics](https://pypi.python.org/pypi/collective.googleanalytics)
* [nmd.plonelinkasvideoembed](https://pypi.python.org/pypi/nmd.plonelinkasvideoembed)
* [collective.z3cform.norobots](https://pypi.python.org/pypi/collective.z3cform.norobots)
* [qi.portlet.TagClouds](https://pypi.python.org/pypi/qi.portlet.TagClouds)
* [collective.singing & collective.dancing](https://pypi.python.org/pypi/collective.singing)
* [archetypes.uploadreferencewidget](https://pypi.python.org/pypi/archetypes.uploadreferencewidget)
* [babel](https://pypi.python.org/pypi/babel)
* [Products.Maps](https://pypi.python.org/pypi/Products.Maps)
* [Products.PloneFormGen](https://pypi.python.org/pypi/Products.PloneFormGen)
* [Products.TinyMCE](https://pypi.python.org/pypi/Products.TinyMCE)
* [Products.TextIndexNG3](https://pypi.python.org/pypi/Products.TextIndexNG3)
* [Products.CompoundField](https://pypi.python.org/pypi/Products.CompoundField)
* [Products.ZNagios](https://pypi.python.org/pypi/Products.ZNagios)
* [five.grok](https://pypi.python.org/pypi/five.grok)
* [Products.MemcachedManager](https://pypi.python.org/pypi/Products.MemcachedManager)
* [Relstorage](https://pypi.python.org/pypi/Relstorage)
* [plone.app.theming](https://pypi.python.org/pypi/plone.app.theming)
* [plone.app.caching](https://pypi.python.org/pypi/plone.app.caching)
* [plone.app.search](https://pypi.python.org/pypi/plone.app.search)


Ces modules étaient présents dans la version Plone3 mais ont été retirés :

* [collective.groupdashboard](https://pypi.python.org/pypi/collective.groupdashboard)
* [collective.portlet.actions](https://pypi.python.org/pypi/collective.portlet.actions)
* [collective.plonebookmarklets](https://pypi.python.org/pypi/collective.plonebookmarklets)
* [collective.contentlicensing](https://pypi.python.org/pypi/collective.contentlicensing)
* [collective.autopermission](https://pypi.python.org/pypi/collective.autopermission)
* [collective.contentrules.mail](https://pypi.python.org/pypi/collective.contentrules.mail)
* [collective.harlequin](https://pypi.python.org/pypi/collective.harlequin)
* [collective.monkeypatcher](https://pypi.python.org/pypi/collective.monkeypatcher)
* [collective.z3cform.grok](https://pypi.python.org/pypi/collective.z3cform.grok)
* [experimental.contentcreation](https://pypi.python.org/pypi/experimental.contentcreation)
* [experimental.aggressiveopaquespeedup](https://pypi.python.org/pypi/experimental.aggressiveopaquespeedup)
* [collective.remove.kss](https://pypi.python.org/pypi/collective.remove.kss)
* [collective.remove.kupu](https://pypi.python.org/pypi/collective.remove.kupu)
* [collective.remove.rules](https://pypi.python.org/pypi/collective.remove.rules)
* [Products.CacheSetup](https://pypi.python.org/pypi/Products.CacheSetup)
* [plone.app.ldap](https://pypi.python.org/pypi/plone.app.ldap)
* [iw.fss](https://pypi.python.org/pypi/iw.fss)

# Migrer de Plone3 à Plone4

La migration a été réalisée via un script de prémigration pour préparer la
base de données à la migration, la migration effective du site, puis une migration liée aux modules.

## Retirer iw.fss

Ce ne fut pas le plus simple. Après avoir lu pas mal de mails autour de ça, j'ai adapté un bout de code à mon cas.

{% gist toutpt/6719656 %}

# Theme

Le changement de charte graphique a été l'événement déclencheur de la migration.
Le thème utilise le framework de grille CSS 960 avec le tout nouveau moteur de thème Plone :
plone.app.theming, basé sur Diazo.

C'est mon second thème avec ce moteur. Mon avis est qu'il accélère la création de thèmes simples
mais ne permet pas la création d'un thème complet.

Le besoin de surcharger des templates, des viewlets, de connaître la mécanique
des 'skins directories' et autre 'browser view' reste nécessaire.

# Integration

J'ai testé beaucoup de modules, créé quelques modules, amélioré,
fait des rapports de bugs, mais aussi de l'intégration.

J'ai ajouté l'intégration entre les modules collective.addthis et
collective.googleanalytics pour que tout partage pousse un événement social dans GA.

J'ai découvert le module plone.app.search qui est le moteur de recherche
de la prochaine version de Plone (4.2). L'intégration au projet a été simple,
il m'a suffi d'ajouter Modernizr au registre des javascripts, de modifier
le rendu (simple template) et de modifier les liens dans le livesearch
pour utiliser cette nouvelle version.
Ce nouveau module est bien plus simple que les précédents moteurs de recherche.

Le proxy cache Varnish est utilisé et intégré à l'aide du module plone.app.caching.
J'ai rapporté un bug concernant la fonction afficher/masquer une portlet qui ne fonctionne pas bien avec Varnish.

SugarCRM est utilisé à plusieurs niveaux : authentification, portlet contact,
formulaire de lead (via le module PloneFormGen) et une viewlet affichant
une entreprise et un contact (activé avec un formulaire autocomplete) le tout via le module collective.sugarcrm.

TinyMCE 1.3 est utilisé dans sa version développement et utilise ici une modification :
la configuration n'est pas la même pour un administrateur de site que pour un contributeur.
Vous trouverez le master sur GitHub.

Les galeries (diaporamas) sont affichées avec le module collective.gallery et
un affichage basé sur le plugin jQuery ad-gallery, en utilisant Picasaweb comme base d'albums photos.
