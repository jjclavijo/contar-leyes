# Análisis de leyes de catastro por conteo de palabras.

En este repositorio trabajamos analizando las leyes de catastro de las 
distintas provincias argentinas a partir de un conteo de palabras.

Los documentos originales están en la carpeta [docs](docs).

En un primer paso se convirtieron los documentos a texto plano, que se encuentran
en la carpeta [txt](txt).

## Criterio de Conteo.

Para el conteo se eliminaron todos los signos de puntuación y se reemplazaron las 
tildes por letras sin tilde, para evitar errores.

Se trabajo con programas nativos del entorno linux (grep, tr, sed), para realizar
un primer conteo de palabras (en [count](count)) y de expresiones de dos palabras,
(en [count2](count2)).

Las expresiones se formaron luego de eliminar palabras no significativas a partir de 
[una lista de palabras](aux/cwds.txt), de modo que por ejemplo donde dijera 
"valor de la tierra" se cuente como "valor tierra".

## Elección de términos

Luego de el primer contéo se elaboraron listas de todos los términos que aparecian 
repetidos en al menos dos leyes, y se filtró en forma manual hasta llegar a una lista
manejable de términos a evaluar. 
Se eligieron 248 [términos de dos palabras](aux/terminos.2.d.txt), 
y 352 [palabras significativas](terminos.d.txt).

En una etapa futura es conveniente unificar el conteo de plurales y palabras derivadas.
Por ejemplo, las menciones a "agrimensores" "agrimensor" "profesional agrimensura", etc. deberían sumarse.

## Filtrado y generacion de tablas.

Finalmente, se filtraron las listas de palabras utilizando los terminos elegidos, ver
[palabras](filtrado) y [terminos](filtrado2) resultantes.

A partir de estos nuevos listados se confeccionaron tablas en formato de texto separado 
por ```|```, para [palabras](tabla.1.csv) y [terminos](tabla.2.csv) respectivamente.
Luego se convirtieron a [excel](xlsx) para mejor manejo.

## Generación de mapas.

Se generó en la carpeta [gis](gis) una capa de [poligonos de provincias](gis/provincias_simple.geojson) simplificado, utilizando la [herramienta topojson](https://github.com/topojson/topojson), de manera que se generó una capa topológicamente correcta.

A partir de esta capa, se generó una [base de datos --puede descargarse aqui y utilizarse en un software como QGIS--](gis/provincias.gpkg) geoespacial en formato geopackage, 
que puede consultarte utilizando sqlite+spatialite a partir de las herramientas provistas
por la libreria [gdal](https://gdal.org/drivers/vector/gpkg.html).

De esta manera se genraron archivos geojson con visualizaciones de ejemplo, una para el
término [certificado catastral (ver este link)](gis/provincias-cc.geojson) y otra para [estado parcelario (ver este link)](gis/provincias-ep.geojson)

### Todos los procesos realizados para generar cada archivo pueden revisarse consultando el [Makefile](Makefile).
