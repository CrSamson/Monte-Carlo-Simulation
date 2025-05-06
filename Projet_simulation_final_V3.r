# Clear the environment
rm(list = ls())

# Charger les bibliothèques nécessaires
library(randomForest)
library(rpart)
library(ggplot2)
library(dplyr)
library(tidyr)

# Construire la matrice des scenarios et initiliaser des variables
n_repetitions <- 1000
scenario_PP <- c(500,5)
scenario_PE <- c(500,15)
scenario_GP <- c(2500,5)
scenario_GE <- c(2500,15)
matrix_scenario <- rbind(scenario_PP,scenario_PE,scenario_GP,scenario_GE)
colnames(matrix_scenario) <- c("Taille_observation", "Nombre_predictor")

training_time_arbre <- c()
training_time_foret <- c()

mse_arbre <- c()
mse_foret <- c()

df_scenario <- c()

#PPL, PPQ, PEL, PEQ, GEQ, GEL, GPL, GPQ

for(name in row.names(matrix_scenario)){
  nb_observations <- matrix_scenario[name,][1]
  nb_predictors <- matrix_scenario[name,][2]
  
  for (i in 1:n_repetitions){
    random <- i + 151
    set.seed(random)
    
    # 1.1) Générer les variables independantes et les predicteurs 
    X <- matrix(rnorm(nb_observations * nb_predictors, mean = 0, sd = 1), nrow = nb_observations, ncol = nb_predictors)
    beta <- rnorm(nb_predictors)
    alpha <- rnorm(nb_predictors)
    
    # 1.2) Générer la variable cible y pour la relation lineaire
    y_line <- X %*% beta
    
    # 1.3) Générer la variable cible y pour la relation quadratique
    y_quad <- X^2 %*% alpha + X %*% beta
    
    # 1.4) Diviser les données en train et test (80% train, 20% test) pour le y_line
    train_index <- sample(1:nb_observations, size = 0.8 * nb_observations)
    X_train <- X[train_index, ]
    X_test <- X[-train_index, ]
    y_train_line <- y_line[train_index]
    y_test_line <- y_line[-train_index]
    y_train_quad <- y_quad[train_index]
    y_test_quad <- y_quad[-train_index]
    
    # 1.5) Mesurer le temps d'exécution
    elapsed_time_dt <- system.time({
      
      # 1.6) Entraîner l'arbre de régression
      dt <- rpart(y_train_line ~ ., data = data.frame(X_train, y_train_line))
    })
    
    # 1.7) Calcul du MSE arbre de regression pour la relation linéaire
    y_pred_dt <- predict(dt, newdata = data.frame(X_test))
    mse_dt_line <- mean((y_test_line - y_pred_dt)^2)
    mse_arbre <- c(mse_arbre,mse_dt_line)
    
    # 1.9) Creer le vecteur pour le temps entrainement de l'arbre de regression
    training_time_arbre <- c(training_time_arbre,elapsed_time_dt["elapsed"])
    
    # 2.4) Mesurer le temps d'exécution
    elapsed_time_dt <- system.time({
      
      # 2.5) Entraîner l'arbre de régression
      dt <- rpart(y_train_quad ~ ., data = data.frame(X_train, y_train_quad))
    })
    
    # 2.6) Calcul du MSE arbre de regression
    y_pred_dt <- predict(dt, newdata = data.frame(X_test))
    mse_dt_quad <- mean((y_test_quad - y_pred_dt)^2)
    mse_arbre <- c(mse_arbre,mse_dt_quad)
    
    # 2.7) Creer le vecteur pour le temps entrainement de l'arbre de regression
    training_time_arbre <- c(training_time_arbre,elapsed_time_dt["elapsed"])
    
    df_scenario <- c(df_scenario, paste0(name,"L")) 
    #---------------------------------------------------------------------------------------------------------------------------    
    # 2.4) Calcul pour la foret aleatoire
    
    # 2.0) Mesurer le temps d'exécution pour la foret aleatoire et relation lineaire
    elapsed_time_rf <- system.time({
      
      # 2.1) Entraîner la forêt aléatoire sur le scenario de relation lineaire
      rf <- randomForest(X_train, y_train_line, ntree = 100)
    })
    
    # 2.2) Calcul du MSE foret aleatoire pour la relation lineaire
    y_pred_rf <- predict(rf, newdata = X_test)
    mse_rf_line <- mean((y_test_line - y_pred_rf)^2)
    mse_foret <- c(mse_foret,mse_rf_line)
    
    # 2.3) Creer le vecteur pour le temps entrainement de foret aleatoire
    training_time_foret <- c(training_time_foret,elapsed_time_rf["elapsed"])
    
    # 2.8) Mesurer le temps d'exécution pour la foret aleatoire et relation quadratique
    elapsed_time_rf <- system.time({
      
      # 2.9) Entraîner la forêt aléatoire + relation quadratique
      rf <- randomForest(X_train, y_train_quad, ntree = 100)
    })
    
    # 3.0) Calcul du MSE foret aleatoire
    y_pred_rf <- predict(rf, newdata = X_test)
    mse_rf_quad <- mean((y_test_quad - y_pred_rf)^2)
    mse_foret <- c(mse_foret,mse_rf_quad)
    
    # 3.1) Creer le vecteur pour le temps entrainement de foret aleatoire
    training_time_foret <- c(training_time_foret,elapsed_time_rf["elapsed"])
    
    df_scenario <- c(df_scenario, paste0(name,"Q"))
  }
}


