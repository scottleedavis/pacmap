
class Player extends GLModel{

  //fx objects
  GLModel      uDirection;  
  InteractiveFrame iFrame;
  MeshPoint        mPoint;
  Scene             scene;
  PApplet          parent;
  
  //network node 
  LineVertex clv;    
  ArrayList<LineVertex> nextLineVertex = new ArrayList<LineVertex>();
  
  //state 
  boolean active         = false;
  boolean ai             = false;
  boolean dead           = false;
  boolean hasDestination = false;
  boolean animate        = false;
  boolean deadSequence   = false;

  //direction
  float destinationAngle     = 0.0f;
  
  //timers
  float animateTimeout       = 0.0f;
  float deadTimeout          = 0.0f;  
  float resetTimeout         = 0.0f;

  //counters
  int choice = 0;
  int vcount = 0;
  
  //size
  float radius = 100f; 
  
  //location & speed
  int speed = 0;
  PVector location      = new PVector(0,0);
  PVector velocity      = new PVector(0,0);
  PVector destination   = new PVector(0,0);
  PVector userDirection = new PVector(0,0);
  PVector tmpUser       = new PVector(0,0);

  //user controller     
  boolean uUp    = false;
  boolean uDown  = false;
  boolean uLeft  = false;
  boolean uRight = false;
  
  
  public Player(PApplet parent, Scene scene,float radius){
  
    super(parent, (int)PAC_DIVISIONS+3+(int)LV_CHUNK, TRIANGLE_FAN, GLModel.STATIC);
    this.parent = parent;
    this.scene = scene;
    iFrame = new InteractiveFrame(scene);
    //mPoint
  } 
  
  void reset(){
    velocity.set(0,0,0);
    nextLineVertex.clear();
    hasDestination = false;    
    resetTimeout = GAME_RESET_TIMEOUT + millis();
  }
  
  void death(){
      
  }
   
  
  void animate(){

  }
  
  void move(){
    
  }
  
  void scan(){

  }
  
  void atDestination(){
    
      setLocation(destination.x,destination.y,destination.z);
      
      if( ai )
        getDestination();  

      LineVertex lv = nextLineVertex.get(choice);  
      setLineVertex(lv);  

      hasDestination = false;

  }
  
  void moveTowards(){

    PVector vel = destination.get();

    vel.sub(location);
    vel.normalize();
    vel.mult(speed);

    destinationAngle = degrees(vel.heading2D());

    if( destinationAngle != destinationAngle)
      velocity.set(0f,0f,0f);
    else
      velocity.set(vel.x,vel.y,vel.z);
    
    setLocation(location.x+velocity.x,location.y+velocity.y,location.z+velocity.z);
    
  }
  
  boolean hasDestination(){
    return hasDestination;
  }
  
  void choosePath(){
  
  }

