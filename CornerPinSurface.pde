
public class CornerPinSurface implements Draggable {

	PApplet parent;

	MeshPoint[] mesh;
 
	float x;
	float y;
	float clickX;
	float clickY;
	
	int res;
	
	final int TL; // top left
	final int TR; // top right
	final int BL; // bottom left
	final int BR; // bottom right
	
	int w;
	int h;
	
	int gridColor;
        int bgColor;
	int controlPointColor; 
	
	/**
	 * @param parent The parent applet -- used for default rendering mode
	 * @param w The surface's width, in pixels
	 * @param h The surface's height, in pixels
	 * @param res The surface's grid resolution
	 */
	CornerPinSurface(PApplet parent, int w, int h, int res) {
		
		this.parent = parent;
		
		this.w = w;
		this.h = h;
		
		res++;
		this.res = res;
		 
		// initialize the point array
		mesh = new MeshPoint[res*res];
		for (int i=0; i < mesh.length; i++) {
			float x = (i % res) / (float)(res-1);
			float y = (i / res) / (float)(res-1);
			mesh[i] = new MeshPoint(this, x*w, y*h, x*w, y*h);
		}
		
		// indices of the corner points
		TL = 0 + 0;  // x + y
		TR = res-1 + 0;
		BL = 0 + (res-1)*(res);
		BR = res-1 + (res-1)*(res);

		// make the corners control points
		mesh[TL].setControlPoint(true);
		mesh[TR].setControlPoint(true);
		mesh[BL].setControlPoint(true);
		mesh[BR].setControlPoint(true);
		
		calculateMesh();
		
		this.gridColor = 128;
		this.controlPointColor = 0xFF00FF00;
	}

	/**
	 * @return The surface's mesh resolution, in number of "tiles"
	 */
	public int getRes() {
		// The actual resolution is the number of tiles, not the number of mesh points
		return res-1;
	}
	
        
        
	/**
	 * Renders and applies keystoning to the image using the parent applet's renderer.
	 */
	public void render(PImage texture) {
  
  
            //configuration window
            if(calibrationMode)
		renderControl(parent.g,texture);
 
               //main display
                parent.g.pushMatrix();
                parent.g.translate(screen.width,0);
		renderDisplay(parent.g, texture);
                parent.g.popMatrix();
                
                
	}
	
        public void renderControl(PGraphics g, PImage texture){
		g.pushMatrix();
		g.translate(x, y);
                g.strokeWeight(1);
		if (calibrationMode) g.stroke(gridColor);
		else g.noStroke();
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
 		
 		if (calibrationMode) renderControlPoints(g);
 		
 		g.popMatrix();
        }
        
	/**
	 * Renders and applies keystoning to the image using a specific renderer.
	 */
	public void renderDisplay(PGraphics g, PImage texture) {
		g.pushMatrix();
		g.translate(x, y);
                g.strokeWeight(1);
		if (calibrationMode) g.stroke(gridColor);
		else g.noStroke();
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
 		
 		if (calibrationMode) renderControlPoints(g);
 		
 		g.popMatrix();
	}

