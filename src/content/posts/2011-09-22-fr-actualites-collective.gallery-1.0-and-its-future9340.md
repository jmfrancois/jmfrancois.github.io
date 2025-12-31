---
title: collective.gallery 1.0 et 2.X
categories: ["fr"]
tags: ["plone", "module", "gallery"]
date: 2011-09-22
---

Je viens juste de sortir la première version officiellement stable 1.0.

Un peu d'histoire pour commencer. Ce module a été commencé en 2009. J'avais choisi Galleriffic comme plugin jQuery pour réaliser une UI parce que c'était le seul à me permettre d'afficher un album ayant plus de 300 photos. Ensuite j'avais choisi Picasaweb comme mode de stockage pour les fonctionnalités et aussi parce que c'est Google.

Aujourd'hui collective.gallery peut afficher des photos fournies par un dossier, une collection, mais aussi par Facebook, Flickr et Picasaweb au travers du type de contenu lien.

Plan pour la 2.0. Faire une super jolie galerie de photos n'est pas chose simple. En effet les photos sont des éléments à tailles fixes alors que Plone propose une interface fluide par défaut. De plus la réalisation d'un site web ne permet pas de prédire la largeur qui sera disponible. Rendre ceci configurable page par page serait juste un enfer pour tout le monde.

C'est pourquoi collective.gallery ne sera pas fourni avec une interface d'affichage dans sa version 2.0. Cependant vous aurez juste à choisir une de celles disponible:

collective.galleriffic
collective.galleria
collective.gallery deviendra donc un fournisseur de photos utilisant les types de contenu de Plone avec une bonne documentation sur comment réaliser une interface graphique rapidement.

