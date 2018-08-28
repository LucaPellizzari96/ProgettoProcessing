class Cube {
  
// Valori delle posizioni
protected int target = 1;
float y;
protected float x, z;
protected boolean moveLeft, moveRight;
  
// COSTRUTTORE
Cube(){
  x = width/2;
  y = height - 50;
  z = -150.0;
}
  
void display(){

  fill(0, 0); // fill(rgb,alpha) : colore usato per riempire le prossime figure
    
  stroke(255); // stroke(color) : colore usato per i bordi delle figure (bianco)
  strokeWeight(1 + (scoreGlobal/300)); // spessore del bordo
  
  if(moveLeft) moveLeft();
  
  if(moveRight) moveRight();
    
  // Creazione di una matrice di trasformazione per effettuare le rotazioni e gli ingrandimenti
  // Utilizzo pushMatrix() e poi popMatrix() perche voglio che il movimento sia locale e che quindi riguardi solo questa parte della scena
  pushMatrix(); // salva il sistema di coordinate corrente sullo stack
    
  // Applico dei cambiamenti al sitema di coordinate, disegno il cubo nella scena e poi ripristino il vecchio sistema di coordinate con popMatrix()
    
  // Displacement
  translate(x, y, z);
    
  box(100); // box(size) : costruisco un cubo di quella dimensione
    
  popMatrix(); // ripristino il sistema di coordinate esistente prima del pushMatrix()
    
}  // void display

void moveLeft(){
  switch(target){
    case 1:
      if(x >= width*3/10 && x <= width/2) target = 0;
      break;
    case 2:
      if(x >= width/2 && x <= width*7/10) target = 1;
      break;
    default:
      break;
  } // switch
  if(target == 0){ // sto andando dalla corsia 1 alla 0
    if(x-8 > width*3/10){ // non sono ancora arrivato
      x -= 8;
    }else{ // se andrei troppo oltre o arriverei giusto
      x = width*3/10;
      moveLeft = false;
    }
  }else if(target == 1){ // sto andando dalla corsia 2 alla 1
    if(x-8 > width/2){ // non sono ancora arrivato
      x -= 8;
    }else{ // se andrei troppo oltre o arriverei giusto
      x = width/2;
      moveLeft = false;
    }
  }
} // moveLeft()

void moveRight(){
  switch(target){
    case 0:
      if(x >= width*3/10 && x <= width/2) target = 1;
      break;
    case 1:
      if(x >= width/2 && x <= width*7/10) target = 2;
      break;
    default:
      break;
  } // switch
  if(target == 1){ // sto andando dalla corsia 0 alla 1
    if(x+8 < width/2){ // non sono ancora arrivato
      x += 8;
    }else{ // se andrei troppo oltre o arriverei giusto
      x = width/2;
      moveRight = false;
    }
  }else if(target == 2){ // sto andando dalla corsia 1 alla 2
    if(x+8 < width*7/10){ // non sono ancora arrivato
      x += 8;
    }else{ // se andrei troppo oltre o arriverei giusto
      x = width*7/10;
      moveRight = false;
    }
  }
} // moveRight()

void reset(){
  x = width/2;
  y = height;
  z = -150.0;
  target = 1;
  moveRight = false;
  moveLeft = false;
}

  
} // classe Cube
