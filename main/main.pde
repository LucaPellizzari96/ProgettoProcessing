import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import java.util.*;
 
Minim minim;
AudioPlayer song;
FFT fft;
LowPassSP lowPass;
HighPassSP highPass;
BandPass bandPass;
PFont f; // font per stampare le stats su schermo

String filter = "No filter"; // mi dice qual'e il tipo di filtro attivo: No filter, LowPass,...
float cutoffFrequency = 0.0; // si riferisce al filtro attivo in questo momento
float bandWidthToPass = 0.0; // vale solo per il filtro passabanda

// Variabili che definiscono le "zone" dello spettro (bassi 20-300 Hz, medi 300-2600 Hz, alti 2600-5500 Hz)
float lowSpectrum = 0.015;  // 1.5%
float midSpectrum = 0.12;  // 12%
float highSpectrum = 0.25;  // 25%

// Valori del punteggio per ogni zona
float lowValue = 0;
float midValue = 0;
float highValue = 0;

// Valori precedenti per ammorbidire/attenuare la riduzione
float oldLowValue = lowValue;
float oldMidValue = midValue;
float oldHighValue = highValue;

// "Attenuazione" => valore maggiore = velocita minore
float attenuation = 25;
// Somma dei valori dei punteggi delle tre zone (alti, medi, bassi), dipende dai valori dello spettro
float scoreSum = 0.0;

// PERSONAGGIO E OSTACOLI
Cube character; // Personaggio appartiene alla classe Cube

int numObstacles = 4; // numero massimo di ostacoli visibili sulla pista in un certo momento
Obstacle[] obstacles = new Obstacle[numObstacles];

int numBonus = 2; // numero massimo di bonus visibili sulla pista in un certo momento
Bonus[] bonus = new Bonus[numBonus];

boolean gameOver = false;

float dist = -25; // distanza fra due punti consecutivi della waveform e della fft su z

float score = 0.0; // punteggio della partita

boolean gameOn = false; // mi dice se sto facendo il minigioco (true) oppure sto visualizzando la pagina iniziale con fft e waveform (false)

int frame = 0; // per contare la durata in frame delle scritte che appaiono quando collido con un bonus
Vector<String> points = new Vector<String>(); // contiene i valori per ogni bonus con cui collido e li mostra su schermo per un certo numero di frame (un valore alla volta)

void setup(){
  
  // fullScreen() oppure size() sono la prima riga obbligatoria del setup
  fullScreen(P3D); // P3D e' il renderer scelto
  
  // Carico il font per le scritte
  f = createFont("../data/SourceCodePro-Regular.ttf", 40);
  textFont(f);
 
  // Carico la libreria minim
  minim = new Minim(this);
 
  // Carico la canzone
  song = minim.loadFile("../data/song.mp3"); // carico il file in un AudioPlayer con bufferSize default = 1024
  
  // Creo l'oggetto FFT per analizzare la canzone, deve avere un buffer della stessa dimensione del buffer dell'oggetto song
  fft = new FFT(song.bufferSize(), song.sampleRate());

  // Personaggio
  character = new Cube();
  
  // Ostacoli
  for (int i = 0; i < numObstacles; i++) {
   obstacles[i] = new Obstacle(); 
  }
  
  // Bonus
  for (int i = 0; i < numBonus; i++) {
   bonus[i] = new Bonus(); 
  }
  
  // Sfondo nero
  background(0);
  
  // Avvio la canzone
  song.loop();
  
} // setup
 
void draw(){
  
  // Fa avanzare la canzone, draw() per ogni "frame" della canzone
  fft.forward(song.mix); // mix : AudioBuffer che contiene il mix dei canali left e right
  // se mono mix contiene solo i campioni left e right contiene gli stessi campioni di left
  
  // Calcolo di "punteggi" (potenza) per le tre categorie di suoni, dopo aver salvato i valori precedenti
  oldLowValue = lowValue;
  oldMidValue = midValue;
  oldHighValue = highValue;
  
  // Reinizializzo i valori
  lowValue = 0;
  midValue = 0;
  highValue = 0;
  
  // Aggiorno in base ai valori nelle varie zone dello spettro
  updateSpectrumValues();
  
  // Faccio rallentare (attenuo) la velocita su z sottraendo attenuation se i punteggi sono inferiori rispetto a quelli del frame precedente
  checkAttenuation();

  // Scelgo se mostrare il minigioco oppure la scena iniziale
  if(gameOn){
    playGame();
  }else{
    stroke(255);
    strokeWeight(1);
    playScene();
  }
  
}  // draw()

