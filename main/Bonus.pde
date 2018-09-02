class Bonus {
  
  float startingZ = -10000; // posizione z in cui compaiono (spawn)
  float maxZ = 0;  // posizione z massima (se z maggiore di questa il cubo non e' + visibile)
  
  // Valori delle posizioni
  private int chooseX;
  private float y;
  protected float x, z;
  
  // COSTRUTTORE
  Bonus(){
    // Posizioni casuali di apparizione dei cubi
    chooseX = (int) random(0,32);
    if (chooseX < 11) x = width*3/10; // al centro della prima corsia
    if (chooseX > 10 && x < 22) x = width/2; // al centro della seconda corsia
    if (chooseX > 21) x = width*7/10; // al centro della terza corsia
    y = height - 50;
    z = random(startingZ, -350);
  }
  
  void display(){
    
    color displayColor = color(lowValue*0.67, midValue*0.67, highValue*0.67); // RGB
    fill(displayColor, 255); // fill(rgb,alpha) : colore usato per riempire le prossime figure
    
    stroke(255); // stroke(color) : colore usato per i bordi delle figure (bianco)
    strokeWeight(1 + (scoreSum/300)); // spessore del bordo
    
    // Creazione di una matrice di trasformazione per effettuare le rotazioni e gli ingrandimenti
    pushMatrix(); // salva il sistema di coordinate corrente sullo stack
    
    // Applico dei cambiamenti al sitema di coordinate, disegno il cubo nella scena e poi ripristino
    // il vecchio sistema di coordinate con popMatrix()
    
    // Displacement
    translate(x, y, z);
    
    box(100); // box(size) : costruisco un cubo di quella dimensione
    
    popMatrix(); // ripristino il sistema di coordinate esistente prima del pushMatrix()
    
    // Displacement su z, dipende da scoreSum (a sua volta dai toni + acuti della traccia)
    z+= (1+(pow((scoreSum/150), 2)));
    
    // Rimpiazzo il cubo che non e' + visibile con un altro
    if (z >= maxZ) { // se la "camera" supera il cubo
      replaceBonus();
    }
    
  }  // void display
  
  void replaceBonus(){
    chooseX = (int) random(0,32);
    if (chooseX < 11) x = width*3/10; // al centro della prima corsia
    if (chooseX > 10 && x < 22) x = width/2; // al centro della seconda corsia
    if (chooseX > 21) x = width*7/10; // al centro della terza corsia
    y = height - 50; // nuovo valore per la y
    z = startingZ; // z = posizione + lontana dalla camera => il nuovo cubo si trova "in fondo" alla scena
  }
  
} // classe Bonus
