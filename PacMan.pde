
class PacMan extends Player{

  float destinationAngleBias    = -37;
  float pie_slice = LV_CHUNK;
  float dead_slice = PAC_DIVISIONS;
  boolean mouth = false;

  public PacMan(PApplet parent, Scene scene,float radius){
  
    super(parent,scene,radius);

    setSize(radius);
    initColors();
    setColor(255,255,0,255);
    setupUDirection(radius);
    this.speed = PAC_MAN_SPEED;
  } 
  
  void reset(){
    super.reset();
    setLineVertex(game.pHome.clv);  
  }
  
  void death(){
    
    dead = true;
    deadSequence = true;
    deadTimeout = millis() + PAC_DEAD_TIMEOUT;
    game.pacDeathCount+=1;
    
    velocity.set(0,0,0);     
  }

  void animate(){
    
    if( dead ){

      if( !deadSequence )
        return;
        
      if( animateTimeout == 0.0f )
        animateTimeout = millis() + 250f;  
        
      if( animateTimeout > millis() )
        return;
      else
      {
        dead_slice-=MINI_LV_CHUNK;//LV_CHUNK;
        animateTimeout = millis() + 250f;
      }
      
      if( dead_slice < 0){
         dead_slice = PAC_DIVISIONS;
         deadSequence = false;
      }
       
      vcount = 0;
      beginUpdateVertices();
      for(int i=0; i<PAC_DIVISIONS;i++,vcount++)
        updateVertex(i,0,0,0);
      endUpdateVertices();
      initColors();
      setColor(0,0,0,0);
      beginUpdateVertices();

      vcount = 2;
        
      float j = 0.0f;
      for(int i=1; i<= (int)(dead_slice);i++){
        //println(i);
        updateVertex(i, cos((j)*PI/180)*radius,  sin(-j*PI/180)*radius,0);
        j+= LV_CHUNK;
        vcount++;
      }

      vcount-=2;
      endUpdateVertices();
      initColors();
      setColor(255,255,0,255);
      
    }else{
      
      if( mouth )
        pie_slice+=MINI_LV_CHUNK;//LV_CHUNK;
      else
        pie_slice-=MINI_LV_CHUNK;//0;
      
      if( pie_slice < 0 || pie_slice >= LV_CHUNK)
         mouth = !mouth;
       
      if( !hasVelocityInput() ){
        mouth = true;
       pie_slice = 0;
      }     
      vcount = 2;
  
      beginUpdateVertices();
      updateVertex(0,0,0,0);

      
      float j = 0.0f;
      int ctr = 0;
      for(int i=1; i<= (PAC_DIVISIONS);i++,ctr++){
        updateVertex(i, cos((j)*PI/180)*radius,  sin(-j*PI/180)*radius,0);
        j+= LV_CHUNK;
        vcount++;
      }
      ctr++;
      for(int i=1; i<LV_CHUNK/3;i++,ctr++){
        updateVertex(ctr, cos((j)*PI/180)*radius,  sin(-j*PI/180)*radius,0);
        j+= pie_slice;
        vcount++;

      }
      vcount-=2;
      endUpdateVertices();
     
      setColor(255,255,0,255);
      
    } 
  }
  
  void move(){
    
    if( game.waiting )
      return;
      
    if( !dead )
    speed = PAC_MAN_SPEED;  
      
    if( resetTimeout > millis() ){
      game.sound.begin();
      return;
    }
      
    if( dead ){
      
      if( !deadSequence ){
        if( game.ingame )
          game.sound.begin();
        atDestination();
        setLineVertex(game.getPacHomeLineVertex());
        getDestination();
      }
      if(deadTimeout < millis()){
        dead = false;
        deadSequence = false;
        getDestination();
      }
           
    }else{
      
      scan();

      getDestination();

      if( location.dist(destination) < speed*2)
        atDestination();
      else
        moveTowards();
    }
  
  }
  
  void scan(){
    
    getClosePellets();
    getClosePortals();
    getCloseGhosts(); 
    
  }
  
  void choosePath(){
    
    
    float tmpA;

    if( hasVelocityInput() ){
             
        for(LineVertex lvv : nextLineVertex ){
          PVector vel = lvv.location.get();
          vel.sub(location);
          tmpA = PVector.angleBetween(velocity, vel);   

          if(  (tmpA == tmpA ) && degrees(tmpA) <= ROUTE_CONTINUATION_ANGLE ){
            destination.x = lvv.location.x;
            destination.y = lvv.location.y;
            
            hasDestination = true;
            nextLineVertex.clear();
            nextLineVertex.add(clv);
            nextLineVertex.add(lvv);
            
            PVector toast = destination.get();
            
            toast.sub(location);
            toast.normalize();
            userDirection.set(toast);
            choice = 1;
            
            return;

          }
 
        } 
        velocity.set(0,0,0);
        
    }
 
  }
    
  void setColor(int r, int g, int b, int a){

    beginUpdateColors();
    
    for(int i=0; i<=vcount;i++)
     updateColor(i,r,g,b,a); 
  
    endUpdateColors();
  }
  
  void setSize(float s){
    
    vcount = 2;
    this.radius = s; 

    beginUpdateVertices();
    updateVertex(0,0,0,0);

    float j = 0.0f;
    for(int i=1; i<= (PAC_DIVISIONS);i++){
      updateVertex(i, cos((j)*PI/180)*radius,  sin(-j*PI/180)*radius,0);
      j+= LV_CHUNK;
      vcount++;
    }
    vcount-=2;
    endUpdateVertices();
   
  }
 
  void setupUDirection(float s){
    
    uDirection = new GLModel(parent,(int)LV_DIVISIONS+3, GLModel.TRIANGLE_FAN, GLModel.DYNAMIC); 
    
     float j = 0.0f;
     int ecount = 0;
     uDirection.beginUpdateVertices();
     uDirection.updateVertex(0,0,0,0);
    for(int i=1; i<= (LV_DIVISIONS+2);i++){
      uDirection.updateVertex(i, cos((j)*PI/180)*s/4f,  sin(-j*PI/180)*s/4f,0);
      j+= LV_CHUNK;
      ecount++;
    }
    uDirection.updateVertex(ecount++,0,0,0);
    uDirection.endUpdateVertices();
    
    uDirection.initColors();

    uDirection.beginUpdateColors();
    
    for(int i=0; i<ecount;i++){
     uDirection.updateColor(i,255,0,0,255); 
    }
  
    uDirection.endUpdateColors();

  }

  void display( GLGraphics renderer){

            
   // if( calibrationMode )
   //   return;
      
    pushMatrix();
    
    iFrame.applyTransformation(); 
   
    gl.glDepthMask(false);  

    animate();
    
    if( dead ){
      if( deadSequence ){
        float deadRotate = (int)dead_slice*(int)LV_CHUNK;
        rotateZ(radians(deadRotate/2+90));
        renderer.model(this);
      }
      else{
        rotateZ(radians(destinationAngleBias-12));
        renderer.model(this); 
      }
      
    }else{
      rotateZ(radians(destinationAngle+destinationAngleBias));
      renderer.model(this);
      rotateX(radians(180));
      rotateZ(radians(-90f-destinationAngleBias-20));
      renderer.model(this);
    }
    
 
    gl.glDepthMask(true);  
    
    popMatrix();
  }
  
  
}