void playScene(){ // scena con forma d'onda in alto e spettro della trasformata in basso
  
  background(0); // sfondo nero
  
  drawWaveform();
  
  drawSpectrum();
  
  updateFilter(); // aggiorno i valori dei filtri in base alla posizione del mouse
  
  // Stats in alto
  fill(255); // colore del font -> bianco
  text(filter, width/100, height/20); // tipo di filtro: No filter, LowPass,...
  if(cutoffFrequency > 0.0) text("Cutoff Frequency: " + str(int(cutoffFrequency)), width/6, height/20);
  if(bandWidthToPass > 0.0) text("BandWidthToPass: " + str(int(bandWidthToPass)), width/1.75, height/20);

} // playScene()

void playGame(){
   
  if(!gameOver){
    
    // Colore "leggero" di sottofondo
    background(lowValue/100, midValue/100, highValue/100);
  
    // Punteggio per tutte le frequenze in questo momento, l'animazione va + veloce per i suoni più acuti
    scoreSum = 0.66*lowValue + 0.8*midValue + 1*highValue;
    
    character.display();
    
    detectCollisions();
    
    displayObstacles();
    
    displayBonus();
    
    drawWaveform();
    
    drawMidLines();
     
    drawSpectrum();
  
    updateFilter();
    
    printStats();
    
    printPoints();
    
  }else{ // Game Over
  
    background(0);
  
    // Testo che indica il gameover e il punteggio raggiunto
    printGameOver();
    
    // Metto in pausa la canzone
    song.pause();
    song.rewind();
    
    // Ripristino gli effetti iniziali (nessun filtro)
    addEffect(3);
    
    // Resetto le impostazioni del personaggio (posizione,...)
    character.reset();
    
  } // gameOver
  
} // playGame()

// Aggiorno i valori delle varie zone dello spettro
void updateSpectrumValues(){
  for(int i = 0; i < fft.specSize()*lowSpectrum; i++){ // specSize() : restituisce la dimensione dello spettro creato dalla trasformata
    lowValue += fft.getBand(i); // getBand() : restituisce l'ampiezza (float) della banda di frequenza richiesta
  }

  for(int i = (int)(fft.specSize()*lowSpectrum); i < fft.specSize()*midSpectrum; i++){
    midValue += fft.getBand(i);
  }

  for(int i = (int)(fft.specSize()*midSpectrum); i < fft.specSize()*highSpectrum; i++){
    highValue += fft.getBand(i);
  }
  
} // updateSpectrumScores()

// Controllo se i vecchi valori dei punteggi sono maggiori di quelli attuali e in caso affermativo calcolo l'attenuazione per la scena
void checkAttenuation(){
  if (oldLowValue > lowValue){
    lowValue = oldLowValue - attenuation;
  }
  
  if (oldMidValue > midValue){
    midValue = oldMidValue - attenuation;
  }
  
  if (oldHighValue > highValue){
    highValue = oldHighValue - attenuation;
  }
} // checkAttenuation()

// Mostro gli ostacoli sulla scena
void displayObstacles(){
  for(int i = 0; i < numObstacles; i++){
    obstacles[i].display();
  }
} // displayObstacles()

// Mostro i bonus sulla scena
void displayBonus(){
  for(int i = 0; i < numBonus; i++){
    bonus[i].display();
  }
} // displayBonus()

void drawWaveform(){
  
  float[] mix = song.mix.toArray();
  
  if(gameOn){ // minigioco
    for(int j = 0; j < mix.length - 1; j++){
      line(width/5, height - mix[j]*150, dist*j, width/5, height - mix[j+1]*150, dist*(j+1)); // confine sinistro della pista
    } // for
  }else{ // scena iniziale
    for(int j = 0; j < mix.length - 1; j++){
      float x = map(j, 0, mix.length-1, 1, width);
      line(x, height/2 - mix[j]*150 - 80, -5, x+1, height/2 - mix[j+1]*150 - 80, -5); // disegno la Waveform in alto
    } // for  
  }
  
} // drawWaveform()

void drawSpectrum(){
  
  if(gameOn){ // minigioco
    for(int i = 0; i < fft.specSize() - 1; i++){
      // Scelgo il colore delle linee in base ai settaggi dei filtri
      if(fft.indexToFreq(i) >= cutoffFrequency && filter == "LowPass"){
        stroke(255,0,0); // rosso
      }else if(fft.indexToFreq(i) <= cutoffFrequency && filter == "HighPass"){
        stroke(255,0,0); // rosso
      }else if((fft.indexToFreq(i) <= cutoffFrequency || fft.indexToFreq(i) >= cutoffFrequency + bandWidthToPass) && filter == "BandPass"){
        stroke(255,0,0); // rosso
      }else{ // no filters
        stroke(255); // bianco
      }
        line(width*4/5, height - fft.getBand(i)*1.5, dist*i, width*4/5, height - fft.getBand(i+1)*1.5,dist*(i+1)); // confine destro della pista, spettro del segnale
    } // for
  }else{ // scena iniziale
    for(int i = 0; i < fft.specSize() - 1; i++){
      // Scelgo il colore delle linee in base ai settaggi dei filtri
      if(fft.indexToFreq(i) >= cutoffFrequency && filter == "LowPass"){
        stroke(255,0,0); // rosso
      }else if(fft.indexToFreq(i) <= cutoffFrequency && filter == "HighPass"){
        stroke(255,0,0); // rosso
      }else if((fft.indexToFreq(i) <= cutoffFrequency || fft.indexToFreq(i) >= cutoffFrequency + bandWidthToPass) && filter == "BandPass"){
        stroke(255,0,0); // rosso
      }else{ // no filters
        stroke(255); // bianco
      }
      float x = map(i, 0, fft.specSize()-1, 1, width);
      line(x, height - fft.getBand(i)*1.5 - 5, x+1, height - fft.getBand(i+1)*1.5 - 5); // spettro su x, y; non considero la z non mi interessa in questa scena
    } // for
  }
  
} // drawSpectrum()

