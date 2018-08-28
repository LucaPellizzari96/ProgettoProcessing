import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
 
Minim minim;
AudioPlayer song;
FFT fft;
LowPassSP lowPass;
HighPassSP highPass;
BandPass bandPass;
PFont f;

// Variabili che definiscono le "zone" dello spettro, per esempio per i bassi prendiamo solo il primo 3% dello spettro totale
float specLow = 0.03;  // 3%
float specMid = 0.125;  // 12.5%
float specHi = 0.20;  // 20%

// Il restante 64% dello spettro possibile non sara' utilizzato
// Questi valori sono solitamente troppo alti per l'orecchio umano

// Valori del punteggio per ogni zona
float scoreLow = 0;
float scoreMid = 0;
float scoreHi = 0;

// Valori precedenti per ammorbidire/attenuare la riduzione
float oldScoreLow = scoreLow;
float oldScoreMid = scoreMid;
float oldScoreHi = scoreHi;

// "Attenuazione" => valore maggiore = velocita minore
float scoreDecreaseRate = 25;

float scoreGlobal = 0.0;

// PERSONAGGIO E OSTACOLI
Cube character;

int numObstacles = 5;
Obstacle[] obstacles = new Obstacle[numObstacles];

int numBonus = 2;
Bonus[] bonus = new Bonus[numBonus];

boolean gameOver = false;

float startingPoint;
float endingPoint;

// Distanza tra ogni punto della linea, negativo perche sulla dimensione z
float dist = -25;

float score = 0.0;

void setup(){
  
  // O fullScreen() oppure size() sono la prima riga obbligatoria del setup
  fullScreen(P3D); // P3D e' il renderer scelto
  
  // Carico il font per le scritte finali
  f = createFont("../data/SourceCodePro-Regular.ttf", 40);
  textFont(f);
 
  // Carico la libreria minim
  minim = new Minim(this);
 
  // Carico la canzone
  song = minim.loadFile("../data/song.mp3"); // carico il file in un AudioPlayer con bufferSize default = 1024
  
  // Creo l'oggetto FFT per analizzare la canzone, deve avere un buffer della stessa dimensione del buffer dell'oggetto song
  fft = new FFT(song.bufferSize(), song.sampleRate());

  // Creo tutti gli oggetti
  
  // Setto i confini per la posizione su x degli ostacoli e del personaggio
  startingPoint = width/5;
  endingPoint = width*4/5;
  
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
  oldScoreLow = scoreLow;
  oldScoreMid = scoreMid;
  oldScoreHi = scoreHi;
  
  // Reinizializzo i valori
  scoreLow = 0;
  scoreMid = 0;
  scoreHi = 0;
  
  // Calcolo i nuovi valori
  updateScores();
  
  // Faccio rallentare (attenuo) la velocita su z sottraendo scoreDecreaseRate
  checkAttenuation();
  
  // Colore "leggero" di sottofondo
  background(scoreLow/100, scoreMid/100, scoreHi/100);
 
  if(!gameOver){
  
    // Punteggio per tutte le frequenze in questo momento, l'animazione va + veloce per i suoni più acuti, che notiamo maggiormente
    scoreGlobal = 0.66*scoreLow + 0.8*scoreMid + 1*scoreHi;
    
    character.display();
    
    detectCollisions();
    
    displayObstacles();
    
    displayBonus();
    
    drawSpectrum();
    
    drawWaveform();
  
    updateFilter();
    
  }else{ // Game Over
  
    // Testo che indica il gameover
    fill(255);
    textAlign(CENTER);
    text("Game Over", width/2, height/2 -15);
    text("Press Enter to retry", width/2, height/2 + 30);
    text("Score: " + str(int(score)), width/2, height/2 + 80);
    
    // Metto in pausa la canzone
    song.pause();
    
    // Ripristino gli effetti iniziali (nessuno)
    song.clearEffects();
    
    // Resetto le impostazioni del personaggio (posizione,...)
    character.reset();
  }
  
}  // draw()

