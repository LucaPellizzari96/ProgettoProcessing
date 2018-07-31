/**
  * This sketch demonstrates how to use an FFT to analyze
  * the audio being generated by an AudioPlayer.
  * 
  * FFT stands for Fast Fourier Transform, which is a 
  * method of analyzing audio that allows you to visualize 
  * the frequency content of a signal. You've seen 
  * visualizations like this before in music players 
  * and car stereos.
  *
  */

import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.*;

Minim minim;
AudioPlayer song;
FFT fft;
LowPassSP lowPass;
HighPassSP highPass;
BandPass bandPass;

// Personaggio
Character character = new Character();
// Ostacoli buoni
int numObstacles = 3; // numero di ostacoli
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>(); // array che contiene gli ostacoli
// Ostacoli cattivi
int numEnemies = 3; // numero di ostacoli
ArrayList<Obstacle> enemies = new ArrayList<Obstacle>(); // array che contiene gli ostacoli
// Spettro
EllipticSpectrum ellipse = new EllipticSpectrum();
//RectangularWaveform rectangle = new RectangularWaveform();
Lifeline lifeline = new Lifeline();
// Costruzione ellisse
float a = 2; // dimensioni dell'ellisse (orizzontale); dimensione verticale b = 1 => non serve scriverla
float incrementoAngolo = 360.0/512.0; // incremento dell'angolo = numero di gradi/numero di campioni
float angolo = 0; // angolo per lo spettro attorno alla circonferenza (mappata in un'ellisse)
// Punteggio
float score = 750.0;
int frame = 0;

void setup()
{
  fullScreen(P3D);
  
  minim = new Minim(this);
  
  // specify that we want the audio buffers of the AudioPlayer
  // to be 1024 samples long because our FFT needs to have 
  // a power-of-two buffer size and this is a good size.
  song = minim.loadFile("../data/song.mp3", 1024);
  
  // loop the file indefinitely
  song.loop();
  
  // create an FFT object that has a time-domain buffer 
  // the same size as song's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  fft = new FFT( song.bufferSize(), song.sampleRate() );
  
  fft.linAverages(128); // TODO
 
  // Inserisco gli ostacoli buoni nell'arraylist
  for(int i = 0; i < numObstacles; i++){
   Obstacle obstacle = new Obstacle();
   obstacles.add(obstacle);
  }
  
  // Inserisco gli ostacoli cattivi nell'arraylist
  for(int i = 0; i < numEnemies; i++){
   Obstacle enemie = new Obstacle();
   enemies.add(enemie);
  }
  
} // setup()

void draw()
{
  background(0);
  
  // perform a forward FFT on the samples in song's mix buffer,
  // which contains the mix of both the left and right channels of the file
  fft.forward( song.mix );
  
  // Traslo per fare in modo che la scena sia al centro dello schermo
  translate(width/2, height/2, 0);
  
  stroke(255,255,0); // mobileAverage lifeline in giallo
  lifeline.display();
  
  stroke(255,0,0); // bordo rosso per il personaggio
  character.display(); // grazie alla traslazione viene posizionato al centro (inizialmente)
  
  updateObstacles();
  
  updateEnemies();
  
  updateFilter();
  
  stroke(0,0,255);  // blu per lo spettro
  
  ellipse.display(); // spettro ellittico

  checkScore();
  
  frame++;
    
}  // draw()

// Gestisco il movimento del personaggio e i filtri in base ai tasti premuti
void keyPressed(){
  if(key == CODED){ // carattere speciale
    switch(keyCode){ // keyCode : variabile speciale per riconoscere alcuni caratteri particolari
      case UP:
        character.animate();
        break;
      case DOWN:
        character.invertAngle();
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
        if(character.gameOver){ // se ho perso
          // riprendo la partita
          song.rewind();
          song.loop();
          character.gameOver = false;
          character.animation = true;
          score = 750;
        }
        break;
      default:
        break;
    } // switch
  }
    
} // keyPressed()

