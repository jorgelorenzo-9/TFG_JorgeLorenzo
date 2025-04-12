function [ventanas_Miercoles_15mins] = enventanar(indice,dia_entero)
% Define el rango de índices para las 900 muestras 
rango = (indice:indice + 900);
% Crea un nuevo vector con las 300 muestras alrededor del máximo
ventanas_Miercoles_15mins = dia_entero(rango);
end