        public PVector getViewPoint(int xx, int yy){
		
          
                //xx,yy are in coordinates local to a mw/mh mesh 400/300
                //  you are mapping these coordinates to the w/h mesh 1024/768
                // You are assuming the mw/mh mesh if rectangular, mapping to whatever skew is needed to make screw view rectangle
                
		// inverse billinear interpolation to figure out the relationship between 
		// the mouse in screen coordinates and the (s,t) position within a warped surface
		
		// modified version of the algorithm found here:
		// http://stackoverflow.com/questions/808441/inverse-bilinear-interpolation

                 PVector tmp = getTransformedPoint((int)x,(int)y);
		// local mouse x and y -- remove translation offset
		int lmx = xx - (int)tmp.x;
		int lmy = yy - (int)tmp.y;
		
		// these will make the following equations more clear
                tmp = getTransformedPoint(0,h);//(int)mesh[BL].x,(int)mesh[BL].y);
		float x0 = tmp.x;//mesh[BL].x;
		float y0 = tmp.y;//mesh[BL].y;
		tmp = getTransformedPoint(w,h);//(int)mesh[BR].x,(int)mesh[BR].y);
		float x1 = tmp.x;//mesh[BR].x;
		float y1 = tmp.y;//mesh[BR].y;
		tmp = getTransformedPoint(0,0);//(int)mesh[TL].x,(int)mesh[TL].y);
		float x2 = tmp.x;//mesh[TL].x;
		float y2 = tmp.y;//mesh[TL].y;
		tmp = getTransformedPoint(w,0);//(int)mesh[TR].x,(int)mesh[TR].y);
		float x3 = tmp.x;//mesh[TR].x;
		float y3 = tmp.y;//mesh[TR].y;
		
		// terms of the algorithm
	    float a  = cross2( x0-lmx, y0-lmy, x0-x2, y0-y2 );
	    float b1 = cross2( x0-lmx, y0-lmy, x1-x3, y1-y3 );
	    float b2 = cross2( x1-lmx, y1-lmy, x0-x2, y0-y2 );
	    float c  = cross2( x1-lmx, y1-lmy, x1-x3, y1-y3 );
	    float b  = 0.5f * (b1 + b2);

	    // what we are looking for. (s,t) coordinates for the input point (lmx, lmy)
	    float s, t;

	    float am2bpc = a-2*b+c;
	    if (am2bpc == 0) {
	    	// this is the simple case, where the quad is linear (ie: not warped)
	    	s = a / (a-c);
	    }
	    else {
	    	// this is the complicated case, where the quad is warped
	    	float sqrtbsqmac = PApplet.sqrt( b*b - a*c );
	        s   = ((a-b) + sqrtbsqmac) / am2bpc;
	    }
	    
	    // now that we know s, calculate t
	    float tdenom_x = (1-s)*(x0-x2) + s*(x1-x3);
        float tdenom_y = (1-s)*(y0-y2) + s*(y1-y3);
        // choose the more robust denominator
        if ( PApplet.abs( tdenom_x ) > PApplet.abs( tdenom_y ) ) {
        	t = 1 - ( (1-s)*(x0-lmx) + s*(x1-lmx) ) / ( tdenom_x );
        }
        else {
            t = 1 - ( (1-s)*(y0-lmy) + s*(y1-lmy) ) / ( tdenom_y );
        }

		return new PVector((int)(s*w), (int)(t*h));

        }
        
        public PVector getTransformedPoint(int xx, int yy){
		
		// inverse billinear interpolation to figure out the relationship between 
		// the mouse in screen coordinates and the (s,t) position within a warped surface
		
		// modified version of the algorithm found here:
		// http://stackoverflow.com/questions/808441/inverse-bilinear-interpolation
		
		// local mouse x and y -- remove translation offset
		int lmx = xx - (int)x;
		int lmy = yy - (int)y;
		
		// these will make the following equations more clear
		float x0 = mesh[BL].x;
		float y0 = mesh[BL].y;
		
		float x1 = mesh[BR].x;
		float y1 = mesh[BR].y;
		
		float x2 = mesh[TL].x;
		float y2 = mesh[TL].y;
		
		float x3 = mesh[TR].x;
		float y3 = mesh[TR].y;
		
		// terms of the algorithm
	    float a  = cross2( x0-lmx, y0-lmy, x0-x2, y0-y2 );
	    float b1 = cross2( x0-lmx, y0-lmy, x1-x3, y1-y3 );
	    float b2 = cross2( x1-lmx, y1-lmy, x0-x2, y0-y2 );
	    float c  = cross2( x1-lmx, y1-lmy, x1-x3, y1-y3 );
	    float b  = 0.5f * (b1 + b2);

	    // what we are looking for. (s,t) coordinates for the input point (lmx, lmy)
	    float s, t;

	    float am2bpc = a-2*b+c;
	    if (am2bpc == 0) {
	    	// this is the simple case, where the quad is linear (ie: not warped)
	    	s = a / (a-c);
	    }
	    else {
	    	// this is the complicated case, where the quad is warped
	    	float sqrtbsqmac = PApplet.sqrt( b*b - a*c );
	        s   = ((a-b) + sqrtbsqmac) / am2bpc;
	    }
	    
	    // now that we know s, calculate t
	    float tdenom_x = (1-s)*(x0-x2) + s*(x1-x3);
        float tdenom_y = (1-s)*(y0-y2) + s*(y1-y3);
        // choose the more robust denominator
        if ( PApplet.abs( tdenom_x ) > PApplet.abs( tdenom_y ) ) {
        	t = 1 - ( (1-s)*(x0-lmx) + s*(x1-lmx) ) / ( tdenom_x );
        }
        else {
            t = 1 - ( (1-s)*(y0-lmy) + s*(y1-lmy) ) / ( tdenom_y );
        }

		return new PVector((int)(s*w), (int)(t*h));

        }
        
