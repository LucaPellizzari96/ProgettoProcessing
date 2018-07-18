class Obstacle {

  private float angle = random(360); // mi serve per dare una posizione pseudo casuale all'interno della circonferenza che rappresenta lo spettro
  private float x = random(250) * cos(radians(angle));
  private float y = random(250) * sin(radians(angle));
  
  void display(){
   rect(x, y, 35, 35); // uso un rect cosi posso settare la sua posizione
  }
  
}
