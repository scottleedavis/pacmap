static ArrayList<LineMap> gLineMap = new ArrayList<LineMap>();

class LineMap {
  //Path ph;
  LineTree lt; 
  PApplet parent;

  public LineMap(PApplet p){
    parent = p;
    lt = new LineTree(parent);
   //ph = new Path(lt);
  }
}

class LineMapNode {
  String id = "";
  PVector location = new PVector(0,0);
  ArrayList<String> neighbors = new ArrayList<String>();
}

LineMap getLMap(int i) throws Exception{
  return gLineMap.get(getLMapIndex());  
}

LineMap getCurrentLMap() throws Exception{
  return gLineMap.get(getLMapIndex()); 
}

void saveLineMap(){

  
  saveVertexObjects();

  try{  
    
    LineMap lm = getCurrentLMap();
    
    proxml.XMLElement file = new proxml.XMLElement("LineMap");
    
    proxml.XMLElement tree = new proxml.XMLElement("LineTree");
    
    //loop through vertex and save adjacent neighbors
    for( LineVertex lv : lm.lt.lGroup ){
      proxml.XMLElement lVertex = new proxml.XMLElement("LineVertex");
      lVertex.addAttribute("id",lv.hashCode());
      lVertex.addAttribute("x", lv.location.x);
      lVertex.addAttribute("y", lv.location.y);
      lVertex.addAttribute("z", lv.location.z);
      proxml.XMLElement lNeighbors = new proxml.XMLElement("Neighbors");
      for( LineVertex lvn : lv.neighbors ){
        proxml.XMLElement lNeighbor = new proxml.XMLElement("Neighbor");  
        lNeighbor.addAttribute("id",lvn.hashCode());
        lNeighbors.addChild(lNeighbor);
      }
      lVertex.addChild(lNeighbors);
      tree.addChild(lVertex);
     
    }
    
    file.addChild(tree);

    XMLInOut xmlInOut =  new XMLInOut(this);
    
    // and call saveElement.
    xmlInOut.saveElement(file, "LineMap.xml");
     
  }
  catch(Exception e){ println(e); }
}

void loadLineMap(){
  
  try{
    XMLInOut xmlIO = new XMLInOut(this);
    xmlIO.loadElement("LineMap.xml"); 

  }
  catch(Exception e){ 
    println(e); 
    generateGrid(GRIDX,GRIDY);
  } 
 
  
}

void xmlEvent(proxml.XMLElement file){

  if(file.getName().equals("keystone")){
    ks.load(file);
    return; 
  }

  if(file.getName().equals("VertexObjects")){
    loadVertexObjectsFile(file);
    return; 
  }
  
  HashMap hm = new HashMap();
  
  proxml.XMLElement tree;
  proxml.XMLElement lVertex;
  proxml.XMLElement lNeighbors;
  proxml.XMLElement lNeighbor;

  try{
    
    LineMap lm = getCurrentLMap();
    lm.lt.lGroup.clear();
    
    
    for(int i = 0; i < file.countChildren();i++){              //linemaps
        //println(element.getElement());
        tree = file.getChild(i);
        for(int j = 0; j < tree.countChildren(); j++){            //line trees
          //println(tree.getChild(j));
          lVertex = tree.getChild(j);                       
          for(int k = 0; k < lVertex.countChildren(); k++){       //linevertex
            //println(lVertex.getChild(k));
            lNeighbors = lVertex.getChild(k);
            String lVertexId = lVertex.getAttribute("id");
            float vx = Float.parseFloat(lVertex.getAttribute("x"));
            float vy = Float.parseFloat(lVertex.getAttribute("y"));
            float vz = Float.parseFloat(lVertex.getAttribute("z"));
            //println(vx+","+vy+","+vz);      
            
            if(hm.containsKey(lVertexId)){ //update location information
              LineMapNode lmn = (LineMapNode)hm.get(lVertexId);
              lmn.location.set(vx,vy,vz);
              hm.put(lVertexId,lmn);
            }else{ //add new line Vertex

              LineMapNode lmn = new LineMapNode();
              lmn.location.set(vx,vy,vz);
              lmn.id = lVertexId;
              hm.put(lVertexId,lmn);
            }
            
            //x,y,z
            for(int l = 0; l < lNeighbors.countChildren(); l++){  //linevertex neighbors
              //println(lNeighbors.getChild(l));
              lNeighbor = lNeighbors.getChild(l);
              String neighborId = lNeighbor.getAttribute("id");  
              //println(" "+neighborId);
              
               if( !hm.containsKey( neighborId ) ){
                  LineMapNode lmn = new LineMapNode();
                  lmn.id = neighborId;
                  hm.put(neighborId,lmn);
               }
               
               LineMapNode lmn = (LineMapNode)hm.get(lVertexId);
               lmn.neighbors.add(neighborId);
               hm.put(lVertexId,lmn);

            }
          }
        }
        
    }
    
    
    //iterate through hashMap...  addPoints
    Iterator i = hm.entrySet().iterator();  // Get an iterator
    
    //build pointts
    while (i.hasNext()) {
      Map.Entry me = (Map.Entry)i.next();
      LineMapNode lmn = (LineMapNode)me.getValue();
      pushPoint(lmn.id,lmn.location.x,lmn.location.y,lmn.location.z);
    }

    for( LineVertex lv : lm.lt.lGroup ){
      LineMapNode lmn = (LineMapNode)hm.get(lv.id);
      //println(lv.id);
     
      for( String id : lmn.neighbors ){
        int offset =  (Integer)lm.lt.lHash.get(id) ;
        LineVertex lvv = lm.lt.lGroup.get(offset);
       // println("   "+lvv.id);
        lv.addNeighbor(lvv);
        //lvv.addNeighbor(lv);
      }   
    }
        
   
  }
  catch(Exception e){ println(e); }
      
}

