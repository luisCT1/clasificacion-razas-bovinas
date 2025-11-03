# Clasificador de razas bovinas 

#HOG 
#Random Forest con ranger

# ---- Paquetes ----
library(magick)
library(OpenImageR)
library(ranger)
library(dplyr)
library(tibble)
library(purrr)
library(stringr)
library(ggplot2)
library(tidyr)
library(forcats)
library(DiagrammeR)
library(patchwork)


set.seed(123)

#configuracion inicial
imagenes <- "imagenes"                       
subcarpetas  <- c("BRAHMAN","GUZERAT","HOLSTEIN")
tamano_imagen <- 160 # tamaño estandar de las imagenes 160*160

#cantidad de imagenes por carpeta
datos_por_carpeta <- map(subcarpetas, ~ list.files(file.path(imagenes, .x),
                                   full.names = TRUE,
                                   pattern = "\\.(jpg|jpeg|png)$",
                                   ignore.case = TRUE)) |>
  set_names(subcarpetas)

conteo <- map_int(datos_por_carpeta, length)
conteo

#rutas de imagenes + etiqueta
imagen_etiqueta <- imap_dfr(datos_por_carpeta, ~ tibble(directorio = .x, label = .y)) |>
  mutate(label = factor(label, levels = subcarpetas))

#función HOG 
hog_funcion <- function(directorio, size = tamano_imagen) {
  img <- image_read(directorio) |>
    image_convert(colorspace = "Gray") |>
    image_resize(paste0(size, "x", size, "!"))
  # extraer matriz gris [0..255]
  m <- as.integer(image_data(img, channels = "gray"))
  m <- matrix(m, nrow = size, ncol = size, byrow = TRUE)
  # HOG
  feat <- OpenImageR::HOG(m, cells = 8, orientations = 9)
  as.numeric(feat)
}

# extracción
extraccion <- purrr::map(imagen_etiqueta$directorio, hog_funcion)
X <- do.call(rbind, extraccion)
colnames(X) <- paste0("x", seq_len(ncol(X)))

todos_datos <- dplyr::bind_cols(imagen_etiqueta, tibble::as_tibble(X))

#separación en entrenamiento y prueba por raza (80/20)
todos_datos <- todos_datos %>% mutate(row_id = row_number())

entrenamiento <- todos_datos %>%
  group_by(label) %>%
  slice_sample(prop = 0.8) %>%
  ungroup()

prueba <- dplyr::anti_join(
  todos_datos,
  dplyr::select(entrenamiento, row_id),
  by = "row_id"
)


#-----------------entrenamiento random forest------------
#selección de solo las columnas con las que se va a trabajar
feature_names <- grep("^x\\d+$", names(entrenamiento), value = TRUE)

entrenamiento_rf <- entrenamiento %>%
  dplyr::select(label, all_of(feature_names))

mtry_val <- floor(sqrt(length(feature_names)))

rf <- ranger::ranger(
  formula       = label ~ .,
  data          = entrenamiento_rf,
  num.trees     = 600,
  mtry          = mtry_val,
  probability   = TRUE,
  max.depth = NULL,
  importance    = "impurity",
  seed          = 123
)

#modelo
rf

prueba_rf <- prueba %>%
  dplyr::select(label, all_of(feature_names))

predicion_probabilidad <- predict(rf, data = dplyr::select(prueba_rf, -label))$predictions
pred_clase  <- colnames(predicion_probabilidad)[max.col(predicion_probabilidad)]

resultado <- tibble(
  observado = prueba_rf$label,
  predicho  = factor(pred_clase, levels = levels(prueba_rf$label))
)

#métricas básicas globales y matriz de confusión
library(caret)
confusionMatrix(resultado$predicho, resultado$observado)


#función para predecir la raza de una imagen nueva
predecir_raza <- function(imagen_nueva, modelo = rf,
                          nombres_caracteristicas = feature_names,
                          tamaño_imagen = tamano_imagen,
                          clases = subcarpetas) {
  
  #obtener las características HOG de la imagen
  caracteristicas <- hog_funcion(imagen_nueva, size = tamaño_imagen)
  datos_imagen <- as_tibble(t(caracteristicas))
  colnames(datos_imagen) <- paste0("x", seq_len(ncol(datos_imagen)))
  
  #columnas usadas en el modelo
  datos_imagen <- datos_imagen[, nombres_caracteristicas, drop = FALSE]
  
  #hacer la predicción
  prediccion <- predict(modelo, data = datos_imagen)$predictions
  
  #clase con mayor probabilidad
  raza_predicha <- colnames(prediccion)[which.max(prediccion)]
  probabilidad <- as.numeric(max(prediccion))
  
  list(
    raza_predicha = raza_predicha,
    probabilidad = probabilidad
  )
}

imagen_prueba <- "5.JPG"
resultado <- predecir_raza(imagen_prueba, clases = subcarpetas)

resultado$raza_predicha
round(resultado$probabilidad, 4)