	/**
	 * This function will give you the position of the mouse in the surface's coordinate system. 
	 * 
	 * @return The transformed mouse position
	 */
	public PVector getTransformedMouse() {
		
		// this was more of a pain than I tought!
		// basically, we have to do an inverse billinear interpolation to figure out the relationship between 
		// the mouse in screen coordinates and the (s,t) position within a warped surface
		
		// modified version of the algorithm found here:
		// http://stackoverflow.com/questions/808441/inverse-bilinear-interpolation
		
		// local mouse x and y -- remove translation offset
		int lmx = parent.mouseX - (int)x;
		int lmy = parent.mouseY - (int)y;
		
		// these will make the following equations more clear
		float x0 = mesh[BL].x;
		float y0 = mesh[BL].y;
		
		float x1 = mesh[BR].x;
		float y1 = mesh[BR].y;
		
		float x2 = mesh[TL].x;
		float y2 = mesh[TL].y;
		
		float x3 = mesh[TR].x;
		float y3 = mesh[TR].y;
		
		// terms of the algorithm
	    float a  = cross2( x0-lmx, y0-lmy, x0-x2, y0-y2 );
	    float b1 = cross2( x0-lmx, y0-lmy, x1-x3, y1-y3 );
	    float b2 = cross2( x1-lmx, y1-lmy, x0-x2, y0-y2 );
	    float c  = cross2( x1-lmx, y1-lmy, x1-x3, y1-y3 );
	    float b  = 0.5f * (b1 + b2);

	    // what we are looking for. (s,t) coordinates for the input point (lmx, lmy)
	    float s, t;

	    float am2bpc = a-2*b+c;
	    if (am2bpc == 0) {
	    	// this is the simple case, where the quad is linear (ie: not warped)
	    	s = a / (a-c);
	    }
	    else {
	    	// this is the complicated case, where the quad is warped
	    	float sqrtbsqmac = PApplet.sqrt( b*b - a*c );
	        s   = ((a-b) + sqrtbsqmac) / am2bpc;
	    }
	    
	    // now that we know s, calculate t
	    float tdenom_x = (1-s)*(x0-x2) + s*(x1-x3);
        float tdenom_y = (1-s)*(y0-y2) + s*(y1-y3);
        // choose the more robust denominator
        if ( PApplet.abs( tdenom_x ) > PApplet.abs( tdenom_y ) ) {
        	t = 1 - ( (1-s)*(x0-lmx) + s*(x1-lmx) ) / ( tdenom_x );
        }
        else {
            t = 1 - ( (1-s)*(y0-lmy) + s*(y1-lmy) ) / ( tdenom_y );
        }

		return new PVector((int)(s*w), (int)(t*h));
	}

    // 2d cross product
	private float cross2( float x0, float y0, float x1, float y1 ) {
		return x0*y1 - y0*x1;
	}
	
	/**
	 * Draws targets around the control points
	 */
      /*
	private void renderControlPoints(PGraphics g) {
		g.stroke(controlPointColor);
		g.noFill();
		for (int i=0; i < mesh.length; i++)  {
			if (mesh[i].isControlPoint()) {
				g.ellipse(mesh[i].x, mesh[i].y, 30, 30);
				g.ellipse(mesh[i].x, mesh[i].y, 10, 10);
			}
		} 	
	}
	*/
	public void renderControlPoints(PGraphics g) {


		for (int i=0; i < mesh.length; i++)  {
			if (mesh[i].isControlPoint()) {
                        
                          if( i == TL ) {
                            g.fill( 255,0,0,80 );
                            g.stroke( 255,0,0 );
                          }else if( i == TR ) {
                            g.fill( 0,255,0,80 );
                            g.stroke( 0,255,0 );
                          }else if( i == BL ) {
                            g.fill( 0,0,255,80 );
                            g.stroke( 0,0,255 );
                          }else if( i == BR ) {
                            g.fill( 255,255,0,80 );
                            g.stroke( 255,255,0 );
                          }  
                          else {
                           g.fill( 255 );
                            g.stroke( 255 );
                          }
                          
				g.ellipse(mesh[i].x, mesh[i].y, 30, 30);
				g.ellipse(mesh[i].x, mesh[i].y, 10, 10);

                          
                       }
		} 	
	}