void generateGrid(int x, int y){
  
  int total = x * y;
  int minX = w * -1;
  int maxX = w;
  int minY = h * -1;
  int maxY = h;
  
  float spanX = maxX - minX;
  float spanY = maxY - minY;
  float xdiv = spanX / x;
  float ydiv = spanY / y;
  float tmpX = minX;
  float tmpY = minY;
  
  LineVertex[][] gridl = new LineVertex[x][y];
  try{
  
    LineMap lm = getCurrentLMap();
    
    for(int i=0; i<x; i++){
      tmpY = minY;
      
      for(int j=0; j<y; j++){
 
        LineVertex lVertex = new LineVertex(this,lm.lt,scene,lm.lt.lWidth);
        lVertex.setLocation(tmpX,tmpY,0);
        lVertex.setLineWidth(lm.lt.lWidth);
        lVertex.setColor(lm.lt.lColor.r,lm.lt.lColor.g,lm.lt.lColor.b,lm.lt.lColor.a);  
        lm.lt.lGroup.add(lVertex);
        gridl[i][j] = lVertex;
        tmpY += ydiv;
      }
      tmpX += xdiv;
    }
    
    for(int i=0; i<x; i++){
      for(int j=0; j<y; j++){ 

        if(i < (x-1) && j < (y-1)){
          gridl[i][j].addNeighbor( gridl[i+1][j] ); 
          gridl[i+1][j].addNeighbor( gridl[i][j] );
          gridl[i][j].addNeighbor( gridl[i][j+1] ); 
          gridl[i][j+1].addNeighbor( gridl[i][j] );
        }
        else{
           if( j == y-1 ){
              gridl[i][j].addNeighbor(gridl[i+1][j]);
             gridl[i+1][j].addNeighbor(gridl[i][j]);
            }
            if( i == x-1){
              gridl[i][j].addNeighbor(gridl[i][j+1]);
             gridl[i][j+1].addNeighbor(gridl[i][j]);
            }
        }
      
      }
      
    }
  
  }
  catch(Exception e){}
  
}

LineMap setupLineMap(){

  if( gLineMap != null && gLineMap.size() > 0 ){
    return gLineMap.get(0); 
  }

  gLineMap.add(new LineMap(this));
  
  setLMapIndex(0);  
  
  gLineMap.get(0).lt.setLineWidth(LINE_WIDTH);
  
  return gLineMap.get(0);
  
}

void setLMapIndex(int index){
  if( gLineMap.size() > 0 && index >= 0)
    lMapIndex = index;
  else
    index = -1;
}

int getLMapIndex(){
  return lMapIndex;  
}
  
void addLineMap(){
    gLineMap.add(new LineMap(this));
 // setLMapIndex(lMap.size()-1);
}

void removeLineMap(){
  if( gLineMap.size() > 0 )
    gLineMap.remove( gLineMap.size() - 1);
  
}

void removeLineMap(int index){
  try {
    gLineMap.remove( index ); 
  } catch( Exception e) {} 
  
}

void pushPoint(String id,float x, float y, float z){

  try{
  LineMap lm = getCurrentLMap();
  lm.lt.pushPoint(id,x,y,z);
  }
  catch(Exception e){ println("pushPoint exception: "+e); }
}

void addPoint(float x, float y, float z){

  try{
  LineMap lm = getCurrentLMap();
  lm.lt.addPoint(x,y,z);
  }
  catch(Exception e){ println("addPoint exception: "+e); }
}

void removePoint(){
  try{
  LineMap lm = getCurrentLMap();
  lm.lt.removePoint();
  }
  catch(Exception e){ println("removePoint exception: "+e); }
}

