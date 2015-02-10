class gColor{
    int r;
    int g;
    int b;
    int a;
}

int ghostColorSize = 4;
gColor[] ghostColors = new gColor[ghostColorSize];
  
class Ghost extends Player{

  //fx objects
  GLModel eyeBall;
  GLModel eye;
  GLModel mouth;
  
  boolean showMouth = false;
  boolean eyeBulge  = false;
  
  float scaredTimeout        = 0.0f;
  
   
  int r = 0;
  int g = 0;
  int b = 0;
  int a = 255;
  
  public Ghost(PApplet parent, Scene scene,float radius){
  
    super(parent, scene, radius);

    setSize(radius);
    initColors();
    setColor(255,0,0,255);
    this.speed = PAC_MAN_SPEED;
  } 

  void reset(){
    super.reset();
    setLineVertex(game.gHome.clv);  
  }
  
  void death(){
    
    //println("ghost dies!");  
    dead = true;
    deadTimeout = millis() + GHOST_DEAD_TIMEOUT;
    velocity.set(0,0,0);

  }
  
  void move(){

    if( game.waiting )
      return;

    if( game.pMan.dead && game.pMan.deadSequence )
      return;

    if( resetTimeout > millis() ){
      return;
    }
    
    if( dead )
      speed = GHOST_DEAD_SPEED;
    else if( scaredTimeout > millis() ){
      speed = GHOST_SCARED_SPEED; 
    }else{
      speed = PAC_MAN_SPEED;  
    }

    scan();

    if( game.pMan.dead || (dead && ai) ){
      
        //setLineVertex(game.gHome.clv);
        destination.set(game.gHome.location);
        PVector toast = destination.get();
        nextLineVertex.clear();
        nextLineVertex.add(clv);
        nextLineVertex.add(game.gHome.clv);
        toast.sub(location);
        toast.normalize();
        userDirection.set(toast);
        hasDestination = true;
        getDestination();
        choice = 1;

    }
    else
      getDestination();
          

    
    if( dead ){
      
      if( !ai ){
        if(location.dist( game.getGhostHomeLineVertex().location ) <  PELLET_DISTANCE ) //BOOM, non ai character is home
          deadTimeout = 0f;  
        else
          deadTimeout = millis() + GHOST_DEAD_TIMEOUT;
      }
      
      if(deadTimeout < millis()){
        
        dead = false;
        atDestination();
        setLineVertex(game.getGhostHomeLineVertex());
        
      }
      
  }
  if( location.dist(destination) < speed*2)
      atDestination();
    else
      moveTowards();

  
  
  }
 
   void scan(){
    
    getClosePortals();
    
  }
  