void drawMidLines(){
  for(int i = 0; i < fft.specSize(); i++){
    line(width*2/5, height, dist*i, width*2/5, height,dist*(i+1)); // linea fra la prima e la seconda corsia nel minigioco
    line(width*3/5, height, dist*i, width*3/5, height,dist*(i+1)); // linea fra la seconda e la terza corsia nel minigioco
  } // for
} // drawMidLines()

void detectCollisions(){
  for(int i = 0; i < numObstacles; i++){
    if(collisionDetection(obstacles[i].x, obstacles[i].z)){ // se collido con un ostacolo
      gameOver = true;
      obstacles[i].z = 300; // essendo la z dell'ostacolo maggiore del valore maxZ = 0 che puo assumere, al prossimo frame questo ostacolo sparisce dalla scena
    }
  } // for
  for(int j = 0; j < numBonus; j++){
    if(collisionDetection(bonus[j].x, bonus[j].z)){ // collisione con un bonus
      bonus[j].z = 300; // essendo la z del bonus maggiore del valore maxZ = 0 che puo assumere, al prossimo frame questo bonus sparisce dalla scena
      score += 0.05*scoreSum; // il punteggio che vale il bonus dipende dal valore delle tre zone dello spettro
      String pt = "+ " + int(0.05*scoreSum);
      points.add(pt); // salvo questo valore nel vettore con i valori dei punteggi dei bonus colpiti
    }
  } // for
} // detectCollision()

boolean collisionDetection(float x, float z){
  if(collisionX(x) && collisionZ(z)){ // non serve controllare su y, gli ostacoli si trovano tutti alla stessa altezza (per ora) e hanno tutti le stesse dimensioni
    return true;
  }else{  
    return false;
  }  
} // collisionDetection()

boolean collisionX(float x){
  
  boolean collisionX = false;
  // collisione con ostacolo a sinistra del personaggio
  if(x + 50.0 >= character.x - 50.0){ // parte destra dell'ostacolo + a destra della parte sinistra del personaggio e
    if(x + 50.0 <= character.x + 50.0){ // parte destra dell'ostacolo + a sinistra della parte destra del personaggio
    collisionX = true;
    }
  }
  // collisione con ostacolo a destra del personaggio
  if(x - 50.0 >= character.x - 50.0){ // parte sinistra dell'ostacolo + a destra rispetto alla parte sinistra del personaggio e
    if(x - 50.0 <= character.x + 50.0){ // parte sinistra dell'ostacolo + a sinistra della parte destra del personaggio
    collisionX = true;
    }
  }
  return collisionX;
  
} // collisionX()

boolean collisionZ(float z){
  
  boolean collisionZ = false;
  
  // Supponiamo che gli ostacoli siano rivolti verso di noi, mentre il personaggio ci da le spalle
  
  // parte avanti
  if(z + 50.0 >= -200.0){ // parte avanti (quella che guarda verso di noi) dell'ostacolo + avanti rispetto alla parte avanti (quella non verso di noi) del personaggio e
    if(z + 50.0 <= -100.0){ // parte avanti dell'ostacolo + indietro della parte dietro (la faccia del cubo che "guarda" verso di noi) del personaggio
    collisionZ = true;
    }
  }
  // parte dietro
  if(z - 50.0 >= - 200.0){ // parte dietro (quella che non guarda verso di noi) dell'ostacolo + avanti rispetto alla parte avanti (quella non verso di noi) del personaggio e
    if(z - 50.0 <= -100.0){ // parte dietro dell'ostacolo + indietro della parte dietro (la faccia del cubo che "guarda" verso di noi) del personaggio
    collisionZ = true;
    }
  }
  
  return collisionZ;
  
} // collisionZ()

