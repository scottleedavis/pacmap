
class Game {
    
  PApplet parent;
  LineMap lm;
  GLGraphics renderer;

  Sound sound;  
  PacMan pMan;
  PacHome pHome;
  GhostHome gHome;
  ArrayList<Pellet> pellets  = new ArrayList<Pellet>();
  ArrayList<Portal> portals  = new ArrayList<Portal>();
  Ghost[] ghosts             = new Ghost[GHOST_COUNT];
  
    
  //game state
  boolean           begun = false;
  boolean  	   ingame = false;
  boolean         waiting = false;
  boolean        gameOver = false;
  boolean	showtitle = true;
  boolean          scared = false;
  boolean           dying = false;
  boolean    portalToggle = false;
  

  //timers
  float    waitingTimeout = 0.0f;
  float   gameOverTimeout = 0.0f;

  //counters  
  int           munchedCount  = 0;
  int           pacDeathCount = 0;
  int           pointCount    = 0;
  int           highScore     = 0;  

  int           deathcounter  = 0;
  int              pacsleft   = 0;


  
  public Game(PApplet p)
  {
    parent = p;

    sound = new Sound(p);
    
    setupGhosts();

    pMan = new PacMan(parent,scene,GHOST_WIDTH);
    
    resetAi();
      
    GameInit();

        
  }
  
  void setup(){
    GameInit(); 
  }

  void increaseSpeed(){
    PAC_MAN_SPEED++;
    GHOST_SCARED_SPEED = (int)((float)PAC_MAN_SPEED*0.8f);
    GHOST_DEAD_SPEED = (int)((float)PAC_MAN_SPEED*1.5f); 
  }
  
  void decreaseSpeed(){
    PAC_MAN_SPEED--;
    if(PAC_MAN_SPEED <= 0 )
      PAC_MAN_SPEED = 0;
      
    GHOST_SCARED_SPEED = (int)((float)PAC_MAN_SPEED*0.8f);
    GHOST_DEAD_SPEED = (int)((float)PAC_MAN_SPEED*1.5f);      
  }
  
  
  void resetAi(){
    pMan.ai = true;
    for( Ghost g: ghosts)
      g.ai = true;
  }
  
  public void addPacHome(){
    pHome = new PacHome(parent,scene,PORTAL_WIDTH);
    pHome.setColor(255,255,0,110);
    pHome.setupRing(pHome.radius);
    pHome.setLocation(scene.xCoord(mouseX),scene.yCoord(mouseY),0);
  }
  
  public void addGhostHome(){
    gHome = new GhostHome(parent,scene,PORTAL_WIDTH);
    gHome.setColor(0,0,255,110);
    gHome.setupRing(gHome.radius);
    gHome.setLocation(scene.xCoord(mouseX),scene.yCoord(mouseY),0);
  }
  
  public LineVertex getPacHomeLineVertex(){
    // to do... if a pac home exists... else, first node.
    if( pHome == null )
      return gLineMap.get(0).lt.lGroup.get(0);
    return pHome.clv;
  }
  
  public LineVertex getGhostHomeLineVertex(){
    // to do... if a pac home exists... else, last node.
    if( gHome == null )
      return gLineMap.get(0).lt.lGroup.get(gLineMap.get(0).lt.lGroup.size()-1);
    return gHome.clv;
  }
  
  void setupPacMan(){
    
    if( gLineMap.size() > 0 ){

        if( game.pHome == null ){
          game.pMan.setLineVertex( gLineMap.get(0).lt.lGroup.get( (int)random(0,gLineMap.get(0).lt.lGroup.size()  ) ) );
  
          
        }
        else{
          game.pMan.nextLineVertex.clear();
          game.pMan.hasDestination = false;
          game.pMan.setLineVertex( game.pHome.clv );

        }
    }
        
  }
  
  void setupGhosts(){
    
    for( int i =0 ; i < ghostColorSize; i++)
      ghostColors[i] = new gColor();
    

    ghostColors[0].r = 255;
    ghostColors[0].g = 0;
    ghostColors[0].b = 0;
    ghostColors[0].a = 255;
    
    ghostColors[1].r = 0;
    ghostColors[1].g = 255;
    ghostColors[1].b = 0;
    ghostColors[1].a = 255;
    
    ghostColors[2].r = 0;
    ghostColors[2].g = 255;
    ghostColors[2].b = 255;
    ghostColors[2].a = 255;
    
    ghostColors[3].r = 255;
    ghostColors[3].g = 0;
    ghostColors[3].b = 255;
    ghostColors[3].a = 255;
  
    for(int i =0; i< GHOST_COUNT; i++){
      ghosts[i] = new Ghost(parent,scene,GHOST_WIDTH);
      ghosts[i].setColor(ghostColors[i%ghostColorSize].r,ghostColors[i%ghostColorSize].g,ghostColors[i%ghostColorSize].b,ghostColors[i%ghostColorSize].a);
    }
    
  }
  
