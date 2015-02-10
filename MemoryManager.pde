
static class MemoryManager{
 
  //megabytes
 static float CurrentMemoryUsage(){
   return (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory())/1048576f;
   
 }

  static void GC(){
     System.gc(); 
  }  
}
