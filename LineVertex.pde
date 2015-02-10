
class LineVertex{
 
  //boolean touched = false;
  boolean visited = false;
  boolean approaching = false;
  boolean active = false;
  boolean drawn = false;
  InteractiveFrame iFrame;
  Scene scene;
  PApplet parent;
  String id = "";
  GLModel vModel;
  
  LineTree lt;
  ArrayList<LineVertex> neighbors = new ArrayList<LineVertex>();
  ArrayList<Line> neighborLine = new ArrayList<Line>();
  
  float radius = 100;
  float lineWidth = 5;
  PVector location = new PVector();
  
  public LineVertex(PApplet parent, LineTree lt, Scene scene, float radius){

    this.parent = parent;
    this.scene = scene;
    iFrame = new InteractiveFrame(scene);
    this.lt = lt;
    setupOpenGL(radius);
    
  } 

  public LineVertex(PApplet parent, LineTree lt, Scene scene, String id){

    this.parent = parent;
    this.scene = scene;
    iFrame = new InteractiveFrame(scene);
    this.lt = lt;
    this.id = id;
    
  } 
  
  void setupOpenGL(float radius){
  
    vModel = new GLModel(parent, (int)LV_DIVISIONS+3, TRIANGLE_FAN, GLModel.STATIC);    
    setSize(radius);
    vModel.initColors();  
    setColor(lt.lColor.r,lt.lColor.g,lt.lColor.b,lt.lColor.a);  
    drawn = true;  
  }
  
  void setSize(float s){
    
    this.radius = s; 

    vModel.beginUpdateVertices();
    vModel.updateVertex(0,0,0,0);
    vModel.updateVertex(1, cos(0)*radius,sin(0)*radius,0);
    
        
    float j = 0.0f;
    for(int i=2; i<= LV_DIVISIONS+2;i++){//LV_DIVISIONS; i++){
      vModel.updateVertex(i, cos((j)*PI/180)*radius,  sin(-j*PI/180)*radius,0);
      j+= LV_CHUNK;
    }
    vModel.endUpdateVertices();
   
  }
  
  void setLineWidth(float lWidth){
    lineWidth = lWidth;  
    for( Line nl : neighborLine ){
      nl.setWidth(lWidth);  
    }
  }
  
  void addNeighbor(LineVertex lv){
    
    if( !neighbors.contains(lv) ){
      neighbors.add(lv);
      PVector p2 = lv.location;
      neighborLine.add(new Line(parent,scene,location,p2,lineWidth));
    }
    
  }
  
  void removeNeighbor(LineVertex lv){
    neighbors.remove(lv);
  }
  
  
  void rescanNeighborLines(){

    if( neighbors.size() >= neighborLine.size() ){ //we have add 

       for( LineVertex lv : neighbors ) {
          PVector p2 = lv.getLocation();
          Line l = new Line(parent,scene,location,p2,lineWidth);
          l.setColor(lt.lColor.r,lt.lColor.g,lt.lColor.b,lt.lColor.a);
          neighborLine.add(l);
          
        }
    }
    else if( neighbors.size() < neighborLine.size() ){ //we have a delete
    
      neighborLine.clear();
    
      for( LineVertex lv : neighbors ) {
        PVector p2 = lv.getLocation();
        Line l = new Line(parent,scene,location,p2,lineWidth);
        l.setColor(lt.lColor.r,lt.lColor.g,lt.lColor.b,lt.lColor.a);
        neighborLine.add(l);
        
      }
    }
    
  }
  
  void setColor(int r, int g, int b, int a){

    vModel.beginUpdateColors();
    
    for(int i=0; i<=LV_DIVISIONS+2;i++){
     vModel.updateColor(i,r,g,b,a); 
    }
  
    vModel.endUpdateColors();
  
    for( Line nl : neighborLine ){
      nl.setColor(r,g,b,a); 
    }
   
  }
  
  void setLocation(float x, float y, float z){
    location.x = x;
    location.y = y;
    location.z = z;
    iFrame.setPosition(location);

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
  
  void displayNeighbors( GLGraphics renderer ){
    
    for( Line l : neighborLine )
      l.display(renderer);

  }
  
  void display( GLGraphics renderer){

    if( !drawn ){ //create graphics when needed
      setupOpenGL(lt.lWidth);  
    }
     
    pushMatrix();
   
    iFrame.applyTransformation(); //optimum

    noStroke();
    
    if(iFrame.grabsMouse() && mousePressed ){
     
     lt.deactivateGroup();
     setActive(true); 
      
    }

    //testing helpful
    if (calibrationMode){
      if(iFrame.grabsMouse())
        setColor(255,0,0,125);
      else
        setColor(0,255,0,125);
    }
    else
      setColor(lt.lColor.r,lt.lColor.g,lt.lColor.b,lt.lColor.a);
   
    renderer.gl.glDepthMask(false);  
    renderer.model(vModel);
    renderer.gl.glDepthMask(true);


    popMatrix();

  }
  
}
