function [] = plotWeekDays(vector_en_dias)
% Crea un vector de tiempo en horas (86449 pasos representando un día)
tiempo_en_horas = linspace(0, 24, 86449);

% Grafica los datos para cada día de la semana
for i=1:7
    figure;
    plot(tiempo_en_horas, vector_en_dias(:,i));
    xlabel('Hora del día', 'FontSize', 14, 'FontWeight', 'bold');
    ylabel('Bitrate', 'FontSize', 14, 'FontWeight', 'bold');
    title(['Datos dia ' num2str(i)], 'FontSize', 14, 'FontWeight', 'bold');
    % Establecer el formato del eje x en días y horas
    ax = gca;
    ax.FontSize = 14; % Cambiar el tamaño de la letra de los ejes
        
end

end


