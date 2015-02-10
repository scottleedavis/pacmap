
boolean toggleRedSlider = false;
boolean toggleGreenSlider = false;
boolean toggleBlueSlider = false;

void keyReleased(){
                  
  //game.ghosts[0].showMouth =         false; 
   if( key == CODED){
    
     switch(keyCode){
      case UP:
        //game.ghosts[0].removeUp();
        game.pMan.removeUp();
        break;
        
      case DOWN:
        //game.ghosts[0].removeDown();
        game.pMan.removeDown();
        break;
        
      case LEFT:
        //game.ghosts[0].removeLeft();
        game.pMan.removeLeft();
        break;
        
      case RIGHT:
       //game.ghosts[0].removeRight();
       game.pMan.removeRight();
        break;
     }
  } 
}

void keyPressed(){
  
  
  if( key == CODED){
    
     switch(keyCode){
      case UP:
        ///game.ghosts[0].addUp();
        game.pMan.addUp();
        break;
        
      case DOWN:
        ///game.ghosts[0].addDown();
        game.pMan.addDown();
        break;
        
      case LEFT:
        //game.ghosts[0].addLeft();
        game.pMan.addLeft();
        break;
        
      case RIGHT:
        //game.ghosts[0].addRight();
        game.pMan.addRight();
        break;
     }
  }
  else{
      
    switch(key){

       case 'r':  //hard reset game
       
         hardResetGame();

           
         break;
         
       case 'z':  //toggle debug mode
       
         debug = !debug;
         
         break;
         
       case 'u':  //faster
       
         game.increaseSpeed();
         break;
         
       case 'i':  //slower
      
         game.decreaseSpeed();
         break;
        
        
       case 'h':  //add pacman home
       
         game.addPacHome();
         break;
         
       case 'j':  //add ghost home
      
         game.addGhostHome();
         break;
        
       case 'p':  //push Portal
      
         game.pushPortal();
         break;
      
       
       case 'o':  //pop Portal
      
         game.popPortal();
         break;
      
            
       case 's':  //save state
      
         saveLineMap();
         ks.save();
         break;
      
       case 'l':  //load state
      
         loadLineMap();
         try{
         //ks.load();
         }catch(Exception e){println(e);}
        //setupHome();
        //loadVertexObjects();
         break;
           
       case '\'':  //increase cursor width
      
        MOUSE_WEIGHT += 1;
        break;
      
      case ';':  //decrease cursor width
      
        MOUSE_WEIGHT -= 1;  
        if(MOUSE_WEIGHT < 1)
          MOUSE_WEIGHT = 1;   
        break;
        
      case '.':  //increate cursor size
      
        MOUSE_SIZE += 10f;
        break;
      
      case ',':  //decrease cursor size
      
        MOUSE_SIZE -= 10f;  
        if(MOUSE_SIZE < 1.0F)
          MOUSE_SIZE = 1.0f;   
        break;
        
      case '1':
        setLMapIndex(0);  
        break;
  
      case '2':
        setLMapIndex(1);  
        break;
        
      case '3':
        setLMapIndex(2);  
        break;
        
      case '4':
        setLMapIndex(3);  
        break;
              
      case 'c':   //clears active index
        
        try{
          LineMap lm = getCurrentLMap();
          lm.lt.deactivateGroup();
        }
        catch(Exception e){ println(e); }
        break;           
              
      case 'a':  //add point
      
        if( calibrationMode ){
            PVector p = new PVector(mouseX,mouseY,0);
          //  p = glCam.unprojectedCoordinatesOf(p);
           p.set(scene.xCoord((float)p.x),scene.yCoord((float)p.y),scene.zCoord());
          
           addPoint(p.x,p.y,0);
        }
       else{
          if(  !game.ingame ){
            
            if( !game.waiting ){
               game.waiting = true;
               game.waitingTimeout = millis() + GAME_WAIT_TIMEOUT; 
               game.pMan.ai = true;
               game.pMan.reset();
               //game.sound.begin();
               for( Ghost g : game.ghosts){
                 g.ai = true;
                 g.reset();
               }
            }
            else
            {
              game.pMan.ai = false;
    
            }
          }
       }   
       
       break;
       
      case 'd':  //delete point
        
        if( calibrationMode )
          removePoint();
        break;
      
      case 'f':  //calibration mode toggle

        calibrationMode = !calibrationMode;
        
        if( calibrationMode ){
          
          game.removePellets();
          game.pMan.remove();
          for(Ghost g: game.ghosts)
            g.remove();
          
        }else{
         
          game.populatePellets(); 
        }
        
        break;

    default:
      break;
      
    }
  }
  
 
 }
 
void mousePressed() {
  if (mouseEvent.getClickCount()==2){
    println("double click");
  }
}

void mouseDragged(){

  try{
    LineMap lm = getCurrentLMap();
    lm.lt.rescanCurrentPoint();
  }
  catch(Exception e){ println("dragPoint exception: "+e); }
  
}
 
void mouseReleased(){
  
  try{
    LineMap lm = getCurrentLMap();
    lm.lt.rescanCurrentPoint();
    lm.lt.snapPoint();
  }
  catch(Exception e){ println("snapPoint exception: "+e); } 
 
  try{
    for( Portal p: game.portals)
        p.snap();
  }catch(Exception e){ println("snap exception: "+e); } 

  try{
    game.pHome.snap();
  }catch(Exception e){ println("snap exception: "+e); } 
  
  try{
    game.gHome.snap();
  }catch(Exception e){ println("snap exception: "+e); } 
    
    
}
 
 

