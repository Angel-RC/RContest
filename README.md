# RContest

Para participar en el concurso organizado por los usuarios de R de Asturias (https://rusersasturias.github.io/contest/), he hecho esta app.

La organización del proyecto:
- data: En esta carpeta están los datos en bruto.
- data_tidy: En esta carpeta están los datos una vez han sido limpiados.
- src: En esta carpeta están los ficheros con las funciones y librerias necesarias además del script para limpiar los datos. 

La app:
La app consta de 2 ventanas (Map y Summary), cada una supone una participación para el concurso:
- En Maps se puede ver un mapa con las distintas localizaciones de las multas (solo para las multas con localización). 
- En Summary se puede ver un gráfico de Sol que se puede hacer con varias categorias de los datos (año, mes, tipo...)
y debajo se ve una serie temporal respecto al conjunto completo de las multas (o pertenecientes a una serie de categorias si se hace click en el primer gráfico).

En el menu de la izquierda hay dos opciones:
- filter data: para aplicar un filtro de los datos que se quieren visualizar.
- Options: para cambiar aspectos del mapa o de la serie temporal.
