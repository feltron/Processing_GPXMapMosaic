
// - - - - - - - - - - - - - - - - - - - - - - - 
// BOX
// - - - - - - - - - - - - - - - - - - - - - - - 

class Box {
  color c = color(random(70, 100), random(80, 100), random(70, 90));
  int index, count;
  String latlon;
  float posX, posY;

  Box(int index_, String latlon_, int count_) {
    index = index_;
    latlon = latlon_;
    count = count_;
  }

  void display() {
    noStroke();
    fill(c);
    posX = index%mosaicCount*boxSize;
    posY = index/mosaicCount*boxSize;
    rect(posX, posY, boxSize, boxSize);
    //println("Box: " + index + " / " + index%mosaicCount + " / " + index/mosaicCount);
    fill(100);
    textAlign(LEFT);
    //float[] latlonTrim = float(latlon.split(","));
    //String boxLocation = int(latlonTrim[0]*100)/100.0 + ", " + int(latlonTrim[1]*100)/100.0;
    text(locationIndexNames[index], posX+boxMargin, posY+boxSize-boxMargin);
    textAlign(RIGHT);
    if (count == 1) {
      text(count + " Run", posX+boxSize-boxMargin, posY+boxSize-boxMargin);
    } else {
      text(count + " Runs", posX+boxSize-boxMargin, posY+boxSize-boxMargin);
    }
  }
}