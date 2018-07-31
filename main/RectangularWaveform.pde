class RectangularWaveform{
  
  void display(){
    
    int i;
    
    float[] mix = song.mix.toArray();
    
    for(i = 0; i < 171; i++){ // lato destro
      
      float y1 = map(i, 0, 171, 0, height);
      float y2 = map(i+1, 0, 171, 0, height);
      line(width - mix[i]*150, y1, width - mix[i+1]*150, y2);
      
    } // for
    
    for(i = 171; i < 514; i++){ // lato basso
    
      float x1 = map(i, 171, 514, 0, width);
      float x2 = map(i+1, 171, 514, 0, width);
      line(x1, height - mix[i]*150, x2, height - mix[i+1]*150);
    
    }
    
    for(i = 514; i < 685; i++){ // lato sinistro
    
      float y1 = map(i, 514, 685, 0, height);
      float y2 = map(i+1, 514, 685, 0, height);
      line(mix[i]*150, y1, mix[i+1]*150, y2); 
      
    }    
    
    for(i = 685; i < mix.length - 1; i++){ // lato alto
    
      float x1 = map(i, 685, 1024, 0, width);
      float x2 = map(i+1, 685, 1024, 0, width);
      line(x1, mix[i]*150, x2, mix[i+1]*150);
    
    }
    
 } // void display()

} // classe RectangularWaveform
