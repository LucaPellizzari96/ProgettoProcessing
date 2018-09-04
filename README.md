## Descrizione:

Il progetto si articola in due parti, entrambe basate su un evento comune in sottofondo: la riproduzione di una traccia audio in formato mp3 presa dalla cartella data, cartella
che contiene, oltre ad un paio di tracce, un font che utilizzo per stampare su schermo i valori relativi ai filtri e il punteggio del minigioco.

La prima parte mostra nella metà superiore della pagina la forma d'onda relativa al segnale audio in riproduzione, mentre nella metà inferiore lo spettro della trasformata del segnale.
C'è la possibilità di applicare dei filtri al segnale (lowpass, highpass, bandpass) e in base al filtro scelto, nella parte alta dello schermo, ci sono alcune statistiche che ci 
dicono qual'è il filtro attivo, qual'è la sua frequenza di taglio e nel caso di filtro passabanda qual'è la sua banda passante; inoltre una semplice rappresentazione grafica ci mostra
la zona dello spettro su cui il filtro agisce. Osservazione:

* Filtro passabasso (lowpass): filtro che permette il passaggio di frequenze al di sotto di una certa soglia detta frequenza di taglio, bloccando le alte frequenze;
* Filtro passa alto (highpass): filtro che permette solo il passaggio di frequenze al di sopra di un certo valore detto frequenza di taglio;
* Filtro passabanda (bandpass): filtro che permette il passaggio di frequenze all'interno di un dato intervallo (la cosiddetta banda passante) ed attenua le frequenze al di fuori di esso.

Dopo aver capito qual'è l'effetto dell'applicazione di questi tre filtri sullo spettro di un segnale la comprensione della rappresentazione grafica è immediata:

* Filtro passabasso: ho evidenziato la parte dello spettro con frequenza maggiore della frequenza di taglio (la parte che viene tagliata);
* Filtro passa alto: ho evidenziato la parte dello spettro con frequenza minore della frequenza di taglio;
* Filtro passabanda: ho evidenziato la parte dello spettro con frequenza minore della frequenza di taglio e la parte dello spettro con frequenza maggiore della somma: frequenza di taglio + banda passante.

La seconda parte è un minigioco con alcune caratteristiche (velocità di avanzamento degli ostacoli, spessore dei bordi degli oggetti e delle linee che formano la pista, colore di sottofondo e punteggio) che
dipendono dal valore dei toni bassi, medi e alti dello spettro della traccia audio in esecuzione. Ci sono tre corsie su cui il personaggio può transitare, si passa da una all'altra con i tasti direzionali (freccia destra e freccia sinistra): l'obiettivo del
minigioco è quello di evitare gli ostacoli "cattivi" (cubi di colore girgio i cui bordi cambiano spessore dinamicamente in funzione delle caratteristiche spettrali della traccia in esecuzione
durante la partita) e colpire gli ostacoli "buoni" (cubi il cui colore varia dinamicamente in base alle caratteristiche della traccia, anche per loro lo spessore dei bordi varia dinamicamente).
Le corsie sono delimitate da quattro "linee", due di queste, quelle centrali, sono semplici linee costruite utilizzando la funzione "line(x,y,z,x2,y2,z2)" che riceve
come argomento le coordinate di due punti e costruisce una linea che unisce i due punti. Le due "linee" più esterne invece rappresentano una (quella di destra) lo spettro della 
trasformata e l'altra (quella di sinistra) la forma d'onda del segnale. Anche queste due sono costruite sfruttando la funzione line() e variando le coordinate y dei due punti, una in base al
valore restituito dalla funzione fft.getBand(i) che restituisce l'ampiezza (float) della banda di frequenza i-esima; per la forma d'onda invece prendo un AudioBuffer che contenga il mix dei canali
left e right in questo modo: float[] mix = song.mix.toArray(); e poi ad ogni punto che passo alla funzione line() assegno un valore di y che dipende dal valore i-esimo contenuto nel buffer mix moltiplicato per una
costante per rendere la forma d'onda visibile sullo schermo. Ovviamente c'è la possibilità di applicare dei filtri al segnale da tastiera: con la lettera 'l' applichiamo un filtro passabasso, con 
la 'b' un filtro passa banda, con la 'h' un filtro passa alto e con la 'n' ritorniamo alla situazione iniziale (nessun filtro). La frequenza di taglio dei filtri varia in base alla posizione su y del mouse 
sullo schermo, in particolare se la coordinata y del mouse aumenta (quindi movimento verso il basso in base al sistema di riferimento in processing) anche la frequenza di taglio aumenta fino ad un valore massimo
di 10000 Hz. Il gioco termina quando si colpisce un ostacolo (cubo grigio) e il punteggio è determinato in base a quanti bonus (cubi di colore variabile) sono stati colpiti; per ogni cubo viene assegnato un
punteggio calcolato in base alla "velocità" con cui i cubi avanzano durante la partita. Questa velocità è determinata principalmente dall'intensità dei toni alti nello spettro della canzone di sottofondo.
Ho deciso di dare un minimo di importanza anche all'aspetto grafico, ovvero ho cercato di fare in modo che il sistema di gestione delle collisioni con i vari ostacoli fosse preciso. Il sistema è composto 
da due funzioni, una che calcola la collisione sull'asse delle x e l'altra che calcola la collisione sull'asse delle z. Gli oggetti della scena si muovono quasi tutti solo sull'asse z, mentre il cubo scelto come
personaggio si muove anche su x per poter evitare gli ostacoli schivandoli lateralmente. La velocità con cui gli ostacoli avanzano durante la partita è determinata dal valore della variabile globale scoreSum
che viene ricalcolata ad ogni frame in base ai valori delle tre zone dello spettro (bassi, medi, alti) secondo la formula scoreSum = 0.66 x lowValue + 0.8 x midValue + 1 x HighValue; quindi come già detto prima diamo
maggiore importanza ai toni alti. Volendo si può provare a modificare la formula nel modo seguente: scoreSum = 1 x lowValue + 0.8 x midValue + 0.66 x HighValue, in questo modo assegnamo peso maggiore alle basse frequenze
che sono quelle che notiamo maggiormente in quanto stimolano la coclea in regioni più ampie e distribuite spazialmente rispetto alle alte frequenze. 
Le variabili lowValue, midValue e highValue corrispondono alla somma dei valori dello spettro compresi nei tre range di frequenze:

