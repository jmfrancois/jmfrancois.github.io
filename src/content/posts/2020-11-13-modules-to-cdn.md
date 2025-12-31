---
title:  "Du fork à la production : Comment module-to-cdn a révolutionné notre build time"
categories: ["fr"]
tags: ["Talend", "JavaScript", "CDN", "UMD", "Webpack"]
date: 2020-11-13
---

La compilation de notre stack Talend/UI prenait des temps énormes et posait des défis majeurs. Découvrez comment le fork de `module-to-cdn` nous a permis de réduire le temps de build de 2 minutes à 10 secondes.

## Le problème : Une stack qui n'échelle pas

Chez Talend, nous avons investi massivement dans Talend/UI, notre design system et nos composants React réutilisables. Avec plus de 15 packages interconnectés, l'architecture est complexe et puissante, mais elle pose un problème majeur : **la compilation de la stack complète prend un temps considérable**.

### Les défis spécifiques

**1. Compilation lente et complexe**

Compiler l'intégralité de la stack Talend/UI requiert des connaissances approfondies en tooling et webpack. Cela demande du temps, des ressources, et crée des goulots d'étranglement dans nos pipelines CI/CD.

**2. Sass dans node_modules**

Nos librairies contiennent du Sass qui se retrouve directement dans le `node_modules` des projets consommateurs. Cela signifie que chaque projet doit avoir sa propre copy et son propre processus de compilation pour le Sass.

**3. Chaque changement est un breaking change**

Quand nous mettions à jour une librairie, les projets consommateurs devaient recompiler entièrement. Pas de compilation incrémentale possible, pas de déploiement indépendant. Chaque fix dans `@talend/components` requérait une recompilation totale dans tous les projets consommateurs.

**4. Évolution du design system et CI/CD**

Notre design system progresse rapidement. L'équipe souhaitait pouvoir déployer des mises à jour en production **via le CDN** sans avoir besoin de recompiler les projets clients. Une véritable approche micro-frontend.

## La recherche de solution

C'est dans ce contexte que nous avons découvert **module-to-cdn**, un package brillant créé par l'équipe de POS Tai.

### Qu'est-ce que module-to-cdn ?

`module-to-cdn` est un utilitaire qui maintient un mapping entre des packages npm et leurs URLs CDN. Par exemple :

```javascript
// Avant
import React from 'react';  // Bundle include dans le build
import ReactDOM from 'react-dom';
import { Button } from '@talend/components';  // 150KB

// Après avec module-to-cdn
// React, ReactDOM, @talend/components pointent sur le CDN
// Taille du bundle : 10KB
```

### Tentatives de contact et décision de forker

J'ai essayé plusieurs fois de contacter l'auteur original pour discuter de nos besoins spécifiques pendant notre POC. Malheureusement, sans réponse. Après plusieurs essais, nous avons pris la décision pragmatique : **forker le package pour l'adapter à nos besoins**.

