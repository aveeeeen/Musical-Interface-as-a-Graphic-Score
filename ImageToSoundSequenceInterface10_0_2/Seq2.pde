public class Seq2 {
  int id;
  String deviceName;
  int midiIndex;

  float x, y;
  int seqRow;
  int seqCol;
  int current;
  int seqTimeState = 2;
  float offset;

  SeqImg seqimg;
  SeqData seqdata;
  MappingData mapdata;
  PVector pos;
  Behaviour behaviour;
  States state;

  SeqDraw draw;
  MidiMap midimap;

  public Seq2(int seqStart, String deviceName, int id, float x, float y) {
    this.deviceName = deviceName;
    this.id = id;
    this.x = x;
    this.y = y;
    seqRow = 32;
    seqCol = 32;
    // default seqLength is 16
    // this can be changable after user input
    seqdata = new SeqData(seqStart, 16);
    current = 0;
    behaviour = new Behaviour(false, true, 1);
    state = new States();
    pos = new PVector(0, 0);
    this.draw = new SeqDraw(this.seqdata, this.seqimg, this.state, this.behaviour, this.pos, this.x, this.y);

    //int[] mScale = new int[]{0, 2, 4, 7, 9, 11, 12};
    int[] mScale = Scale.MINOR_PENTATONIC;
    //Scale.MAJOR_PENTATONIC;
    mapdata = new MappingData(mScale, 12, 5, "E");
    this.midimap = new MidiMap(this.deviceName, this.id, this.seqdata, this.behaviour, this.state, mapdata);
  };

  public void render() {
    float pixSize = imgSource.pixSize;
    float canvasWidth = imgSource.canvasWidth;
    if (state.isAlive) {
      draw.render(pixSize, getOffset(), getMatrixWidth(), current);
    }
  }

  public void tickAction() {
    color[][] img = tempC;
    toNext();
    updateData(img);
    sendMidi();
  }

  public void updateMidi(String source) {
    this.deviceName = source;
    midimap.updateMidiSource(source);
  }

  public void updateData(color[][] img) {
    this.seqdata = seqdata.correctToOffset(getOffset(), imgSource.col);
    updateSeqColor(img);
    updatePos();
    this.draw = new SeqDraw(this.seqdata, this.seqimg, this.state, this.behaviour, this.pos, this.x, this.y);
  }

  public void sendMidi() {
    if (state.isAlive) {
      if(!state.isMute)midimap.sendMidi(seqimg);
    } else {
      midimap.pause();
    }
  }

  public float getOffset() {
    return imgSource.row/seqRow;
  };

  public int getMatrixWidth() {
    return seqRow;
  }

  public void updatePos() {
    pos = getPos();
  }

  //this requires a reference from mother image, pixSize, offset

  private PVector getPos() {
    int col = imgSource.col;
    int[] p = Utils.get2dPos(seqdata.seqStart, col);
    return new PVector(p[1]*imgSource.pixSize, p[0]*imgSource.pixSize);
  };

  public int getCurrent2d() {
    int[] p = Utils.get2dPos(current, seqdata.colLength);
    return p[0] + p[1] * seqdata.colLength;
  };

  public void updateSeqColor(color[][] ref) {
    color[] tempColor = extractColor(ref);
    seqimg = new SeqImg(tempColor, tempColor[current]);
  };

  private color[] extractColor(color[][] tempC) {
    color[] c;
    if (!behaviour.isMatrix) {
      c = Utils.extractImgData1d(Utils.arr2dToArr1d(tempC), seqdata, getOffset());
    } else {
      c = Utils.extractImgData2d(Utils.arr2dToArr1d(tempC), seqdata, getOffset());
    };
    return c;
  };

  public int getSeqTime() {
    return round(getOffset());
  };

  public void toNext() {
    if (state.isAlive) current++;
    //when looping
    if (!behaviour.isMoving && current > seqdata.seqLength-1) current = 0;
    //when it moves to next array
    if (behaviour.isMoving && current > seqdata.seqLength-1) {
      int arrLength = imgSource.col*imgSource.row;
      int shiftIndex = 0;
      int currentRow = floor(arrLength/seqdata.seqStart);
      int rowShiftOffset = 1;
      //when linear grid
      if (!behaviour.isMatrix) shiftIndex = floor(seqdata.seqLength*getOffset());
      //when matrix grid
      if (behaviour.isMatrix){
        shiftIndex = floor(seqdata.colLength*getOffset());
        rowShiftOffset = seqdata.colLength;
      }
      int nextIndexRow = floor(arrLength/(shiftIndex + seqdata.seqStart));
      if (currentRow > nextIndexRow) shiftIndex += floor(imgSource.col * rowShiftOffset * getOffset());
      seqdata = seqdata.shift(shiftIndex);
      current = 0;
    }
  }
};

