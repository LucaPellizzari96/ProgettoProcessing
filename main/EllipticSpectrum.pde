class EllipticSpectrum{
  
  void display(){
    // Spettro esterno (segue la trasformata del segnale)
    angolo = 0; // angolo per lo spettro attorno alla circonferenza (che diventera un'ellisse)
      for(int i = 0; i < fft.specSize(); i++){ // disegno lo spettro in forma ellittica
    
        float raggio1 = map(fft.getBand(i), 0, 1, 200, 300) * 1.6;  // mappo il valore di fft.getBand(i) fra 200 e 300 per allontanarmi dal centro dello schermo
        float raggio2 = map(fft.getBand(i), 0, 1, 200, 300) * 1.625;  // mappo il valore di fft.getBand(i) fra 200 e 300 per allontanarmi dal centro dello schermo
        
        // moltiplico il raggio per allontanare la scena dal centro dello schermo
        line( raggio1*cos(radians(angolo))*a, raggio1*sin(radians(angolo)), raggio2*cos(radians(angolo))*a, raggio2*sin(radians(angolo)) );
    
        angolo += incrementoAngolo;
      } // for
    
 } // void display()

} // classe EllipticSpectrum
