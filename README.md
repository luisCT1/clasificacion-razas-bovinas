# 🐄 Clasificador de Razas Bovinas (HOG + Random Forest con ranger)

Este proyecto implementa un clasificador de imágenes para identificar tres razas bovinas: **Brahman**, **Guzera** y **Holstein**.  
Utiliza descriptores **HOG (Histogram of Oriented Gradients)** para la extracción de características y un **Bosque Aleatorio (Random Forest)** entrenado con el paquete `ranger`.

---

## 📦 Requisitos

- **R ≥ 4.1** (recomendado)
- Paquetes de R necesarios:
  - `magick`, `OpenImageR`, `ranger`, `dplyr`, `tibble`, `purrr`, `yardstick`,
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
