
void controlMessage(String message, float firstValue, float secondValue){

  //red
  if( message.equals("/1/xy") ){  
    try{
    float i = 0;
    LineMap lm = getCurrentLMap();
    i = (100 * firstValue);
    lm.lt.updateSize(i);
    i = (100 * secondValue);
    //lm.ph.updateSize(i);
    }
    catch(Exception e){ println(e); }
    return;
  }
    
}

boolean handleColorMessage(String message, float value){
  
  //red
  if( message.equals("/1/fader1") ){  
    try{
    int i = 0;
    LineMap lm = getCurrentLMap();
    i = (int)(255f * value);
    if( toggleRedSlider )
      ;//lm.ph.updateRedColor(i);
    else
      lm.lt.updateRedColor(i);
   
    }
    catch(Exception e){ println(e); }
    return true; 
  }
 
  //green
  if( message.equals("/1/fader2") ){  
    try{
    int i = 0;
    LineMap lm = getCurrentLMap();
    i = (int)(255f * value);
    if( toggleGreenSlider )
      ;//lm.ph.updateGreenColor(i);
    else
      lm.lt.updateGreenColor(i);
   
    }
    catch(Exception e){ println(e); }
    return true; 
  }

  //blue
  if( message.equals("/1/fader3") ){  
    try{
    int i = 0;
    LineMap lm = getCurrentLMap();
    i = (int)(255f * value);
    if( toggleBlueSlider )
      ;//lm.ph.updateBlueColor(i);
    else
      lm.lt.updateBlueColor(i);
   
    }
    catch(Exception e){ println(e); }
    return true; 
  }

  //alpha
  if( message.equals("/1/fader4") ){  
    try{
    int i = 0;
    LineMap lm = getCurrentLMap();
    i = (int)(255f * value);
    lm.lt.updateAlphaColor(i);
    //lm.ph.updateAlphaColor(i);
   
    }
    catch(Exception e){ println(e); }
    return true; 
  }

  //redtoggle
  if( message.equals("/1/toggle1") ){  
    try{
    LineMap lm = getCurrentLMap();
    toggleRedSlider = value > 0.5 ? true : false;
    }
    catch(Exception e){ println(e); }
    return true;
  } 
  
  //greentoggle
  if( message.equals("/1/toggle2") ){  
    try{
    LineMap lm = getCurrentLMap();
    toggleGreenSlider = value > 0.5 ? true : false;
    }
    catch(Exception e){ println(e); }
    return true;
  } 

  //bluetoggle
  if( message.equals("/1/toggle3") ){  
    try{
    LineMap lm = getCurrentLMap();
    toggleBlueSlider = value > 0.5 ? true : false;
    }
    catch(Exception e){ println(e); }
    return true;
  } 

  
  return false;
  
}

boolean handleLineMessage(String message, float value){


  //line 1
  if( message.equals("/1/push1") ){  
    try{
    setLMapIndex(0);
    }
    catch(Exception e){ println(e); }
    return true;
  } 

  //line 2
  if( message.equals("/1/push2") ){  
    try{
    setLMapIndex(1);
    }
    catch(Exception e){ println(e); }
    return true;
  } 

  //line 3
  if( message.equals("/1/push3") ){  
    try{
    setLMapIndex(2);
    }
    catch(Exception e){ println(e); }
    return true;
  } 

  //line 4
  if( message.equals("/1/push4") ){  
    try{
    setLMapIndex(3);
    }
    catch(Exception e){ println(e); }
    return true;
  } 
  
  //line 5
  if( message.equals("/1/push5") ){  
    try{
    setLMapIndex(4);
    }
    catch(Exception e){ println(e); }
    return true;
  } 
  
  return false;
  
}

boolean handleRouteMessage(String message, float value){
  
      print("### "+message);
      println(" "+value); 
      
    OscMessage o = new OscMessage(message);
    o.add(value);
    oscP5.send(o,oscRoute);
      
      
    return false;
}

boolean checkWiiMoteInt(int num,String message, int value){

  if( message.equals("/wii/"+num+"/button/1") ){
  
          if( num == PAC_MAN_WIIMOTE ){
            
          }
          else{

            if( value == 1 )
              game.ghosts[num-GHOST_WIIMOTE].showMouth = true;
            else
              game.ghosts[num-GHOST_WIIMOTE].showMouth = false;
          }

      return true;
      
  }
  
  if( message.equals("/wii/"+num+"/button/2") ){
  
          if( num == PAC_MAN_WIIMOTE ){
            
          }
          else{
            if( value == 1 )
              game.ghosts[num-GHOST_WIIMOTE].showMouth = true;
            else
              game.ghosts[num-GHOST_WIIMOTE].showMouth = false;
          }

      return true;
      
  }
  return false;
}