* lowValue = 20-300 Hz
* midValue = 300-2600 Hz
* highValue = 2600-5500 Hz

Per quanto riguarda la scelta di questi valori ho cercato informazioni su diversi siti Internet, ho fatto una media e ho eseguito una serie di test per vedere quali si adattavano meglio alle caratteristiche del minigioco.

## Screenshots

 ![First scene](/screenshots/Screen-waveAndspectrum.png)
 ![Minigame](/screenshots/Screen-minigame.png)

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
* Animare il personaggio con tasti freccia (bug da risolvere)

*27 agosto*

* Inseriti filtri per il segnale (lowpass, highpass, bandpass)
* Scritta game over e punetggio su schermo in caso di game over
* Forma d'onda sulla sinistra della pista, la rappresentazione della sua trasformata sulla destra

*28 agosto*

* Risolto bug sul movimento del personaggio
* Risolto bug : personaggio trapassato dalle linee quando ci passa sopra (distrazione sui valori iniziali delle coordinate y del personaggio e degli ostacoli)
* Refactoring del main (raggruppati alcuni for e if in semplici funzioni)
* Modificata la posizione su z del personaggio
* Aggiunte Stats sul lato sinistro dello schermo con lo stato dei filtri

*31 agosto*

* Implementata prima parte della scena
* Possibilità di passare dalla prima parte alla seconda con la freccia in alto
* Refactoring del main e aggiunti commenti
* Feedback sui bonus presi: una scritta colorata con il punteggio che rimane attiva per qualche frame

*2 settembre*

* Risolto bug con il testo dopo il game over
* Inserita possibilità di effettuare screenshot premendo 's' da tastiera

*4 settembre*

* Ultimi fix
* Inserita unità di misura della frequenza nel testo che viene stampato a schermo

## Fonti:

1) documentazione minim http://code.compartmental.net/minim/javadoc/

2) documentazione processing https://processing.org/reference/

3) Wikipedia

## Tool software utilizzati:

Processing (versione 3.3.7)

## Futuri sviluppi

* Inserire scena iniziale con spettro della fft, parte reale dello spettro e parte immaginaria dello spettro
* Migliorare l'aspetto grafico del personaggio e degli ostacoli (sono tutti dei cubi)
* Inserire animazioni/suoni all'impatto con i vari tipi di ostacolo
* Inserire possibilità di saltare sopra gli ostacoli (ad esempio con la freccia in alto)