  int scanPacMan(){
    if( distance(game.pMan.location.x,game.pMan.location.y,location.x,location.y) < GHOST_SEARCH_RADIUS )
      return orientTowards(game.pMan.location);  
    else
      return choice;
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
 
  int orientTowards(PVector target){

    float pDistance = GHOST_SEARCH_RADIUS;
    int selection = 0;
    int tmpChoice = choice;

    for(LineVertex lv: nextLineVertex ){
      if( distance(lv.location.x,lv.location.y,target.x,target.y) < pDistance ){
        tmpChoice = selection;
      }
      selection++;
    }
    return tmpChoice;
  }
  
  void setSize(float s){
    
    vcount = 2;
    this.radius = s; 

    beginUpdateVertices();
    updateVertex(0,0,0,0);
    updateVertex(1, cos(0)*radius,sin(0)*radius,0);
    
    float j = 0.0f;
    for(int i=2; i<= (LV_DIVISIONS+4)/2;i++){
      updateVertex(i, cos((j)*PI/180)*radius,  sin(-j*PI/180)*radius,0);
      j+= LV_CHUNK;
      vcount++;
    }
    updateVertex(vcount++, -radius, radius,0);
    
    updateVertex(vcount++, -radius/2, 2*radius/3,0);
    updateVertex(vcount++, 0, radius,0);
    updateVertex(vcount++,radius/2,2*radius/3,0); 
     
    updateVertex(vcount++, radius, radius,0);
    updateVertex(vcount++, radius,0,0);
    updateVertex(vcount++, 0, 0,0);
    endUpdateVertices();
 
    setupEyeball(s);
    setupEye(s);
    setupMouth(s);  
    
  }
 
    void setupMouth(float s){
    
     mouth = new GLModel(parent,(int)LV_DIVISIONS+3, GLModel.TRIANGLE_FAN, GLModel.DYNAMIC); 
    
     float j = 0.0f;
     int ecount = 0;
     mouth.beginUpdateVertices();
     mouth.updateVertex(0,0,0,0);
    for(int i=1; i<= (LV_DIVISIONS+2);i++){
      mouth.updateVertex(i, cos((j)*PI/180)*s*0.4f,  sin(-j*PI/180)*s*0.3f,0);
      j+= LV_CHUNK;
      ecount++;
    }
    mouth.updateVertex(ecount++,0,0,0);
    mouth.endUpdateVertices();
    
    mouth.initColors();

    mouth.beginUpdateColors();
    
    for(int i=0; i<ecount;i++){
     mouth.updateColor(i,0,0,0,255); 
    }
  
    mouth.endUpdateColors();

  }
  
   void setupEye(float s){
    
     s /= 2;
     
     eye = new GLModel(parent,(int)LV_DIVISIONS+3, GLModel.TRIANGLE_FAN, GLModel.DYNAMIC); 
    
     float j = 0.0f;
     int ecount = 0;
     eye.beginUpdateVertices();
     eye.updateVertex(0,0,0,0);
    for(int i=1; i<= (LV_DIVISIONS+2);i++){
      eye.updateVertex(i, cos((j)*PI/180)*s/4f,  sin(-j*PI/180)*s/4f,0);
      j+= LV_CHUNK;
      ecount++;
    }
    eye.updateVertex(ecount++,0,0,0);
    eye.endUpdateVertices();
    
    eye.initColors();

    eye.beginUpdateColors();
    
    for(int i=0; i<ecount;i++){
     eye.updateColor(i,0,0,0,255); 
    }
  
    eye.endUpdateColors();

  }

  void setupEyeball(float s){
    
    eyeBall = new GLModel(parent,(int)LV_DIVISIONS+3, GLModel.TRIANGLE_FAN, GLModel.DYNAMIC); 
    
     float j = 0.0f;
     int ecount = 0;
     eyeBall.beginUpdateVertices();
     eyeBall.updateVertex(0,0,0,0);
    for(int i=1; i<= (LV_DIVISIONS+2);i++){
      eyeBall.updateVertex(i, cos((j)*PI/180)*s/4f,  sin(-j*PI/180)*s/4f,0);
      j+= LV_CHUNK;
      ecount++;
    }
    eyeBall.updateVertex(ecount++,0,0,0);
    eyeBall.endUpdateVertices();
    
    eyeBall.initColors();

    eyeBall.beginUpdateColors();
    
    for(int i=0; i<ecount;i++){
     eyeBall.updateColor(i,255,255,255,255); 
    }
  
    eyeBall.endUpdateColors();

  }
  
  void setScaredColor(int r, int g, int b, int a){

    beginUpdateColors();
    
    for(int i=0; i<=vcount;i++){
     updateColor(i,r,g,b,a); 
    }
  
    endUpdateColors();
  }

  void setDeadColor(int r, int g, int b, int a){

    beginUpdateColors();
    
    for(int i=0; i<=vcount;i++){
     updateColor(i,r,g,b,a); 
    }
  
    endUpdateColors();
  }
  
  void setColor(int r, int g, int b, int a){
    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
    beginUpdateColors();
    
    for(int i=0; i<=vcount;i++){
     updateColor(i,r,g,b,a); 
    }
  
    endUpdateColors();
  }

  
  void display( GLGraphics renderer){

        
    if( calibrationMode )
      return;
      
    if( deadTimeout > millis() ){
      setDeadColor(0,0,0,0);
      scaredTimeout = 0.0f;
    }
    else{
      dead = false;
      if( scaredTimeout > millis() )
        setScaredColor(0,0,255,255);
      else
        setColor(r,g,b,a);  
    }
    pushMatrix();
    
    iFrame.applyTransformation(); 

    PVector vel = destination.get();
    vel.sub(location);
    vel.normalize();
    
    gl.glDepthMask(false);  
    renderer.model(this);
    
    if( showMouth ){
      pushMatrix();
      translate(0,GHOST_WIDTH/3,0);
      renderer.model(mouth);
      popMatrix();
    }
    
    if( scaredTimeout > millis() ){

    }
    else{
      translate(-GHOST_WIDTH/3,-GHOST_WIDTH/2,0f);
      renderer.model(eyeBall);
      pushMatrix();
      translate(vel.x*radius/8,vel.y*radius/8,vel.z*radius/8);
      renderer.model(eye);
      popMatrix();
    }
    
    if( scaredTimeout > millis() ){
      
    }
    else{
      translate(2*GHOST_WIDTH/3,0,0f);
      renderer.model(eyeBall);
      pushMatrix();
      translate(vel.x*radius/8,vel.y*radius/8,vel.z*radius/8);
      renderer.model(eye);
      popMatrix();
      gl.glDepthMask(true);
    }
    popMatrix();

  }

  
}

