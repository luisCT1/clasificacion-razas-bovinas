# 🐄 Clasificador de Razas Bovinas (HOG + Random Forest con ranger)

Este proyecto es un **ejemplo práctico de aplicación de Inteligencia Artificial en producción animal**, orientado a la **clasificación automática de razas bovinas** a partir de imágenes.
El objetivo es mostrar cómo combinar la **visión por computadora** y **aprendizaje automático clásico** en **R** para clasificar imagenes de razas bovinas (Brahman, Guzerat y Holstins, integrando **HOG (Histogram of Oriented Gradients)** y el modelo **Random Forest** mediante el paquete `ranger`.

---

## 🎯 Objetivos del proyecto

* Demostrar cómo aplicar IA en problemas reales de producción animal.
* Implementar un algoritmo de clasificación de imágenes completamente en R.
* Evaluar el desempeño de un modelo clásico de Bosques Aleatorios la clasificación de imagenes.
* Mostrar resultados reproducibles y fáciles de adaptar a nuevos contextos (otras razas, animales o especies).

---

## 📦 Requisitos

* **R ≥ 4.1** (recomendado)
* Paquetes de R necesarios:

  * `magick`, `OpenImageR`, `ranger`, `dplyr`, `tibble`, `purrr`, `yardstick`,
    `stringr`, `ggplot2`, `tidyr`, `forcats`, `DiagrammeR`, `patchwork`,
    `caret`, `gt`

Instala todos los paquetes de una vez:

```r
pkgs <- c(
  "magick","OpenImageR","ranger","dplyr","tibble","purrr","yardstick",
  "stringr","ggplot2","tidyr","forcats","DiagrammeR","patchwork","caret","gt"
)
to_install <- setdiff(pkgs, rownames(installed.packages()))
if (length(to_install)) install.packages(to_install, dependencies = TRUE)
```

---

## 🧠 Metodología

1. **Adquisición de datos:**
   Las imágenes usadas en este protecto fueron sacadas de internet, estas correspondientes a tres razas bovinas (**Brahman**, **Guzerat**, **Holstein**) organizadas en subcarpetas, cada una con 488 imagenes, esto para asegurar un balance en los datos. El dataset usando esta disponible en: **[Descargar dataset desde Google Drive](https://drive.google.com/drive/folders/10xaSyEvKPO9y59YrHvT2lZJTuNpB-1YJ?usp=sharing)**

   
3. **Preprocesamiento:**

   * Redimensionado a `160x160` píxeles.
   * Conversión a escala de grises con `magick`.
4. **Extracción de características:**

   * Uso del descriptor **HOG (Histogram of Oriented Gradients)** implementado con `OpenImageR::HOG`.
   * Parámetros: celdas = 8, orientaciones = 9.
5. **Entrenamiento:**

   * División de datos (80% entrenamiento / 20% prueba por raza).
   * Modelo **Random Forest (`ranger`)** con:

     * `num.trees = 600`
     * `mtry = sqrt(#features)`
     * `probability = TRUE`
     * `importance = "impurity"`
6. **Evaluación:**

   * Cálculo de métricas (`yardstick::metrics`).
   * Matriz de confusión (`caret::confusionMatrix`).
   * Visualización de resultados con `ggplot2` y `gt`.
7. **Predicción individual:**

   * La función `predictor_imagen()` permite evaluar una imagen nueva y obtener la raza y probabilidad de clasificación.

---

## 🗂️ Estructura de datos esperada

```
imagenes/
├── BRAHMAN/
│   ├── img_001.jpg
│   └── ...
├── GUZERAT/
│   ├── img_001.jpg
│   └── ...
└── HOLSTEIN/
    ├── img_001.jpg
    └── ...
```

Formatos aceptados: `.jpg`, `.jpeg`, `.png`.

---

## 🧪 Cómo reproducir el proyecto

### 1️⃣ Clonar el repositorio

Abre un scrip en r y ejecuta la siguiente línea de código:

```bash
install.packages("gert")
library(gert)

gert::git_clone("https://github.com/luisCT1/clasificacion-razas-bovinas.git", path = "clasificacion_razas_bovinas")
```
esto te creará una carpeta llamada "clasificacion_razas_bovinas" en documentos, en ella debes agregar la carpeta "imagenes" (que contiene las subcarpetar por raza con las imágenes)

### 2️⃣ Abrir en R o RStudio

Asegúrate de que las imágenes estén la carpeta `imagenes/` con la estructura indicada.

### 3️⃣ Ejecutar el script principal

Primero abre el protecto `proyecto.Rproj`,  y luego:

```r
source("script.R")
```

Esto:

* Carga las imágenes.
* Extrae descriptores HOG.
* Entrena el modelo.
* Evalúa los resultados (métricas y matriz de confusión).
* Muestra gráficos de desempeño.

### 4️⃣ Predicción sobre una imagen nueva

asegurate que sea una imagen que no fue usada para entrenar el modelo, para ello se incluyenron unos ejemplos (1, 2, 3, 4 y 5, todas en formato .jpg).

```r
img_path <- "5.JPG"
prediccion_nueva <- predictor_imagen(img_path, clases = c("BRAHMAN","GUZERAT","HOLSTEIN"))

prediccion_nueva$raza
round(prediccion_nueva$prob, 4)
print(prediccion_nueva$votos_por_clase)
```

---

## ⚙️ Parámetros ajustables

| Parámetro       | Descripción                        | Valor por defecto |
| --------------- | ---------------------------------- | ----------------- |
| `tamano_imagen` | Tamaño de las imágenes reescaladas | 160               |
| `cells`         | Celdas para HOG                    | 8                 |
| `orientations`  | Orientaciones para HOG             | 9                 |
| `num.trees`     | Árboles del Random Forest          | 600               |
| `mtry`          | Nº de variables por split          | √(#features)      |
| `seed`          | Semilla aleatoria                  | 123               |

---

mtry se relizó de la forma como se muestra en la tabla siguiendo la regla empírica clásica propuesta por Breiman (2001), el creador de Random Forest.

## 📊 Resultados obtenidos

El modelo logra una clasificación sólida entre las tres razas, alcanzando una **precisión global del 75.5%**.

### **Métricas generales (`yardstick::metrics`)**

| Métrica  | Valor     |
| -------- | --------- |
| Accuracy | **0.755** |
| Kappa    | **0.633** |

### **Matriz de confusión (`caret::confusionMatrix`)**

```
          Reference
Prediction BRAHMAN GUZERAT HOLSTEIN
  BRAHMAN       76     16        6
  GUZERAT       12     65       11
  HOLSTEIN      10     17       81
```

**Estadísticas por clase:**

| Clase    | Sensibilidad | Especificidad | F1    | Exactitud balanceada |
| -------- | ------------ | ------------- | ----- | -------------------- |
| Brahman  | 0.7755       | 0.8878        | 0.776 | 0.832                |
| Guzerat  | 0.6633       | 0.8827        | 0.739 | 0.773                |
| Holstein | 0.8265       | 0.8622        | 0.750 | 0.844                |

**Resumen general:**

* Accuracy: **0.7551**
* Kappa: **0.6327**
* Balanced Accuracy (promedio): **0.816**

> Estos resultados reflejan un rendimiento estable y equilibrado en las tres clases, con una buena separación de patrones visuales a partir de HOG, sin necesidad de redes neuronales.

---

## 🧩 Interpretación

Este proyecto muestra que los métodos clásicos de Machine Learning aún pueden ofrecer buenos resultados en visión por computadora aplicada a la producción animal.
Aunque la clasificación de razas puede realizarse visualmente por un experto, este tipo de técnicas abre la puerta a resolver problemas más complejos y de alto impacto, como por ejemplo:

* Detección automática del estado corporal a partir de imágenes o videos, para monitorear la salud y nutrición del ganado.
* Identificación individual de animales mediante patrones de pelaje o morfología, reemplazando o complementando métodos tradicionales como  los chips.
* Detección temprana de enfermedades o cojeras a través del análisis de postura, movimiento o superficie corporal.
* Estimación del peso o tamaño corporal usando visión 2D, reduciendo el manejo físico y el estrés animal.
* Monitoreo del comportamiento animal, como tiempo de pastoreo, alimentación o actividad, mediante cámaras fijas o drones.
* Control automático de ingreso y salida en corrales o tambos, con reconocimiento visual en tiempo real.
* Evaluación morfométrica o genética visual, identificando rasgos fenotípicos de interés productivo o reproductivo.

En este sentido, el flujo de trabajo presentado (extracción de características + modelo supervisado) puede adaptarse fácilmente a distintas tareas dentro de la ganadería de precisión y la agricultura inteligente, donde las imágenes son una fuente valiosa de datos objetivos y automatizables.

---

## 📁 Estructura recomendada del repositorio

```
.
├── imagenes/               # Datos de entrada
│   ├── BRAHMAN/
│   ├── GUZERAT/
│   └── HOLSTEIN/
├── 5.jpg                # imagen nueva a clasificar
├── script.R                # Código principal
├── README.md               # Este archivo
├── .gitignore              
└── LICENSE                 # MIT License
```

---

## 🧾 Licencia

Este proyecto se distribuye bajo la **MIT License**, permitiendo el uso, modificación y distribución del código con atribución al autor.
Consulta el archivo `LICENSE` para más información.

---

## 🙌 Agradecimientos

* A la comunidad R por herramientas como `magick`, `OpenImageR`, `ranger`, `yardstick`, `caret` y `ggplot2`.
* A los investigadores y técnicos que promueven el uso de **IA en la ganadería y las ciencias agropecuarias**.
* A todos los desarrolladores de software libre que hacen posible proyectos abiertos y reproducibles.

---

**Autor:** Luis Cohen
**Año:** 2025
**Licencia:** MIT License
**Contacto:** [lcohent@unal.edu.co](mailto:lcohent@unal.edu.co)
