#!/usr/bin/perl -w
#
# script in Perl per la conversione di tracce GPX. 
#Prima scarica le tracce dal GPS (i-blue 747), converte la traccia TRK in waypoint WP; in seconda battuta viene creato uno shapefile SHP del WP in modo da conservare tutti i dati #(compreso il TIMESTAMP) all'interno della tabella attributi. Infine lo SHP viene riproiettao da WGS84 a Gauss-Boaga Fuso Ovest.
#

#Inserimento nome da assegnare al GPX scaricato
print "Inserisci il nome da dare al file GPX (senza estensione): ";
chomp($nome_gpx = <>);


#Inserimento nome dello SHP finale
print "Inserisci il nome del file SHP di output (senza estensione): ";
chomp($nome_ref = <>);

#Scarica i dati tramite mtkbabel dal GPS i-blue 747
system("mtkbabel -l off -f $nome_gpx -t");

#Rimuove i file scaricati in formaro .bin
system("rm $nome_gpx.bin");

#Le tracce salvate da mtkbabel hanno un suffisso "_trk"; trasformo il nome della traccia salvata in una variabile in modo da poterla richiamare nelle parti successive dello script stesso. "._trk" significa che ho concatenato il nome della variabile $nome_gpx a "_trk" mediante il punto ".".
$nome_mod = $nome_gpx._trk;

#Rinomina il file delle track 
system("mv $nome_mod.gpx data_trk.gpx");

#Caricamento di tutti i .gpx in un array.
#@gpx = `ls *.gpx`;

# Carica il GPX specificato e lancia l'array per la conversione
@gpx = $nome_gpx;

foreach $gpx (@gpx) {

   #Ti comunica che sta lavorando
   print "Processamento ".$gpx;

#  usa il programma gpsbabel per convertire trk in wp
   system("gpsbabel -i gpx -f data_trk.gpx -x transform,wpt=trk -o gpx -F $nome_ref.gpx");

#  usa gpx2shp per convertire il GPX creato in SHP
   system("gpx2shp -w -o $nome_ref.shp $nome_ref.gpx");

#  usa ogr2ogr per convertire il GPX creato in SHP
#   system("ogr2ogr -f 'ESRI Shapefile' $nome_ref.shp $nome_ref.gpx");

#  usa ogr2ogr per riproiettare lo shape creato da EPSG 4326 (lat-long) a EPSG 3003 (Gauss-Boaga Fuso Ovest)
   system("ogr2ogr gb_$nome_ref.shp $nome_ref.shp -s_srs EPSG:4326 -t_srs '+proj=tmerc +ellps=intl +lat_0=0 +lon_0=9 +k=0.999600
+x_0=1500000 +y_0=0 +units=m +towgs84=-104.1,-49.1,-9.9,0.971,-2.917,0.714,-11.68'");

# conversione del file shp in GML per caricamento con openlayers
	system("ogr2ogr -f GML gml_$nome_ref.gml $nome_ref.shp");
}