## Descrizione:

Partendo dal video della canzone Five Hours di Deorro su YouTube, realizzato un minigioco simile a quella mostrato dal video della canzone (nome: AudioSurf).
Ci sono tre corsie su cui il personaggio può transitare, si passa da una all'altra con i tasti direzionali (freccia destra e freccia sinistra): l'obiettivo del
minigioco è quello di evitare gli ostacoli "cattivi" (cubi di colore girgio i cui bordi cambiano spessore dinamicamente in funzione delle caratteristiche spettrali della traccia in esecuzione
durante la partita) e colpire gli ostacoli "buoni" (cubi il cui colore varia dinamicamente in base alle caratteristiche della traccia, anche per loro lo spessore dei bordi varia dinamicamente).
Le corsie sono delimitate da quattro "linee", due di queste, quelle centrali, sono semplici linee costruite utilizzando la funzione "line(x,y,z,x2,y2,z2)" che riceve
come argomento le coordinate di due punti e costruisce una linea che unisce i due punti. Le due "linee" più esterne invece rappresentano una (quella di destra) lo spettro della 
trasformata e l'altra (quella di sinistra) la forma d'onda del segnale. Anche queste due sono costruite sfruttando la funzione line() e variando le coordinate y dei due punti una in base al
valore restituito dalla funzione fft.getBand(i) che restituisce l'ampiezza (float) della banda di frequenza i-esima; per la forma d'onda invece prendo un AudioBuffer che contenga il mix dei canali
left e right in questo modo: float[] mix = song.mix.toArray(); e poi ad ogni punto che passo alla funzione line() assegno un valore di y che dipende dal valore i-esimo contenuto nel buffer mix moltiplicato per una
costante per rendere la forma d'onda visibile sullo schermo. Ovviamente c'è la possibilità di applicare dei filtri al segnale da tastiera: con la lettera 'l' applichiamo un filtro passabasso, con 
la 'b' un filtro passabanda, con la 'h' un filtro passaalto e con la 'n' ritorniamo alla situazione iniziale (nessun filtro). La frequenza di taglio dei filtri varia in base alla posizione su y del mouse 
sullo schermo, in particolare se la coordinata y del mouse aumenta (quindi movimento verso il basso in base al sitema di riferimento in processing) anche la frequenza di taglio aumenta fino ad un valore massimo
di 10000 Hz. Il gioco termina quando si colpisce un ostacolo (cubo grigio) e il punteggio è determinato in base a quanti bonus (cubi di colore variabile) sono stati colpiti; per ogni cubo viene assegnato un
punteggio calcolato in base alla "velocità" con cui i cubi avanzano durante la partita. Questa velocità è determinata principalmente dall'intensità dei toni alti nello spettro della canzone di sottofondo.
Ho deciso di dare un minimo di importanza anche all'aspetto grafica 3D, ovvero ho cercato di fare in modo che ilsistema di gestione delle collisioni con i vari ostacoli fosse preciso. Il sistema è composto principalmente
da due funzioni, una che calcola la collisione sull'asse delle x e l'altra che calcola la collisione sull'asse delle z. Gli oggetti della scena si muovono quasi tutti solo sull'asse z, mentre il cubo scelto come
personaggio si muove anche su x per poter evitare gli ostacoli schivandoli lateralmente.


## Journal:

*18 luglio*

Sfogliata documentazione sulle librerie sound e minim di processing

*19 luglio*

Lettura degli esempi presenti nelle varie sezioni della documentazione per capire come sfruttare le varie funzionalità fornite dal software

*20 luglio*

* File di partenza: esempio minim/examples/Basics/AnalyseSound che mostra una FFT per analizzare un audio generato da un AudioPlayer
* Inserito oggetto cubo che rappresenterà il personaggio da muovere

*20 luglio - 25 agosto*

Gli obiettivi iniziali del progetto non sono sempre rimasti gli stessi, all'inizio avevo un'idea diversa da quella che alla fine ho scelto. In questo mese ho esplorato le
varie funzionalità offerte da Processing, ho visto qualche tutorial online e ho iniziato a portare avanti la prima delle idee che mi era venuta ma poi mi sono accorto che si
poteva fare di meglio allora ho cambiato gli obiettivi del progetto.

*25 agosto*

* Creata pista con tre corsie con ai lati rappresentazione della trasformata del segnale
* Inseriti ostacoli "buoni" e "cattivi" e limitata la loro posizione all'interno delle tre corsie
* Aggiunto avanzamento in 3D degli ostacoli sulla pista
* Bordi degli ostacoli, del personaggio e delle linee che delimitano le corsie della pista aumentano di spessore in base all'intensità dei toni alti della traccia sonora in esecuzione durante il minigioco

*26 agosto*

* Gestite le collisioni con gli ostacoli e con i bonus (su y non serve)
* Raggruppate in due funzioni le collisioni su X e su Z e commentato il relativo codice

*27 agosto*

* Inseriti filtri per il segnale (lowpass, highpass, bandpass)
* Scritta game over e punetggio su schermo in caso di game over
* Forma d'onda sulla sinistra della pista, la rappresentazione della sua trasformata sulla destra

## Da fare:

* Animare il personaggio con tasti freccia (da sistemare)
* Personaggio trapassato dalle linee quando ci passa sopra (trasparenza?)

## Link utili:

1) documentazione minim http://code.compartmental.net/minim/javadoc/

2) documentazione processing https://processing.org/reference/

## Futuri sviluppi

* Migliorare l'aspetto grafico del personaggio e degli ostacoli (sono tutti dei cubi)
* Inserire animazioni/suoni all'impatto con i vari tipi di ostacolo