boolean checkWiiMote(int num,String message, float value){


  
  if( message.equals("/wii/"+num+"/button/A") ){
  
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
          if( num == PAC_MAN_WIIMOTE ){
            game.pMan.ai = false;
          }
          else{
            game.ghosts[num-GHOST_WIIMOTE].ai = false;
          }
        }
      }else{
          if( num == PAC_MAN_WIIMOTE ){
            game.pMan.ai = false;
          }
          else{
            game.ghosts[num-GHOST_WIIMOTE].ai = false;
          }
      }
      return true;
      
  }
         
  if( message.equals("/wii/"+num+"/button/Left") ){  
    try{

      if( num == PAC_MAN_WIIMOTE ){
      
        if( value == 1.0f)
          game.pMan.removeDown();
        else
          game.pMan.addDown();
        
      }
      else{
        if( value == 1.0f)
          game.ghosts[num-GHOST_WIIMOTE].removeDown();
        else
          game.ghosts[num-GHOST_WIIMOTE].addDown();
      }

    }
    catch(Exception e){ println(e); }
    return true; 
  }
  if( message.equals("/wii/"+num+"/button/Up") ){  
    try{

      if( num == PAC_MAN_WIIMOTE ){
      
        if( value == 1.0f)
          game.pMan.removeLeft();
        else
          game.pMan.addLeft();
        
      }
      else{
        if( value == 1.0f)
          game.ghosts[num-GHOST_WIIMOTE].removeLeft();
        else
          game.ghosts[num-GHOST_WIIMOTE].addLeft();
      }

    }
    catch(Exception e){ println(e); }
    return true; 
  }
  if( message.equals("/wii/"+num+"/button/Down") ){  
    try{

      if( num == PAC_MAN_WIIMOTE ){
      
        if( value == 1.0f)
          game.pMan.removeRight();
        else
          game.pMan.addRight();
        
      }
      else{
        if( value == 1.0f)
          game.ghosts[num-GHOST_WIIMOTE].removeRight();
        else
          game.ghosts[num-GHOST_WIIMOTE].addRight();
      }

    }
    catch(Exception e){ println(e); }
    return true; 
  }  
  if( message.equals("/wii/"+num+"/button/Right") ){  
    try{

      if( num == PAC_MAN_WIIMOTE ){
      
        if( value == 1.0f)
          game.pMan.removeUp();
        else
          game.pMan.addUp();
        
      }
      else{
        if( value == 1.0f)
          game.ghosts[num-GHOST_WIIMOTE].removeUp();
        else
          game.ghosts[num-GHOST_WIIMOTE].addUp();
      }

    }
    catch(Exception e){ println(e); }
    return true; 
  }

  return false;
}

boolean handleWiimoteMessageInt(String message, int value){

  for( int i=1; i<= GHOST_COUNT+1; i++){
    if( checkWiiMoteInt(i,message,value) )
      return true;  
  }
  
  return false;
  
}

boolean handleWiimoteMessage(String message, float value){

  for( int i=1; i<= GHOST_COUNT+1; i++){
    if( checkWiiMote(i,message,value) )
      return true;  
  }
  
  return false;
  
}

boolean handleTimeMessage(String message, float value){
  //blue
  if( message.equals("/time0") ){  
    try{

    LineMap lm = getLMap(0);
    //lm.ph.t.pause();
    //lm.ph.t.seek(value);
    //lm.ph.t.resume();
    }
    catch(Exception e){ println(e); }
    return true; 
  }
  if( message.equals("/time1") ){  
    try{

    LineMap lm = getLMap(1);
    //lm.ph.t.pause();
    //lm.ph.t.seek(value);
    //lm.ph.t.resume();
    }
    catch(Exception e){ println(e); }
    return true; 
  }
  if( message.equals("/time2") ){  
    try{

    LineMap lm = getLMap(2);
    //lm.ph.t.pause();
    //lm.ph.t.seek(value);
    //lm.ph.t.resume();
    }
    catch(Exception e){ println(e); }
    return true; 
  }
  if( message.equals("/time3") ){  
    try{

    LineMap lm = getLMap(3);
    //lm.ph.t.pause();
    //lm.ph.t.seek(value);
    //lm.ph.t.resume();
    }
    catch(Exception e){ println(e); }
    return true; 
  }
  
  return false;
  
}

void controlMessage(String message, float value){
  
  if( handleWiimoteMessage(message,value) )
    return;
    
  if( handleTimeMessage(message,value) )
    return;
    
  if( handleColorMessage(message,value) )
    return;

  if( handleLineMessage(message,value) )
    return;

  if( handleRouteMessage(message,value) )
    return;
  
}


void oscEvent(OscMessage theOscMessage) {

    if(theOscMessage.checkTypetag("f")) {
     float secondValue = theOscMessage.get(0).floatValue(); // get the second osc argument
     // print("### "+theOscMessage.addrPattern());
     // println(" "+secondValue);
      controlMessage(theOscMessage.addrPattern(),secondValue);
     
      return;
    }
    else if(theOscMessage.checkTypetag("i")){
       int secondValue = theOscMessage.get(0).intValue(); // get the second osc argument
       // print("### "+theOscMessage.addrPattern());
       // println(" "+secondValue);
        handleWiimoteMessageInt(theOscMessage.addrPattern(),secondValue);
        return;
     
    }
    else if(theOscMessage.checkTypetag("ff")) {
      /* parse theOscMessage and extract the values from the osc message arguments. */
      float firstValue = theOscMessage.get(0).floatValue();  // get the first osc argument
      float secondValue = theOscMessage.get(1).floatValue(); // get the second osc argument
     // String thirdValue = theOscMessage.get(2).stringValue(); // get the third osc argument
    //  print("### "+theOscMessage.addrPattern());
     // println(" "+firstValue+", "+secondValue);
      controlMessage(theOscMessage.addrPattern(),firstValue,secondValue);
     
    
      return;
    }
    
  println("### received an osc message. with address pattern "+
          theOscMessage.addrPattern()+" typetag "+ theOscMessage.typetag());
}


 





