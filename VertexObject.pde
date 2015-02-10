void setupVertexObjects(){

  //doah, some threads may not be loading information before now... double doah.
  try{ Thread.sleep(1500); }catch(Exception e){}
  
  for(PortalQueue pq : portalQueue ){

          Portal p1 = new Portal(this,scene,PORTAL_WIDTH);
          p1.id = pq.id;
          p1.idOther = pq.other;
          p1.setLocation(pq.location.x,pq.location.y,pq.location.z);
         // p1.setLineVertex(getCurrentLMap().lt.getRandomLineVertex()); 
          p1.setClosestLineVertex();
          p1.setColor(pq.r,pq.g,pq.b,pq.a);
          p1.setupRing(p1.radius);
          game.portals.add(p1);
  }  

  for( int i = 0; i < game.portals.size(); i++){
 
      Portal p = game.portals.get(i);;    
      if( p.other == null ){
        
        for(int j =0; j < game.portals.size(); j++){
          Portal p2 = game.portals.get(j);
          if( p2.id.equals(p.idOther) ){
            p.setOther(p2);
            p2.setOther(p);
          }
    
        }
      }
    
  }
  
  
}


void loadVertexObjects(){
  
  try{
    XMLInOut xmlIO = new XMLInOut(this);
    xmlIO.loadElement("vertex_objects.xml"); 
  }
  catch(Exception e){ 
    println(e); 
  } 
  
}

class PortalQueue {
  PVector location = new PVector(0,0,0);
  String id;
  String other;
  int r;
  int g;
  int b;
  int a;
}

CopyOnWriteArrayList<PortalQueue> portalQueue = new CopyOnWriteArrayList<PortalQueue>();

void loadVertexObjectsFile(proxml.XMLElement root){

  portalQueue.clear();
    
  for (int i=0; i < root.countChildren(); i++) {

		 String type = root.getChild(i).getName();

                 if( type.equals("powerpellet") ){
                   
                 }
                 else if( type.equals("pachome") ){
                   
                   game.pHome.setLocation(root.getChild(i).getFloatAttribute("x"),root.getChild(i).getFloatAttribute("y"),root.getChild(i).getFloatAttribute("z")); 
                   game.pHome.setClosestLineVertex();

                 }
                 else if( type.equals("ghosthome") ){
                   
                   game.gHome.setLocation(root.getChild(i).getFloatAttribute("x"),root.getChild(i).getFloatAttribute("y"),root.getChild(i).getFloatAttribute("z")); 
                   game.gHome.setClosestLineVertex();

                 }
                 else if( type.equals("portal") ){
                   PortalQueue p = new PortalQueue();
                   p.location.set(root.getChild(i).getFloatAttribute("x"),root.getChild(i).getFloatAttribute("y"),root.getChild(i).getFloatAttribute("z")); 
                   p.id = root.getChild(i).getAttribute("id");
                   p.other = root.getChild(i).getAttribute("other");
                   p.r = root.getChild(i).getIntAttribute("r");
                   p.g = root.getChild(i).getIntAttribute("g");
                   p.b = root.getChild(i).getIntAttribute("b");
                   p.a = root.getChild(i).getIntAttribute("a");
                   
                   portalQueue.add(p);

                 }

  }


  
}

void saveVertexObjects() {

  String filename = "vertex_objects.xml";
  
		proxml.XMLElement root = new proxml.XMLElement("VertexObjects");

		for (Portal p : game.portals) {

			proxml.XMLElement xml = new proxml.XMLElement("portal"); 
                        xml.addAttribute("id",p.hashCode());
                        xml.addAttribute("other",p.other.hashCode());
                        xml.addAttribute("x", p.location.x);
                        xml.addAttribute("y", p.location.y);
                        xml.addAttribute("z", p.location.z);
                        xml.addAttribute("r", p.r);
                        xml.addAttribute("g", p.g);
                        xml.addAttribute("b", p.b);
                        xml.addAttribute("a", p.a);
                         			
			root.addChild(xml);

		}

		for (Pellet p : game.pellets) {

                  if( p.isPower ){
			proxml.XMLElement xml = new proxml.XMLElement("powerpellet"); 
                        xml.addAttribute("x", p.location.x);
                        xml.addAttribute("y", p.location.y);
                        xml.addAttribute("z", p.location.z);
                         			
			root.addChild(xml);
                  }

		}

                if( game.pHome != null ){
			proxml.XMLElement xml = new proxml.XMLElement("pachome"); 
                        xml.addAttribute("x", game.pHome.location.x);
                        xml.addAttribute("y", game.pHome.location.y);
                        xml.addAttribute("z", game.pHome.location.z);
                         			
			root.addChild(xml);    
                }

                if( game.gHome != null ){
			proxml.XMLElement xml = new proxml.XMLElement("ghosthome"); 
                        xml.addAttribute("x", game.gHome.location.x);
                        xml.addAttribute("y", game.gHome.location.y);
                        xml.addAttribute("z", game.gHome.location.z);
                         			
			root.addChild(xml);    
                }
                
		try {
                        XMLInOut xmlInOut =  new XMLInOut(this);
                        xmlInOut.saveElement(root, filename);
		} catch (Exception e) {
			PApplet.println(e.getStackTrace());
		}
		
		PApplet.println("VertexObjects layout saved to " + filename);
	}



class VertexObject extends GLModel{
 
  boolean active = false;
  
  InteractiveFrame iFrame;
  Scene scene;
  PApplet parent;
  
  LineVertex clv;
  int vcount = 0;

  float radius = 100f;
  PVector location = new PVector(0,0,0);

  int r = 0;
  int g = 255;
  int b = 255;
  int a = 255;
  
  public VertexObject(PApplet parent, Scene scene,float radius){
  
    super(parent, (int)LV_DIVISIONS+5, TRIANGLE_FAN, GLModel.STATIC);
    this.parent = parent;
    this.scene = scene;
    iFrame = new InteractiveFrame(scene);

  } 

  
  void setSize(float s){

  }

  
  void setColor(int r, int g, int b, int a){

  }
  
  void setClosestLineVertex(){
    for( LineVertex lv : gLineMap.get(0).lt.lGroup ){
      if( lv.location.dist(location) < PELLET_DISTANCE ){
        setLineVertex(lv);
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
  
  PVector getLocation(){
    return location;
  }
  
  void setActive(boolean state){
    active = state;
  }
  
  boolean isActive(){
    return active;
  }
  
 
  public void snapVertexObject() throws Exception{
    
    LineMap lm = getCurrentLMap();
    if( lm.lt.lGroup.size() >= 0 ){

      for(LineVertex lv2 : lm.lt.lGroup ){

        if( location.dist(lv2.location) <= snapDistance ){

          location.x = lv2.location.x;
          location.y = lv2.location.y;
          setLineVertex(lv2);
          return;
        }
            
      }
        
    }

  }
  
  public void snap() throws Exception{
    
    LineMap lm = getCurrentLMap();
    if( lm.lt.lGroup.size() >= 0 ){

      for(LineVertex lv2 : lm.lt.lGroup ){

        if( location.dist(lv2.location) <= snapDistance ){
          setLineVertex(lv2);
          return;
        }
            
      }
        
    }

  }
  
  void display( GLGraphics renderer){
  
      if( calibrationMode )
        return;

  }
  
  
}



