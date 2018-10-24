
# Contexte et Objectif

Ce jeu de données provient du site Kaggle, le membre qui a proposé cette analyse l'a lui même trouvé  sur le site UCI (site de dépôt de jeux de données pour du machine learning).

C'est un jeu de données pour l'identification d'un type de verre.

La variable qu'on veut prédire est la variable **Type de verre** qui décrit l'usage qui est fait du verre et les procédés (flotté ou non) qui ont eu lieu pendant sa fabrication.

L'objectif de cette application est de déterminer le **Type** du verre à partir de sa composition en éléments chimiques grâce au machine learning. 

Nous allons donc réaliser une première analyse exploratoire du jeu de données puis tester et comparer l'efficacité de différentes méthodes de machine learning  grâce au critère de l'**accuracy**.

# Informations sur les variables :

**Unité de mesure** : pourcentage de la masse correspondant à l'oxyde, à part pour RI

 - **RI** : indice de réfraction du verre
 - **Na** : Sodium
 - **Mg** : Magnesium
 - **Al** : Aluminum
 - **Si** : Silicone
 - **K** : Potassium
 - **Ca** : Calcium
 - **Ba** : Baryum
 - **Fe** : Fer
 - **Type de verre** :
    1. verre flotté pour immeuble 
    2. verre non flotté pour immeuble 
    3. vitre flottée pour véhicule 
    4. ~~vitre non flottée pour véhicule~~ *(non présent dans ce jeu de données)*
    5. bocal en verre
    6. vaisselle
    7. verre de lampe frontale

# Jeu de données