// Aggiorno il punteggio delle varie zone dello spettro
void updateScores(){
  for(int i = 0; i < fft.specSize()*specLow; i++){ // specSize() : restituisce la dimensione dello spettro creato dalla trasformata
    scoreLow += fft.getBand(i); // getBand() : restituisce l'ampiezza (float) della banda di frequenza richiesta
  }
  
  for(int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++){
    scoreMid += fft.getBand(i);
  }
  
  for(int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++){
    scoreHi += fft.getBand(i);
  }
} // updateScores()

// Controllo se i vecchi valori dei punteggi sono maggiori di quelli attuali e in caso affermativo calcolo l'attenuazione
void checkAttenuation(){
  if (oldScoreLow > scoreLow){
    scoreLow = oldScoreLow - scoreDecreaseRate;
  }
  
  if (oldScoreMid > scoreMid){
    scoreMid = oldScoreMid - scoreDecreaseRate;
  }
  
  if (oldScoreHi > scoreHi){
    scoreHi = oldScoreHi - scoreDecreaseRate;
  }
} // checkAttenuation()

void displayObstacles(){
  for(int i = 0; i < numObstacles; i++){
    obstacles[i].display();
  }
} // displayObstacles()

void displayBonus(){
  for(int i = 0; i < numBonus; i++){
    bonus[i].display();
  }
} // displayBonus()

void drawSpectrum(){
  for(int i = 0; i < fft.specSize(); i++){
    
    float bandValue = fft.getBand(i);
    line(width*2/5, height, dist*i, width*2/5, height,dist*(i+1)); // linea fra la prima e la seconda corsia
    line(width*3/5, height, dist*i, width*3/5, height,dist*(i+1)); // linea fra la seconda e la terza corsia
    line(endingPoint, height, dist*i, endingPoint, height-bandValue*1.5,dist*i); // confine destro della pista
    
  } // for

} // drawSpectrum()

void drawWaveform(){
  
  float[] mix = song.mix.toArray();
  
  for(int j = 0; j < mix.length - 1; j++){
    line(startingPoint, height - mix[j]*150, dist*j, startingPoint, height - mix[j+1]*150, dist*(j+1)); // confine sinistro della pista
  }
  
} // drawWaveform()

void detectCollisions(){
  for(int i = 0; i < numObstacles; i++){
    if(collisionDetection(obstacles[i].x, obstacles[i].z)){
      gameOver = true;
      obstacles[i].z = 300;
    }
  }
  for(int j = 0; j < numBonus; j++){
    if(collisionDetection(bonus[j].x, bonus[j].z)){
      bonus[j].z = 300;
      score += 0.05*scoreGlobal;
    }
  }
} // detectCollision()

boolean collisionDetection(float x, float z){
  if(collisionX(x) && collisionZ(z)){
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
      case ENTER:
        if(gameOver){ // se ho perso
          // riprendo la partita
          song.rewind();
          song.loop();
          gameOver = false;
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
      lowPass = new LowPassSP(200, 44100); // cutoff frequency e samplerate
      song.addEffect(lowPass);
      break;
    case 1:
      song.clearEffects();
      highPass = new HighPassSP(600, 44100); // cutoff frequency e samplerate
      song.addEffect(highPass);
      break;
    case 2:
      song.clearEffects();
      bandPass = new BandPass(200, 700, 44100); // cutoff frequency, bandWidth to pass e samplerate
      song.addEffect(bandPass);
      break;
    case 3:
      song.clearEffects();
      break;
    default:
      break;
  } // switch
} // addEffect()

// Aggiorno la frequenza di taglio dei filtri in base alla posizione del mouse su Y
void updateFilter(){
  if(song.hasEffect(lowPass)){
    lowPass.setFreq( map(mouseY, height, 0, 10000, 100));
  }else if(song.hasEffect(highPass)){
    highPass.setFreq( map(mouseY, height, 0, 10000, 100));
  }else if(song.hasEffect(bandPass)){
    bandPass.setFreq( map(mouseY, height, 0, 10000, 300));
  }
} // updateFilter()
