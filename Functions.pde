
// - - - - - - - - - - - - - - - - - - - - - - - 
// FUNCTIONS
// - - - - - - - - - - - - - - - - - - - - - - - 

void importData() { // import all files from directory
  java.io.File folder = new java.io.File(dataPath(""));
  String[] allFilenames = folder.list();
  println(allFilenames);
  // Remove .DS_Store
  if (allFilenames[0].equals(".DS_Store")) {
    println("removing");
    filenames = new String[allFilenames.length-1];
    for (int i=1; i<allFilenames.length; i++) { 
      filenames[i-1] = allFilenames[i];
    }
  } else {
    filenames = new String[allFilenames.length];
    for (int i=0; i<allFilenames.length; i++) { 
      filenames[i] = allFilenames[i];
    }
  }
  println(filenames);
  println("Imported " + filenames.length + " files…");
}

// - - - - - - - - - - - - - - - - - - - - - - - 

void buildLocationIndex() {
  locationList = new String[filenames.length];
  for (int i=0; i<filenames.length; i++) { // filenames.length
    float gridLat = 0;
    float gridLon = 0;
    XML xml = loadXML(filenames[i]);
    XML[] track = xml.getChildren("trk/trkseg/trkpt");
    float[] lat = new float[track.length];
    float[] lon = new float[track.length];
    for (int j = 0; j<track.length; j++) {
      String s = track[j].toString();
      String[] s2 = s.split("\"");
      lat[j] = float(s2[1]);
      lon[j] = float(s2[3]);
    }
    for (float j=-90; j<90; j+=locationGranularity) {
      if (lat[0]>j && lat[0]<j+locationGranularity) {
        gridLat = j+locationGranularity/2;
      }
    }
    for (float j=-180; j<180; j+=locationGranularity) {
      if (lon[0]>j && lon[0]<j+locationGranularity) {
        gridLon = j+locationGranularity/2;
      }
    }
    locations.add(gridLat + "," + gridLon, 1);  
    // Create index of Avg Lats
    if (locationMidLat.hasKey(gridLat+","+gridLon) == true) {
      float tempMidLat = locationMidLat.get(gridLat+","+gridLon);
      float avgLat = (min(lat)+max(lat))/2;
      locationMidLat.set(gridLat + "," + gridLon, (tempMidLat + avgLat)/2);
    } else {
      locationMidLat.set(gridLat + "," + gridLon, (min(lat)+max(lat))/2);
    }
    // Create index of Avg Lons
    if (locationMidLon.hasKey(gridLat+","+gridLon) == true) {
      float tempMidLon = locationMidLon.get(gridLat+","+gridLon);
      float avgLon = (min(lon)+max(lon))/2;
      locationMidLon.set(gridLat + "," + gridLon, (tempMidLon + avgLon)/2);
    } else {
      locationMidLon.set(gridLat + "," + gridLon, (min(lon)+max(lon))/2);
    }
    locationList[i] = gridLat + "," + gridLon; // name
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - 

void geocodeLocationIndex() {
  locationIndexNames = new String[locationMidLat.size()];
  float[] midlats = locationMidLat.valueArray();
  float[] midlons = locationMidLon.valueArray();

  for (int i=0; i<locationMidLat.size(); i++) {
    try {
      String request = "http://maps.googleapis.com/maps/api/geocode/xml?latlng=" + midlats[i] + "," + midlons[i] + "&sensor=false";
      geoXML = loadXML(request);
      parseGeoResponse(geoXML, i, midlats[i], midlons[i]);
    } 
    catch (Exception e) {
    }
    delay (millisecondDelay);
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - 

void parseGeoResponse(XML xml, int n, float l1, float l2) {
  String country = "";
  String adminLevel1 = "";
  String locality = "";
  //  println("- - - - - - - - - - - - - - - - - - - - - - - - - - - -");
  XML result = xml.getChild("result");
  //  println(result);
  //  println("- - - - - - - - - - - - - - - - - - - - - - - - - - - -");
  XML[] address_component = result.getChildren("address_component");
  //  println(address_component);
  //  println(address_component.length);
  for (int i=0; i<address_component.length; i++) {
    XML address_type = address_component[i].getChild("type");
    if (address_type!=null) {
      //      println(address_type);
      if (address_type.getContent().equals("country")) {
        XML country_1 = address_component[i].getChild("long_name");
        country = country_1.getContent();
        //        println(country);
      }
      if (address_type.getContent().equals("administrative_area_level_1")) {
        XML admin_level1 = address_component[i].getChild("long_name");
        adminLevel1 = admin_level1.getContent();
        //        println(adminLevel1);
      }
      if (address_type.getContent().equals("locality")) {
        XML locality_1 = address_component[i].getChild("long_name");
        locality = locality_1.getContent();
        //        println(locality);
      }
    }
  }
  println(l1 + ", " + l2 + ": " + country + " / " + adminLevel1 + " / " + locality);
  if (!locality.equals("")) {
    locationIndexNames[n] = locality;
  } else {
    locationIndexNames[n] = adminLevel1;
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - 

void buildBoxes() {
  mosaicCount = ceil(sqrt(locations.size()));
  boxSize = width/float(mosaicCount);
  println("Mosaic Size: " + mosaicCount);
  BoxList = new ArrayList<Box>();
  locationKeys = locations.keyArray();
  locationAmounts = locations.valueArray();
  for (int i=0; i<locations.size(); i++) {
    BoxList.add(new Box(i, locationKeys[i], locationAmounts[i]));
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - 

void buildRoutes() {
  RouteList = new ArrayList<Route>();
  for (int i=0; i<filenames.length; i++) { //filenames.length
    XML gpx_file = loadXML(filenames[i]);
    RouteList.add(new Route(gpx_file, i));
    println("Route " + i + ": " + filenames[i]);
  }
}

// - - - - - - - - - - - - - - - - - - - - - - - 

void savePNG() {
  if (frameCount==1) {
    saveFrame(hour() + " - " + minute() + " - " + second() + ".png");
  }
}