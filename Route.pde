

// - - - - - - - - - - - - - - - - - - - - - - - 
// ROUTE
// - - - - - - - - - - - - - - - - - - - - - - - 

class Route {
  float[] lat, lon, elevation, posX, posY;
  String[] time;
  int routeNumber;
  int mosaicIndex;
  float xOrigin, yOrigin, latCenter, lonCenter;

  Route(XML source, int routeNumber_) {
    routeNumber = routeNumber_;
    parseXML(source);
    mapPoints();
  }

  void display() {
    noStroke();
    fill(100, 10);
    for (int i=0; i<posX.length; i++) {
      ellipse(posX[i], posY[i], 1, 1);
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - 

  void parseXML(XML xml) {
    XML[] track = xml.getChildren("trk/trkseg/trkpt");
    lat = new float[track.length];
    lon = new float[track.length];
    elevation = new float[track.length];
    time = new String[track.length];
    for (int i = 0; i<track.length; i++) {
      String s = track[i].toString();
      String[] s2 = s.split("\"");
      lat[i] = float(s2[1]);
      lon[i] = float(s2[3]);
      String[] s3 = s2[4].split("<");
      String[] s4 = s3[1].split(">");
      elevation[i] = float(s4[1]);
      //println(i + " / " + track.length);
      //println("lat: " + lat[i] + " / lon: " + lon[i] + " / elevation: " + elevation[i]);
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - -

  void mapPoints() {
    // Find Mosaic Index
    for (int i=0; i<locationKeys.length; i++) {
      if (locationList[routeNumber].equals(locationKeys[i])) {
        mosaicIndex = i;
      }
    }
    xOrigin = mosaicIndex%mosaicCount*boxSize;
    yOrigin = mosaicIndex/mosaicCount*boxSize;
    // Calculate Route Positions
    posX = new float[lat.length];
    posY = new float[lat.length];
    // Calculate offset from box center to runs center
    latCenter = locationMidLat.get(locationList[routeNumber]) ; // float(latlon[0])
    lonCenter = locationMidLon.get(locationList[routeNumber]) ; // float(latlon[1])
    for (int i=0; i<lat.length; i++) {
      posX[i] = map(lon[i], lonCenter-locationGranularity/2, lonCenter+locationGranularity/2, xOrigin, xOrigin+boxSize);
      posY[i] = map(lat[i], latCenter+locationGranularity/2, latCenter-locationGranularity/2, yOrigin, yOrigin+boxSize);
    }
  }
}