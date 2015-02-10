
void drawMeshSurface(MeshSurface ms, GLGraphics renderer){

  offscreen.beginDraw();
  offscreen.background(0,0,0,0);
  offscreen.endDraw();

  ms.render( renderer,offscreen.getTexture());
  
}  

class MeshSurface extends CornerPinSurface {
  
  int style;
    
  public MeshSurface(PApplet parent, int s, int w, int h, int res) {
      super(parent,w,h,res);
      style = s;
      bgColor = color(0,0,0,0);
  }

	void calculateMesh() {
  
             
  
		for (int i=0; i < mesh.length; i++) {
			int x = i%res;
			int y = i/res;
			float fX = (float)x / (res-1);
			float fY = (float)y / (res-1);
			MeshPoint bot = mesh[TL].interpolateTo(mesh[TR], fX);
			MeshPoint top = mesh[BL].interpolateTo(mesh[BR], fX);
			mesh[i].interpolateBetween(bot, top, fY);
		}

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
