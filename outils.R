
# LISTES DE VARIABLES
# Ce sont les listes de variables des données de l'UCI et les cartes pour savoir comment elles
# sont liées à l'interface utilisateur de l'application. Le numéro à droite est le numéro de la colonne
# numéro de colonne dans l'ensemble de données original.

attrs_list = list(
  "pregnant"   = "pregnant",        # 1
  "glucose"    = "glucose",         # 2
  "pressure"   = "pressure",        # 3
  "triceps"    = "triceps",         # 4
  "insulin"    = "insulin",         # 5
  "mass"       = "mass",            # 6
  "pedigree"   = "pedigree",        # 7
  "age"        = "age"              # 8
)

# Ce sont les variables incluses dans le modèle par défaut, choisies pour donner
# des résultats qui ne sont pas déraisonnables mais qui ne sont pas non plus extraordinaires.
attrs_list_default = list(
  "pregnant",
  "glucose",
  "glucose"
)




# FONCTIONS MATHÉMATIQUES
# Les fonctions réalisent les tâches les plus importantes de l'application. Cela comprend
# le travail sur l'arbre de décision réel, mais aussi le calcul de la précision,
# la spécificité, et plus encore.
#############################
# CONSTRUCTION DE MODELE
#############################
makeTree = function(model_vars, min_split, max_depth) {
  # Prend une liste de variables de modèle (chaînes de caractères), un paramètre de fractionnement minimum (int), un paramètre de taille de seau minimum (int) et une profondeur d'arbre maximum.
  # (int), un paramètre de taille minimale du seau (int) et un paramètre de profondeur maximale de l'arbre (int).
  # (int) et une profondeur maximale de l'arbre (int), puis renvoie un arbre de classification rpart.
  # créé avec ces paramètres en utilisant Gini-index sans aucun élagage.
  
  train_dat = read.csv(file = "diab_train.csv", header = TRUE, sep = ",")
  # créer une formule compatible rpart pour le modèle à partir des variables choisies
  f = paste("diabetes ~ ", paste(model_vars, collapse = " + "))
  # rpart effectue les calculs de division et renvoie l'arbre.
  tree = rpart(
    as.formula(f),
    method = "class",  # l'établit comme un problème de classification
    data = train_dat,
    parms = list(split = "gini"),  # assure que rpart utilise les indices gini
    minsplit = min_split,
    maxdepth = max_depth,
    cp = 0  # paramètre de complexité, à zéro empêche l'élagage sur les branches
  )
  
  return(tree)
}

###############################
# Tuning de l'arbre
##############################

tuneTree = function(model_vars, min_split, max_depth, cv, cp){
  
  train_dat = read.csv(file = "diab_train.csv", header = TRUE, sep = ",")
  f = paste("diabetes ~ ", paste(model_vars, collapse = " + "))
  
  
}

#############################
# UTILISATION DE L'ARBRE
#############################
useTree = function(tree, filename) {
  # Prend un arbre généré par rpart et un nom de fichier (chaîne de caractères) en entrée et
  # puis prédit les étiquettes des données dans ce fichier en utilisant l'arbre. Il
  # renvoie un cadre de données avec deux colonnes bool (0,1) : prédiction et vérité.
  
  data = read.csv(file = filename, header = TRUE, sep = ",")
  prediction = predict(tree, data, type = "class")
  results = as.data.frame(prediction)
  results$truth = data$diabetes
  
  return(results)
}

#############################
# CALCUL DES RÉSULTAT
#############################
calcScores = function(results) {
  # Prend un cadre de données de résultats en entrée et calcule ensuite les scores de
  # la précision, le taux de vrais négatifs et le taux de vrais positifs. Il renvoie une
  # liste de chaînes formatées détaillant ces résultats.
  
  results = table(results)
  # calculer les scores sur lesquels nous jugerons notre modèle à 2 décimales près.
  accuracy = round(100 * (results[1] + results[4]) / sum(results), 2)
  true_neg = round(100 * results[1] / sum(results[1, ]), 2)
  true_pos = round(100 * results[4] / sum(results[2, ]), 2)
  
  # L'argument de l'effondrement supprime l'espacement qui existerait autrement.
  return(list(
    paste(c("Précision globale: ",   accuracy, "%"), collapse = ""),
    paste(c("Taux de vrais positifs: ", true_pos, "%"), collapse = ""),
    paste(c("Taux de vrais négatifs: ", true_neg, "%"), collapse = "")
  ))
}

#############################
# AFICHAGE DES RÉSULTAT
#############################
resultsTable = function(results) {
  # Prend un cadre de données de résultats en entrée, puis reconstruit et renvoie
  # un cadre de données dont la disposition est similaire à celle de l'interface de ligne de commande.
  # sortie de la fonction table(...) de R.
  
  data = table(results)
  Resultat = c("Prédit un test négative", "Prédit un test positive", "Totale")
  # reconstruire les colonnes de la table de R(...) CLI display
  c1 = c(data[, 1], sum(data[, 1]))  # data[, 1] est un vecteur de longueur 2
  c2 = c(data[, 2], sum(data[, 1]))  # data[, 2] est un vecteur de longueur 2
  c3 = c(sum(data[, 1]), sum(data[2, ]), sum(data))
  
  # transformer ces colonnes en un cadre de données mais avec des en-têtes appropriés
  output = data.frame(Resultat)
  output$"Négatif" = c1
  output$"Positif" = c2
  output$"Totale"  = c3
  
  return(output)
}




