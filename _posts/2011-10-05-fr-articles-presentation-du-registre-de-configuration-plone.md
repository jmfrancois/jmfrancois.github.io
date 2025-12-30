---
layout: post
title: Présentation du registre de configuration Plone
categories: fr
tags: plone
---

Le nouveau moteur de configuration est disponible sous forme de module additionnel depuis Plone4:

* [plone.registry](http://pypi.python.org/pypi/plone.registry)
* [plone.app.registry](http://pypi.python.org/pypi/plone.app.registry)
 

Il utilise z3cform comme moteur de formulaire qui sera donc également installé.

Dans les versions précédentes de Plone vous utilisiez le portal_properties
qui est un conteneur de "feuille de propriétés" (propertysheet).
Dans son utilisation vous pouviez ajouter, modifier ou supprimer vos
configurations en ZMI ou via les profils d'installation.
Vous pouviez également accéder à vos propriétés par l'appel à l'API de portal_properties.


Alors pourquoi changer ? Le passage aux composants de Zope date de 2001 avec
l'apparition de Zope3 ; La communauté Plone a fait le choix de ré-écrire
certaines parties de CMF en utilisant les composants dans le plus grand
respect de Zope2. On peut ainsi voir l'ensemble des packages plone.* comme des modules
python/ztk et tous les packages plone.app.* comme leur intégration dans Zope2/CMF.
Au-delà des raisons techniques, l'interface graphique de gestion des configurations s'en trouve améliorée.
On voit aussi disparaître la notion de propertysheet.

# Présentation de plone.registry

Voici la liste des fichiers importants:

* interfaces.py
* registry.py
* recordsproxy.py
* configure.zcml
* field.py
* record.py

## Les interfaces (API)

* IPersistentField
* IRecord
* IRecordProxy
* IRegistry


IPersistentField est un champ persistant. Un champ définit un type de donnée,
par exemple le type nombre entier. Il définit également des métadonnées dessus :
le nom, la description, quelques contraintes comme la valeur minimale par exemple.
La liste des types de champs est disponible sur la documentation officielle ou dans le fichier field.py.
En dehors des champs de type primitif, on retrouve un champ de type référence vers un autre Record.

IRecord est un enregistrement dans le registre de configuration.
Cet objet appartient donc au registre et garde un pointeur vers celui-ci via l'attribut __parent__.
L'attribut field correspond à une instance de IPersistentField et l'attribut value correspond à la valeur de votre configuration.

IRecordProxy est utilisé dans le cadre de l'utilisation de schéma de configuration.
Un schéma de configuration est une interface (zope.interface.Interface) ayant des champs (zope.schema).
C'est l'approche que je privilégie dans mes implémentations car elle est très claire, orientée objet et facile à utiliser.
Donc un RecordProxy est un objet qui peut implémenter dynamiquement un schéma de données.
Les accès au valeur se font alors par les attributs de l'instance.

IRegistry est le chef d'orchestre.
C'est le composant que vous allez demander via l'utilisation de queryUtility.
Il est le conteneur des enregistrements et dispose d'une API permettant d'accéder à la configuration de différentes manières :

* clé/valeur
* record proxy
 

# Intégration au CMS (plone.app.registry)

Maintenant que vous avez compris la base de ce module nous allons passer à la partie CMS.

L'intégration réalisée met à disposition un registre au niveau du site accessible par le panneau de configuration sous le nom 'Registre de configuration'.
Il se présente sous la forme d'un tableau clé, valeur.
Chaque clé est affichée sous la forme d'un lien qui ouvrira un 'overlay' contenant un formulaire qui vous permettra de modifier les valeurs

![screenshot of the plone.app.registry controlpanel]({{ site.url }}/assets/imgs/plone-app-registry-edit-field.png)

# Utilisation (développeur & intégrateur)

Qui dit configuration dit aussi profil de configuration.
Lors de l'installation de votre module vous souhaitez disposer d'une configuration.
Voici la marche à suivre.

## Définition et initialisation de la configuration

Il faut commencer par créer un schéma de données comme par exemple :

    from zope.interface import Interface
    from zope import schema
    class IZooSettings(Interface):
        entryPrice = schema.Decimal(title=u"Admission charge")
        messageOfTheDay = schema.TextLine(title=u"A banner message", default=u"Welcome!")

Ajouter un fichier registry.xml dans le profile d'installation de votre module:

    <registry>
      <record interface="my.package.interfaces.IZooSettings" prefix="my.package"/>
    </registry>

Vous pouvez installer votre module pour qu'il bénéficie de la configuration correspondante.
Les clés auront toutes la forme "my.package." via l'utilisation de l'option prefix.

Les valeurs par défaut de l'interface seront utilisées à la création de votre configuration.
Vous pouvez cependant outre passer cela de la manière suivante et proposer d'autres valeurs dans le profile de configuration:

    <registry>
      <record interface="my.package.interfaces.IZooSettings" prefix="my.package">  
        <value key="entryPrice">70</value>
      </record>
    </registry>


C'est pratique lorsque vous effectuez une intégration de plusieurs modules et que vous souhaitez proposer une autre configuration que celle par défaut d'un module X ou Y.

Vous pouvez également demander au registre de ne pas prendre en compte certains champs de votre interface :

    <records interface="my.package.interfaces.IZooSettings">
      <omit>messageOfTheDay</omit>
    </records>
 

## Utilisation de la configuration

 

Nous pouvons maintenant apprendre à utiliser cette configuration.
Vous pouvez récupérer votre configuration sous deux formes.
Soit vous continuez avec un objet correspondant aux schémas de données que plone.registry se charge de construire pour vous avec la classe Record, soit vous décidez d'utiliser la configuration sous forme de dictionnaire Python (clé ; valeur)

La base est toujours la même :


    from zope import component
    from plone.registry.interfaces import IRegistry
    from my.package import interfaces
    
    ...
    
    def mymethod():
        registry = component.getUtility(IRegistry)
        #access par cle/valeur
        entryPrice = registry['my.package.entryPrice']
        #access par recordproxy
        zooSettings = registry.forInterface(interfaces.IZooSettings, check=False)
        if zooSettings is not None:
            entryPriceBis = zooSettings.entryPrice

Le paramètre "check=False" permet de ne rien retourner si le registre ne dispose pas des enregistrements correspondant à l'interface.
Dans le cas contraire une exception "KeyError" est soulevée et vous devez donc la gérer avec les instructions python try/except.


## Création d'un panneau de configuration de votre module additionnel

Il est toujours pratique pour un administrateur de site de disposer d'un panneau de configuration de votre module additionnel.
L'intégration de plone.registry dans le CMS met à disposition la base nécessaire pour pouvoir réaliser un panneau de configuration très rapidement.
Pour commencer vous devez créer un fichier controlpanel.py avec ce code:

    from plone.app.registry.browser import controlpanel as basepanel
    from plone.z3cform import layout
    from my.package import interfaces
    from my.package import messageFactory as _
    
    class ZooControlPanelForm(basepanel.RegistryEditForm):
        schema = interfaces.IZooSettings
    
    ZooControlPanelView = layout.wrap_form(ZooControlPanelForm, ControlPanelFormWrapper)
    
    ZooControlPanelView.label = _(u"Zoo settings")


Dans votre fichier configure.zcml il faut maintenant ajouter la vue correspondante:

    <browser:page
      name="zoo-controlpanel"
      for="Products.CMFPlone.interfaces.IPloneSiteRoot"
      permission="cmf.ManagePortal"
      class=".controlpanel.ZooControlPanelView"
    /> 


Dans le profile d'installation vous devez également déclarer la "configlet" pour que votre vue soit accéssible à partir du panneau de contrôle:

    <?xml version="1.0"?>
    <object
      name="portal_controlpanel"
      xmlns:i18n="http://xml.zope.org/namespaces/i18n"
      i18n:domain="my.package">
    
      <configlet
        title="Zoo settings"
        action_id="my.package.zoosettings" 
        appId="my.package"
        category="Products"
        condition_expr=""
        url_expr="string:${portal_url}/@@zoo-controlpanel"
        icon_expr="string:${portal_url}/++resource++my.package/icon.png"
        visible="True"
        i18n:attributes="title">
          <permission>Manage portal</permission>
      </configlet>
    
    </object>
 

La classe RegistryEditForm définie les méthodes "updateFields" et "updateWidgets" qui vous permette d'intervenir sur la construction du formulaire, pour par exemple changer le widgetFactory d'un champs ou encore changer les paramètres d'un widget comme par exemple le paramètre rows d'un champs texte.

Disponible sous forme de module additionnel pour Plone 4 ce module est déjà largement utilisé.

