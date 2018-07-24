class Lifeline{
  
  void display(){
    
      int samples = floor(map(score, 0.0, 750.0, 0.0, fft.avgSize())); // mappo il punteggio nel numero dei campioni => cala il tempo implica che vedro meno campioni
      for(int i = 0; i < samples; i++){ // disegno la media dello spettro in forma lineare
        line(i*5 - width/4, 0, i*5 - width/4, - map(fft.getAvg(i) * 100, 0, 300, 0, 75));
      } // for

 } // void display()
 
} // classe Lifeline
