# Svolgimento:

Partendo dall'esempio minim/examples/Basics/AnalyseSound che mostra una FFT per analizzare un audio generato da un AudioPlayer

## Note:

* Origine in (0,0) (in alto a sinistra sullo schermo)
* X positivo verso destra
* Y positivo verso il basso
* "camera" guarda verso -Z

## Fatto:

* Scaricata libreria minim da github 17/07
* Modificata la rappresentazione della trasformata in modo che compia un movimento su una circonferenza 18/07
* Inserire oggetto (cubo o sfera) che rappresenterà il personaggio da muovere 18/07
* Animare l'oggetto con tasti freccia 18/07
* Inserire ostacoli e limitare la loro posizione 18/07
* Cambiata la rappresentazione dello spettro da circolare a ellittica 19/07
* Inserito movimento ellittico per il personaggio 19/07
* Aggiunta classe Spectrum per gestire gli spettri in file separato 19/07
* Prima prova delle collisioni 19/07
* Inserire velocità di movimento su z 19/07

## Da fare:

* Righe per collegare le ellissi
* Sistemare collisioni
* Applicare filtri alla trasformata (lowPass, highPass, passabanda)
