class Spectrum2{
  
  float [] zSpettri = {0.05, 0.65, 1.25, 1.85};
  
  void shift(){
    for(int k=3; k > 0; k--){
      zSpettri[k] = zSpettri[k-1];
    }  // for
      zSpettri[0] = zMin; // setto al minimo il valore che e' andato oltre il limite
  }  // void shift()
  
  void display(){
    // Spettro esterno (segue la trasformata del segnale)
    angolo = 0; // angolo per lo spettro attorno alla circonferenza (che diventera un'ellisse)
      for(int i = 0; i < fft.specSize(); i++){ // disegno lo spettro in forma ellittica
    
        float raggio = map(fft.getBand(i), 0, 1, 200, 300);  // mappo il valore di fft.getBand(i) fra 200 e 300 per allontanarmi dal centro dello schermo
        
        // moltiplico il raggio per allontanare la scena dal centro dello schermo
        line( 1.7*raggio*cos(radians(angolo))*a, 1.7*raggio*sin(radians(angolo)), 1.725*raggio*cos(radians(angolo))*a, 1.725*raggio*sin(radians(angolo)) );
    
        angolo += incrementoAngolo;
      } // for
    
    // Ellissi interne
    for(int j = 0; j < 4; j++){ // per ogni ellisse (4 in totale)
    
      noFill();
      
      ellipse(0.0, 0.0, 500*zSpettri[j], 250*zSpettri[j]);

      zSpettri[j] += 0.005;
      
    } // for
    
    if(zSpettri[3] >= zMax){  // se il primo spettro esce dalla scena
      shift();
    }
    
 } // void display()

} // classe Spectrum
