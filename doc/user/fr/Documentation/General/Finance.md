---
title: Trésorier
description: 
published: true
date: 2021-10-03T10:08:32.204Z
tags: 
editor: markdown
dateCreated: 2021-03-21T11:42:04.483Z
---

# Trésorier
Foodsoft dispose de quelques fonctions pour aider à la gestion de la trésorerie de la boufcoop. Ces fonctions sont accessibles seulement aux équipes pour lesquelles les permissions de trésorerie ont été activées.

## Crédits des cellules
Chaque cellule dispose d'un certain montant qui va lui permettre de commander. Pour créditer le compte d'une cellule qui vient d'effectuer un versement, va sur la page *Crédits des cellules*, accessible sous l'onglet *Trésorerie* du menu principal. Tu y verras le récapitulatif des crédits de toutes les cellules. Clique alors sur le bouton *Nouvelle transaction* sur la ligne correspondante à la cellule à modifier, et saisis le montant du versement. Le crédit sera immédiatement disponible pour que la cellule puisse commander.

## Supplément mutualisé
Lors de la configuration de Foodsoft, il est possible d'activer un certain pourcentage de supplément automatique qui sera appliqué à tous les prix, de telle sorte que les commandes génèrent un surplus. Ce surplus peut ensuite permettre de financer divers projets coopératifs, comme la location d'un local par exemple. Il s'agit d'une forme de cotisation proportionnelle à la consommation, qui peut se substituer ou bien venir s'additionner à un système de cotisations fixes périodiques.

## Décompte des commandes
Comme il peut y avoir des changements entre les quantités et les prix des produits commandés et ce qui est effectivement recu, et afin d'éviter tout litige, chaque commande doit être décomptée et validée à la main avant que le coût en soit définitivement ponctionné sur les crédits des cellules. En attendant que ce décompte soit fait, les commandes sont en attente, considérées comme *à décompter*, et les crédits engagés par les cellules sont temporairement bloqués.

Pour effectuer le décompte d'une commande, va sur la page *Décompte des commandes* accessible sous l'onglet *Trésorerie* du menu principal. Tu y verras la liste de toutes les commandes clôturées. Cliquer alors sur le bouton bleu *Décompter* sur la ligne de la commande qui t'intéresse. Si ce bouton est absent, cela signifie que la commande a déjà été décomptée.

Sur la page de décompte, l'encart en haut à droite résume le prix de la commande HT et TTC, ainsi que le montant total décompté aux cellules. Le prix TTC et le montant facturé aux cellules devraient en principe être égaux, de telle sorte que le montant affiché sur la ligne suivante (*Gain de la boufcoop sans supplément*) devrait être égal à zéro. Cependant, il peut arriver qu'il ne le soit pas, pour diverses raisons:

- produits offerts par les fournisseur-e-s mais qu'on décide de décompter quand même aux cellules
- produits qui n'ont pas été livrés, ou dont le prix a changé
- produits refusés, en mauvais état.

Finalement, la dernière ligne indique le gain de la boufcoop en tenant compte du [Supplément mutualisé](#supplément-mutualisé) si il a été configuré.

Si l'état des lieux ne correspond pas à ce qui est souhaité, il va falloir réajuster les choses à l'aide du tableau de droite. Ce tableau récapitule l'ensemble des produits livrés. Tout d'abord, si un produit manque dans le tableau, il faut l'ajouter à l'aide du bouton *Ajouter un produit* en haut à droite. Ensuite, pour chaque produit, en cliquant sur le nom, la répartition entre les cellules telle qu'elle avait été demandée lors de la commande s'affiche. Les quantités peuvent être ajustées en cliquant sur les boutons + et - pour les faire correspondre à ce qui a effectivement été recu par les cellules. Pour cela, il peut être utile de s'aider des commentaires (encart tout en bas à gauche de l'écran), où les cellules ont pu laisser des informations ou des réclamations concernant ce qu'elles ont recu. Si une cellule a récupéré des produits alors qu'elle n'en avait pas commandé, tu peux l'ajouter à la liste grâce au bouton *Ajouter une cellule*.

Une fois tous les produits contrôlés de cette facon, tu peux à ton tour laisser des commentaires dans l'encart *Notes/Remarques* afin de garder traces des éventuels arbitrages que tu as du faire. Tu peux aussi saisir les informations sur la facture payée au-à la fournisseur-e (voir [Factures](#factures). Finalement, clique sur le bouton bleu *Terminer la commande*. Les crédits des cellules seront alors immédiatement débités, et la commande sera définitivement terminée.

## Factures
Foodsoft intègre aussi un outil d'archivage des factures qui peut servir deux objectifs principaux:

- payer les fournisseur-e-s de facon différée en utilisant un compte en banque mutualisé,
- faciliter la comptabilité de la boufcoop, c'est-à-dire le contrôle des recettes et des dépenses pour éviter les détournements et évaluer la viabilité de la coopérative à long terme (par opposition à la trésorerie qui concerne les opérations courantes de paiement et de recettes).

La liste des *factures* est accessible sous l'onglet *Trésorerie* du menu principal. Pour ajouter une facture, le mieux est de le faire au moment du [Décompte des commandes](#décompte-des-commandes), de sorte que la facture reste associée à la commande qui lui correspond. Si cela a été oubliée, ou bien si il y a une facture qui ne correspond pas à une commande (achat de matériel par exemple), tu peux *ajouter une facture* directement en cliquant sur le bouton bleu en haut à droite. Saisis alors les informations concernant la facture. Si elle n'a pas encore été payée, laisse vide le champ *Payée le*.