//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------


public class SeqDraw {
  SeqData seqdata;
  SeqImg seqimg;
  States state;
  Behaviour behaviour;
  PVector pos;
  float canvasX;
  float canvasY;

  public SeqDraw(SeqData seqdata, SeqImg seqimg, States state, Behaviour behaviour, PVector pos, float x, float y) {
    this.seqdata = seqdata;
    this.seqimg = seqimg;
    this.state = state;
    this.behaviour = behaviour;
    this.pos = pos;
    this.canvasX = x;
    this.canvasY = y;
  };

  public SeqDraw update(SeqData seqdata, SeqImg seqimg, States state, Behaviour behaviour, PVector pos, float x, float y) {
    return new SeqDraw(seqdata, seqimg, state, behaviour, pos, x, y);
  };

  public void render(float pixSize, float offset, int seqWidth, int current) {
    drawSeq(pixSize, offset, seqWidth);
    drawCurrent(pixSize, offset, seqWidth, current);
    drawFrame(pixSize, offset, seqWidth);
  }

  public void drawArc(float arcX, float arcY, float w, float subDiv, color c) {
    //arc(a, b, c, d, start, stop)
    for (int i = 0; i < subDiv; i++) {
      float arcStart = TWO_PI*i/subDiv + TWO_PI*1/(subDiv*4);
      float arcEnd = TWO_PI*(i+1)/subDiv - TWO_PI*1/(subDiv*4);
      noFill();
      strokeWeight(2);
      stroke(c);
      arc(arcX, arcY, w, w, arcStart, arcEnd);
    }
  }

