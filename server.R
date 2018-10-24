# server side

shinyServer(function(input, output) {

###################################################################################################
# statistique exploratoire

    # afficher le jeu de données
    output$dataTable <- renderDataTable({glass}, options = optTabl) # options d'affichage

    # vue d'ensemble du jeu de données
    output$summary <- renderPrint({summary(glass)})

    # répartition des types de verre
    output$Repartition <- renderPlotly({
        ggplot(data = glass, aes(x = Type, fill = Type)) + geom_histogram(stat = "count") + 
            labs(title = "Effectif par type de verre", x = "Type de verre", y = "") +
            optGG + theme(legend.position = "none")
    })

    # boxplot d'une des variables explicatives
    output$boite <- renderPlotly({
        ggplot(data = glass, mapping = aes(x = "", y = get(input$choix_box))) +
            geom_boxplot(fill = "dodgerblue") + labs(title = input$choix_box, y = "") + optGG
    })

    # boxplot d'une des variables explicatives selon le type de verre
    output$boite_type <- renderPlotly({
        ggplot(data = glass, mapping = aes(x = Type, y = get(input$choix_box), fill = Type)) +
            labs(x = "Type de verre", y = "", title = input$choix_box, fill = "") + optGG +
            geom_boxplot() + theme(legend.position = "none")
    })

    # graphiques d'ACP
    output$ACP_inertie <- renderPlotly({
        fviz_screeplot(glassACP, title = "Dimensions factorielles", y = "% d'inertie",
            barfill = c("cadetblue2", "coral", "goldenrod1", "lightgreen", "lightsteelblue1",
                        "slateblue1", "yellowgreen", "tomato", "lightskyblue")
        ) + optGG
    })
    output$ACP_indi <- renderPlot({
        fviz_pca_ind(glassACP, title = "Graphe des individus", label = "none",
            habillage = glass$Type, legend.title = "Type", addEllipses = TRUE
        ) + optGG #+ coord_fixed() # repère orthonormé mais bug
    })
    output$ACP_var <- renderPlotly({
        fviz_pca_var(glassACP, title = "Graphe des variables", labelsize = 6, col.var = "cos2",
            legend.title = "cos²", gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07")
        ) + optGG
    })

    # graphique des corrélations
    output$corr <- renderPlotly({
        ggplot(data = cormat, aes(x = Var2, y = Var1, fill = value)) + geom_tile(color = "white") +
            scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0,
                                 limit = c(-1, 1), space = "Lab", name = "Corrélation") +
            geom_text(aes(x = Var2, y = Var1, label = value), color = "black", size = 3) + 
            labs(x = "", y = "", title = "Matrice des corrélations") + optGG + coord_fixed()
    })

    #graphiques classification
    glassHCPC <- HCPC(glassACP, nb.clust = -1, graph = FALSE)
    output$HCPC_graphe <- renderPlot({
        fviz_cluster(glassHCPC, palette = c("#00AFBB","#E7B800", "#FC4E07"),
            main = "Graphe des groupes", geom = "point", legend.title = "groupes",
        ) + optGG #+ coord_fixed() # repère orthonormé mais bug
    })
    output$HCPC_classe <- renderPrint({glassHCPC$desc.var$quanti})

###################################################################################################
# machine learning

    #graphique de la précision des différentes méthodes mises en oeuvres
    output$comp_Accu <- renderPlotly({
        ggplot(data = X[input$choix_methodes,], mapping = aes(x = methodes, y = accuracy)) +
            optGG + geom_point(size = 2) + coord_flip() + ylim(0, 1) +
            geom_errorbar(mapping = aes(ymin = accuracy - accuracySD, ymax = accuracy + accuracySD),
                          width = .03)
    })

    # graphique d'importance des var de randomForest
    output$var_imp <- renderPlot({plot(varImp(mod_rf))})

###################################################################################################
})
