
CopyOnWriteArrayList<CornerPinSurface> surfaces;
int                   mw = 400;
int                   mh = 300;
int                   cw = 400;
int                   ch = 300;
int      alphaBackground = 255;
int      colorBackground = 0;
int        visualization = 1;
int         maxThreshold = 255;
int              surf_id = 1;
int    cam_surf_division = 5;
int        surf_division = 5;
int    img_surf_division = 5;
int    selectedQuad  = 0;
boolean dual_screen_mode =  false;

public class Keystone {

	public final String VERSION = "44";

	PApplet parent;

	Draggable dragged;

	public Keystone(PApplet parent) {
		this.parent = parent;
		this.parent.registerMouseEvent(this);

		surfaces = new CopyOnWriteArrayList<CornerPinSurface>();
		dragged = null;
		
		// check the renderer type
		// issue a warning if its PGraphics2D
		PGraphics pg = (PGraphics)parent.g;
		if ((pg instanceof PGraphics2D) ) {
			PApplet.println("will not work with PGraphics2D.  " +
					"Try P3D, OPENGL or GLGraphics.");
		}
	}

	public CornerPinSurface createCornerPinSurface(int w, int h, int res) {
		CornerPinSurface s = new CornerPinSurface(parent, w, h, res);
		surfaces.add(s);
		return s;
	}

	public DrawSurface createDrawSurface(int style, int w, int h, int res) {
		DrawSurface s = new DrawSurface(parent, style, w, h, res);
		surfaces.add(s);
		return s;
	}

	public void startCalibration() {
		calibrationMode = true;
	}

	public void stopCalibration() {
		calibrationMode = false;
	}

	public void toggleCalibration() {
		calibrationMode = !calibrationMode;
	}


	public String version() {
		return VERSION;
	}
	

	public void save(String filename) {

		proxml.XMLElement root = new proxml.XMLElement("keystone");
                String fmt = "";
		// create XML elements for each surface containing the resolution
		// and control point data
		for (CornerPinSurface s : surfaces) {

                        DrawSurface ds = (DrawSurface)s;
			proxml.XMLElement xml = new proxml.XMLElement("surface"); 
                        xml.addAttribute("type", "DrawSurface");
                        xml.addAttribute("res",s.getRes());
                        xml.addAttribute("x",s.x);
                        xml.addAttribute("y",s.y);
                        xml.addAttribute("style",ds.style);
			
			for (int i=0; i < s.mesh.length; i++) {
				if (s.mesh[i].isControlPoint()) {

                                        proxml.XMLElement xml2 = new proxml.XMLElement("point"); 
                                        xml2.addAttribute("i", i);
                                        xml2.addAttribute("x",s.mesh[i].x);
                                        xml2.addAttribute("y",s.mesh[i].y);
                                        xml2.addAttribute("u",s.mesh[i].u);
                                        xml2.addAttribute("v",s.mesh[i].v);
					xml.addChild(xml2);
				}
			}
			
			root.addChild(xml);

		}

		// write the settings to keystone.xml in the sketch's data folder
		try {
			//OutputStream stream = parent.createOutput(parent.dataPath(filename));
			//XMLWriter writer = new XMLWriter(stream);
			//writer.write(root, true);
                        XMLInOut xmlInOut =  new XMLInOut(parent);
                        
                        // and call saveElement.
                        xmlInOut.saveElement(root, filename);
		} catch (Exception e) {
			PApplet.println(e.getStackTrace());
		}
		
		PApplet.println("Keystone: layout saved to " + filename);
	}
	

	public void save() {
		save("scoreboard.xml");
	}

	public void load(proxml.XMLElement root){
  

		//proxml.XMLElement root = new proxml.XMLElement(parent, parent.dataPath(filename));
		for (int i=0; i < root.countChildren(); i++) {

  			//surfaces.get(i).load(root.getChild(i));
		 String type = root.getChild(i).getAttribute("type");

                  if( type.equals("DrawSurface") ){
                    
                   // DrawSurface ds = ks.createDrawSurface(root.getChild(i).getIntAttribute("style"),mw,mh, surf_division);  
                      surface = ks.createDrawSurface(1, mw,mh, surf_division);
          		surface.x = root.getChild(i).getFloatAttribute("x");
          		surface.y = root.getChild(i).getFloatAttribute("y");
                        surface.style = root.getChild(i).getIntAttribute("style");
                        
                       //ds.moveTo(ds.x,ds.y);
          		// reload the mesh points
          		for (int j=0; j < root.getChild(i).countChildren(); j++) {
          			proxml.XMLElement point = root.getChild(i).getChild(j);
          			MeshPoint mp = surface.mesh[point.getIntAttribute("i")];
          			mp.x = point.getFloatAttribute("x");
          			mp.y = point.getFloatAttribute("y");
          			mp.u = point.getFloatAttribute("u");
          			mp.v = point.getFloatAttribute("v");
          			mp.setControlPoint(true);
          		}
          		surface.calculateMesh();
                  }

		}

	}

	/**
	 * Loads a saved layout from "keystone.xml"
	 */
	public void load() {
          XMLInOut xmlInOut =  new XMLInOut(parent);
          xmlInOut.loadElement("scoreboard.xml");      
	}
	

	/**
	 * @invisible
	 */
	public void mouseEvent(MouseEvent e) {
		

		// ignore input events if the calibrationMode flag is not set
		if (!calibrationMode)
			return;

		int x = (int)scene.xCoord(e.getX());
		int y = (int)scene.yCoord(e.getY());

                //if( e.getButton() == MouseEvent.BUTTON2)
                //  return;
             
		switch (e.getID()) {

		case MouseEvent.MOUSE_PRESSED:
                        
			CornerPinSurface top = null;
			// navigate the list backwards, as to select 
			for (int i=surfaces.size()-1; i >= 0; i--) {
				CornerPinSurface s = (CornerPinSurface)surfaces.get(i);
				dragged = s.select(x, y);
				if (dragged != null) {
                                //println("dragged");
					top = s;
					break;
				}
			}

			if (top != null) {
				// moved the dragged surface to the beginning of the list
				// this actually breaks the load/save order.
				// in the new version, add IDs to surfaces so we can just 
				// re-load in the right order (or create a separate list 
				// for selection/rendering)
				//int i = surfaces.indexOf(top);
				//surfaces.remove(i);
				//surfaces.add(0, top);
			}
			break;

		case MouseEvent.MOUSE_DRAGGED:
			if (dragged != null)
				dragged.moveTo(x, y);
			break;

		case MouseEvent.MOUSE_RELEASED:
			dragged = null;
			break;
		}
	}

}

