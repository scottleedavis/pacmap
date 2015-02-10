

class GhostHome extends VertexObject{
 
  GhostHome other;
  GLModel ring;

  public GhostHome(PApplet parent, Scene scene,float radius){
  
    super(parent, scene, radius);

    setSize(radius);
    setupRing(radius);
    initColors();
    setColor(r,g,b,a);
  } 
  
  void setSize(float s){
    
    vcount = 2;
    this.radius = s; 

    beginUpdateVertices();
    updateVertex(0,0,0,0);
    updateVertex(1, cos(0)*radius,sin(0)*radius,0);
    
    float j = 0.0f;
    for(int i=2; i<= (LV_DIVISIONS+4)/2;i++){
      updateVertex(i, cos((j)*PI/180)*radius,  sin(-j*PI/180)*radius,0);
      j+= LV_CHUNK;
      vcount++;
    }
    updateVertex(vcount++, -radius, radius,0);
    
    updateVertex(vcount++, -radius/2, 2*radius/3,0);
    updateVertex(vcount++, 0, radius,0);
    updateVertex(vcount++,radius/2,2*radius/3,0); 
     
    updateVertex(vcount++, radius, radius,0);
    updateVertex(vcount++, radius,0,0);
    updateVertex(vcount++, 0, 0,0);
    endUpdateVertices();
   
    
  }
   

   void setupRing(float s){
    
     int ecount = 2;
     s *= 1.7;
     
     
     ring = new GLModel(parent,(int)LV_DIVISIONS+3, GLModel.TRIANGLE_FAN, GLModel.DYNAMIC); 
    
     float j = 0.0f;

    ring.beginUpdateVertices();
    ring.updateVertex(0,0,0,0);
    ring.updateVertex(1, cos(0)*s,sin(0)*s,0);
    
    for(int i=2; i<= (LV_DIVISIONS+4)/2;i++){
      ring.updateVertex(i, cos((j)*PI/180)*s,  sin(-j*PI/180)*s,0);
      j+= LV_CHUNK;
      ecount++;
    }
    
    ring.updateVertex(ecount++, -s, s,0);
    
    ring.updateVertex(ecount++, -s/2, 2*s/3,0);
    ring.updateVertex(ecount++, 0, s,0);
    ring.updateVertex(ecount++,s/2,2*s/3,0); 
     
    ring.updateVertex(ecount++, s, s,0);
    ring.updateVertex(ecount++, s,0,0);
    ring.updateVertex(ecount++, 0, 0,0);
    ring.endUpdateVertices();
    
    ring.initColors();

    ring.beginUpdateColors();

    for(int i=0; i<ecount;i++){
     ring.updateColor(i,r,g,b,200); 
    }
  
    ring.endUpdateColors();

  }
  
  void setColor(int r, int g, int b, int a){

    this.r = r;
    this.g = g;
    this.b = b;
    this.a = a;
    beginUpdateColors();
    
    for(int i=0; i<=vcount;i++){//(LV_DIVISIONS+4)/2;i++){
     updateColor(i,0,0,0,200);//updateColor(i,r,g,b,a); 
    }
  
    endUpdateColors();
  }
  
  
  void display( GLGraphics renderer){

    pushMatrix();
    iFrame.applyTransformation(); 
      
    gl.glDepthMask(false); 
    renderer.model(ring);
    renderer.model(this);
    gl.glDepthMask(true);
      
    popMatrix();


  }
  
  
}

