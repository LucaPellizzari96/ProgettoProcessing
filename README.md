## Descrizione:

3D troppo difficile da gestire (collisioni) => Gioco in 2D in cui sul bordo dello schermo vedo lo spettro del segnale e all'interno di questo spettro c'è un personaggio che per
sopravvivere deve raccogliere delle forme geometriche che hanno una certa "durata": il colore al loro interno parte da bianco/grigio quando vengono generate e ogni tot frame cambia le sue
componenti RGB e si avvicina sempre di più al colore nero. Quando questo succede l'ostacolo sparisce e ne riappare un altro in un altra posizione dello schermo. Il personaggio
per ora è rappresentato da una circonferenza con il bordo rosso che si muove ciclicamente all'interno dello spettro. Si può interrompere/bloccare il suo movimento con
il tasto 'UP' = freccia verso l'alto e si può invertire il verso del movimento con il tasto 'DOWN' = freccia verso il basso. L'obiettivo del gioco è raccogliere una serie di
ostacoli (quelli con il bordo verde) ed evitare di colpire gli ostacoli con il bordo viola. Colpendo un ostacolo "buono" la lifeline gialla che si trova al centro dello
schermo, che rappresenta il tempo che rimane prima che avvenga il game over, cresce mentre colpendo un ostacolo con il bordo viola si riduce. Quando la lifeline diventa di 
lunghezza pari a zero il gioco termina e il personaggio viene portato al centro dello schermo; con il tasto ENTER la lifeline viene ripristinata al valore di partenza e si può
effettuare una nuova partita.

## Journal:

*18 luglio*

Sfogliata documentazione sulle librerie sound e minim di processing

*19 luglio*

Lettura degli esempi presenti nelle varie sezioni della documentazione per capire come sfruttare le varie funzionalità fornite dal software

*20 luglio*

* File di partenza: esempio minim/examples/Basics/AnalyseSound che mostra una FFT per analizzare un audio generato da un AudioPlayer
* Inserito oggetto (cubo o sfera) che rappresenterà il personaggio da muovere
* Animato il personaggio con tasti freccia
* Inseriti ostacoli e limitata la loro posizione

*23 luglio*

* Convertito lo spettro lineare preso dall'esempio in spettro circolare tramite le funzioni trigonometriche sin e cos
* Mappato spettro circolare in spettro ellittico
* Ostacoli buoni e ostacoli cattivi aggiunti in due ArrayList
* Apparizione pseudo-random e opacità (sopravvivenza) degli ostacoli
* Collisioni circonferenza-rettangolo => personaggio-ostacoli

*24 luglio*

* Aggiunta possibilità di applicare filtri (lowPass, highPass, bandPass) da tastiera tramite funzione keyPressed()
* Inserito punteggio con lifeline gialla che cala con il tempo e in base agli ostacoli colpiti
* Canzone ferma quando perdo (game over)
* Lifeline sostituita con spettro che contiene la mobile average lineare della fft (numero di campioni mostrati cala con il tempo)
* Semplificata la leggibilità del metodo draw() raccogliendo i vari for in diverse funzioni

*31 luglio*

* Refactoring del main
* La canzone riparte da capo quando perdo
* Dopo aver visto l'implementazione della classe AudioPlayer e della sua superclasse AudioSource della libreria Minim ho impostato una frequenza di taglio
per i filtri che dipende dalla posizione su y del mouse

## Da fare:

* map(fft.getBand(i), 0,1,...) OPPURE map(fft.getBand(i), 0,25,...) sia per ellisse che per sfera
* Lifeline che si muove in base al valore mobileAverage degli ultimi campioni
* Settare valori sensati per i tre filtri (vedere teoria)
* Possibilità di aumentare/diminuire la frequenza di taglio dei filtri con '-' e '+' (?)

* Nuovo livello con rettangolo (forma d'onda non fft); movimento libero in tutte le direzioni all'interno del rettangolo, mangiare gli ostacoli per sopravvivere,
tipo snake 2D

## Link utili:

1) audio visualization (cubes) https://www.youtube.com/watch?v=gHpxRv4MBBA

2) documentazione minim http://code.compartmental.net/minim/javadoc/

3) documentazione processing https://processing.org/reference/
