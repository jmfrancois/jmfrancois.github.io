---
title: Comment tester un module Plone en 10 minutes
categories: ["fr"]
tags: ["plone"]
date: 2011-09-21
---

# Introduction

Quand on travaille avec un CMS, il est courant de vouloir tester un module
et de ne pas le faire par manque de temps. Ce que vous ne savez peut-être pas,
c'est qu'un module peut être testé en 10 minutes.

## Prérequis

Il faut pour suivre ce tutoriel disposer d'un Python version 2.6 avec
le nécessaire en dépendances (support SSL, tar, zip, libjpeg, ...)

Un autre prérequis est de connaître l'adresse URL du dépôt de code utilisé
pour ce module. Avec Plone vous avez souvent:

* [svn collective](https://svn.plone.org/collective/)
* [github collective](https://github.com/collective)
* un github privé

Sinon ce n'est pas bon signe, votre module ne fait pas partie de la communauté Plone.

# Tutoriel

## Initialisation (2 minutes)

Disons que nous voulons tester collective.galleria

    git clone https://github.com/collective/collective.galleria.git collective.galleria
    python bootstrap.py
    bin/buildout
    bin/instance fg

Si le module ne dispose pas des fichiers buildout.cfg et bootstrap.py c'est assez facile de les ajouter:

    wget http://svn.zope.org/*checkout*/zc.buildout/trunk/bootstrap/bootstrap.py
    wget https://github.com/collective/collective.googledocsviewer/blob/master/buildout.cfg

Il vous reste à modifier le fichier buildout.cfg pour remplacer le contenu
de la variable package-name par le nom du module que vous souhaitez tester
(dans notre cas il faudra mettre collective.lemodule)

## Lecture du code (3 minutes)

Il faut jeter un oeil pour vérifier quelques points:

* setup.py il y a des dépendances ?
* [src/]collective/package/profiles/default/* Qu'est ce que le module installe, un tool ? un type de contenu ? des vues ? ...)
* regarder rapidement le reste du code pour en voir la qualité
* regarder changelog ([docs]/CHANGES.txt, [docs]/HISTORY.txt) pour voir si le module est récent et s'il le développement est actif

## Tester le module

* ajouter un site Plone
* installer le module
* tester les fonctionnalités que vous avez comprises du profil par défaut du module

S'il vous reste un peu de temps, vous pouvez faire la traduction directement et faire un mail sur la liste de diffusion plone-fr.

# Conclusion

On ne prend pas assez le temps de vérifier les dépendances et l'état d'un module.
Le problème, c'est qu'après quand il y a un souci sur la production, c'est bien vous qu'on va venir voir,
et vous serez responsable de ce code.

C'est bien là que le logiciel libre prend tout son sens. En ayant des gens capables de maintenir du code
écrit par quelqu'un qui n'est plus là.
