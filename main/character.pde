class Character {

  private float x = 250.0; // parto da 0 poi applico la traslazione in draw() e porto l'oggetto al centro
  private float y = 250.0;
  private float x2 = 0.0;
  private float y2 = 0.0;
  private float z = 1.95;
  protected int raggio = 25;
  // variabili per la rotazione della sfera attorno all'ellisse (all'interno)
  protected boolean animation = true; // rotazione attiva o meno
  private float angoloCharacter = 0.0;
  private float incrementoAngoloCharacter = 0.5;
  protected boolean gameOver = false;
  
  float getX(){
    return x2;
  }
  
  float getY(){
    return y2;
  }
  
  float getZ(){
    return z;
  }
  
  void moveCharacter(){
    if(animation){
    angoloCharacter += incrementoAngoloCharacter; // aumento l'angolo per il movimento del personaggio
    }
  }
  
  void animate(){
    animation = !animation;
  }
  
  void invertAngle(){
    incrementoAngoloCharacter = -incrementoAngoloCharacter;
  }
  
  void display(){
    if(!gameOver){
      moveCharacter();
      x2 = x*cos(radians(angoloCharacter))*2;
      y2 = y*sin(radians(angoloCharacter));
      ellipse(x2, y2, raggio, raggio); // uso l'ellipse cosi posso settare la sua posizione
    }else{
      ellipse(0.0, 0.0, raggio, raggio);
    }
  }

}
