

class Pellet extends VertexObject{
 
  boolean isPower = false;
  boolean munched = false;

  public Pellet(PApplet parent, Scene scene,float radius){
  
    super(parent, scene, radius);

    setSize(radius);
    initColors();
    setColor(255,0,0,255);
  } 
  
  void setSize(float s){
    
    vcount = 2;
    this.radius = s; 

    beginUpdateVertices();
    updateVertex(0,0,0,0);
    updateVertex(1, cos(0)*radius,sin(0)*radius,0);
    
    float j = 0.0f;
    for(int i=2; i<= (LV_DIVISIONS+2);i++){
      updateVertex(i, cos((j)*PI/180)*radius,  sin(-j*PI/180)*radius,0);
      j+= LV_CHUNK;
      vcount++;
    }
    
    vcount--;
    endUpdateVertices();
   
  }
  
  void setColor(int r, int g, int b, int a){

    beginUpdateColors();
    
    for(int i=0; i<=vcount;i++){//(LV_DIVISIONS+4)/2;i++){
     updateColor(i,r,g,b,a); 
    }
  
    endUpdateColors();
  }
  
  void setPowerPellet(){
    isPower = true;
    setSize( radius*1.5);
    setColor(255,255,0,255);
    
  }
  
  void display( GLGraphics renderer){

            
    if( calibrationMode )
      return;
      
        if( !munched ){
          pushMatrix();
          
          iFrame.applyTransformation(); 
      
          noStroke();
      
          gl.glDepthMask(false);  
          renderer.model(this);
          gl.glDepthMask(true);
      
          popMatrix();
        }
        else{
          iFrame.removeFromMouseGrabberPool();
        }
        
  } 
  
}