  public boolean hasUserInput(){
    
    boolean hasDirection = false;
    float da = 0.0f;
    float da2 = 0.0f;

    if( nextLineVertex.size() == 2){
      
      tmpUser.x = uRight ? 1 : (uLeft ? -1 : 0);
      tmpUser.y = uDown ? 1 : (uUp ? -1 : 0);
      
      boolean directionPressed = tmpUser.x != 0.0f || tmpUser.y != 0.0f;

      if( directionPressed){
        PVector tmpUser2 = tmpUser.get();
        
        tmpUser2.mult(-1);
        da = degrees(PVector.angleBetween(tmpUser,velocity));
        da2 = degrees(PVector.angleBetween(tmpUser2,velocity));
  
        if( da <= ROUTE_CONTINUATION_ANGLE) { 
          userDirection.x = uRight ? 1 : (uLeft ? -1 : 0);
          userDirection.y = uDown ? 1 : (uUp ? -1 : 0);
        }
        else if( tmpUser2.equals(userDirection) ){
            userDirection.x = uRight ? 1 : (uLeft ? -1 : 0);
            userDirection.y = uDown ? 1 : (uUp ? -1 : 0);
        }
        else if( da2 <= ROUTE_CONTINUATION_ANGLE) {    
            userDirection.x = uRight ? 1 : (uLeft ? -1 : 0);
            userDirection.y = uDown ? 1 : (uUp ? -1 : 0);
        } 
        else{

          if( hasVelocityInput() ){
            PVector doah = velocity.get();
            doah.normalize();
            userDirection.set(doah);
          }
          else{

              userDirection.x = uRight ? 1 : (uLeft ? -1 : 0);
              userDirection.y = uDown ? 1 : (uUp ? -1 : 0);
            /*
            da = degrees(PVector.angleBetween(tmpUser,destination));
            da2 = degrees(PVector.angleBetween(tmpUser2,destination));
  
            if( da <= ROUTE_CONTINUATION_ANGLE) { 
              userDirection.x = uRight ? 1 : (uLeft ? -1 : 0);
              userDirection.y = uDown ? 1 : (uUp ? -1 : 0);
            }
            else if( tmpUser2.equals(userDirection) ){
                userDirection.x = uRight ? 1 : (uLeft ? -1 : 0);
                userDirection.y = uDown ? 1 : (uUp ? -1 : 0);
            }
            else if( da2 <= ROUTE_CONTINUATION_ANGLE) {    
                userDirection.x = uRight ? 1 : (uLeft ? -1 : 0);
                userDirection.y = uDown ? 1 : (uUp ? -1 : 0);
            } 
            */
          }
 
        }

      }
      else{

      }
            
    }
    else{

      tmpUser.x = uRight ? 1 : (uLeft ? -1 : 0);
      tmpUser.y = uDown ? 1 : (uUp ? -1 : 0);
      userDirection.set(tmpUser);
 
    }

    hasDirection = userDirection.x != 0.0f || userDirection.y != 0.0f;

    return  hasDirection;

  }  

  
  void chooseDestination(){
       
    if( ai )
      choice = aiChoice();
    else
      choice = userChoice();

      if( ai ){
        LineVertex lv = nextLineVertex.get(choice); 
        destination.set(lv.location);
        hasDestination = true;
      }
      else{ 
        LineVertex lv = nextLineVertex.get(choice); 
        destination.set(lv.location);
        hasDestination = true;
      }
  }
  
  void getDestination(){
    
    if( clv == null )
      return;
    
    if( hasDestination() )
      return;

    nextLineVertex.clear();

    nextLineVertex.add(clv);
       
    if( location.equals(clv.location) ){
       
        for( LineVertex lv : clv.neighbors )
          nextLineVertex.add(lv);  
        
    }

    
    if( nextLineVertex.size() == 0 )
      return;
    
     makeChoice();
     //printChoice(); 
       
  }
  
  void printChoice(){
  
    println(millis()+" choice ");
    for(LineVertex lv: nextLineVertex){
      float test;
      PVector vel = lv.location.get();
      vel.sub(location);
      vel.normalize();
      test = degrees(vel.heading2D());
      println("   lv: ("+test+")"+lv.location.x+","+lv.location.y);        
      
    }
    
  }
  
  void makeChoice(){
    
    if( ai )
      choice = aiChoice();
    else
      choice = userChoice();
        
      if( choice != 0){
  
        LineVertex lv = nextLineVertex.get(choice); 
        destination.set(lv.location);
        
        hasDestination = true;

        nextLineVertex.clear();
        nextLineVertex.add(clv);
        nextLineVertex.add(lv);


      }
      else{
        LineVertex lv = nextLineVertex.get(choice); 
        destination.set(lv.location);   
      }

  }
  
  int aiChoice(){
    
    float tmpA = 360;
    float minA = 360;
    int id = 0;
    int saveId = 0;
    

    choice = (int)random(1, nextLineVertex.size()); 
    saveId = choice;
    
   /* 
    if( game.pellets.size() > 0){
      
      //compare direction to closests from the next LineVertex
      for(Pellet p : game.pellets){
      //for(LineVertex lv : nextLineVertex){
        if( !p.munched ){
        PVector vel = p.location.get();
        vel.sub(location);
      
        id = 0;
        for( LineVertex lv : nextLineVertex ){
          //if( id != 0){
            tmpA = PVector.angleBetween(lv.location, vel);
            if( tmpA < minA ){
              saveId = id;
              minA = tmpA;
            }
          //}
          
             id++;       
        }
        }
        

      }
    }
    */
    return saveId;
  }
  