  public void drawFrame(float pixSize, float offset, int matrixWidth) {
    int col = imgSource.col;
    PVector[] points = new PVector[2];
    points[0] = new PVector(0, 0);
    points[1] = new PVector(0, 0);
    if (!behaviour.isMatrix) {
      //when the seqimg should be represented in a linear grid
      for (int i = 0; i < seqdata.seqLength; i++) {
        int[] matrixIndex = Utils.get2dPos(floor(seqdata.seqStart/offset), floor(col));
        int iIndex = floor(matrixIndex[0]);
        int jIndex = floor((matrixIndex[1] + i));
        while (jIndex > matrixWidth - 1) {
          iIndex += 1;
          jIndex -= matrixWidth;
        }
        while (iIndex > matrixWidth - 1) iIndex -= matrixWidth;
        if (i == 0) points[0] = new PVector(jIndex, iIndex);
        if (i == seqdata.seqLength - 1) points[1] = new PVector(jIndex, iIndex);
      }
    }
    if (behaviour.isMatrix) {
      for (int i = 0; i < seqdata.colLength; i++) {
        for (int j = 0; j < seqdata.colLength; j++) {
          int[] matrixIndex = Utils.get2dPos(floor(seqdata.seqStart/offset), floor(col));
          int iIndex = floor((matrixIndex[0] + i));
          int jIndex = floor((matrixIndex[1] + j));
          while (jIndex > matrixWidth - 1) {
            iIndex += 1;
            jIndex -= matrixWidth;
          }
          while (iIndex > matrixWidth - 1) iIndex -= matrixWidth;
          if (i == 0 && j == 0) points[0] = new PVector(jIndex, iIndex);
          if (i == seqdata.colLength - 1 && j == seqdata.colLength - 1) points[1] = new PVector(jIndex, iIndex);
        }
      }
    }
    PVector dir = new PVector(1, 1);
    dir.mult(1.25);
    PVector dirSelected = new PVector(1, 1);
    dirSelected.mult(1.5);
    float m = 40;
    float m2 = 80;
    PVector[] edges = new PVector[4];
    PVector[] selectedEdges = new PVector[4];
    float w = 0;
    float h = 0;
    if (behaviour.isMatrix) {
      w = seqdata.colLength - 1;
      h = seqdata.colLength - 1;
    }

    edges[0] = new PVector(points[0].x - dir.x, points[0].y - dir.y);
    edges[1] = new PVector(points[1].x + dir.x, points[1].y - h - dir.y);
    edges[2] = new PVector(points[1].x + dir.x, points[1].y + dir.y);
    edges[3] = new PVector(points[0].x - dir.x, points[0].y + h + dir.y);

    selectedEdges[0] = new PVector(points[0].x - dirSelected.x, points[0].y - dirSelected.y);
    selectedEdges[1] = new PVector(points[1].x + dirSelected.x, points[1].y - h - dirSelected.y);
    selectedEdges[2] = new PVector(points[1].x + dirSelected.x, points[1].y + dirSelected.y);
    selectedEdges[3] = new PVector(points[0].x - dirSelected.x, points[0].y + h + dirSelected.y);

    float collideOffset = pixSize*offset*2;

    for (int i = 0; i < 4; i++) {
      float xTrans = collide(edges[i].x*pixSize*offset, 0, imgSource.canvasWidth, collideOffset);
      float yTrans = collide(edges[i].y*pixSize*offset, 0, imgSource.canvasHeight, collideOffset);
      stroke(0, 0, 50);
      strokeWeight(2);
      pushMatrix();
      translate(xTrans+this.canvasX, yTrans+this.canvasY);
      rotate(TWO_PI*i/4);

      beginShape(LINES);
      vertex(0, m);
      vertex(0, 0);
      vertex(0, 0);
      vertex(m, 0);
      endShape();
      popMatrix();
    }

    if (state.selected) {
      for (int i = 0; i < 4; i++) {
        float xTrans = collide(selectedEdges[i].x*pixSize*offset, 0, imgSource.canvasWidth, collideOffset);
        float yTrans = collide(selectedEdges[i].y*pixSize*offset, 0, imgSource.canvasHeight, collideOffset);
        stroke(0, 100, 100);
        strokeWeight(2);
        pushMatrix();
        translate(xTrans+this.canvasX, yTrans+this.canvasY);
        rotate(TWO_PI*i/4);
        beginShape(LINES);
        vertex(0, m2);
        vertex(0, 0);
        vertex(0, 0);
        vertex(m2, 0);
        endShape();
        popMatrix();
      }
    }
  }

