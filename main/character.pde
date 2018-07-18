class Character {

  private int x = 0; // parto da 0 poi applico la traslazione in draw() e porto l'oggetto al centro
  private int y = 0;
  private int dx = 10; // spostamento su x
  private int dy = 10; // spostamento su y
  private int raggio = 20;
  
  void moveLeft(){
    x -= dx;
  }
  
  void moveRight(){
    x += dx;
  }
  
  void moveUp(){
    y -= dy;
  }
  
  void moveDown(){
    y += dy;
  }
  
  void display(){
   ellipse(x, y, raggio, raggio); // uso l'ellipse cosi posso settare la sua posizione
  }

}