  int userChoice(){
    
    float tmpA = 360;
    float minA = 360;
    int id = 0;
    int saveId = 0;
    if( hasUserInput() ){
      
      //compare direction to closests from the next LineVertex
      for(LineVertex lv : nextLineVertex){
        
        PVector vel = lv.location.get();
        vel.sub(location);
        tmpA = PVector.angleBetween(userDirection, vel);
        if( tmpA < minA ){
          saveId = id;
          minA = tmpA;
        }
        id++;  
      }

    }
    
    return saveId;
  }
  
  boolean hasVelocityInput(){
    
    boolean hasVelocity = false;
    
    hasVelocity = ( velocity.x != 0 || velocity.y != 0 );
    
    return hasVelocity;
  }
  


  void getClosePellets(){
    
    if( game.pellets == null )
      return;
      
    if( calibrationMode )
      return;
      
    for(Pellet p : game.pellets){
     
      if( !p.munched ){

        if( distance(p.location.x,p.location.y,location.x,location.y) < PELLET_DISTANCE ){
          p.munched = true;
          if( p.isPower ){
            game.setGhostsScared();
            game.pointCount+=POWER_PELLET_POINTS;
            if(game.ingame)
            game.sound.eatPower.trigger();
          }
          else{
            if(game.ingame)
            game.sound.chomp();  
          }
          game.munchedCount++;
          game.pointCount++;
        }
        
      }
      
    }
    
  }

  void getCloseGhosts(){
    
    boolean check = false;
    
    if( game.ghosts == null )
      return;
      
    if( calibrationMode )
      return;
      
    for(Ghost g : game.ghosts){
     
        if( distance(g.location.x,g.location.y,location.x,location.y) < radius){
          if( g.scaredTimeout > millis() ) { //eatable
            g.death();
            game.pointCount+=GHOST_POINTS;
            if(game.ingame)
            game.sound.eatGhost.trigger();
          }
          else if( g.deadTimeout<millis() && !dead){ //ghost kills me!
            death();  
            check =true;
            if(game.ingame)
            game.sound.death.trigger();
            break;
          }
          
          return;
        }
        
    }
    
    if( check ) {
      for(Ghost g : game.ghosts){
        ;//g.destination( game.gHome.clv );  
      }
      
    }
    
  }
  
  void getClosePortals(){
    
    if( game.portals == null )
      return;
      
    for(Portal p : game.portals){
     
        if( distance(p.location.x,p.location.y,location.x,location.y) < PELLET_DISTANCE ){
          setLineVertex(p.other.clv);
          //nextLineVertex.clear();
          hasDestination = false;
          //atDestination();
          getDestination();
          return;
        }
        
    }
  }

  
  void setLineVertex(LineVertex lv){
    this.clv = lv;
    setLocation(lv.location.x,lv.location.y,0);
  }
  
  void setLocation(float x, float y, float z){
    location.set(x,y,z);
    iFrame.setPosition(location);
  }
 
   void remove(){
     iFrame.removeFromMouseGrabberPool();
   }
   
   void removeUp(){
    uUp = false;
  }
  
  void removeDown(){
    uDown = false;
  }
  
  void removeLeft(){
   uLeft = false;
  }
  
  void removeRight(){
   uRight = false;
  }
  
  void addUp(){
    uUp = true;
  }
  
  void addDown(){
   uDown = true;
  }
  
  void addLeft(){
   uLeft = true;
  }
  
  void addRight(){
   uRight = true;
  }
  
  PVector getLocation(){
    return location;
  }
  
  void setActive(boolean state){
    active = state;
  }
  
  boolean isActive(){
    return active;
  }
  
  void setColor(int r, int g, int b, int a){


  }
  
  void setSize(float s){
    
  }

  void display( GLGraphics renderer){

            
    if( calibrationMode )
      return;
 
  }
  
  
}