// Funzione che inserisce un nuovo ostacolo "buono" nell'ArrayList
void insertObstacle(){
    Obstacle obstacle = new Obstacle();
    obstacles.add(obstacle);
}

// Funzione che inserisce un nuovo ostacolo "cattivo" nell'ArrayList
void insertEnemie(){
    Obstacle enemie = new Obstacle();
    enemies.add(enemie);
}

// Funzione che date le dimensioni e i "confini" di due figure (circonferenza e rettangolo) mi dice se queste si intersecano
boolean collisionDetection(float boxx, float boxy,float boxWidth, float boxHeight, float circleCenterX, float circleCenterY, float radius){
  
  float closeX = circleCenterX;
  float closeY = circleCenterY;
  
  // controllo il lato sx del rettangolo
  if(circleCenterX < boxx) closeX = boxx;
  
  // lato dx del rettangolo
  if(circleCenterX > boxx + boxWidth) closeX = boxx + boxWidth;
  
  // controllo il lato superiore del rettangolo
  if(circleCenterY < boxy) closeY = boxy;
  
  // lato inferiore del rettangolo
  if(circleCenterY > boxy + boxHeight) closeY = boxy + boxHeight;
  
  // distanza fra le due figure
  float distance = sqrt(sq(closeX - circleCenterX) + sq(closeY - circleCenterY));
  
  if(distance < radius) return true;
  
  return false;
  
} // collisionDetection()

// Aggiorno ostacoli "buoni" e gestisco le eventuali collisioni con essi
void updateObstacles(){
  stroke(0,255,0); // bordo verde
  
  for(int i = 0; i < obstacles.size(); i++){ // per ogni ostacolo
    Obstacle temp = obstacles.get(i);
    // Controllo se l'ostacolo deve sparire per il tempo
    if(temp.R <= 0){
     obstacles.remove(i);
     insertObstacle();
    }
    // Controllo le collisioni con il personaggio: scrivo gia i valori delle dimensioni per non dover accedere ogni volta agli oggetti
    if(collisionDetection(temp.x, temp.y, 30.0, 30.0, character.x, character.y, 25.0)){
     score += 15; // incremento il punteggio
     if(score > 750.0){
       score = 750.0; // normalizzo il punteggio se va oltre il massimo
     }
     obstacles.remove(i); // rimuovo l'ostacolo colpito e
     insertObstacle(); // ne inserisco uno nuovo
    }
     temp.display();
  } // for
  
} // updateObstacles()

// Aggiorno ostacoli "cattivi" e gestisco le eventuali collisioni con essi
void updateEnemies(){
  stroke(255,0,255); // bordo viola

  for(int i = 0; i < enemies.size(); i++){
    Obstacle temp = enemies.get(i);
    // Controllo se l'ostacolo deve sparire per il tempo
    if(temp.R <= 0){
     enemies.remove(i);
     insertEnemie();
    }
    // Controllo le collisioni con il personaggio: scrivo gia i valori delle dimensioni per non dover accedere ogni volta agli oggetti
    if(collisionDetection(temp.x, temp.y, 30.0, 30.0, character.x, character.y, 25.0)){
     score -= 10; // decremento il punteggio
     enemies.remove(i); // rimuovo l'ostacolo colpito e
     insertEnemie(); // ne inserisco uno nuovo
    }
     temp.display();
  } // for
  
} // updateEnemies()

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
    bandPass.setFreq( map(mouseY, height, 0, 10000, 100));
  }
}

// Controllo il punteggio
void checkScore(){
  if(score > 0){ // punteggio non negativo
    if(frame > 4){ // ogni 4 frame
      score--;
      frame = 0;
    }
  }else{ // score <= 0 quindi game over
    character.gameOver = true;
    song.pause();
  }
} // checkScore()

// Funzione che interrompe l'animazione
void stop()
{
  song.close();
  minim.stop();
  super.stop();
}
