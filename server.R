library(methods)       # analyses à grande échelle
library(rpart)         # création d'arbres de décision
library(rpart.plot)    # tracer les arbres de décision
library(mlbench)
source("./outils.R")
##########################################
# FONCTION LOGIQUE DE SERVEUR
#########################################


data("PimaIndiansDiabetes2", package = "mlbench")
our_data = na.omit(PimaIndiansDiabetes2)
# Cette fonction prend la sortie des fonctions mathématiques ci-dessus et
# les traite pour les afficher dans le cadre de la fonction d'interface utilisateur.
server = function(input, output, session) {
  # RÉACTIONS AUX ÉVÉNEMENTS D'ENTRÉE
  # reconstruit l'arbre à chaque fois que createModel est pressé
  tree = eventReactive(
    eventExpr = input$createModel,
    valueExpr = makeTree(
      model_vars = c(input$attrs),
      input$min_split, input$max_depth
    )
  )
  # régénérer les résultats de la formation chaque fois que l'on appuie sur createModel
  training_results = eventReactive(
    eventExpr = input$createModel,
    valueExpr = useTree(tree(), "diab_train.csv")
  )
  # régénérer les résultats du test chaque fois que l'on appuie sur createModel
  test_results = eventReactive(
    eventExpr = input$testModel,
    valueExpr = useTree(tree(), "diab_test.csv")
  )
  
  # PRÉPARATION DE L'AFFICHAGE DE SORTIE
  # les scores d'évaluation sont chacun regroupés pour être affichés sur une nouvelle ligne
  output$training_scores = renderText(
    paste(calcScores(training_results()), collapse = "\n")
  )
  output$test_scores = renderText(
    paste(calcScores(test_results()), collapse = "\n")
  )
  
  # Les tableaux des ruptures de résultats sont des widgets statiques.
  output$training_table = renderTable(
    resultsTable(training_results()),
    align = "lccc",  # aligner à gauche la première colonne, centrer le reste
    striped = TRUE
  )
  output$test_table = renderTable(
    resultsTable(test_results()),
    align = "lccc",  # alignement à gauche de la première colonne, centrage du reste
    striped = TRUE
  )
  
  # cadre pour un tracé de l'arbre de décision
  output$tree_plot = renderPlot(
    # prp prend une sortie de rpart et la trace (littéralement Plot RPart)
    prp(
      tree(), roundint = FALSE,
      # mettre de l'ordre dans les nœuds et les bords, retirer les étiquettes détaillées
      extra = 0, branch = 0, varlen = 0,
      # colorier les terminaux de positive en rouge, les terminaux de négative en bleu
      box.col = c("cornflowerblue", "tomato")[tree()$frame$yval]
    )
  )
  
  
  output$diab_data = renderDataTable(our_data,options = c(pageLength = 6))
}