class Cube {
  
// Valori delle posizioni
protected int chooseX;
float y;
protected float x, z;
  
// COSTRUTTORE
Cube(){
  // Posizioni casuali di apparizione dei cubi
  chooseX = 0;
  x = width/2;
  y = height;
  z = -175.0;
}
  
void display(){
    
  color displayColor = color(0); // RGB
  fill(displayColor, 255); // fill(rgb,alpha) : colore usato per riempire le prossime figure
    
  stroke(255); // stroke(color) : colore usato per i bordi delle figure (bianco)
  strokeWeight(1 + (scoreGlobal/300)); // spessore del bordo
    
  // Creazione di una matrice di trasformazione per effettuare le rotazioni e gli ingrandimenti
  pushMatrix(); // salva il sistema di coordinate corrente sullo stack
    
  // Applico dei cambiamenti al sitema di coordinate, disegno il cubo nella scena e poi ripristino
  // il vecchio sistema di coordinate con popMatrix()
    
  // Displacement
  translate(x, y, z);
    
  box(100); // box(size) : costruisco un cubo di quella dimensione
    
  popMatrix(); // ripristino il sistema di coordinate esistente prima del pushMatrix()
    
}  // void display
  
} // classe Cube
