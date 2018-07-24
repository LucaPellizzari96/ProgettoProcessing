/**
  * This sketch demonstrates how to use an FFT to analyze
  * the audio being generated by an AudioPlayer.
  * <p>
  * FFT stands for Fast Fourier Transform, which is a 
  * method of analyzing audio that allows you to visualize 
  * the frequency content of a signal. You've seen 
  * visualizations like this before in music players 
  * and car stereos.
  * <p>
  * For more information about Minim and additional features, 
  * visit http://code.compartmental.net/minim/
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
// personaggio e ostacoli
Character character = new Character();  // costruttore del personaggio
int numObstacles = 3; // numero di ostacoli "buoni"
ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>(); // array che contiene gli ostacoli
int numEnemies = 3; // numero di ostacoli "dannosi"
ArrayList<Obstacle> enemies = new ArrayList<Obstacle>(); // array che contiene gli ostacoli
EllipticSpectrum ellipse = new EllipticSpectrum();
//SphereSpectrum sphere = new SphereSpectrum();
// costruzione ellisse
float a = 2; // dimensioni dell'ellisse (orizzontale); dimensione verticale b = 1 => non serve scriverla
float incrementoAngolo = 360.0/512.0; // incremento dell'angolo = numero di gradi/numero di campioni
float angolo = 0; // angolo per lo spettro attorno alla circonferenza (mappata in un'ellisse)

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
 
  // Inserisco gli ostacoli nell'arraylist
  for(int i = 0; i < numObstacles; i++){
   Obstacle obstacle = new Obstacle();
   obstacles.add(obstacle);
  }
  
  // Inserisco gli ostacoli nell'arraylist
  for(int i = 0; i < numEnemies; i++){
   Obstacle enemie = new Obstacle();
   enemies.add(enemie);
  }
  
} // void setup()

// Gestisco il movimento del personaggio
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
    switch(key){
      case 'l':
        addEffect(0);
        break;
      case 'h':
        addEffect(1);
        break;
      case 'b':
        addEffect(2);
        break;
      case 'n':
        addEffect(3);
        break;
      case ENTER:
        character.gameOver = false;
        character.animation = true;
        break;
      default:
        break;
    } // switch
  }
    
} // keyPressed()

void draw()
{
  background(0);
  
  // perform a forward FFT on the samples in song's mix buffer,
  // which contains the mix of both the left and right channels of the file
  fft.forward( song.mix );
  
  // Traslo per fare in modo che la scena sia al centro dello schermo
  translate(width/2, height/2, 0);
  
  stroke(255,0,0); // rosso
  character.display(); // grazie alla traslazione viene posizionato al centro (inizialmente)
  
  // Aggiorno ostacoli e collisioni
  stroke(0,255,0); // verde
  for(int i = 0; i < obstacles.size(); i++){
    Obstacle temp = obstacles.get(i);
    if(temp.R <= 0){ // controllo se l'ostacolo deve sparire
     obstacles.remove(i);
     insertObstacle();
    }
    // scrivo gia i valori delle dimensioni per non dover accedere ogni volta all'oggetto
    if(collisionDetection(temp.x, temp.y, 30.0, 30.0, character.x, character.y, 25.0)){ // controllo le collisioni con il personaggio
     obstacles.remove(i);
     insertObstacle();
    }
     temp.display();
  }
  
  // Aggiorno ostacoli (dannosi) e collisioni
  stroke(255,0,255); // viola
  for(int i = 0; i < enemies.size(); i++){
    Obstacle temp = enemies.get(i);
    if(temp.R <= 0){ // controllo se l'ostacolo deve sparire
     enemies.remove(i);
     insertEnemie();
    }
    // scrivo gia i valori delle dimensioni per non dover accedere ogni volta all'oggetto
    if(collisionDetection(temp.x, temp.y, 30.0, 30.0, character.x, character.y, 25.0)){ // controllo le collisioni con il personaggio
     character.gameOver = true;
    }
     temp.display();
  }
  stroke(0,0,255);  // blu per lo spettro
  
  ellipse.display();
    
}  // void draw()

void insertObstacle(){
    Obstacle obstacle = new Obstacle();
    obstacles.add(obstacle);
}

void insertEnemie(){
    Obstacle enemie = new Obstacle();
    enemies.add(enemie);
}

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
  
  float distance = sqrt(sq(closeX - circleCenterX) + sq(closeY - circleCenterY));
  
  if(distance < radius) return true;
  
  return false;
}

void addEffect(int effect){
  switch(effect){
    case 0:
      song.clearEffects();
      lowPass = new LowPassSP(200,44100); // cutoff frequency e samplerate
      song.addEffect(lowPass);
      break;
    case 1:
      song.clearEffects();
      highPass = new HighPassSP(400,44100); // cutoff frequency e samplerate
      song.addEffect(highPass);
      break;
    case 2:
      song.clearEffects();
      bandPass = new BandPass(200, 400, 44100); // cutoff frequency, bandWidth to pass e samplerate
      song.addEffect(bandPass);
      break;
    case 3:
      song.clearEffects();
      break;
    default:
      break;
  } // switch
}

void stop()
{
  song.close();
  minim.stop();
  super.stop();
}
