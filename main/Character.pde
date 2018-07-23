class Character {

  // variabili per la rotazione del personaggio attorno all'ellisse (all'interno)
  protected boolean animation = true; // rotazione attiva o meno
  private float angoloCharacter = random(360);
  private float incrementoAngoloCharacter = 0.5;
  // variabili per la posizione del personaggio
  protected float x = 500.0 * cos(radians(angoloCharacter)); // 500 perche sarebbe 250.0 *...* 2 = a (dimensione) dell'ellisse
  protected float y = 250.0 * sin(radians(angoloCharacter));
  protected boolean gameOver = false;
  
  void moveCharacter(){
    if(animation){
      angoloCharacter += incrementoAngoloCharacter; // aumento l'angolo per il movimento del personaggio
      x = 500.0 * cos(radians(angoloCharacter));
      y = 250.0 * sin(radians(angoloCharacter));
    }
  }
  
  void animate(){
    animation = !animation;
  }
  
  void invertAngle(){
    incrementoAngoloCharacter = -incrementoAngoloCharacter;
  }
  
  void display(){
    fill(0);
    if(!gameOver){
      moveCharacter();
      // scrivo gia i valori delle dimensioni per non dover accedere ogni volta all'oggetto
      ellipse(x, y, 25.0, 25.0); // uso l'ellipse cosi posso settare la sua posizione
    }else{ // gameOver => porto il personaggio al centro
      // scrivo gia i valori delle dimensioni per non dover accedere ogni volta all'oggetto
      ellipse(0.0, 0.0, 25.0, 25.0);
      angoloCharacter = random(360);
    }
  }

}
