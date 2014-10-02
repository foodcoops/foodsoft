=========
Commander
=========

L'idée générale
===============

Le principe de foodsoft est que pour recevoir leurs produits, les cellules s’associent pour passer des **commandes**
aux fournisseur-e-s. Voilà comment ça se passe :

- une liste de commande correspondant à un-e fournisseur-e, par exemple ‘Sucre et services’, est d’abord mise en ligne par un-e membre de la boufcoop,
- cette liste reste accessible pendant un certain temps à tou-te-s les membres, qui peuvent choisir la quantité des différents produits qu’illes souhaitent commander,
- à la date prévue, la commande est clôturée, on ne peut plus la modifier,
- une personne se charge alors de récupérer les quantités de chaque produit et de contacter le-la fournisseur-e,
- les produits sont livrés. Il arrive que la livraison ne corresponde pas exactement à la commande (erreurs, produits indisponibles, quiproquos, changement de prix de dernière minute, pertes...).
- les produits sont répartis entre les cellules, en restant au plus proche de leurs souhaits initiaux,
- une personne compare attentivement les quantités effectivement reçues par chaque cellule et leurs commandes, et effectue le **décompte** final de la commande.

Les commandes peuvent donc être dans trois états : **en cours**, **clôturées** ou **décomptées**. La phase de décompte permet
de s’assurer que ce qui est payé par les cellules correspond bien à ce qu’elles ont reçu. Elle est expliquée plus en
détail dans la section :ref:`tresorerie`.
Pour commander, chaque cellule dispose d’un certain crédit. Le crédit actuel de ta cellule est affiché sur ton
tableau de bord. Des informations plus détaillées sont fournies sur la page *Passer une commande*, accessible sous
l’onglet *Commandes* du menu principal. Le crédit y est décomposé en trois parties :

- crédit engagé dans des commandes en cours,
- crédit engagé dans des commandes déjà clôturées, mais pas encore décomptées,
- crédit disponible

Passer une commande
===================

Une fois sur la page *Passer une commande*, accessible sous l’onglet *Commandes* du menu principal, si tu cliques
sur le nom d’un-e fournisseur-e pour le-laquelle il exsite une commande en cours, tu atteris sur la liste de commande. L’encart en haut à gauche réunit quelques informations utiles sur la commande :

- la personne qui a créé la liste,
- la date de clôture prévue, à partir de laquelle la commande ne sera plus modifiable,
- le montant déjà engagé par toutes les cellules sur cette commande,
- le crédit disponible de ta cellule.

Choisir des produits
--------------------

Tu trouveras en dessous de cet encart la liste des produits proposés pour cette commande. Il ne s’agit par forcément
de tous les produits du-de la fournisseur-e, puisque la personne qui crée la liste de commande a eu la possibilité
d’en sélectionner seulement un sous-ensemble (voir :ref:`gestion`).

Pour chaque produit, il te faut choisir le nombre d’unités que tu souhaites commander. L’unité varie suivant le
produit (1kg, 75cl, ...), et est donc indiquée dans la colonne *unité* du tableau (4ème colonne). Le prix d’une unité
est indiqué dans la colonne *prix* (3ème colonne). Pour augmenter ou réduire le nombre d’unités que tu souhaites
pour ta cellule, utilises les boutons + et - de la 6ème colonne (quantité).

Comme les produits sont proposés par le-la fournisseur-e sous forme de lots (voir :ref:`lots`), tant qu’il manque
des unités pour compléter le lot en cours, tu n’est pas sûr-e de recevoir le produit. Ce nombre est affiché dans la
5ème colonne (*Manquant*). Le nombre d’unités que tu n’est pas sûr-e de recevoir apparaît en rouge, tandis que le
nombre qui apparaît en vert est sûr.

Tolérance
---------