  void removePortals(){
    for( Portal p : portals)
      p.iFrame.removeFromMouseGrabberPool();
    portals.clear(); 
  }
  
  public void rePopulatePortals(){
    removePortals();
    populatePortals();
  }
  
  void setGhostsScared(){
    
    for( Ghost g: ghosts)
      g.scaredTimeout = millis()+POWER_PELLET_TIMEOUT;  
   
  }
  

  public void pushPortal(){
    
    if( portals.size() == 0 )
      portalToggle = false;
    
    
    if( portalToggle ){ //second portal link
      try{
   
          Portal p1 = new Portal(parent,scene,PORTAL_WIDTH);
          p1.setLocation(scene.xCoord(mouseX),scene.yCoord(mouseY),0);
         // p1.setLineVertex(getCurrentLMap().lt.getRandomLineVertex()); 
          Portal p2 = portals.get(portals.size()-1);
          portals.add(p1);
          p2.setOther(p1);
          p1.setOther(p2);
          p1.setColor(p2.r,p2.g,p2.b,p2.a);
          p1.setupRing(p1.radius);
          
        
      }
      catch(Exception e){ println(e); }
    }
    else{ //first portal link
      try{
   
          Portal p1 = new Portal(parent,scene,PORTAL_WIDTH);
          p1.setColor((int)random(0,255),(int)random(0,255),255,110);
          p1.setupRing(p1.radius);
          p1.setLocation(scene.xCoord(mouseX),scene.yCoord(mouseY),0);
         // p1.setLineVertex(getCurrentLMap().lt.getRandomLineVertex()); 
          portals.add(p1);
  
        
      }
      catch(Exception e){ println(e); }
    }
    
    portalToggle = !portalToggle;
    
  }
  
  public void popPortal(){
    
    if( portals.size() == 0 )
      return;
      
    Portal p = portals.remove(portals.size()-1);
    p.iFrame.removeFromMouseGrabberPool();

    portalToggle = !portalToggle;
  }
  
  public void populatePortals(){
    
    if( portals != null && portals.size() > 0){
      //rePopulatePortals();
      return;
    }
    try{
 
      for(int i =0; i< PORTALS/2; i++){

        Portal p1 = new Portal(parent,scene,PORTAL_WIDTH);
        Portal p2 = new Portal(parent,scene,PORTAL_WIDTH);
        p1.setColor(0,255,255,110);
        p2.setColor(0,255,255,110);
        p1.setOther(p2);
        p2.setOther(p1);
        p1.setLineVertex(getCurrentLMap().lt.getRandomLineVertex());       
        p2.setLineVertex(getCurrentLMap().lt.getRandomLineVertex());
        
        while( p1.clv == p2.clv )
          p2.setLineVertex(getCurrentLMap().lt.getRandomLineVertex());
          
        portals.add(p1);
        portals.add(p2);

      }
      
    }
    catch(Exception e){ println(e); }
    
  }
  
  public void removePellets(){
    for( Pellet p: pellets)
      p.iFrame.removeFromMouseGrabberPool();
    pellets.clear(); 
  }
  
  public void rePopulatePellets(){
    removePellets();
    populatePellets();
    munchedCount = 0;
  }
  
  public void populatePellets(){
    
    if( pellets != null && pellets.size() > 0){
      rePopulatePellets();
      return;
    }
    try{
       munchedCount = 0;
       LineMap lMap = getCurrentLMap();

      ArrayList<PVector> pVisited = new ArrayList<PVector>();

      for( LineVertex lv : lMap.lt.lGroup ){

         Pellet p = new Pellet(parent,scene,PELLET_WIDTH);
                         
         p.setColor(255,255,255,255);
         p.setLineVertex(lv);
         pellets.add(p); 
         
         for( Line l : lv.neighborLine){
           if( !pVisited.contains(l.p2)){
             
              pVisited.add(l.p1);
              makePelletLine(l.p1,l.p2, PELLET_SPACING);

           }
         }

      }
      
      int pp =  (int)((float)pellets.size() * POWER_PELLET_PERCENTAGE);  
      //println(pp);
      for(int i =0; i< pp; i++){
        
        Pellet p = pellets.get( (int)random(0, pellets.size()) );
        p.setPowerPellet();
        
      }
      
    }
    catch(Exception e){ println(e); }
    
  }
  
  void makePelletLine(PVector p1, PVector p2, float spacing){
    
    float d = distance(p1.x,p1.y,p2.x,p2.y);
    
    if( d < PELLET_SPACING/2f ) //too short...
      return;
    
    if( d < PELLET_SPACING ){ //enough FOR ONE
    
        float tx = lerp(p1.x,p2.x, 0.5);
        float ty = lerp(p1.y,p2.y, 0.5);
           Pellet p = new Pellet(parent,scene,PELLET_WIDTH);
                           
           p.setColor(255,255,255,255);
           p.setLocation(tx,ty,0);
           pellets.add(p); 
      
    }
    else{
      
      int chunks = floor(d / spacing);
      
      for(int i =1; i< chunks; i++){
        
        float tx = lerp(p1.x,p2.x, (float)i/(float)chunks);
        float ty = lerp(p1.y,p2.y, (float)i/(float)chunks);
           Pellet p = new Pellet(parent,scene,PELLET_WIDTH);
                           
           p.setColor(255,255,255,255);
           p.setLocation(tx,ty,0);
           pellets.add(p);       
      }
    }
    
  }
  
