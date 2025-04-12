function [serie_sintetica, serie_sumada] = Superponer_trafico(i, serie_sintetica, serie_original)
% Se suma el tráfico de las dos series de 900 puntos (15 minutos) para ver
% su representación y como quedaría el ataque

% Se soluciona el problema de la amplitud con un factor de escala que
% ajuste el tráfico sintético al original
%rango_original = max(serie_original(i)) - min(serie_original(i));

% Se escala punto a punto el vector "serie_sintética" 
%serie_sintetica = 0.7.*serie_sintetica;

% Se mitigan los picos grandes de paquetes generados en la serie sintética
%for i=1:901
 %   if (serie_sintetica(i) > (1.5*mean(serie_sintetica)))
 %       serie_sintetica(i) = mean(serie_sintetica);
 %   end
%end
serie_sintetica1 = zeros(size(serie_original))
%serie_sintetica1 = serie_sintetica1 + serie_sintetica
%serie_sintetica1(1:120) = serie_sintetica
%serie_sintetica1((size(serie_original)-size(serie_sintetica)):size(serie_original)) = serie_sintetica
serie_sintetica1(end-119:end) = serie_sintetica

serie_sumada = serie_sintetica1 + serie_original;
% Gráfica de ventana original para poder comparar
figure;
subplot(3,1,1)
plot(serie_original);
xlabel('Ventana 15 minutos'); ylabel('Bitrate');
title('Gráfica la serie original');
legend('Serie Original');
grid on;

% Gráfica de las dos series por separado
subplot(3,1,2)
plot(serie_sintetica1, 'b'); % serie_sintetica en azul
hold on;
plot(serie_original, 'r'); % serie_original en rojo
xlabel('Ventana 15 minutos'); ylabel('Bitrate');
title('Gráfica de las dos series por separado');
legend('Serie Sintética', 'Serie Original');
grid on;
hold off;

% Gráfica de las dos series superpuestas
subplot(3,1,3)
plot(serie_sumada, 'b'); 
xlabel('Ventana 15 minutos'); ylabel('Bitrate');
title('Gráfica de las dos series superpuestas');
legend('Serie sumada');
grid on;
end