La quantité que tu indiques comme *tolérance* est un maximum que tu es prêt-e à recevoir, en plus de la quantité
commandée normalement, au cas où cela permette de compléter un lot au moment de la clotûre de la commande.
Si il n’y a pas de lot à compléter, cette quantité sera simplement ignorée. Le fait de mettre une tolérance non nulle
lors de tes commandes est bénéfique pour l’ensemble de la boufcoop, car cela augmente les chances de compléter
certains lots qui sinon ne pourraient pas être commandés. De plus, cela peut même encourager d’autres personnes
qui ont encore plus besoin du produit que toi à passer commande, car tu leur donneras plus d’espoir que le lot soit
complété.

	**Exemple** :

	La cellule Banane a vraiment besoin de 3 plaquettes de chocolat. Mais le chocolat ne peut être livré
	qu’en lots de 8 plaquettes. Banane commande donc 3 plaquettes, plus une tolérance de 2, le maximum
	qu’elle puisse se permettre de payer, en espérant qu’une autre cellule complète la commande.

	Le lendemain, la cellule Figue voit cela. Elle n’a besoin que d’une seule plaquette, et la commande
	donc. A ce stade, il y a 4 plaquettes en commande ferme, plus une tolérance de 2, donc le lot ne
	peut toujours pas être complété ! Heureusement, la cellule Pomme voit qu’il ne manque que deux
	plaquettes pour compléter le lot, elle est sûre d’avoir son chocolat. Elle en commande trois plaquettes.

	La coop recoit donc 8 plaquettes. Figue et Pomme ont leurs plaquettes commandées, et il en reste donc
	4. Banane recoit donc ses 3 plaquettes, plus 1 en bonus, ce qui entre bien dans sa marge de tolérance.
	Tout le monde est content, alors que si personne n’avait pas indiqué de tolérance, la livraison n’aurait
	peut-être même pas été possible !


.. _gestion:

Gestion des commandes
=====================

La page de *Gestion des commandes* est accessible sous l’onglet *Commandes* du menu principal, mais seulement si
tu fais partie d’une équipe qui y a accès. Cette option peut être configurée par un-e administrat-rice-eur dans les
paramètres de chaque équipe.

Définir une nouvelle commande
-----------------------------

Pour définir une nouvelle commande, clique sur le bouton en haut à droite de la page, et sélectionne le nom d’un-e
fournisseur-e. Tu peux alors choisir les dates d’ouverture et de clôture de la commande, ainsi que les articles que tu
souhaites y faire apparaître. La liste des articles peut être modifiée à partir de l’:ref:`annuaire`. Une
fois la commande créée, elle apparaîtra dans la liste des commande en cours et les cellules pourront commencer à
commander.

Clôture et envoi
----------------

Pour clôturer la commande, clique sur le bouton *Clôturer* à partir de la page *Gestion des commandes*. La date
de clôture est donnée à titre indicatif, les commandes doivent toujours être clôturées manuellement. Une fois la
commande clôturée, tu atteris sur la page de résumé des quantités commandées. Tu peux aussi accéder à cette
page à partir de la *Gestion des commandes*, en cliquant sur le bouton *Afficher* à droite de la commande clôturée
souhaitée.

Le plus pratique pour transmettre la commande au-à la fournisseur-e est le *Fax au format PDF*, accessible depuis le
menu *Télécharger* (même si tu l’envoies par email et non par fax). En effet, le tableau obtenu résume simplement
le nombre de lots à commander pour chaque produit, ainsi que le prix, mais ne fait pas mention de la répartition
entre les cellules (ce qui n’intérresse en général pas le-la fournisseur-e).

Réception et vérification
-------------------------

Une fois la livraison arrivée à bon port, il peut être judicieux de vérifier son contenu afin de prendre en compte
les éventuels changements par rapport à la commande (produits indisponibles, changements de prix...). Le bouton
*Réceptionner* accessible depuis la page de *Gestion des commandes* permet de valider cette étape de vérification.
Le tableau qui s’affiche récapitule les quantités commandées pour chaque produit, et il faut alors saisir dans la
colonne adéquate la quantité effectivement recue après vérification. En cliquant sur le bouton *Modifier*, on peut
même changer le prix de chaque produit si il s’est avéré qu’il y a eu une erreur. Finalement, on peut même ajouter
un produit à la liste si la livraison contient des produits qui n’étaient pas présents dans la liste de commande
(cadeaux, changements de dernière minute...).

Si on le souhaite, il est possible de laisser des commentaires (en bas de la page de gestion de la commande)
pour garder trace de tous ces changements, ce qui pourra être utile lors du décompte et de la facturation (voir
:ref:`tresorerie`).

Répartition entre les cellules
------------------------------

Pour aider à la répartition entre les cellules, le mieux est de télécharger la *Matrice de répartition en PDF*, accessible depuis le menu *Télécharger* sur la page récapitulative de toute commande clôturée. Le fichier PDF que tu
obtiendras est composé d’abord d’un tableau des produits et de leurs quantités, puis d’un grand tableau à double
entrée, dont les colonnes sont les produits, et les lignes sont les articles, avec à l’intersection le nombre d’unités
de chaque produit que doit recevoir la cellule correspondante.

Si il y a des problèmes lors de la répartition, il peut être utile de le noter aussi dans les commentaires de la
commande.

Facturation et décompte
-----------------------

Voir la section :ref:`tresorerie`.