  public void drawSeq(float pixSize, float offset, int matrixWidth) {
    int col = imgSource.col;
    if(!behaviour.isMatrix){
      //when the seqimg should be represented in a linear grid
      for (int i = 0; i < seqdata.seqLength; i++) {
        int[] matrixIndex = Utils.get2dPos(floor(seqdata.seqStart/offset), floor(col));
        int iIndex = floor(matrixIndex[0]);
        int jIndex = floor((matrixIndex[1] + i));
        while (jIndex > matrixWidth - 1) {
          iIndex += 1;
          jIndex -= matrixWidth;
        }
        while (iIndex > matrixWidth - 1) iIndex -= matrixWidth;
        strokeWeight(1);
        noStroke();
        if (state.selected) {
          strokeWeight(4);
          stroke(255, 0, 0);
        };
        drawArc(jIndex*pixSize*offset+this.canvasX, iIndex*pixSize*offset+this.canvasY, pixSize*(offset*0.3), 4, inverseColor(seqimg.seqRGB[i]));
      }
    }
    if(behaviour.isMatrix){
      //when the seqimg should be represented in a matrix like grid
      for (int i = 0; i < seqdata.colLength; i++) {
        for (int j = 0; j < seqdata.colLength; j++) {
          int[] matrixIndex = Utils.get2dPos(floor(seqdata.seqStart/offset), floor(col));
          int iIndex = floor((matrixIndex[0] + i));
          int jIndex = floor((matrixIndex[1] + j));
          while (jIndex > matrixWidth - 1) {
            iIndex += 1;
            jIndex -= matrixWidth;
          }
          while (iIndex > matrixWidth - 1) iIndex -= matrixWidth;
          strokeWeight(1);
          noStroke();
          if (state.selected) {
            strokeWeight(4);
            stroke(255, 0, 0);
          };
          drawArc(jIndex*pixSize*offset+this.canvasX, iIndex*pixSize*offset+this.canvasY, pixSize*(offset*0.3), 4, inverseColor(seqimg.seqRGB[j + i * seqdata.colLength]));
        }
      }
    };
  };

  public void drawCurrent(float pixSize, float offset, float matrixWidth, int current) {
    int col = imgSource.col;
    int[] matrixIndex = Utils.get2dPos(floor(seqdata.seqStart/offset), floor(col));
    int iIndex = floor(matrixIndex[0]);
    int jIndex = floor(matrixIndex[1]);
    int nextIndex = current + 1;
    if (nextIndex > seqimg.seqRGB.length - 1) nextIndex = 0;
    color nextRGB = seqimg.seqRGB[nextIndex];

    //println("[" + x + "]" + "[" + y + "]");
    if(!behaviour.isMatrix){
      //when the seqimg should be represented in a linear grid
      jIndex += current;
      int jNext = floor(matrixIndex[1]) + nextIndex;
      int iNext = iIndex;
      while (jIndex > matrixWidth - 1) {
        iIndex += 1;
        jIndex -= matrixWidth;
      }
      while (jNext > matrixWidth - 1) {
        iNext += 1;
        jNext -= matrixWidth;
      };
      while (iIndex > matrixWidth - 1) iIndex -= matrixWidth;
      while (iNext > matrixWidth - 1) iNext -= matrixWidth;
      strokeWeight(1);
      stroke(0, 255, 0);
      fill(seqimg.currentRGB);
      rect(jIndex*pixSize*offset-(pixSize*offset/2)+this.canvasX, iIndex*pixSize*offset-(pixSize*offset/2)+this.canvasY, pixSize*offset, pixSize*offset);
      drawArc(jNext*pixSize*offset+this.canvasX, iNext*pixSize*offset+this.canvasY, pixSize*(offset*0.6), 6, inverseColor(nextRGB));
    }else{
      //when the seqimg should be represented in a matrix like grid
      int[] current2d = Utils.get2dPos(current, seqdata.colLength);
      int[] nextCurrent2d = Utils.get2dPos(nextIndex, seqdata.colLength);
      iIndex += current2d[0];
      jIndex += current2d[1];
      int iNextMatrix = floor(matrixIndex[0]) + nextCurrent2d[0];
      int jNextMatrix = floor(matrixIndex[1]) + nextCurrent2d[1];
      while (jIndex > matrixWidth - 1) {
        iIndex += 1;
        jIndex -= matrixWidth;
      }
      while (jNextMatrix > matrixWidth - 1) {
        iNextMatrix += 1;
        jNextMatrix -= matrixWidth;
      }
      while (iIndex > matrixWidth - 1) iIndex -= matrixWidth;
      while (iNextMatrix > matrixWidth - 1) iNextMatrix -= matrixWidth;
      //println("[" + x + "]" + "[" + y + "]");
      strokeWeight(1);
      stroke(0, 255, 0);
      fill(seqimg.currentRGB);
      rect(jIndex*pixSize*offset-(pixSize*offset/2)+this.canvasX, iIndex*pixSize*offset-(pixSize*offset/2)+this.canvasY, pixSize*offset, pixSize*offset);
      drawArc(jNextMatrix*pixSize*offset+this.canvasX, iNextMatrix*pixSize*offset+this.canvasY, pixSize*(offset*0.6), 6, inverseColor(nextRGB));
    };
    //println("=======================================");
  };
}


