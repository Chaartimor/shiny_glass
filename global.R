###################################################################################################
# tous objets dans ce fichier sont disponibles dans les 2 côtés : server + user

# fixer le nombre de chiffres après la virgule + largeur du console, cacher les messages d'avertissement
options(digits = 2, width = 200, warn = -1)

library(shiny)

# automatiser l'installation + chargement des packages
# https://stackoverflow.com/questions/4090169/elegant-way-to-check-for-missing-packages-and-install-them
.need <- c("ggplot2", "plotly", # graphique interactif
           "caret", "nnet", "randomForest", # machine learning
           "doParallel", # calcul parallèlisé. NB: `caret` est parallèlisé par défaut
           "FactoMineR", "factoextra") # ACP et classif
.miss <- .need[!(.need %in% installed.packages()[, "Package"])] # packages pas encore installés
if(length(.miss) > 0) install.packages(.miss) # installer
.need <- setdiff(.need, c("nnet", "randomForest")) # ces packages ne sont pas nécessaires à charger
eval(parse(text = paste("library(", .need, ")"))) # charger les packages

###################################################################################################
# préliminaires

# importer le jeu de données
glass <- read.table("assets/glass.csv", header = TRUE, sep = ",") # il faut préciser l'emplacement
glass$Type <- as.factor(glass$Type)

# matrice des corrélation
# http://www.sthda.com/french/wiki/ggplot2-heatmap-d-une-matrice-de-corr-lation-logiciel-r-et-visualisation-de-donn-es
cormat <- round(cor(glass[1:9]), digits = 2)
cormat[lower.tri(cormat)] <- NA # enlever la moitié triangulaire
cormat <- reshape2::melt(cormat, na.rm = TRUE) # `reshape2` vient avec `factoextra`


# ACP
glassACP <- PCA(glass, quali.sup = 10, graph = FALSE)
# HCPC
glassHCPC <- HCPC(glassACP, nb.clust = -1, graph = FALSE) # classif automatique

###################################################################################################
# machine learning

# cluster
grappe <- makeCluster(detectCores(logical = FALSE)) # cœurs physiques réels
registerDoParallel(grappe) # lancer le cluster

# préliminaires
fitControl <- trainControl(method = "repeatedcv", number = 10, repeats = 20)

# stocker les valeurs nécessaires pour faires les graphiques
X <- data.frame(
    methodes = c("1NN","5NN","9NN", "LDA", "nnet 1n", "nnet 5n", "nnet 9n", "rf 1", "rf 5", "rf 9", "svm lin"),
    accuracy = 0, accuracySD = 0,
    stringsAsFactors = FALSE # pour l'argument `choiceNames` de `checkboxGroupInput` dans l'`ui`
)

# kNN
params_knn <- data.frame(k = c(1, 5, 9))
mod_knn <- train(Type ~ ., data = glass, method = "knn", trControl = fitControl, tuneGrid = params_knn)
X[1:3, 2:3] <- list(accuracy = mod_knn$results$Accuracy, accuracySD =  mod_knn$results$AccuracySD)

# LDA
mod_lda <- train(Type ~ ., data = glass, method = "lda", trControl = fitControl)
X[4, 2:3] <- list(accuracy = mod_lda$results$Accuracy, accuracySD =  mod_lda$results$AccuracySD )

# réseau de neurones
params_nnet <- data.frame(size = c(1, 5, 9), decay = .1)
mod_nnet <- train(Type ~ ., data = glass, method = "nnet", trControl = fitControl, trace = FALSE, tuneGrid = params_nnet)
X[5:7, 2:3] <- list(accuracy = mod_nnet$results$Accuracy, accuracySD = mod_nnet$results$AccuracySD)

# random forest
params_rf <- data.frame(mtry = c(1, 5, 9))
mod_rf <- train(Type ~ ., data = glass, method = "rf", trControl = fitControl, tuneGrid = params_rf)
X[8:10, 2:3] <- list(accuracy = mod_rf$results$Accuracy, accuracySD = mod_rf$results$AccuracySD)

# SVM kernel linéaire
params_svm <- data.frame(C = 1)
mod_svm <- train(Type ~ ., data = glass, method = "svmLinear", trControl = fitControl, tuneGrid = params_svm)
X[11, 2:3] <- list(accuracy = mod_svm$results$Accuracy, accuracySD = mod_svm$results$AccuracySD )

stopCluster(grappe)

###################################################################################################

# options graphiques dans ggplot2
optGG <- theme(
    plot.title = element_text(hjust = .5, size = 30),
    axis.title = element_text(colour = "firebrick4", size = 15),
    legend.title = element_text(hjust = .5, size = 20),
    legend.text = element_text(size = 15),
    panel.background = element_rect(fill = "azure2"),
    legend.background = element_rect(fill = "white", colour = "black", size = 0.7, linetype = 1),
    plot.background = element_rect(fill = "grey"),
    panel.grid = element_line(colour = "white")
)

# options d'affichage de tableau du jeu de données
# https://datatables.net/plug-ins/i18n/French
optTabl <- list(
    pageLength = 5, # nombre de lignes à afficher par défaut
    lengthMenu = list(c(5, 15, -1), c("5", "15", "Toutes")), # choisir nombre de lignes à afficher
    language = list( # traduction française
        emptyTable = "Aucune donnée disponible dans le tableau",
        info = "Affichage de l'élément _START_ à _END_ sur _TOTAL_ éléments",
        infoEmpty = "Affichage de l'élément 0 à 0 sur 0 élément",
        infoFiltered = "(filtré de _MAX_ éléments au total)",
        lengthMenu = "Afficher _MENU_ éléments",
        loadingRecords = "Chargement en cours...",
        processing = "Traitement en cours...",
        search = "Rechercher :",
        zeroRecords = "Aucun élément à afficher",
        paginate = list(
            first = "Premier",
            last = "Dernier",
            "next" = "Suivant",
            previous = "Précédent"
        ),
        aria = list(
            sortAscending = ": activer pour trier la colonne par ordre croissant",
            sortDescending = ": activer pour trier la colonne par ordre décroissant"
        )
    )
)
