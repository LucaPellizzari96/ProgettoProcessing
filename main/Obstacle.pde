class Obstacle {

  private float angle = random(360); // mi serve per dare una posizione pseudo casuale all'interno dell'ellisse che rappresenta lo spettro
  protected float x = 500.0 * cos(radians(angle)); // 500 perche sarebbe 250.0 *...* 2 = a (dimensione) dell'ellisse
  protected float y = 250.0 * sin(radians(angle));
  private float dim = 30.0;
  private float time = 0; // per gestire il colore dell'ostacolo
  protected float R = random(20,255);
  
  void display(){
    if(time < 80){
      fill(R,R,R);
      rect(x, y, dim, dim); // uso rect() cosi posso settare la posizione
      time++;
    }else{ // ogni 80 frame
      R -= 10;
      time = 0;
    }
  }  // void display()
  
} // classe Obstacle
