
  
class LineTree{
 
  float lWidth = 1;
  float pSize = 1;
  PApplet parent;
  
  ArrayList<LineVertex> lGroup = new ArrayList<LineVertex>();
  HashMap lHash = new HashMap();
  
  int activeVertex = -1;
  boolean updateSize = false;
  LineColor lColor = new LineColor();
  
  public LineTree(PApplet parent){
   
    this.parent = parent;
    lColor.update =true;
    lColor.r = 255;
    lColor.g = 0;
    lColor.b = 0;
    lColor.a = 75;
   
  }

  public LineVertex getRandomLineVertex(){
    int i = (int)random(0,lGroup.size());
    return lGroup.get(i);
  }

  public void setLineWidth(float lWidth){
    this.lWidth = lWidth;
    for(LineVertex lv : lGroup){
       lv.setLineWidth(lWidth);
    }  
  }
  
  void setSize(float s){
    pSize = s;
    for(LineVertex lv : lGroup){
      lv.setSize(s);
      lv.setLineWidth(s);
    } 
  }
  
  public void updateSize(float s){
    this.lWidth = s;
    this.pSize = s;  
    updateSize = true;
  }
  
  public void updateRedColor(int r){
    lColor.r = r;
    lColor.update = true;
  }

  public void updateGreenColor(int g){
    lColor.g = g;
    lColor.update = true;
  }
  
  public void updateBlueColor(int b){
    lColor.b = b;
    lColor.update = true;
  }
 
  public void updateAlphaColor(int a){
    lColor.a = a;
    lColor.update = true;
  }
  
  public void setColor(int r, int g, int b, int a){
    lColor.update = false;
    lColor.r = r;
    lColor.g = g;
    lColor.b = b;
    lColor.a = a;
    
    for(LineVertex lv : lGroup){
      lv.setColor(r,g,b,a);
    }  
  }

  public void rescanCurrentPoint(){
    activeVertex = rescanActiveVertex();
    if( activeVertex >= 0 ){
      LineVertex lv = lGroup.get(activeVertex);
      lv.rescanNeighborLines();
      for(LineVertex lv2 : lv.neighbors ){
        lv2.rescanNeighborLines(); 
      } 
    }
  }
  
  public void rescanPoints(){
   for( LineVertex lv : lGroup )
     lv.rescanNeighborLines();
  }
  
  public void snapPoint(){
       activeVertex = rescanActiveVertex();
    if( activeVertex >= 0 ){
      LineVertex lv = lGroup.get(activeVertex);
      
      int ctr = 0;
      boolean check = false;
      for(LineVertex lv2 : lGroup ){
        if( lv2 != lv ){
          if( lv.location.dist(lv2.location) <= snapDistance ){
            lv.location.x = lv2.location.x;
            lv.location.y = lv2.location.y;
            for( LineVertex lv2n : lv2.neighbors ){
              lv.addNeighbor(lv2n);
              lv2n.addNeighbor(lv);
              lv2n.removeNeighbor(lv2);   
            }
            check = true;
            break;
          }
        }
        ctr++;
      }
      
      if( check ){
        LineVertex lv3 = lGroup.remove(ctr);
        scene.removeFromMouseGrabberPool(lv3.iFrame);
      }
    }
  }

  public void pushPoint(String id,float x, float y, float z){

    LineVertex lVertex = new LineVertex(parent,this,scene,id);
    lVertex.setLocation(x,y,z);
    lGroup.add(lVertex);
    lHash.put(id,lGroup.size()-1);

  }
  
  public void addPoint(float x, float y, float z){
//println(x+" "+y+" "+z);
    activeVertex = rescanActiveVertex();

    LineVertex lVertex = new LineVertex(parent,this,scene,lWidth);
    lVertex.setLocation(x,y,z);
    lVertex.setLineWidth(lWidth);
    lVertex.setColor(lColor.r,lColor.g,lColor.b,lColor.a);  
      
    //find active, not active?  set last in list active.
    if( activeVertex >= 0 ){
      LineVertex lv = lGroup.get(activeVertex);
      deactivateGroup();
      lVertex.setActive(true);
      lv.addNeighbor(lVertex);
      lVertex.addNeighbor(lv);
      lGroup.add(lVertex);
      activeVertex = lGroup.size()-1;

    }
    else{
      activeVertex =lGroup.size();
      deactivateGroup();
      lVertex.setActive(true);
      lGroup.add(lVertex);
    }

    rescanCurrentPoint();
 
  }
  
  public void removePoint(){
    
   activeVertex = rescanActiveVertex();
   
   if(activeVertex >= 0){
      
      LineVertex lVertex = lGroup.get(activeVertex);
      
        if( lVertex.neighbors.size() <= 1 ){
        lVertex = lGroup.remove(activeVertex);
        for( LineVertex lv : lGroup ){
          if( lv != lVertex ){
            lv.removeNeighbor(lVertex);  
          }
        }
        scene.removeFromMouseGrabberPool(lVertex.iFrame);
        activeVertex = lGroup.size()-1;
      }
      
   }

   activeVertex = rescanActiveVertex();  
   
    rescanCurrentPoint();

  }
  
  
  public void deactivateGroup(){
      for( LineVertex lv : lGroup )
        lv.setActive(false);
    
  }
  
  public int rescanActiveVertex(){
    
    if( lGroup.size() == 0)
      return -1;
      
    int i = 0;
    for( LineVertex lv : lGroup ){
      if( lv.isActive() )
        return i;
      i++;
    }
    
    lGroup.get(lGroup.size()-1).setActive(true);
    
    return -1;
  }
  

 
  void display(GLGraphics renderer ){

   if( lColor.update )
     setColor(lColor.r,lColor.g,lColor.b,lColor.a);
     
   if( updateSize )
     setSize( lWidth );  
   
    for( LineVertex lv : lGroup ){
      
      lv.display(renderer); 
      lv.displayNeighbors(renderer);     

    }
  }
  
}
