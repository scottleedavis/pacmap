
//grafix
import processing.opengl.*;
import codeanticode.glgraphics.*;
import javax.media.opengl.*;
import javax.media.opengl.glu.GLU;
import remixlab.proscene.*;
import deadpixel.keystone.*;


//io
import ddf.minim.*;
import java.io.OutputStream;
import proxml.*;
import oscP5.*;
import netP5.*;

//misc
import java.util.concurrent.*;
import java.nio.FloatBuffer;


int w = SCREEN_WIDTH;
int h = SCREEN_HEIGHT;

//grafix
Scene scene;
GLGraphicsOffScreen offscreen;
Keystone ks;
DrawSurface surface;

GLCamera glCam;
PImage bg;
PFont fontA;

//game
Game game;

//io
OscP5 oscP5;
NetAddress oscRoute;

//misc
boolean calibrationMode = true;



void setup() {
 

  
  //w = screen.width;
  //h = screen.height;
  size(w,h, GLConstants.GLGRAPHICS);

  fontA = loadFont(FONT_FILE);
  
  oscP5    = new OscP5(this,12000);
  oscRoute = new NetAddress("127.0.0.1",12001);
  
  setupScene();

  setupLineMap();
  loadLineMap();
  
  setupGame(this);

  setupHome();
  loadVertexObjects();
  
  noCursor();


  setupVertexObjects();
  
  
  offscreen = new GLGraphicsOffScreen(this, 400,300);

  ks = new Keystone(this);
  try{
         ks.load();
  }catch(Exception e){
    surface = ks.createDrawSurface(1, mw,mh, surf_division);
  }
  ks.stopCalibration();
  calibrationMode = false;


  
  
        try{
          LineMap lm = getCurrentLMap();

          if( lm.lt.lGroup.size() > 1 ){
            beginGame();

          }else
            game.begun = false;
        }
        catch(Exception e){ println("beginGame: "+e); } 
  
}

void setupScene(){
  
  scene    = new Scene(this);
  glCam    = new GLCamera(scene);
  
  AxisPlaneConstraint apc = new WorldConstraint();
  PVector dir = new PVector(0f,0f,0f);

  apc.setRotationConstraintType(AxisPlaneConstraint.Type.FORBIDDEN);
  apc.setRotationConstraintDirection(dir);
 
  scene.setCamera(glCam);
  scene.setCameraType(Camera.Type.ORTHOGRAPHIC);
  scene.camera().frame().setConstraint(apc);
  scene.setFrameSelectionHintIsDrawn(false);
  scene.setShortcut('f', Scene.KeyboardAction.DRAW_FRAME_SELECTION_HINT);
  scene.setRadius(w);
  scene.showAll();
  scene.setAxisIsDrawn(false);
  scene.setGridIsDrawn(false);  
  scene.removeShortcut('a');
  
  apc.setTranslationConstraintType(AxisPlaneConstraint.Type.FORBIDDEN);
  apc.setTranslationConstraintDirection(dir);
  
}

void draw() {

  GLGraphics renderer = (GLGraphics)g;

  drawDrawSurface(surface,renderer);
  
  renderer.beginGL();
           
  GL gl = renderer.gl;
  gl.glEnable(GL.GL_BLEND);
  gl.glBlendFunc(GL.GL_SRC_ALPHA, GL.GL_ONE);

  try{
    for( LineMap lm : gLineMap )
      lm.lt.display(renderer);
  }
  catch(Exception e){ println("lineMap: "+e); }
  
  try{
    if( calibrationMode )
      game.pMan.ai = false;
      
    if( game.begun )
      game.run(renderer);
  }
  catch(Exception e){ println("game: "+e); }
  
  renderer.endGL();    


   if( calibrationMode )
      scene.drawCross(MOUSE_COLOR, mouseX,mouseY, MOUSE_SIZE,MOUSE_WEIGHT);
   
}

void stop(){
  game.sound.stop();
}

