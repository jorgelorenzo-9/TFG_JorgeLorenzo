warning('off')

data1 = readtable('../series_concatenadas/archivo_concatenado_miercoles.csv'); 
%data1 = readtable('../series_concatenadas_rampa/cambio_intensidades/archivo_concatenado_miercoles_intensidad_1+1_5_diff.csv'); 
%data1 = readtable('../series_concatenadas_meseta/cambio_intensidades/archivo_concatenado_miercoles_intensidad_5_2intento_diff.csv'); 
%data1 = readtable('../series_concatenadas/archivo_concatenado_miercoles_cambio_0_55_diff.csv'); 
data2 = readtable('../series_concatenadas_sin_ataque/archivo_concatenado_miercoles_sin_ataque_diff.csv'); 



window_size = 898;
%window_size = 98;
step = 1

d1 = data1.Var1;
d2 = data2.Var1;

% Determine the number of windows
num_windows = floor((length(d1) - window_size) / step) + 1; %Ventanas deslizantes

% Initialize arrays to store the parameters
alpha_values = zeros(num_windows*2, 1);
beta_values = zeros(num_windows*2, 1);
gamma_values = zeros(num_windows*2, 1);
delta_values = zeros(num_windows*2, 1);
attack_value = zeros(num_windows*2, 1);
% Loop through each window
for i = 1:num_windows
    start_idx = (i-1)*step + 1;
    % Extraer una ventana de 720 muestras para ajustar la distribución estable
    current_window = d1(start_idx : start_idx + 719);
    
    % Ajustar la distribución estable
    try
        pd1 = fitdist(current_window, 'Stable');
    catch exception
        continue
    end
    
    % Extraer la parte correspondiente a las muestras de 720 a 898
    cw1 = d1(start_idx + 719 : start_idx + 897);
    cw2 = d2(start_idx + 719 : start_idx + 897);
    
    % Verificar que el escalado no resulte en infinito
    if (isinf((cw1(1)-pd1.delta)/pd1.gam) || isinf((cw2(1)-pd1.delta)/pd1.gam))
        continue
    end
    
    % Escalar los datos
    cw1 = (cw1 - pd1.delta) / pd1.gam;
    cw2 = (cw2 - pd1.delta) / pd1.gam;
    
    % Ajustar de nuevo la distribución estable en las ventanas escaladas
    try
        pd21 = fitdist(cw1, 'Stable');
        pd22 = fitdist(cw2, 'Stable');
    catch exception
        continue
    end
    
    % Guardar parámetros para la serie con ataque y sin ataque
    alpha_values(i) = pd21.alpha;
    beta_values(i) = pd21.beta;
    gamma_values(i) = pd21.gam;
    delta_values(i) = pd21.delta;
    attack_value(i) = 1;
    
    alpha_values(num_windows+i) = pd22.alpha;
    beta_values(num_windows+i) = pd22.beta;
    gamma_values(num_windows+i) = pd22.gam;
    delta_values(num_windows+i) = pd22.delta;
    attack_value(num_windows+i) = 0;
end


result_table = table(alpha_values, beta_values, gamma_values, delta_values, attack_value);


% Save the table to a CSV file

writetable(result_table, 'alpha_fit_normalized_miercoles_concatenado.csv'); 

%writetable(result_table, 'cambio_intensidades/alpha_fit_normalized_miercoles_concatenado_rampa_desl_p1_intens_1+1_5_2intento.csv'); 
%writetable(result_table, 'cambio_intensidades/alpha_fit_normalized_miercoles_concatenado_meseta_desl_p1_intens_5_2intento.csv'); 
%writetable(result_table, 'cambio_intensidades/alpha_fit_normalized_miercoles_concatenado_alfa_desl_p1_intens_cambio_0_55.csv'); 