  public void printGhostState(){
    for(int i =0; i< GHOST_COUNT; i++)
      println(" ghost "+i+": "+ghosts[i].location.x+", "+ghosts[i].location.y);
    
  }
  
  public void GameInit()
  {

    int dx=1;
  
    try{
      
      for (int i=0; i<GHOST_COUNT; i++)
      {
         LineVertex lv = gHome.clv;
         if( lv == null )
           lv = gHome.clv;
           
         ghosts[i].setLineVertex(lv);    
         ghosts[i].velocity.set(0f,(float)dx,0);
         dx=-dx;

      }
 
      
    }catch(Exception e){}
 
   // printGhostState();

    dying=false;
    scared=false;

  }



  
  void run(GLGraphics r) throws Exception {
      
    renderer = r;
    DrawMaze();
    DrawScore();
    DoAnim();
    PlayGame();

  }

  void PlayGame(){
    
    CheckScared();
    MoveGhosts();
    MovePacMan();
    ShowIntroScreen();

  }
  
  public void CheckMaze()
  {
      DrawScore();
      GameInit();
  }

  public void MovePacMan()
  {


    if( pMan.ai ){
      
      if( game.pellets.size() > 0 ){
        if( !pMan.hasDestination() )
          pMan.getDestination();
        else
          pMan.chooseDestination();
      }
      
    }
    else
    {

      if( pMan.hasUserInput() ){

        if( !pMan.hasDestination() )
          pMan.getDestination();
        else
          pMan.chooseDestination();
          
      }
      else{
        pMan.choosePath();
      }
      
    }

    pMan.move();
  
    pMan.display(renderer); 
    
  }

  public void CheckScared()
  {

  }

  public void Death()
  {

    deathcounter--;

    if (deathcounter==0)
    {

      pacsleft--;

      if (pacsleft==0)
        ingame=false;

      GameInit();

    }

  }


  public void DrawMaze()
  {

      try{

        for( Pellet p : pellets ){
          p.display(renderer);
        }
        
         for( Portal p : portals ){
          p.display(renderer);
        }  
   
        pHome.display(renderer);
        gHome.display(renderer); 
        
      }
      catch(Exception e){ println("drawMaze :"+e); }
  
  }

  void DrawScore()
  {
   // println("munched count = "+game.munchedCount+ " / "+game.pellets.size());
  }
  
  void MoveGhosts()
  {

    for (int i=0; i<GHOST_COUNT; i++)
    {
    
      if( ghosts[i].ai ){
        
          if( !ghosts[i].hasDestination() )
            ghosts[i].getDestination();
          else
            ghosts[i].chooseDestination();
        
      }
      else
      {
  
        if( ghosts[i].hasUserInput() ){
  
          if( !ghosts[i].hasDestination() )
            ghosts[i].getDestination();
          else
            ghosts[i].chooseDestination();
            
        }
        else{
          ghosts[i].choosePath();
        }
        
      }
  
      ghosts[i].move();

      ghosts[i].display(renderer);

    }

  }


  void ShowIntroScreen()
  {

    if( munchedCount == pellets.size() ){
      rePopulatePellets();  
     // rePopulatePortals();
    }

  }
  
  
  void DoAnim()
  {


  }
  
  void setLineMap(LineMap lm){
    this.lm = lm;
  }
} 

void setupHome(){
  
  try{
    if( game.pHome == null ){
      game.addPacHome();
      game.pHome.setLineVertex(gLineMap.get(0).lt.lGroup.get(0));
    }
  }
  catch(Exception e){ println(e); }
  try{
    if( game.gHome == null ){
      game.addGhostHome();
      game.gHome.setLineVertex(gLineMap.get(0).lt.lGroup.get(gLineMap.get(0).lt.lGroup.size()-1));
    }
  }
  catch(Exception e){ println(e); }
  
}

void beginGame(){
  
  MemoryManager.GC();
  setupGame(this);
  game.setLineMap(setupLineMap());
  game.setupPacMan();
  game.populatePellets();
  game.begun = true;
  game.pointCount = 0;
  MemoryManager.GC();
}

void setupGame(PApplet p){
 
  if(game == null)
    game = new Game(this);
  
  game.setup();
 
}

void hardResetGame(){
  beginGame();
  game.pMan.reset();
  game.pMan.resetTimeout = 0f;
  for(Ghost g : game.ghosts){
    g.reset();
    g.resetTimeout = 0f;
  }  

}

