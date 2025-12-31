---
title:  "Yarn et les dépendances : Une révolution dans la gestion des packages JavaScript"
categories: ["fr"]
tags: ["Talend", "Yarn", "JavaScript", "MonoRepo"]
date: 2017-06-10
---

Dans le monde JavaScript, la gestion des dépendances a toujours été un défi. Puis est arrivé Yarn, qui a changé la donne. Retour sur cette révolution et ses avantages, particulièrement dans le contexte des mono-repositories.

## L'histoire de Yarn

En octobre 2016, **Facebook**, en collaboration avec **Exponent** (aujourd'hui Expo), **Google** et **Tilde**, annonce la sortie de Yarn. Le projet est principalement mené par **Sebastian McKenzie**, ingénieur chez Facebook et créateur de Babel.

À cette époque, npm (le gestionnaire de packages par défaut de Node.js) souffrait de plusieurs problèmes :
- **Lenteur** : Les installations prenaient un temps considérable
- **Non-déterminisme** : Deux installations successives pouvaient donner des résultats différents
- **Manque de fiabilité** : Les installations échouaient parfois sans raison apparente
- **Problèmes de sécurité** : Peu de vérifications sur l'intégrité des packages

Yarn est né de la frustration de grandes entreprises qui géraient des bases de code massives avec des milliers de dépendances. Facebook, en particulier, avait besoin d'une solution plus robuste pour gérer React, React Native et ses nombreux autres projets open source.

## L'adoption fulgurante

L'adoption de Yarn a été remarquablement rapide :

- **Octobre 2016** : Sortie de Yarn 0.15.1
- **Fin 2016** : Adoption par de nombreux projets majeurs (React, Angular, Ember...)

Chez **Talend**, nous avons adopté Yarn dès janvier car nous souffrions terriblement du manque de stabilite des installations avec NPM et le besoin de faire un monorepo c est fait sentir tres vite pour eviter le lag des releases entre les differents repository.

## Le fichier yarn.lock : Le héros méconnu

Le véritable génie de Yarn réside dans son fichier `yarn.lock`. C'est ce fichier qui garantit le **déterminisme** des installations.

### Comment ça marche ?

Quand vous installez un package avec Yarn, il crée (ou met à jour) un fichier `yarn.lock` qui contient :
- Les versions **exactes** de tous les packages installés
- Les versions de toutes les dépendances transitives
- Les checksums pour vérifier l'intégrité

```yaml
"@babel/core@^7.0.0":
  version "7.12.10"
  resolved "https://registry.yarnpkg.com/@babel/core/-/core-7.12.10.tgz#..."
  integrity sha512-eTAlQKq65zHfkHZV0sIVODCPGVgoo1HdBlbSLi9CqOzuZanMv2ihzY+4paiKr1mH+XmYESMAmJ/dpZ68eN6d8w==
  dependencies:
    "@babel/code-frame" "^7.10.4"
    "@babel/generator" "^7.12.10"
    ...
```

### Pourquoi c'est crucial ?

Imaginez ce scénario classique avec npm (avant npm 5) :

1. Développeur A installe les dépendances : `package.json` spécifie `"lodash": "^4.0.0"`
2. Lodash 4.17.10 est installé
3. Deux mois plus tard, Lodash 4.17.20 sort avec un bug
4. Développeur B clone le projet et installe : il obtient la version 4.17.20
5. L'application ne fonctionne plus chez B mais fonctionne chez A
6. Début d'un long debugging...

Avec `yarn.lock`, ce problème n'existe plus. Les deux développeurs obtiennent **exactement** la même version de chaque package.

## Yarn et les Mono-repositories

C'est dans le contexte des **mono-repositories** que Yarn brille particulièrement. Un monorepo, c'est un repository unique contenant plusieurs projets (souvent appelés "packages" ou "workspaces").

### Le problème avant Yarn Workspaces

Prenons un exemple concret chez Talend. Nous avions :
- Un package de composants UI (`@talend/components`)
- Un package de redux actions (`@talend/actions`)
- Une application consommant les deux

Avant Yarn Workspaces, chaque package avait son propre `node_modules` :

```
monorepo/
├── packages/
│   ├── components/
│   │   └── node_modules/    (React 16.8.0, lodash 4.17.10...)
│   ├── actions/
│   │   └── node_modules/    (React 16.8.0, lodash 4.17.15...)
│   └── app/
│       └── node_modules/     (React 16.8.0, lodash 4.17.20...)
```

Problèmes :
- **Duplication massive** : React installé 3 fois !
- **Versions différentes** : Lodash en 3 versions différentes
- **Espace disque** : Des gigaoctets gaspillés
- **Temps d'installation** : Multiplié par le nombre de packages
- **Conflits de versions** : Difficiles à détecter

### La solution : Yarn Workspaces

Yarn Workspaces (introduit en Yarn 1.0, septembre 2017) résout ces problèmes élégamment.

Configuration dans le `package.json` racine :

```json
{
  "private": true,
  "workspaces": [
    "packages/*"
  ]
}
```

Résultat :

```
monorepo/
├── node_modules/         (UN SEUL node_modules à la racine)
│   ├── react/           (Version unique : 16.8.0)
│   ├── lodash/          (Version unique : 4.17.20)
│   ├── @talend/
│   │   ├── components/  (symlink vers packages/components)
│   │   └── actions/     (symlink vers packages/actions)
├── packages/
│   ├── components/
│   ├── actions/
│   └── app/
└── yarn.lock            (UN SEUL fichier de lock)
```

### Les avantages en pratique

Chez Talend, la migration vers Yarn Workspaces nous a apporté :

1. **Réduction de 70% de l'espace disque** utilisé par node_modules
2. **Installation 3x plus rapide** : Une seule installation au lieu de N
3. **Cohérence garantie** : Impossible d'avoir des versions différentes d'une machine a l'autre
4. **Développement simplifié** : Les changements dans un package sont immédiatement visibles dans les autres
5. **CI/CD optimisé** : Un seul `yarn install` pour tout le monorepo

### Exemple concret

Avant, pour travailler sur `@talend/components` et voir les changements dans l'app :

```bash
cd packages/components
# faire des changements
yarn build
yarn pack
cd ../app
yarn add ../components/talend-components-v1.0.0.tgz
yarn start
```

Avec Yarn Workspaces :

```bash
cd packages/components
# faire des changements
cd ../app
yarn start
# Les changements sont immédiatement visibles ! 🎉
```

## Les autres avantages de Yarn

Au-delà des workspaces, Yarn offre de nombreux autres avantages :

### 1. Performance

- **Installation parallèle** : Yarn télécharge et installe plusieurs packages en parallèle
- **Cache offline** : Une fois un package téléchargé, il est mis en cache
- **Installation déterministe** : Même ordre d'installation = performances prévisibles

Sur notre CI, nous sommes passés de **8 minutes** d'installation (npm) à **2 minutes** (Yarn) !

### 2. Sécurité

Yarn vérifie l'intégrité de chaque package installé grâce aux checksums dans le yarn.lock :

```bash
$ yarn install
[1/4] 🔍  Resolving packages...
[2/4] 🚚  Fetching packages...
[3/4] 🔗  Linking dependencies...
[4/4] 🔨  Building fresh packages...
✨ Done in 2.45s.
```

Si un package a été modifié ou corrompu, Yarn le détecte immédiatement.

### 3. Commandes utiles

Yarn ajoute des commandes pratiques :

```bash
# Voir pourquoi un package est installé
yarn why lodash

# Mettre à jour interactivement
yarn upgrade-interactive

# Lister les packages obsolètes
yarn outdated

# Vérifier les licences
yarn licenses list
```

### 4. Résolution des conflits

Le fichier `yarn.lock` est conçu pour éviter les conflits git :

```yaml
# Structure claire et lisible
"package@version":
  version "exact-version"
  resolved "url"
  integrity "checksum"
  dependencies:
    dep "version"
```

Les conflits de merge sont faciles à résoudre.

## Notre expérience chez Talend

La migration vers Yarn a été un des meilleurs choix techniques que nous ayons faits. Voici quelques chiffres concrets :

- **~15 packages** dans notre monorepo
- **~2000 dépendances** au total
- **Avant Yarn** : 8 minutes d'installation, 4 GB de node_modules
- **Après Yarn** : 2 minutes d'installation, 1.2 GB de node_modules
- **Gain de productivité** : Immédiat et mesurable

## Conclusion

Yarn a apporté une véritable révolution dans l'écosystème JavaScript :
- **Déterminisme** grâce au yarn.lock
- **Performance** avec l'installation parallèle et le cache
- **Workspaces** pour les monorepos
- **Sécurité** avec la vérification d'intégrité

Aujourd'hui, npm a rattrapé une partie de son retard (notamment avec npm 7+ qui supporte les workspaces), mais Yarn reste un choix solide, particulièrement pour les projets complexes et les monorepos.

Si vous n'utilisez pas encore Yarn dans votre projet, je vous encourage vivement à l'essayer. Le gain en fiabilité et en productivité est réel et immédiat.

Et vous, quelle est votre expérience avec Yarn ? Utilisez-vous les workspaces ? N'hésitez pas à partager en commentaire !

---

**Pour aller plus loin :**
- [Documentation officielle Yarn](https://yarnpkg.com/)
- [Yarn Workspaces](https://yarnpkg.com/features/workspaces)
- [Migrating from npm to Yarn](https://yarnpkg.com/getting-started/migration)