	/**
	 * Sets the grid used for calibration's color
	 */
	public void setGridColor( int newColor ) {
		gridColor = newColor;
	}
	
	/**
	 * Sets the control points color
	 */
	public void setControlPointsColor( int newColor ) { 
		controlPointColor = newColor;
	}
	
	/**
	 * @invisible
	 */
	Draggable select(float x, float y) { 
		// first, see if one of the control points are selected
  // println(x+","+y+" == "+mouseX+","+mouseY+"   "+scene.xCoord(mouseX)+","+scene.yCoord(mouseY));
		x -= this.x;
		y -= this.y;
		for (int i=0; i < mesh.length; i++) {
			if (PApplet.dist(mesh[i].x, mesh[i].y, x, y) < 30 && mesh[i].isControlPoint()) return mesh[i];
                      //  if (PApplet.dist(mesh[i].x, mesh[i].y, x, y) < 3 ); return mesh[i]; //&& mesh[i].isControlPoint()) return mesh[i];
		}
	 
		// then, see if the surface itself is selected
		if (isMouseOver()) {
			clickX = x;
			clickY = y; 
			return this;
		}
		return null;
	}
	
	/**
	 * Returns true if the mouse is over this surface, false otherwise. 
	 */
	public boolean isMouseOver() {
		if (isPointInTriangle(scene.xCoord(mouseX)-x, scene.yCoord(mouseY)-y, mesh[TL], mesh[TR], mesh[BL]) || 
			isPointInTriangle(scene.xCoord(mouseX)-x, scene.yCoord(mouseY)-y, mesh[BL], mesh[TR], mesh[BR])) return true;
		return false;
	}
	
	/**
	 * Used for mouse selection of surfaces
	 */
	private boolean isPointInTriangle(float x, float y, MeshPoint a, MeshPoint b, MeshPoint c) {
		// http://www.blackpawn.com/texts/pointinpoly/default.html
		PVector v0 = new PVector(c.x - a.x, c.y - a.y);
		PVector v1 = new PVector(b.x - a.x, b.y - a.y);
		PVector v2 = new PVector(  x - a.x,   y - a.y);
		 
		float dot00 = v0.dot(v0);
		float dot01 = v1.dot(v0);
		float dot02 = v2.dot(v0);
		float dot11 = v1.dot(v1);
		float dot12 = v2.dot(v1); 
		
		// Compute barycentric coordinates
		float invDenom = 1 / (dot00 * dot11 - dot01 * dot01);
		float u = (dot11 * dot02 - dot01 * dot12) * invDenom;
		float v = (dot00 * dot12 - dot01 * dot02) * invDenom;

		// Check if point is in triangle
		return (u > 0) && (v > 0) && (u + v < 1);		
	}
	
	/**
	 *  Interpolates the position of the points in the mesh according to the 4 corners
	 *  TODO: allow for abritrary control points, not just the four corners
	 */
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
	
	/**
	 * @invisible
	 * 
	 * This moves the surface according to the offset from where the mouse was pressed when 
	 * selecting the surface.
	 */
	public void moveTo(float x, float y) {
		this.x = x - clickX;
		this.y = y - clickY;
	}
	
	/**
	 * @invisible
	 * 
	 * Populates values from an XML object 
	 */
/*
	void load(XMLElement xml) {
		this.x = xml.getFloatAttribute("x");
		this.y = xml.getFloatAttribute("y");
		// reload the mesh points
		for (int i=0; i < xml.getChildCount(); i++) {
			XMLElement point = xml.getChild(i);
			MeshPoint mp = mesh[point.getIntAttribute("i")];
			mp.x = point.getFloatAttribute("x");
			mp.y = point.getFloatAttribute("y");
			mp.u = point.getFloatAttribute("u");
			mp.v = point.getFloatAttribute("v");
			mp.setControlPoint(true);
		}
		calculateMesh();
	}
*/
}

