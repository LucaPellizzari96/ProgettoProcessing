## Descrizione:

Partendo dal video della canzone Five Hours di Deorro su YouTube, realizzato un minigioco simile a quella mostrato dal video della canzone (nome: AudioSurf).

## Journal:

*18 luglio*

Sfogliata documentazione sulle librerie sound e minim di processing

*19 luglio*

Lettura degli esempi presenti nelle varie sezioni della documentazione per capire come sfruttare le varie funzionalità fornite dal software

*20 luglio*

* File di partenza: esempio minim/examples/Basics/AnalyseSound che mostra una FFT per analizzare un audio generato da un AudioPlayer
* Inserito oggetto cubo che rappresenterà il personaggio da muovere

*25 agosto*

* Creata pista con tre corsie con ai lati rappresentazione della trasformata del segnale
* Inseriti ostacoli "buoni" e "cattivi" e limitata la loro posizione all'interno delle tre corsie
* Aggiunto avanzamento in 3D degli ostacoli sulla pista
* Bordi degli ostacoli, del personaggio e delle linee che delimitano le corsie della pista aumentano di spessore in base all'intensità dei toni alti della traccia sonora in esecuzione durante il minigioco

*26 agosto*

* Gestite le collisioni con gli ostacoli e con i bonus (su y non serve)
* Raggruppate in due funzioni le collisioni su X e su Z e commentato il relativo codice

## Da fare:

* Animato il personaggio con tasti freccia
* Forma d'onda sopra (o sotto) la rappresentazione della trasformata
* Inserire filtri

## Link utili:

1) documentazione minim http://code.compartmental.net/minim/javadoc/

2) documentazione processing https://processing.org/reference/
