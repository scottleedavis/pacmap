class GLCamera extends Camera {
  protected PGraphicsOpenGL pgl;
  protected GL gl;
  protected GLU glu;
    
  public GLCamera(Scene scn) {
    super(scn);
    pgl = (PGraphicsOpenGL)pg3d;
    gl = pgl.gl;
    glu = pgl.glu;
  }
    
  protected WorldPoint pointUnderPixel(Point pixel) {
    float []depth = new float[1];
    pgl.beginGL();
    gl.glReadPixels((int)pixel.x, (screenHeight() - (int)pixel.y), 1, 1, GL.GL_DEPTH_COMPONENT, GL.GL_FLOAT, FloatBuffer.wrap(depth));
    pgl.endGL();
    PVector point = new PVector((int)pixel.x, (int)pixel.y, depth[0]);
    point = unprojectedCoordinatesOf(point);
    return new WorldPoint(point, (depth[0] < 1.0f));
  }
}

