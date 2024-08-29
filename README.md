# Metodologías de Machine Learning para Valorar Equipos de Fútbol Profesionales como Activos de Inversión
Este repositorio contiene el código y la documentación asociados a mi trabajo de fin de grado titulado "Metodologías de Machine Learning para valorar equipos de fútbol profesionales como activos de inversión". El proyecto explora diversas técnicas de machine learning y su aplicación para evaluar el valor de los equipos de fútbol, proporcionando una perspectiva innovadora para inversores en el sector deportivo.

**Contenido**
- [Introducción](#introducción)
- [Estructura del Proyecto](#estructura)
- [Instalación](#instalación)
- [Uso](#uso)
- [Licencia](#licencia)

## Introducción
El objetivo de este proyecto es desarrollar un modelo de machine learning que pueda estimar el valor de mercado de los equipos de fútbol profesionales. Para ello, se han utilizado datos financieros, deportivos y demográficos, así como diversas metodologías de machine learning, como la regresión lineal, los árboles de decisión y los modelos de redes neuronales..

## Estructura
.
├── data/               # Datos crudos y procesados
├── notebooks/          # Jupyter notebooks con análisis exploratorio y desarrollo de modelos
├── scripts/            # Scripts de Python para procesamiento de datos y entrenamiento de modelos
├── models/             # Modelos entrenados y resultados
├── reports/            # Informes y resultados del análisis
└── README.md           # Este archivo

## Instalación
Para ejecutar el proyecto en tu máquina local, sigue los siguientes pasos:

Clonar el repositorio:

``` bash
git clone https://github.com/tuusuario/nombre-del-repo.git
cd nombre-del-repo
Crear y activar un entorno virtual:
```

``` bash
python3 -m venv env
source env/bin/activate  # En Windows usa `env\Scripts\activate`
```
Instalar las dependencias:
``` bash
pip install -r requirements.txt
```

## Uso
Para reproducir los análisis y modelos, puedes utilizar los notebooks de la carpeta notebooks. Asegúrate de tener todas las dependencias instaladas y de haber configurado correctamente tu entorno.

- **Análisis Exploratorio**: Revisa el notebook notebooks/EDA.ipynb para un análisis preliminar de los datos.
- **Entrenamiento de Modelos**: Utiliza el notebook notebooks/Model_Training.ipynb para entrenar los modelos y evaluar su rendimiento.
