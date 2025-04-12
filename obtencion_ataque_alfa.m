clear; close all;clc; warning off;
addpath('./Datasets/');
addpath('./Functions/');

load("centroide_objetivo.mat")


% Estructura de los archivos BPSyPSS ->
% - Columna 1 : Tiempo (segundos)
% - Columna 2 : Bytes transmitidos desde el segundo anterior hasta el segundo actual
% - Columna 3 : Paquetes transmitidos desde el segundo anterior hasta el segundo actual

% Se ha probado todas las semanas, las validas son las siguientes:
mayo3 = load("./Datasets/may_week3_csv/BPSyPPS.txt");
abril3 = load("./Datasets/april_week3_csv/BPSyPPS.txt");
junio2 = load("./Datasets/june_week2_csv/BPSyPPS.txt");
marzo4 = load("./Datasets/march_week4_csv/BPSyPPS.txt");
marzo3 = load("./Datasets/march_week3_csv/BPSyPPS.txt");
junio3 = load("./Datasets/june_week3_csv/BPSyPPS.txt");

f = ["pdf"]; % Formato para guardar imagenes vectoriales



[Mayo3_enDias,ventanas_15mins_Mayo3,alpha_params_Mayo3] = Dataset_to_windows(mayo3);
[Abril3_enDias,ventanas_15mins_Abril3,alpha_params_Abril3] = Dataset_to_windows(abril3);
[Junio2_enDias,ventanas_15mins_Junio2,alpha_params_Junio2] = Dataset_to_windows(abril3);
[Marzo4_enDias,ventanas_15mins_Marzo4,alpha_params_Marzo4] = Dataset_to_windows(marzo4);
[Junio3_enDias,ventanas_15mins_Junio3,alpha_params_Junio3] = Dataset_to_windows(junio3);


plotWeekDays(Mayo3_enDias);

num_ventanas = 8

ALFA_PARAMS = {alpha_params_Mayo3 alpha_params_Abril3 alpha_params_Junio2 alpha_params_Marzo4 alpha_params_Junio3};


alfas = zeros(1,200);
betas = zeros(1,200);
gammas = zeros(1,200);
deltas = zeros(1,200);

for semana=1:numel(ALFA_PARAMS)
    for dia=1:numel(ALFA_PARAMS{1, 1})
        for ventana=1:num_ventanas
        alfas((ventana - 1) * (5 * 5) + (semana - 1) * 5 + dia) = ALFA_PARAMS{1, semana}{1, dia}(1,ventana);
        betas((ventana - 1) * (5 * 5) + (semana - 1) * 5 + dia) = ALFA_PARAMS{1, semana}{1, dia}(2,ventana);
        gammas((ventana - 1) * (5 * 5) + (semana - 1) * 5 + dia) = ALFA_PARAMS{1, semana}{1, dia}(3,ventana);
        deltas((ventana - 1) * (5 * 5) + (semana - 1) * 5 + dia) = ALFA_PARAMS{1, semana}{1, dia}(4,ventana);
        end
    end
end


% Clusterización con K-means - Puedo elegir varios clusters
num_clusters = 2;
[idx, centros,coeficiente_silueta] = clusterizacion(alfas, gammas, deltas, num_clusters);

% Comprobado 2 centroides mejor que 1 y que 3,4...
coeficiente_silueta_medio = mean(coeficiente_silueta);

% Inicializo vectores para stables sin festivos
alfas_sf = zeros(1,84);
gammas_sf = zeros(1,84);
deltas_sf = zeros(1,84);
cont=0;
% Ver índices del segundo cluster para estudio analítico
indices_2do_cluster = [];
for i=1:200
%for i=1:50 %Si queremos cambiar el numero de ventanas. i=50 para 2
    if(idx(i)==2)
        indices_2do_cluster = [indices_2do_cluster,i];
        cont = cont + 1;
    else
        alfas_sf(i-cont) = alfas(i);
        gammas_sf(i-cont) = gammas(i);
        deltas_sf(i-cont) = deltas(i);
    end
end


%% CF - FUNCIÓN CARACTERÍSTICA ESTABLE

distribucion_estable_centroide1 = makedist('Stable', 'alpha', centros(1,1), 'beta', 1, 'gam', centros(1,2), 'delta', centros(1,3));

num_muestras = 120;
muestras_centroide_1 = random(distribucion_estable_centroide1, num_muestras,1);

% Representar series temporales generadas según su distribución estable
figure;
plot(muestras_centroide_1);
xlabel('Ventana 900 muestras'); ylabel('Bitrate');
title('Tráfico maligno generado con Centroide 1');

%% SUPERPOSICIÓN DE TRÁFICO - haciendo pruebas - CON DISTRIBUCIONES ESTABLES CONJUNTAS (objetos medios de todas las series temporales)

[Serie_sintetica_generica1, serie_sumada1] = Superponer_trafico(1,muestras_centroide_1,ventanas_15mins_Mayo3(:,1));
[Serie_sintetica_generica2, serie_sumada2] = Superponer_trafico(2,muestras_centroide_1,ventanas_15mins_Mayo3(:,2));
[Serie_sintetica_generica3, serie_sumada3] = Superponer_trafico(3,muestras_centroide_1,ventanas_15mins_Mayo3(:,3));
[Serie_sintetica_generica4, serie_sumada4] = Superponer_trafico(4,muestras_centroide_1,ventanas_15mins_Mayo3(:,4));
[Serie_sintetica_generica5, serie_sumada5] = Superponer_trafico(5,muestras_centroide_1,ventanas_15mins_Mayo3(:,5));
[Serie_sintetica_generica6, serie_sumada6] = Superponer_trafico(6,muestras_centroide_1,ventanas_15mins_Mayo3(:,6));
[Serie_sintetica_generica7, serie_sumada7] = Superponer_trafico(7,muestras_centroide_1,ventanas_15mins_Mayo3(:,7));
[Serie_sintetica_generica8, serie_sumada8] = Superponer_trafico(8,muestras_centroide_1,ventanas_15mins_Mayo3(:,8));

%PARA GUARDAR DIRECTAMENTE LAS SERIES SUMADAS

%----------------------------------------------------------
folderName = 'series_sumadas';

% Obtener la ruta completa de la carpeta
currentFolder = fileparts(mfilename('fullpath'));
targetFolder = fullfile(currentFolder, folderName);

% Lista de las variables a guardar
series = {serie_sumada1, serie_sumada2, serie_sumada3, serie_sumada4, serie_sumada5, serie_sumada6, serie_sumada7, serie_sumada8};

% Guardar cada serie en un archivo separado
for i = 1:length(series)
    % Crear el nombre del archivo dinámicamente
    %fileName = sprintf('serie_sumada_lun_%d.csv', i);
    %fileName = sprintf('serie_sumada_mar_%d.csv', i);
    %fileName = sprintf('serie_sumada_mie_%d.csv', i);
    %fileName = sprintf('serie_sumada_jue_%d.csv', i);
    fileName = sprintf('serie_sumada_vie_%d.csv', i);
    filePath = fullfile(targetFolder, fileName);
    
    % Guardar la serie en un archivo .csv
    %writematrix(series{i}, filePath);
    %fprintf('Archivo guardado: %s\n', filePath);
end