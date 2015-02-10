
void drawDrawSurface(DrawSurface ds, GLGraphics renderer){


  offscreen.beginDraw();
  offscreen.background(0,0,0,0);//ds.bgColor);   

  if( calibrationMode ){

    offscreen.fill(255,255,0,255);
    offscreen.textAlign(CENTER);
    offscreen.textFont(fontA, 60);
    offscreen.text("pac map", mw/2,mh/2-102);
    offscreen.fill(0,255,255,255);
    offscreen.textFont(fontA, 30);
    offscreen.text("by", mw/2,mh/2-72);  
    offscreen.textFont(fontA, 30);
    offscreen.fill(255,255,255,255);    
    offscreen.text("LightTroupe", mw/2,mh/2-42);    
    
        if(debug){
        offscreen.fill(255);  
        offscreen.textFont(fontA, 40);
        offscreen.text((int)MemoryManager.CurrentMemoryUsage()+"MB  "+(int)frameRate+"fps", mw/2,mh/2+120);
        }  
  }
  else{
    
    offscreen.textAlign(CENTER);
    
    //if game not game playing, demo mode...
    if( !game.ingame ){
      
      if( !game.waiting ){
        
        

    offscreen.fill(255,255,0,255);
    offscreen.textAlign(CENTER);
    offscreen.textFont(fontA, 60);
    offscreen.text("pac map", mw/2,mh/2-102);
    offscreen.fill(0,255,255,255);
    offscreen.textFont(fontA, 30);
    offscreen.text("by", mw/2,mh/2-72);  
    offscreen.textFont(fontA, 30);
    offscreen.fill(255,255,255,255);    
    offscreen.text("LightTroupe", mw/2,mh/2-42);    
    
        offscreen.fill(0,255,255,255);
        offscreen.textFont(fontA, 30);
        offscreen.text("Press A", mw/2,mh/2);  
        offscreen.text("to start", mw/2,mh/2+30); 
        offscreen.textFont(fontA, 20);
        offscreen.fill(255,255,0,255);
        offscreen.text("high score",mw/2,mh/2+50);
        offscreen.textFont(fontA, 40);
        offscreen.fill(255,0,0,255);
        offscreen.text(game.highScore,mw/2,mh/2+80);
        if(debug){
        offscreen.fill(255);
        offscreen.textFont(fontA, 40);
        offscreen.text((int)MemoryManager.CurrentMemoryUsage()+"MB  "+(int)frameRate+"fps", mw/2,mh/2+120);
        }
        game.resetAi();
      }  
      else{
        int countDown = (int)((game.waitingTimeout-millis())/1000);
        
        //show users connected
        if( countDown > 0 ){
          
          offscreen.fill(0,255,255,255);
          offscreen.textFont(fontA, 50);
          offscreen.text("Press A", mw/2,mh/2-100);  
          offscreen.text("to join", mw/2,mh/2-50);  
          offscreen.text(countDown, mw/2,mh/2);     
          if(debug){
          offscreen.fill(255);
          offscreen.textFont(fontA, 40);
          offscreen.text((int)MemoryManager.CurrentMemoryUsage()+"MB  "+(int)frameRate+"fps", mw/2,mh/2+120);
          }  
          //wiimotes press A and join
          
        } 
        else{
          game.waiting = false;
          game.gameOver = false;
          game.ingame = true;
          game.pacDeathCount = 0;
      
          try{
            LineMap lm = getCurrentLMap();
  
            if( lm.lt.lGroup.size() > 1 )
              beginGame();
            else
              game.begun = false;
          }
          catch(Exception e){ println("beginGame: "+e); }
          
          }
      }
      
    }
    else{

      int lives = 3-game.pacDeathCount;

      if( game.pointCount > game.highScore )
        game.highScore = game.pointCount;    
              
      if( lives > 0 ){

    offscreen.fill(255,255,0,255);
    offscreen.textAlign(CENTER);
    offscreen.textFont(fontA, 60);
    offscreen.text("pac map", mw/2,mh/2-102);
    offscreen.fill(0,255,255,255);
    offscreen.textFont(fontA, 30);
    offscreen.text("by", mw/2,mh/2-72);  
    offscreen.textFont(fontA, 30);
    offscreen.fill(255,255,255,255);    
    offscreen.text("LightTroupe", mw/2,mh/2-42);   
         
        //    playgame billboard
        //offscreen.text(str(surf_id++), mw/2,mh*2/3);
        offscreen.textFont(fontA, 40);
        offscreen.fill(255,0,0,255);
        offscreen.text(game.pointCount, mw/2,mh/2+80);
        offscreen.fill(255,255,0,255);        
        offscreen.textFont(fontA, 80);

        String ccc = "";
        for( int i=0; i< lives; i++)
          ccc += "C ";
        if( ccc != "" )
          offscreen.text(ccc, mw/2,mh/2+40); 
        
        if(debug){
        offscreen.fill(255);
        offscreen.textFont(fontA, 40);
        offscreen.text((int)MemoryManager.CurrentMemoryUsage()+"MB  "+(int)frameRate+"fps", mw/2,mh/2+120);
        }
      }
      else{
          
          if( !game.gameOver ){
            game.gameOverTimeout = millis()+GAME_OVER_TIMEOUT;
            game.gameOver = true;
          }
          
          if( game.gameOverTimeout > millis() ){
            offscreen.fill(255,0,0,255);
            offscreen.textFont(fontA, 50);
            offscreen.text("Game", mw/2,mh/2-100);  
            offscreen.text("Over", mw/2,mh/2-50);  
            offscreen.fill(0,255,255,255);
            offscreen.textFont(fontA, 80);
            offscreen.text(game.pointCount, mw/2,mh/2+20);
            if(debug){
            offscreen.fill(255);
            offscreen.textFont(fontA, 40);
            offscreen.text((int)MemoryManager.CurrentMemoryUsage()+"MB  "+(int)frameRate+"fps", mw/2,mh/2+120);
            }
          } 
          else{
            game.ingame = false;  
          }
        
      }

    }
  
  }
  
  offscreen.endDraw();

  ds.render( renderer,offscreen.getTexture());
 
  
}




class DrawSurface extends CornerPinSurface {
  
  int style;
    
  public DrawSurface(PApplet parent, int s, int w, int h, int res) {
      super(parent,w,h,res);
      style = s;
      bgColor = color(0,0,0,0);
  }
    
  public void render(GLGraphics renderer,PImage texture) {

      PGraphics g = parent.g;

      g.pushMatrix();
      g.translate(x, y);
		
      if (calibrationMode)
        g.stroke(gridColor);
      else 
        g.noStroke();
		
      g.fill(255);
      g.beginShape(PApplet.QUADS);
      g.texture(texture);
      
		for (int x=0; x < res-1; x++) {
			for (int y=0; y < res-1; y++) { 
				MeshPoint mp;
				mp = mesh[(x)+(y)*res];
				g.vertex(mp.x, mp.y, mp.u, mp.v);
				mp = mesh[(x+1)+(y)*res];
				g.vertex(mp.x, mp.y, mp.u, mp.v);
				mp = mesh[(x+1)+(y+1)*res];
				g.vertex(mp.x, mp.y, mp.u, mp.v);
				mp = mesh[(x)+(y+1)*res];
				g.vertex(mp.x, mp.y, mp.u, mp.v);
			}
		}

      g.endShape(PApplet.CLOSE);
 		
      if (calibrationMode) 
        renderControlPoints(g);

      g.popMatrix();
      
    }
}