//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------


// retreives input color
//midi を送信する部分と　光学情報をmidi信号にマップする機能はクラスを分けた方がいいのか？？
public class MidiMap {
  SeqImg seqimg;
  States state;
  Behaviour behaviour;
  MappingData mapdata;
  boolean[] noteOn;
  int midiCh;
  int mStep;
  int mNote;
  int currentOct;
  String deviceName;
  ToneEngineMIDI midi;

  public MidiMap(String deviceName,int id , SeqData seqdata, Behaviour behaviour, States state, MappingData mapdata) {
    this.midi = new ToneEngineMIDI(deviceName);
    this.deviceName = deviceName;
    this.midiCh = id; 
    this.behaviour = behaviour;
    this.state = state;
    noteOn = new boolean[seqdata.seqLength];
    for (int i = 0; i < noteOn.length; i++) {
      noteOn[i] = true;
    };
    this.mapdata = mapdata; //Scale.MAJOR_PENTATONIC;
    //mScale =Scale.MAJOR_PENTATONIC;
  };

  public void updateMidiSource(String source) {
    this.midi = new ToneEngineMIDI(source);
    this.deviceName = source;
  }
  
  public String getNoteText(){
    return mapdata.getNotes(mStep);
  }

  private void play() {
    int ch = this.midiCh;
    if(this.deviceName.equals(targetMidiIn)) ch = 0;
    if(state.isShortTrig){
      midi.note_on(mNote, 100,0.05f);    
    }else{
      midi.note_on(mNote, 100);    
    }
  };

  public void pause() {
    int ch = this.midiCh;
    if(this.deviceName.equals(targetMidiIn)) ch = 0;
    midi.note_off(mNote);
  };
  
  public int getCurrentOct(){
    return this.currentOct / 12;
  }

  private int getOct(color currentColor) {
    int baseNote = mapdata.getBaseNote();
    int returnBaseNote = baseNote;
    switch(behaviour.oct) {
      // bass octave only
    case 0:
      break;
      // variable octave
    case 1:
      mNote = Scale.get_note(mapdata.mScale, baseNote, mStep);
      for (int i = 0; i < mapdata.octRange.length; i++) {
        if (mapdata.octRange[i] < brightness(currentColor)) {
          //if i == middle it plays the middle C octave
          //if i is more than middle octave up
          //if i is less than middle octave down
          returnBaseNote = baseNote + 12 * (i);
        }
      }
      break;
    };
    return returnBaseNote;
  };
  
  private void octMap(color currentColor){
    int oct = getOct(currentColor);
    this.currentOct = oct;
    println("key: " + mapdata.key);
    mNote = Scale.get_note(mapdata.mScale, oct, mStep);
  }

  private void noteMap(color currentColor) {
    float hueVal = hue(currentColor);
    for (int i = 0; i < mapdata.scaleRange.length; i++) {
      if (mapdata.scaleRange[i] < hueVal) mStep = i;
    }
    println(mStep);
    mStep %= mapdata.mScale.length;
  };


  public void sendMidi(SeqImg seqimg) {
    pause();
    color currentColor = seqimg.currentRGB;
    noteMap(currentColor);
    octMap(currentColor);
    // no sound limit
    state.isNoteOn = (10 < brightness(currentColor)) ? true : false;

    play();
  };
};
