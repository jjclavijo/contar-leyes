texts := $(shell ls docs/* | sed -E 's/docs\/(.*)\.(doc|docx|pdf)/txt\/\1.txt/g')

txt/%.txt: docs/%.pdf
	pdftotext "$<" "$@"

txt/%.txt: docs/%.docx 
	loffice --convert-to txt:Text "$<"
	mv $*.txt "$@"

txt/%.txt: docs/%.doc
	loffice --convert-to txt:Text "$<"
	mv $*.txt "$@"

txt: ${texts}

count2/%.txt: txt/%.txt 
	iconv -f utf8 -t ascii//TRANSLIT < "$<" |\
	       	tr -C '[:alnum:]\n' '\n' | tr 'A-Z' 'a-z'  |\
	       	sed -E '/^[\s\n]+$$/d;/^[0123456789]+o?$$/d' |\
		sed -e "$$(sed 's:.*:/^&$$/d:' aux/cwds.txt)" |\
	       	sed -n 'H;x;s/\n/ /;p;x;h' | tail -n +2 | sort |\
	       	uniq -c > "$@"

count2: $(patsubst txt/%.txt,count2/%.txt,$(texts))

%.2.sed: count2/%.txt
	sed -E 's:\s+([0123456789]+)\s+(.*):/[\\ 0123456789]\\+\2\$$/ {c\\\n&\nb\n}:' "$<" > "$@"
	for i in a b c d e f g h i j k l m n o p q r s t u v w x y z;\
	do (sed -n '/\\+'$$i'/q;p' $@ && echo :$$i && sed -n '/\\+'$$i'/,$$ p;' $@) > tmp.sed ;\
	mv tmp.sed $@;\
	done
	cp aux/encabezado.sed tmp.sed
	cat $@ >> tmp.sed
	mv tmp.sed $@
	
filtrado2/%.txt: %.2.sed 
	sed -f $< aux/terminos.2.d.txt > "$@"

filtrados2: $(patsubst txt/%.txt,filtrado2/%.txt,$(texts))

count/%.txt: txt/%.txt 
	iconv -f utf8 -t ascii//TRANSLIT < "$<" |\
	       	tr -C '[:alnum:]\n' '\n' | tr 'A-Z' 'a-z'  |\
	       	sed -E '/^[\s\n]+$$/d;/^[0123456789]+o?$$/d' |\
		sed -e "$$(sed 's:.*:/^&$$/d:' aux/cwds.txt)" |\
	       	sort |\
	       	uniq -c > "$@"

count: $(patsubst txt/%.txt,count/%.txt,$(texts))

%.sed: count/%.txt
	sed -E 's:\s+([0123456789]+)\s+(.*):/[\\ 0123456789]\\+\2\$$/ {c\\\n&\nb\n}:' "$<" > "$@"
	for i in a b c d e f g h i j k l m n o p q r s t u v w x y z;\
	do (sed -n '/\\+'$$i'/q;p' $@ && echo :$$i && sed -n '/\\+'$$i'/,$$ p;' $@) > tmp.sed ;\
	mv tmp.sed $@;\
	done
	cp aux/encabezado.sed tmp.sed
	cat $@ >> tmp.sed
	mv tmp.sed $@
	
filtrado/%.txt: %.sed 
	sed -f $< aux/terminos.d.txt > "$@"

filtrados: $(patsubst txt/%.txt,filtrado/%.txt,$(texts))

tabla.1.csv: filtrados
	sed 's/\ *0\ *//' aux/terminos.d.txt > tmp.paste
	for i in $(patsubst txt/%.txt,filtrado/%.txt,$(texts));\
		do sed 's/\ *//;s/\ /|/' $$i |\
	           cut -d\| -f1 - | paste -d\| tmp.paste - > tmp2.paste;\
	mv tmp2.paste tmp.paste;\
	done
	(echo termino $(patsubst txt/%.txt,%,$(texts)) |\
		sed -E 's/[0123456789_-]*//g;s/\ /|/g' &&\
		cat tmp.paste) > "$@"
	rm tmp.paste
	echo -n "<Totales>" >> "$@"
	for i in $(patsubst txt/%.txt,count/%.txt,$(texts));\
		do echo -n \|$$(sed -E 's/\ +([0-9]+)\ .*/\1/' $$i | paste -sd+ - | bc);\
		done >> "$@"
	echo "" >> "$@"

tabla.2.csv: filtrados2
	sed 's/\ *0\ *//' aux/terminos.2.d.txt > tmp.paste
	for i in $(patsubst txt/%.txt,filtrado2/%.txt,$(texts));\
		do sed 's/\ *//;s/\ /|/' $$i |\
	           cut -d\| -f1 - | paste -d\| tmp.paste - > tmp2.paste;\
	mv tmp2.paste tmp.paste;\
	done
	(echo termino $(patsubst txt/%.txt,%,$(texts)) |\
		sed -E 's/[0123456789_-]*//g;s/\ /|/g' &&\
		cat tmp.paste) > "$@"
	rm tmp.paste
	echo -n "<Totales>" >> "$@"
	for i in $(patsubst txt/%.txt,count2/%.txt,$(texts));\
		do echo -n \|$$(sed -E 's/\ +([0-9]+)\ .*/\1/' $$i | paste -sd+ - | bc);\
		done >> "$@"
	echo "" >> "$@"
	
terminos.2.txt: count2
	touch terminos.2.tmp.txt
	for i in count2/*;\
		do sort $$i | sed 's/^[^a-z]*//' >> terminos.2.tmp.txt;\
	done
	sort terminos.2.tmp.txt | uniq -c | sort -r |\
	       	sed '/\ 2\ /q' > terminos.2.txt
	rm terminos.2.tmp.txt

terminos.txt: count
	touch terminos.tmp.txt
	for i in count/*;\
		do sort $$i | sed 's/^[^a-z]*//' >> terminos.tmp.txt;\
	done
	sort terminos.tmp.txt | uniq -c | sort -r |\
	       	sed '/\ 2\ /q' > terminos.txt
	rm terminos.tmp.txt

clean:
	-@rm count/*
	-@rm count2/*
	-@rm filtrado/*
	-@rm filtrado2/*
	-@rm txt/*
	-@rm tabla.[12].csv
	-@rm terminos.txt terminos.2.txt

xlsx/una_palabra.csv: tabla.1.csv 
	tr '|' ',' < tabla.1.csv > $@

xlsx/una_palabra.xlsx: xlsx/una_palabra.csv
	cd xlsx;\
	loffice --convert-to xlsx:"Calc MS Excel 2007 XML" una_palabra.csv


xlsx/dos_palabras.csv: tabla.2.csv 
	tr '|' ',' < tabla.2.csv > $@

xlsx/dos_palabras.xlsx: xlsx/dos_palabras.csv
	cd xlsx;\
	loffice --convert-to xlsx:"Calc MS Excel 2007 XML" dos_palabras.csv

tabla.%.tr.csv : tabla.%.csv
	echo '' > "$@"
	while read linea;\
	do echo $$linea | tr '|' '\n' | paste -d, "$@" - > tmp.tbl;\
	mv tmp.tbl "$@";\
	done < tabla.2.csv
	sed -i 's/^,//;s/^termino,/provincia,/' "$@"

gis/provincias.gpkg: tabla.1.tr.csv tabla.2.tr.csv
	if [ -f $@ ];\
		then rm $@;\
	fi
	ogr2ogr -f gpkg $@ gis/provincias_simple.geojson -sql 'SELECT nam FROM provincias_simple' -nln provincias
	ogr2ogr -f gpkg $@ tabla.2.tr.csv -nln datos_dos -update
	ogr2ogr -f gpkg $@ tabla.1.tr.csv -nln datos_uno -update

# https://codereview.stackexchange.com/questions/69833/generate-sample-coordinates-inside-a-polygon
# Para generar puntitos aleatorios segun cantidad de menciones.
# Falta encontrar el tope de opacidad automaticamente en lugar de hard-codearlo.

gis/provincias-ep.geojson: gis/provincias.gpkg
	ogr2ogr -f geojson $@ -t_srs urn:ogc:def:crs:OGC:1.3:CRS84 $< -sql 'SELECT geom,nam,"estado parcelario"/39.0 as "fill-opacity" FROM provincias JOIN datos_dos ON nam=provincia'

gis/provincias-cc.geojson: gis/provincias.gpkg
	ogr2ogr -f geojson $@ -t_srs urn:ogc:def:crs:OGC:1.3:CRS84 $< -sql 'SELECT geom,nam,"certificado catastral"/16.0 as "fill-opacity" FROM provincias JOIN datos_dos ON nam=provincia'