// Gestisco il movimento del personaggio e i filtri in base ai tasti premuti
void keyPressed(){
  if(key == CODED){ // carattere speciale
    switch(keyCode){ // keyCode : variabile speciale per riconoscere alcuni caratteri particolari
      case LEFT:
        character.moveLeft = true;
        character.moveRight = false;
        break;
      case RIGHT:
        character.moveRight = true;
        character.moveLeft = false;
        break;
      case UP:
        if(!gameOver) gameOn = !gameOn; // freccia in alto, passo da scena iniziale a minigioco e viceversa
        break;
      default:
        break;
    } // switch
  }else{ // carattere normale
    switch(key){ // key : variabile per i caratteri non speciali
      case 'l': // lowpass
        addEffect(0);
        break;
      case 'h': // highpass
        addEffect(1);
        break;
      case 'b': // bandpass
        addEffect(2);
        break;
      case 'n': // no filter
        addEffect(3);
        break;
      case 's': // screenshot
        saveFrame("line-####.png");
        break;
      case ENTER:
        if(gameOver){ // se ho perso
          // riprendo la partita
          gameOver = false;
          song.loop();
          score = 0.0;
        }
        break;
      default:
        break;
    } // switch
  }
    
} // keyPressed()

// Funzione che dato un intero in [0,...,3] applica un filtro al segnale in base al valore dell'intero
void addEffect(int effect){
  switch(effect){
    case 0:
      song.clearEffects(); // rimuovo effetti precedenti (se presenti)
      lowPass = new LowPassSP(20, 44100); // cutoff frequency e samplerate
      song.addEffect(lowPass);
      filter = "LowPass";
      bandWidthToPass = 0.0;
      break;
    case 1:
      song.clearEffects();
      highPass = new HighPassSP(20, 44100); // cutoff frequency e samplerate
      song.addEffect(highPass);
      filter = "HighPass";
      bandWidthToPass = 0.0;
      break;
    case 2:
      song.clearEffects();
      bandPass = new BandPass(400, 700, 44100); // cutoff frequency = the center frequency of the band to pass (in Hz), bandWidth to pass = la larghezza di banda da filtrare e samplerate
      song.addEffect(bandPass);
      filter = "BandPass";
      break;
    case 3:
      song.clearEffects();
      filter = "No filter";
      cutoffFrequency = 0.0;
      bandWidthToPass = 0.0;
      break;
    default:
      break;
  } // switch
} // addEffect()

// Aggiorno la frequenza di taglio dei filtri in base alla posizione del mouse su Y (e per il filtro passabanda la banda passante in base alla posizione del mouse su x)
void updateFilter(){
  if(song.hasEffect(lowPass)){
    cutoffFrequency = map(mouseY, height, 0, 10000, 20); // mappo la posizione del mouse su y che va da height a 0 nell'intervallo 10000 - 20
    lowPass.setFreq( cutoffFrequency );
  }else if(song.hasEffect(highPass)){
    cutoffFrequency = map(mouseY, height, 0, 10000, 20);
    highPass.setFreq( cutoffFrequency);
  }else if(song.hasEffect(bandPass)){
    cutoffFrequency = map(mouseY, height, 0, 10000, 300);
    bandPass.setFreq( cutoffFrequency );
    bandWidthToPass = map(mouseX, 0, width, 400, 1500);
    bandPass.setBandWidth( bandWidthToPass );
  }
} // updateFilter()

// Stampo i valori impostati per i filtri (se presenti)
void printStats(){
    fill(255); // colore del font -> bianco
    textAlign(LEFT);
    text("Filter: " + filter, width/100, height/20); // tipo del filtro: LowPass, HighPass, BandPass
    if(cutoffFrequency > 0.0) text("Cutoff Frequency: " + str(int(cutoffFrequency)), width/100, height/10); // valore della frequenza di taglio
    if(bandWidthToPass > 0.0) text("BandWidthToPass: " + str(int(bandWidthToPass)), width/100, height/6.5); // valore della banda passante
} // printStats()

void printPoints(){
  if(frame > 12){ // lascio il testo (punti guadagnati colpendo il bonus) per 12 frame poi lo tolgo
    frame = 0;
    if(points.size() > 0) points.remove(points.get(0));
  }else if(points.size() > 0){ // solo se ho elementi nel Vector points altrimenti non faccio nulla
    fill(lowValue*0.67, midValue*0.67, highValue*0.67); // colore del testo: dipende dallo spettro
    text(points.get(0), width/2, height/2);
    frame++; // conto i frame per sapere quando smettere di mostrare il testo sullo schermo
  }
} // printPoints()

void printGameOver(){
  fill(255);
  textAlign(CENTER);
  text("Game Over", width/2, height/2 -15);
  text("Press Enter to retry", width/2, height/2 + 30);
  text("Score: " + str(int(score)), width/2, height/2 + 80);
} // printGameOver()
