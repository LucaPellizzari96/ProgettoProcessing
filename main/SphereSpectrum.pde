class SphereSpectrum{
  
  void display(){
      // Spettro esterno (segue la trasformata del segnale)
      angolo = 0; // angolo per lo spettro attorno alla circonferenza (che diventera un'ellisse)
      for(int i = 0; i < fft.specSize(); i++){ // disegno lo spettro in forma ellittica
    
        float raggio1 = map(fft.getBand(i), 0, 1, 320.0, 480.0);  // mappo il valore di fft.getBand(i) fra 320 e 480 per allontanarmi dal centro dello schermo
        float raggio2 = map(fft.getBand(i), 0, 1, 325.0, 487.5);  // mappo il valore di fft.getBand(i) fra 325 e 487.5 per allontanarmi dal centro dello schermo
        
        // moltiplico il raggio per allontanare la scena dal centro dello schermo
        line( raggio1*cos(radians(angolo)), raggio1*sin(radians(angolo)), raggio2*cos(radians(angolo)), raggio2*sin(radians(angolo)) );
        
        angolo += incrementoAngolo;     

      } // for
    
 } // void display()

} // classe Spectrum
