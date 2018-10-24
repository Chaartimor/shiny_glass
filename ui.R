# user side

# diviser en 3 onglets
shinyUI(fluidPage(title = "Projet Shiny ", theme = "darkly.css", navbarPage(title = "#DataScience",

###################################################################################################
# 1er onglet : présentation générale du jeu de données

tabPanel(title = "Présentation",
    includeMarkdown("assets/presentation.md"),
    dataTableOutput(outputId = "dataTable")
),

###################################################################################################
# 2e onglet : statistique exploratoire

tabPanel(title = "Statistique exploratoire",
    tags$h1("Vue d'ensemble des variables"),
    wellPanel(verbatimTextOutput(outputId = "summary")),
    tags$h1("Répartition des types de verre dans le jeu de données"),
    wellPanel(plotlyOutput(outputId = "Repartition")),
    includeMarkdown("assets/repartition_des_types.md"),
    tags$h1("Exploration des données"),
    # diviser en 3 sous-onglets
    navlistPanel(widths = c(2, 10),

        # 1er sous-onglet
        tabPanel(title = "Visualisation des variables explicatives", fluidRow(
            column(width = 2, wellPanel(
                radioButtons(inputId = "choix_box",
                    choices = colnames(glass)[-10], # exclure la var à expliquer
                    label = "Choisir une variable à représenter :",
                    selected = "Al"
                )
            )),
            column(width = 3, wellPanel(plotlyOutput(outputId = "boite"))),
            column(width = 7, wellPanel(plotlyOutput(outputId = "boite_type")))
        )),

        # 2e sous-onglet
        tabPanel(title = "Résultats d'ACP",
            wellPanel(plotlyOutput(outputId  = "ACP_inertie")),
            includeMarkdown("assets/description_ dim_factorielles.md"),
            wellPanel(plotOutput(outputId  = "ACP_indi", width = "100%")), # non interactif
            includeMarkdown("assets/graphe_individus.md"),
            fluidRow(
                column(width = 6, wellPanel(plotlyOutput(outputId = "ACP_var"))),
                column(width = 6, wellPanel(plotlyOutput(outputId = "corr")))
            )
        ),

        # 3e sous-onglet
        tabPanel(title = "Résultats d'une classification avec les résultats de l'ACP",
            wellPanel(plotOutput(outputId  = "HCPC_graphe")), # non interactif
            includeMarkdown("assets/analyse_groupes.md"),
            fluidRow(
                column(width = 6, wellPanel(verbatimTextOutput(outputId = "HCPC_classe"))),
                column(width = 6, includeMarkdown("assets/caracterisation_groupes.md"))
            )
        )
    )
),

###################################################################################################
# 3e onglet : machine learning

tabPanel(title = "Machine learning",
    tags$h1("Sélection du meilleur modèle de prédiction"),
    fluidRow(
        column(width = 2,
            checkboxGroupInput(inputId = "choix_methodes",
                label = "Choix des méthodes d'apprentissage",
                choiceNames = X$methodes,
                choiceValues = 1:nrow(X),
                selected = 1
            )
        ),
        column(width = 7, wellPanel(plotlyOutput(outputId = "comp_Accu")))
    ),
    
    actionButton(inputId = "click",
        label = "Avez-vous trouvé le meilleur modèle ?",
        width = "auto", icon = icon("cogs")
    ),
    conditionalPanel(condition = "input.click > 0", # button cliqué
        tags$h1("Importance des variables dans la construction du modèle rf 1"),
        fluidRow(column(width = 7, offset = 2, wellPanel(plotOutput(outputId = "var_imp"))))
    )
)

###################################################################################################
)))
