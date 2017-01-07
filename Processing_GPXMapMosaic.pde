
// - - - - - - - - - - - - - - - - - - - - - - - 
// GPX MAP MOSAIC V:1
// © NICHOLAS FELTON / FELTRON.COM
// - - - - - - - - - - - - - - - - - - - - - - - 

// TO DO:
// - Compute Route Distances
// - Total Route Distances per Box
// - Click to change colors

// DONE:
// - Create route objects
// - Create index of locations from pos[0] in route
// - Show progress in console
// - Build mosaic to fit locations
// - Add XML parsing to locationIndex();
// - Draw routes in correct mosaic location
// - Center Runs
// - Add framerate
// - Trim Lat/Lon to 2 decimals
// - If 1 run, depluralize
// - Lookup Cities

// - - - - - - - - - - - - - - - - - - - - - - - 
// VARIABLES
// - - - - - - - - - - - - - - - - - - - - - - - 

// Data
String[] filenames;
String[] locationList;
IntDict locations = new IntDict();
FloatDict locationMidLat = new FloatDict();
FloatDict locationMidLon = new FloatDict();
String[] locationIndexNames;
ArrayList<Box> BoxList;
ArrayList<Route> RouteList;
String[] locationKeys;
int[] locationAmounts;

// Draw
float locationGranularity = 0.15;
int boxMargin = 10;
int mosaicCount;
float boxSize;

// GeoCoding
XML geoXML;
int millisecondDelay = 500; // BE POLITE.


// - - - - - - - - - - - - - - - - - - - - - - - 
// SETUP
// - - - - - - - - - - - - - - - - - - - - - - - 
void setup() {
  size(1000, 1000);
  colorMode(HSB, 100);
  background(30);
  importData();
  buildLocationIndex();
  geocodeLocationIndex();
  buildBoxes();
  buildRoutes();
}


// - - - - - - - - - - - - - - - - - - - - - - - 
// DRAW
// - - - - - - - - - - - - - - - - - - - - - - - 
void draw() {
  surface.setTitle(int(frameRate) + " fps / " + frameCount + " frames");
  // Draw Mosaic
  for (int i=0; i<BoxList.size (); i++) {
    BoxList.get(i).display();
  }
  // Draw Routes
  for (int i=0; i<RouteList.size (); i++) {
    RouteList.get(i).display();
  }
  savePNG();
}