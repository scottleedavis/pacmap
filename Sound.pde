

class Sound {
  
  PApplet parent;
  Minim minim;
  AudioSample begin;
  AudioSample chomp;
  AudioSample death;
  AudioSample eatPower;
  AudioSample eatGhost;

  
  float chompTimeout = 0.0f;
  float beginTimeout = 0.0f;
  boolean mute = false;

  public Sound(PApplet parent){
  
      this.parent = parent; 
      minim = new Minim(parent);
      begin = minim.loadSample("pacman_beginning.wav",256);
      chomp = minim.loadSample("pacman_chomp.wav",256);
      death = minim.loadSample("pacman_death.wav",256);
      eatPower = minim.loadSample("pacman_eatfruit.wav",256);
      eatGhost = minim.loadSample("pacman_eatghost.wav",256);
     
  }

  void begin(){
    if( beginTimeout < millis() ){
      beginTimeout = millis()+begin.length();
      if(!mute)
        begin.trigger();      
    }
  }
  void chomp(){
    
    if( chompTimeout < millis() ){
      chompTimeout = millis()+chomp.length()*4f/5f;
      if(!mute)
        chomp.trigger();      
    }
  }
  
  void stop(){
    chomp.stop();  
    death.stop(); 
    eatPower.stop(); 
    eatGhost.stop(); 
    minim.stop();
  }
  
}
