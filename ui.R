library(shiny)         # création d'une interface utilisateur
library(shinyWidgets) 
source("./outils.R")
#####################################
# FONCTION INTERFACE UTILISATEUR
####################################

# Cette section gère la mise en place de l'interface utilisateur de l'application Shiny,
# tout le texte qui circule dans la page, et affiche les sorties
# de la fonction logique du serveur.

ui = fluidPage(
  # Paragraphe d'introduction de premier niveau
  titlePanel("Application de l'algorithm de CART sur la base de données PimaIndiansDiabetes2"),
  
  br(),
  
  # partitionner le reste de la page en contrôles et sorties
  sidebarLayout(
    sidebarPanel(
      h2("Les outils de contrôle de modèle"),
      br(),
      
      actionButton(
        inputId = "createModel",
        label = "Créer le Modèle",
        class = "btn-primary btn-block" 
      ),
      br(), br(),
      actionButton(
        inputId = "testModel",
        label = "Tester le Modèle",
        class = "btn-danger btn-block"  
      ),
      br(),
      br(),
      h4("Contrôler les attributs"),
      helpText(
        "Choisi les attributs que vous voulez parmis les attributs de jeux de données.",
        "Utilisez le sélecteur déroulant pour les ajoutés"
      ),
      pickerInput(
        inputId = "attrs",
        label = NULL,  # étiquette donnée dans le code extérieur
        choices = attrs_list,
        selected =attrs_list_default,
        options = list(`actions-box` = TRUE),
        multiple = TRUE
      ),
      br(),
      
      h3("L'arbre de Décision"),
      helpText(
        "Ces outils permettent de définir les valeurs des hyperparamètres.",
        "qui contrôlent en partie la structure de l'arbre de décision.",
        "Les valeurs par défaut que nous avons mises en place devraient créer un système assez sûr",
        "mais essayez de les changer si vous vous sentez aventureux.."
      ),
      br(),
      h4("Fractionnement minimum"),
      helpText(
        "Si, à un nœud donné, N est inférieur à cette valeur, ce nœud ne peut pas être utilisé.",
        "ne peut plus être divisé : c'est un nœud terminal de l'arbre."
      ),
      sliderInput(
        inputId = "min_split",
        label = NULL,  # étiquette donnée dans le code extérieur
        min = 2,       # deux est le plus petit qui pourrait être divisé
        max = 20,      # choisi de ne pas rendre les modèles trop sauvages
        value = 20      # Par défaut, il n'y a pas de minimum artificiel.
      ),
      br(),
      h4("Taille minimale du Bucket"),
      helpText(
        "Si la création d'une division donnée a pour effet de faire tomber N₁ ou N₂ en dessous de",
        "ce minimum, alors ce fractionnement ne fait pas partie de la",
        "arbre de décision."
      ),
      sliderInput(
        inputId = "min_bucket",
        label = NULL,  # étiquette donnée dans le code extérieur
        min = 1,       # ne peut pas avoir de Bucket de taille zéro
        max = 30,      # rpart par défaut est minbucket = 3*minsplit
        value = 30     # Par défaut, il n'y a pas de minimum artificiel.
      ),
      br(),
      h4("Profondeur maximale de l'arbre"),
      helpText(
        "Contrôler la profondeur maximale que l'arbre de décision peut atteindre.",
        "Notez que, en fonction des fonctionnalités utilisées et les",
        "valeurs des autres paramètres, vous pouvez vous retrouver avec un arbre",
        "beaucoup moins profond que le maximum."
      ),
      sliderInput(
        inputId = "max_depth",
        label = NULL,  # étiquette donnée dans le code extérieur
        min = 2,       # un minimum de 2 permet au moins un fractionnement
        max = 30,      # rpart ne peut pas faire 31+ de profondeur sur les machines 32-bit
        value = 5      # choisi de ne pas rendre le défaut trop sauvage
      )
    ),
    
    mainPanel(
      # contient les données d'évaluation de la bonté
      h2("Le Tableau des données"),
      dataTableOutput("diab_data"),
      # tracé de l'arbre de décision
      h2("L'arbre de décision"),
      helpText(
        "Il s'agit d'une représentation graphique de l'arbre de décision, le modèle",
        "que vous avez créé ! Pour visualiser comment cela fonctionne, imaginez que nous",
        " ont un email supplémentaire que nous souhaitons classer en utilisant ce ",
        "modèle. Nous commençons par le sommet de l'arbre, que l'on appelle un peu ",
        "contre intuitivement appelé le noeud 'racine'. Ensuite, nous déterminons ",
        "quelle est la réponse à la question de ce noeud pour l'email",
        "à portée de main. Si la réponse est oui, nous descendons vers la gauche et",
        "si la réponse est non, on descend vers la droite, en suivant l'organigramme.",
        "Nous répétons pour chaque nouveau noeud et question que nous atteignons jusqu'à ce que",
        "qu'on arrive à un noeud qui n'a plus d'arêtes vers le bas.",
        "On appelle ça des noeuds terminaux. Si le noeud terminal a un",
        "zéro (bleu) alors cela signifie que le modèle prédit que l'email",
        "n'est pas un spam. Si le noeud terminal a un 1 (rouge) alors le modèle a prédit que l'email", 
        "est un spam"
      ),
      plotOutput(outputId = "tree_plot"),
      br(),
      fluidRow(
        label = NULL,
        column(6,
               h2("Ici les résultat d'entrainement"),
               # la précision de la formation, les vrais positifs et les vrais négatifs
               tagAppendAttributes(
                 textOutput("training_scores"),
                 # autoriser les sauts de ligne entre les scores, police plus grande ici
                 style = "white-space: pre-wrap; font-size: 17px;"
               ),
               br(),
               # le tableau des résultats de formation correspond à la mise en page de la présentation
               tableOutput("training_table")
        ),
        column(6,
               h2("Ici les résultats de Test"),
               # la précision du test, les vrais positifs et les vrais négatifs
               tagAppendAttributes(
                 textOutput("test_scores"),
                 # autoriser les sauts de ligne entre les scores, police plus grande ici
                 style = "white-space: pre-wrap; font-size: 17px;"
               ),
               br(),
               # le tableau des résultats de formation correspond à la mise en page de la présentation
               tableOutput("test_table")
        )
      ),
      
    )
  )
)