#Contruire un dataframe avec 3 colonnes: scenarios, mse_arbre, mse_foret
#Scenarios : PPL, PPQ, PEL, PEQ, GEQ, GEL, GPL, GPQ
# PPL = Petite taille d'observation, nombre petit de predicteur et relation lineaire
# GEQ =  Grande taille d'observation, nombre eleve de predicteur et relation quadratique


df <- data.frame(Scenarios = df_scenario,
                 MSE_Arbre = mse_arbre,
                 MSE_Foret = mse_foret,
                 Training_time_Arbre = training_time_arbre,
                 training_time_Foret = training_time_foret
)

df <- df %>%
  arrange(desc(substring(Scenarios, 1, 10)), desc(Scenarios))


# Sauvegarder les résultats dans un fichier CSV
write.csv(df, file = "resultats_simulation.csv", row.names = FALSE)

#________________________________________________________________________________________________________
# VISUALISATION
# Charger les résultats à partir du fichier CSV
df_csv <- read.csv("resultats_simulation.csv")


# GRAPH 1 - MSE
# Calculer les moyennes et écarts-types
df_summary <- df_csv %>%
  group_by(Scenarios) %>%
  summarize(mean_MSE_Arbre = mean(MSE_Arbre),
            sd_MSE_Arbre = sd(MSE_Arbre),
            mean_MSE_Foret = mean(MSE_Foret),
            sd_MSE_Foret = sd(MSE_Foret))

# Tracer les moyennes avec des barres d'erreur
ggplot(df_summary, aes(x = Scenarios)) +
  geom_line(aes(y = mean_MSE_Arbre, color = "Arbre")) +
  geom_point(aes(y = mean_MSE_Arbre, color = "Arbre")) +
  geom_errorbar(aes(ymin = mean_MSE_Arbre - sd_MSE_Arbre, ymax = mean_MSE_Arbre + sd_MSE_Arbre, color = "Arbre"), width = 0.2) +
  geom_line(aes(y = mean_MSE_Foret, color = "Forêt")) +
  geom_point(aes(y = mean_MSE_Foret, color = "Forêt")) +
  geom_errorbar(aes(ymin = mean_MSE_Foret - sd_MSE_Foret, ymax = mean_MSE_Foret + sd_MSE_Foret, color = "Forêt"), width = 0.2) +
  labs(title = "Moyennes des MSE avec écart-type",
       x = "Scénarios",
       y = "MSE moyen") +
  scale_color_manual(values = c("Arbre" = "blue", "Forêt" = "green")) +
  theme_minimal()

# GRAPH 2 - TRAINING TIME
# Calculer les temps d'entraînement moyens par scénario pour les deux modèles
df_avg <- df_csv %>%
  group_by(Scenarios) %>%
  summarize(avg_training_time_Arbre = mean(Training_time_Arbre),
            avg_training_time_Foret = mean(training_time_Foret))

# Restructurer les données en format long pour visualiser les 2 modèles sur le même graphique
df_long_avg <- df_avg %>%
  pivot_longer(cols = c(avg_training_time_Arbre, avg_training_time_Foret), 
               names_to = "Model", 
               values_to = "Avg_Training_Time")

# Graphique en barres pour comparer les temps d'entraînement moyens
ggplot(df_long_avg, aes(x = Scenarios, y = Avg_Training_Time, fill = Model)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Comparaison des Temps d'Entraînement Moyens",
       x = "Scénarios",
       y = "Temps d'Entraînement Moyen (secondes)") +
  scale_fill_manual(name = "Modèle", 
                    values = c("avg_training_time_Arbre" = "blue", "avg_training_time_Foret" = "green")) +
  theme_minimal()

tinytex::install_tinytex()
