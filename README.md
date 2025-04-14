# TFG_JorgeLorenzo

Este repositorio presenta los archivos utilizados para el desarrollo del Trabajo de Fin Grado de Ingeniería de Tecnologías y Servicios de Telecomunicación titulado "Estudio de detección de anomalías de tráfico de red utilizando diferencias finitas".


Archivos utilizados:

- `representaciones_enventanado.ipynb`: Este notebook muestra detalladamente el proceso de enventanado del tráfico original. 
  
- `diffs_finitas_semana.ipynb`: Se realiza todo el desarrollo de los datos realizando distintas pruebas. Se aplica el ataque a cada una de las ventanas para después concatenarlas y aplicar las diferencias finitas a las series concatenadas. Además, se aplican parámetros estadísticos como la media, desviación estándar, curtosis y skew usando ventanas deslizantes para ver si ayudan a detectar ataques.

- `svm_meseta.ipynb`: Muestra los resultados del clasificador para el ataque de meseta. Se entrena tanto con regresión logística como con SVM, mostrando las distintas métricas obtenidas, la matriz de confusión de cada caso y su curva ROC. En este notebook se generan también alguna de las series necesarias con ataque de meseta para posteriormente realizar el entrenamiento de la SVM con variación de intensidades. 

- `svm_rampa.ipynb`: Realiza las mismas tareas que el notebook `svm_meseta.ipynb` pero para el ataque en rampa.

- `svm_alfa.ipynb`: Realiza las mismas tareas que los notebooks `svm_meseta.ipynb` y `svm_rampa.ipynb` pero para el ataque generado usando alfa estables.

- `svm_cambio_intensidades.ipynb`: Muestra los detalles de cada una de las series con variación de intensidad generadas. Se calcula tanto la suma total de los bits, como la energía, como la media. Después, se muestra la comparación de energía para cada caso de variación, siendo la última gráfica del notebook la más óptima.

- `utilities.py`: Este script contiene diversas funciones creadas que sirven principalmente para realizar el enventanado de los datos en python. También hay funciones para realizar el suavizado de series, en caso de que sea necesario.

- `matlab/`: Carpeta que contiene los scripts implementados en matlab. El script `obtencion_ataque_alfa.m` sirve para generar las series de ataque usando alfa estables. Para ello es necesario el uso de `centroide_objetivo.mat`. El script `alpha_fit_normalize_deslizantes.m` se usa para obtener los parámetros alfa estables de las series concatenadas con diferencias finitas. Los parámetros obtenidos se utilizarán para clasificar las series en ataque o no ataque mediante regresión logística y SVM.
