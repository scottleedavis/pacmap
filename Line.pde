
  class LineColor {
    boolean update = false;
    int r = 0;
    int g = 0;
    int b = 0;
    int a = 0;
  }
  
  
class Line{
 
  boolean active = false;
  boolean drawn = false;
  InteractiveFrame iFrame;
  Scene scene;
  GLModel lModel;
  PApplet parent;
  LineColor lColor;
  
  PVector p1;
  PVector p2;
  
  float lWidth = 5;
  
  public Line(PApplet parent, Scene scene,PVector p1, PVector p2,float w){
 
    this.parent = parent;
    this.scene = scene;
    this.p1 = p1;
    this.p2 = p2;
    this.lWidth = w;
    lColor = new LineColor();
  
  } 
 
  void setupModel(){
    lModel = new GLModel(parent, (int)LN_DIVISIONS+1, QUADS, GLModel.STATIC);
    drawn = true;
    setWidth(lWidth);
    lModel.initColors();
    setColor(lColor.r,lColor.g,lColor.b,lColor.a);
  }
  
  void setWidth(float w){


    lModel.beginUpdateVertices();
    
    float dx = p2.x - p1.x;
    float dy = p2.y - p1.y;
    
    float scaled = this.lWidth/(float)Math.sqrt(dx*dx+dy*dy);
    float dx2 = -dy * scaled;
    float dy2 = dx * scaled;
    
    lModel.updateVertex(0,p1.x-dx2,p1.y-dy2,p1.z);
    lModel.updateVertex(1,p1.x+dx2,p1.y+dy2,p1.z);
    
    dx = p1.x - p2.x;
    dy = p1.y - p2.y;
    
    scaled = this.lWidth/(float)Math.sqrt(dx*dx+dy*dy);
    dx2 = -dy * scaled;
    dy2 = dx * scaled;
    
    lModel.updateVertex(2,p2.x-dx2,p2.y-dy2,p2.z);
    lModel.updateVertex(3,p2.x+dx2,p2.y+dy2,p2.z);
    

    lModel.endUpdateVertices();
    
    
  }
  
  
  void setColor(int r, int g, int b, int a){
    
    lColor.r = r;
    lColor.g = g;
    lColor.b = b;
    lColor.a = a;
    
      if( lModel != null){

        lModel.beginUpdateColors();
        
        // Front face
        for(int i=0; i<=LN_DIVISIONS;i++){
         lModel.updateColor(i,lColor.r,lColor.g,lColor.b,lColor.a); 
        }
        
        lModel.endUpdateColors();
      }

    
  }
  
  void setLocation(PVector loc){
    iFrame.setPosition(loc);
  }
  
  void setActive(boolean state){
    active = state;
  }
  
  boolean isActive(){
    return active;
  }
  
  
  void display( GLGraphics renderer){

    if( !drawn )
      setupModel();

      
    pushMatrix();

    renderer.gl.glDepthMask(false);  
    renderer.model(lModel);
    renderer.gl.glDepthMask(true);

    popMatrix();

  }
  
}
