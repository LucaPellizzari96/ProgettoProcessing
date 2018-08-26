import ddf.minim.*;
import ddf.minim.analysis.*;
 
Minim minim;
AudioPlayer song;
FFT fft;

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

void setup()
{
  // O fullScreen() oppure size() sono la prima riga obbligatoria del setup
  fullScreen(P3D); // P3D e' il renderer scelto
 
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
  song.play(0);
  
} // setup
 
void draw()
{
  // Fa avanzare la canzone, draw() per ogni "frame" della canzone
  fft.forward(song.mix); // mix : AudioBuffer che contiene il mix dei canali left e right
  // se mono mix contiene solo i campioni left e right contiene gli stessi campioni di left
  
  // Calcolo di "punteggi" (potenza) per le tre categorie di suoni
  // Prima di tutto salvo i vecchi valori
  oldScoreLow = scoreLow;
  oldScoreMid = scoreMid;
  oldScoreHi = scoreHi;
  
  // Reinizializzo i valori
  scoreLow = 0;
  scoreMid = 0;
  scoreHi = 0;
 
  // Calcolo i nuovi valori
  for(int i = 0; i < fft.specSize()*specLow; i++) // specSize() : restituisce la dimensione dello spettro creato dalla trasformata
  {
    scoreLow += fft.getBand(i); // getBand() : restituisce l'ampiezza (float) della banda di frequenza richiesta
  }
  
  for(int i = (int)(fft.specSize()*specLow); i < fft.specSize()*specMid; i++)
  {
    scoreMid += fft.getBand(i);
  }
  
  for(int i = (int)(fft.specSize()*specMid); i < fft.specSize()*specHi; i++)
  {
    scoreHi += fft.getBand(i);
  }
  
  // Faccio rallentare (attenuo) la velocita su z sottraendo scoreDecreaseRate
  
  if (oldScoreLow > scoreLow) {
    scoreLow = oldScoreLow - scoreDecreaseRate;
  }
  
  if (oldScoreMid > scoreMid) {
    scoreMid = oldScoreMid - scoreDecreaseRate;
  }
  
  if (oldScoreHi > scoreHi) {
    scoreHi = oldScoreHi - scoreDecreaseRate;
  }
  
  // Volume per tutte le frequenze in questo momento, con i suoni più alti + importanti
  // Cio' consente all'animazione di andare + veloce per i suoni più acuti, che notiamo maggiormente
  scoreGlobal = 0.66*scoreLow + 0.8*scoreMid + 1*scoreHi;
  // Colore "leggero" sfondo
  background(scoreLow/100, scoreMid/100, scoreHi/100);
  
  
  if(!gameOver){
    character.display();
    
    detectCollisions();
  }
     
  displayObstacles();
    
  displayBonus();
    
  drawSpectrum();
  
}  // draw

void displayObstacles(){
  for(int i = 0; i < numObstacles; i++){
    obstacles[i].display();
  }
}

void displayBonus(){
  for(int i = 0; i < numBonus; i++){
    bonus[i].display();
  }
}

void drawSpectrum(){
  for(int i = 0; i < fft.specSize(); i++){
    
    float bandValue = fft.getBand(i);

    line(startingPoint, height, dist*i, startingPoint, height-bandValue*1.5,dist*i); // confine sinistro della pista
    line(width*2/5, height, dist*i, width*2/5, height,dist*(i+1)); // linea fra la prima e la seconda corsia
    line(width*3/5, height, dist*i, width*3/5, height,dist*(i+1)); // linea fra la seconda e la terza corsia
    line(endingPoint, height, dist*i, endingPoint, height-bandValue*1.5,dist*i); // confine destro della pista
    
  }
}

void detectCollisions(){
  for(int i = 0; i < numObstacles; i++){
    if(collisionDetection(obstacles[i].x, obstacles[i].z)){
      gameOver = true;
      obstacles[i].z = 5;
    }
  }
  for(int j = 0; j < numBonus; j++){
    if(collisionDetection(bonus[j].x, bonus[j].z)){
      bonus[j].z = 5;
    }
  }
}

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
  
}

boolean collisionZ(float z){
  
  boolean collisionZ = false;
  
  // Supponiamo che gli ostacoli siano rivolti verso di noi, mentre il personaggio ci da le spalle
  
  // parte avanti
  if(z + 50.0 >= -225.0){ // parte avanti (quella che guarda verso di noi) dell'ostacolo + avanti rispetto alla parte avanti (quella non verso di noi) del personaggio e
    if(z + 50.0 <= -125.0){ // parte avanti dell'ostacolo + indietro della parte dietro (la faccia del cubo che "guarda" verso di noi) del personaggio
    collisionZ = true;
    }
  }
  // parte dietro
  if(z - 50.0 >= - 225.0){ // parte dietro (quella che non guarda verso di noi) dell'ostacolo + avanti rispetto alla parte avanti (quella non verso di noi) del personaggio e
    if(z - 50.0 <= -125.0){ // parte dietro dell'ostacolo + indietro della parte dietro (la faccia del cubo che "guarda" verso di noi) del personaggio
    collisionZ = true;
    }
  }
  
  return collisionZ;
  
}
