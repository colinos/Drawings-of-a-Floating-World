void setup2(){
  noStroke();

  for (int i = 0; i < maxNumIdsToRecognize; i++) {
    touchX[i] = -1000;
    touchY[i] = -1000;
  }
}

void draw2(TuioCursor[] tuioCursorList){
  //background(0);
  fill(0,0,0,2);
  rect(0, 0, width, height);

  for (int k = 0; k < maxNumIdsToRecognize; k++) {

    ///////////////////////////////////
    // Enter behaviour/interaction here.
    //
    // touchX[k] and touchY[k] are the x, y coordinates of each TUIO ID
    //  including previous TUIO IDs that have since disappeared and have not been overwritten by newer IDs
    //  If these are undesired, use an if statement to check the current index accesses a currently valid TUIO ID:
    //   if (k < tuioCursorList.length)
    //
    // The 'for' loop in which this comment is located cycles through all TUIO IDs
    // If only specific IDs (e.g. first or second IDs) are required, there is no need for the 'for' loop
    // Remove 'for' loop and just use touchX[0] and touchY[0], etc
    //
    // previousX[k] and previousY[k] refer to the x, y coordinates of each TUIO ID from the previous frame
    //
    // Things to note:
    // touchX[k], touchY[k], previousX[k], previousY[k] are all floats
    // touchX[k] and touchY[k] initialize to 0, even if the TUIO ID hasn't existed yet
    ///////////////////////////////////

    if (k % 2 == 0) {
      inkLeaf_angle += 1;
      float val = cos(radians(inkLeaf_angle)) * random(10.0,30.0);
      for (int a = 0; a < 360; a += 15) {
        float xoff = cos(radians(a)) * val;
        float yoff = sin(radians(a)) * val;
        fill(grass,random(2,40));
        ellipse(touchX[k] + xoff, touchY[k] + yoff, val/2, val/2);
      }

      inkLeaf_angle2 += 180;
      float val2 = cos(radians(inkLeaf_angle)) * random(10.0,30.0);
      for (int a2 = 0; a2 < 360; a2 += 15) {
        float xoff2 = cos(radians(a2)) * val2;
        float yoff2 = sin(radians(a2)) * val2;
        fill(tourq,random(2,40));
        ellipse(touchX[k]+ xoff2, touchY[k] + yoff2, val2/2, val2/2);
      }

      inkLeaf_angle += 1;
      float val3 = cos(radians(inkLeaf_angle)) *random(10.0,30.0);
      for (int a = 0; a < -360; a += -15) {
        float xoff = cos(radians(a)) * val;
        float yoff = sin(radians(a)) * val;
        fill(jade,random(2,40));
        ellipse(touchX[k]-2 + xoff, touchY[k]+2 + yoff, val/2, val/2);
      }

      inkLeaf_angle2 += 180;
      float val4 = cos(radians(inkLeaf_angle)) * random(10.0,30.0);
      for (int a2 = 0; a2 < -360; a2 -= 15) {
        float xoff2 = cos(radians(a2)) * val2;
        float yoff2 = sin(radians(a2)) * val2;
        fill(sky,random(2,40));
        ellipse(touchX[k]+2 + xoff2, touchY[k]-2 + yoff2, val2/2, val2/2);
      }
    } 
    else {
      stroke(grass);
      strokeWeight(2);
      line(touchX[k], touchY[k], previousX[k] , previousY[k]);
      strokeWeight(1);
      noStroke();
      //if (touchX[k] > touchX[k-1]+100 ){

      if (getDistance(touchX[k-1], touchY[k-1], touchX[k], touchY[k]) > 100){

        fill(grass,80);
        if((touchX[k] != previousX[k] )||(touchY[k] != previousY[k])){
          leaf((int)touchX[k], (int)touchY[k]);
        }
      } 
      else {
        fill(orange);
        if((touchX[k] != previousX[k] )||(touchY[k] != previousY[k])){
          leaf((int)touchX[k], (int)touchY[k]);
        }
      }
    }
  }
}


void leaf(int x, int y)
{ 
  translate(x,y);
  scale(random(0.5,1));
  rotate(radians(random(360)));
  beginShape();
  vertex( 0, 0 );
  bezierVertex (-3.00, 7.00, 9.80, 25.90, 38.70, 36.70);
  bezierVertex (23.70, 6.40, 7.50, -2.50, 0.0, 0.0);
  endShape();
}
