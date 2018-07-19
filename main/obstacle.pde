class Obstacle {

  private float angle = random(360); // mi serve per dare una posizione pseudo casuale all'interno dell'ellisse che rappresenta lo spettro
  private float x = 250.0 * cos(radians(angle))* 2;
  private float y = 250.0 * sin(radians(angle));
  private float x2 = 0.0;
  private float y2 = 0.0;
  private float rotY = random(0,1);
  protected float dim = 35.0;
  private float z = random(zMin, zMax);
  
  float getX(){
    return x2;
  }
  
  float getY(){
    return y2;
  }

  float getZ(){
    return z;
  }
  
  void display(){
   fill(0);
   x2 = x*z;
   y2 = y*z;
   dim = z*35; // dim varia con la distanza
   pushMatrix();
   rotateY(rotY);
   translate(x2,y2,0);
   box(dim);
   popMatrix();
   z += 0.005;
   
   if(z > zMax){  // sono troppo vicino, ricalcolo una posizione casuale sull'ellisse e setto z al minimo (lontano)
     angle = random(360);
     x = 250.0 * cos(radians(angle))* 2;
     y = 250.0 * sin(radians(angle));
     z = zMin;
     rotY = random(0,1);
   }
   
  }
  
} // classe Obstacle