Nous avons créé un fork officiel dans [Talend/ui-scripts/pull/123](https://github.com/Talend/ui-scripts/pull/123) avec les améliorations nécessaires pour supporter l'architecture complexe de Talend/UI.

## Notre architecture : UMD + Dynamic CDN Webpack Plugin

L'architecture que nous avons mise en place repose sur deux piliers :

### 1. Format UMD pour les librairies

Nos librairies Talend/UI sont compilées en **UMD (Universal Module Definition)** :

```bash
# Compilation de @talend/components en UMD
yarn build:umd
# Produit: talend-components.umd.js (distributables via CDN)
```

Pourquoi UMD ?
- Compatible avec tous les systèmes de module (AMD, CommonJS, ESM)
- Peut être inclus directement dans le HTML via `<script>`
- Peut être utilisé par webpack avec `externals`

### 2. dynamic-cdn-webpack-plugin

Pour intégrer automatiquement le CDN dans le processus webpack, nous utilisons `dynamic-cdn-webpack-plugin` combiné à notre fork de `module-to-cdn`.

Configuration webpack :

```javascript
const DynamicCdnWebpackPlugin = require('dynamic-cdn-webpack-plugin');
const moduleTocdn = require('@talend/module-to-cdn');

module.exports = {
  // ...
  plugins: [
    new DynamicCdnWebpackPlugin({
      modules: moduleTocdn,
      env: 'production'
    })
  ],
  externals: {
    'react': 'React',
    'react-dom': 'ReactDOM',
    '@talend/components': 'TalendComponents',
    '@talend/store': 'TalendStore',
    // ... toutes nos libs Talend
  }
};
```

Cela dit à webpack : "Ces packages ne sont pas à bundler, ils viennent du CDN".

## Le travail d'intégration

Pas mal de travail était nécessaire pour que tout fonctionne :

### 1. Créer le mapping CDN

Il fallait maintenir à jour un mapping complet de toutes nos librairies avec leurs URLs CDN :

```javascript
module.exports = {
  React: {
    name: 'react',
    var: 'React',
    url: 'https://cdn.talend.com/react/16.13.1/react.umd.production.min.js',
    version: '16.13.1'
  },
  'react-dom': {
    name: 'react-dom',
    var: 'ReactDOM',
    url: 'https://cdn.talend.com/react-dom/16.13.1/react-dom.umd.production.min.js',
    version: '16.13.1'
  },
  '@talend/components': {
    name: '@talend/components',
    var: 'TalendComponents',
    url: 'https://cdn.talend.com/talend-components/2.15.0/talend-components.umd.min.js',
    version: '2.15.0'
  },
  // ... et toutes les autres libs
};
```

### 2. Gérer les dépendances circulaires

Nos librairies Talend ont des dépendances complexes. `@talend/components` dépend de `@talend/store`, qui dépend de Redux, etc.

Il fallait s'assurer que dans le HTML, les scripts étaient chargés dans le bon ordre :

```html
<script src="https://cdn.talend.com/react/16.13.1/react.umd.production.min.js"></script>
<script src="https://cdn.talend.com/redux/4.0.5/redux.umd.js"></script>
<script src="https://cdn.talend.com/react-redux/7.2.1/react-redux.umd.js"></script>
<script src="https://cdn.talend.com/talend-store/1.5.0/talend-store.umd.min.js"></script>
<script src="https://cdn.talend.com/talend-components/2.15.0/talend-components.umd.min.js"></script>
```

### 3. Gestion des versions et compatibility

Avec la stack externalisée, chaque version du CDN doit être compatible avec les versions d'autres packages. Nous avons mis en place une stratégie de versioning stricte.

### 4. Tests et validation

Avant de déployer, nous avons dû tester :
- Que les bundles UMD fonctionnent correctement
- Que webpack externalise vraiment les packages
- Que les dépendances sont chargées dans le bon ordre
- Que le fallback marche si le CDN n'est pas disponible

## Les résultats : Gains spectaculaires

Après des semaines de travail, nous avons déployé cette infrastructure en production. Les résultats ont dépassé nos attentes.

### 1. Temps de compilation divisé par 12

**Avant :**
```
$ yarn build
// ... webpack build de toute la stack...
Chunk {0} main.js: 2.4 MB
Compilation time: 2 minutes 15 seconds
```

**Après :**
```
$ yarn build
// ... webpack build sans les packages externes...
Chunk {0} main.js: 180 KB
Compilation time: 10 seconds
```

### 2. Plus de heap stack memory failures

Webpack compilait tellement de code que nous recevions régulièrement des `JavaScript heap out of memory` errors. Avec la stack externalisée, ce problème a complètement disparu.

Avant, nous devions augmenter la limite de heap :
```bash
NODE_OPTIONS="--max-old-space-size=4096" yarn build
```

Maintenant, le build marche sans configuration spéciale.

### 3. Temps d'affichage initial

Pour les utilisateurs, le gain est également spectaculaire :

**Avant (avec tout bundlé) :**
- Download du bundle : 2.4 MB → ~30 secondes
- Parse et compile : ~1 minute 30 secondes
- Total : ~2 minutes

**Après (avec CDN) :**
- Download du bundle principal : 180 KB → ~0.5 secondes
- Download des librairies du CDN (en parallèle) : ~2 secondes (cached après première visite)
- Parse et compile : ~7 secondes
- Total : ~10 secondes

Un gain d'un **facteur 12** !

### 4. Déploiement indépendant du design system

Notre équipe design system peut maintenant déployer des mises à jour vers le CDN sans que les projets consommateurs aient besoin de recompiler.

Un simple changement de version dans le HTML et on bénéficie des nouvelles composants :

```html
<!-- Avant : il fallait recompiler tout le projet -->

<!-- Après : juste changer la version du CDN -->
<script src="https://cdn.talend.com/talend-components/2.16.0/talend-components.umd.min.js"></script>
```

## Architecture finale

```
┌─────────────────────────────────────────────────────────┐
│                     Projects                             │
│  (React apps consommant Talend/UI)                      │
└─────────────────┬───────────────────────────────────────┘
                  │
                  │ (via dynamic-cdn-webpack-plugin)
                  │
┌─────────────────▼───────────────────────────────────────┐
│            Talend CDN                                    │
│  ├── /react/16.13.1/react.umd.min.js                   │
│  ├── /react-dom/16.13.1/react-dom.umd.min.js           │
│  ├── /talend-components/2.16.0/talend-components.js    │
│  ├── /talend-store/1.5.0/talend-store.umd.min.js       │
│  └── ... (toutes les autres libs)                       │
└─────────────────────────────────────────────────────────┘
                  ▲
                  │
┌─────────────────┴───────────────────────────────────────┐
│        Talend/UI Design System                          │
│  Publie les UMD builds vers le CDN                      │
│  Maintient module-to-cdn à jour                         │
└─────────────────────────────────────────────────────────┘
```

## Leçons apprises

### 1. L'importance du fork
Parfois, forker un package est la bonne décision quand vous avez des besoins spécifiques. Ce n'est pas "mal" si vous le faites pour les bonnes raisons.

### 2. UMD est vivant
Malgré les prédictions pessimistes, UMD reste extrêmement pertinent pour les CDN et les micro-frontends.

### 3. La composition plutôt que le bundling
Avec une architecture bien pensée, on peut construire des systèmes complexes en composant des modules plutôt qu'en les bundlant ensemble.

### 4. Le coût de la complexité
Plus vos projets ont de dépendances, plus vous gagnez avec cette approche. Pour un petit projet, ça ne vaut pas le coup. Pour une entreprise avec des dizaines de projets, c'est transformationnel.

## Conclusion

La décision de forker `module-to-cdn` et d'implémenter une architecture CDN basée sur UMD a été l'une de nos meilleures décisions techniques.

Les chiffres parlent d'eux-mêmes :
- **12x plus rapide** pour la compilation
- **Zéro heap memory errors**
- **Déploiement indépendant** du design system
- **Meilleure expérience utilisateur**

Si vous travaillez dans une architecture monorepo complexe avec plusieurs applications consommant une suite de librairies communes, je vous encourage vivement à explorer cette approche.

Et vous, comment gérez-vous vos dépendances partagées ? Avez-vous des expériences avec les micro-frontends à partager ?

---

**Ressources utiles :**
- [module-to-cdn (original)](https://github.com/Parimala-R/module-to-cdn)
- [Notre fork : Talend/ui-scripts/pull/123](https://github.com/Talend/ui-scripts/pull/123)
- [dynamic-cdn-webpack-plugin](https://github.com/mosesman/dynamic-cdn-webpack-plugin)
- [UMD (Universal Module Definition)](https://github.com/umdjs/umd)
