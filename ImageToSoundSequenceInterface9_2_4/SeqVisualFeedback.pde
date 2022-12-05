import java.util.*;

public class DrawFeedback {
  float x;
  float y;
  float seqPosX;
  float seqPosY;
  SeqMapVis mapvis;
  SeqDrawStatus drawStatus;
  SeqDrawColor drawColor;
  SeqDrawResult drawResult;
  boolean isAlive;
  boolean isLeft;
  boolean selected;

  float yMarg = 10;
  float drawNotesY = 100;
  float mapvisY;
  //float mapvisX = 50;
  float xMarg = 10;
  float indent = 40;
  float hCenter = 240/2;
  float hMargin = 35;
  float indentH = 22;

  public DrawFeedback(float x, float y, Seq2 seq, boolean isLeft) {
    this.x = x;
    this.y = y;
    this.isAlive = seq.state.isAlive;
    this.selected = seq.state.selected;
    this.seqPosX = seq.pos.x;
    this.seqPosY = seq.pos.y;
    this.isLeft = isLeft;
    float h = 0 + yMarg;


   this.drawStatus = new SeqDrawStatus(this.x + xMarg, this.y + h + this.indentH, seq);
    h = this.hCenter + this.yMarg + this.indentH + 10;
    this.mapvis = new SeqMapVis(this.x + xMarg, this.y + h, seq.seqimg, seq.mapdata);
    h += 54;
    this.drawResult = new SeqDrawResult(this.x + xMarg, this.y + h, seq.seqimg, seq.midimap);
  }

  public void render() {
    if (this.isAlive) {
      color tc = color(0, 0, 0);
      color hc = color(0, 0, 80);
      
      highlightText(" palacing ", -2000 , -2000 , 14, tc, hc);
      highlightText(" Status ", this.x + xMarg, this.y + 10, 14, tc, hc);
      drawStatus.render();
      
      drawStatus.render();

      float h = this.hCenter;
      float m2 = 20;
      float w = width-width/2-imgSource.canvasWidth/2 - m2;
      
      highlightText(" Mapping ", this.x + xMarg, this.y + h + 10, 14, tc, hc);

      mapvis.render();
      //drawResult.render();

      drawFrame();
      drawLine();
    }
  }

  public void update(float x, float y, Seq2 seq) {
    this.x = x;
    this.y = y;
    this.isAlive = seq.state.isAlive;
    this.selected = seq.state.selected;
    this.seqPosX = seq.draw.pos.x;
    this.seqPosY = seq.draw.pos.y;
    float h = 0 + yMarg;

    this.drawStatus = new SeqDrawStatus(this.x + xMarg, this.y + h + this.indentH, seq);
    h = this.hCenter + this.yMarg + this.indentH + 10;
    this.mapvis = new SeqMapVis(this.x + xMarg, this.y + h, seq.seqimg, seq.mapdata);
    h += 54;
    this.drawResult = new SeqDrawResult(this.x + xMarg, this.y + h, seq.seqimg, seq.midimap);
  }

  public void updateSeqPos(PVector pos) {
    this.seqPosX = pos.x;
    this.seqPosY = pos.y;
  }

  public void drawLine() {
    float collideOffset = 10;
    float xVal = collide(this.seqPosX, 0, imgSource.canvasWidth, collideOffset) + imgSource.canvasX;
    float yVal = collide(this.seqPosY, 0, imgSource.canvasWidth, collideOffset) + imgSource.canvasY;
    float m2 = 20;
    float lineXMarg = 0;
    if (isLeft) lineXMarg = width-width/2-imgSource.canvasWidth/2 - m2;
    stroke(0, 0, 50);
    strokeWeight(3);
    line(x+lineXMarg, y, xVal, yVal);
  }

  public void drawFrame() {
    int heightDiv = 3;
    float m = 40;
    float m2 = 20;
    float w = width-width/2-imgSource.canvasWidth/2 - m2;
    float h = height/heightDiv - m2;
    PVector[] points = new PVector[4];
    points[0] = new PVector(this.x, this.y);
    points[1] = new PVector(this.x + w, this.y);
    points[2] = new PVector(this.x + w, this.y + h);
    points[3] = new PVector(this.x, this.y + h);
    stroke(0, 0, 100);
    if (this.selected) stroke(0, 100, 100);
    for (int i = 0; i < 4; i++) {

      pushMatrix();
      translate(points[i].x, points[i].y);
      rotate(TWO_PI*i/4);
      strokeWeight(3);
      beginShape(LINES);
      vertex(0, m);
      vertex(0, 0);
      vertex(0, 0);
      vertex(m, 0);
      endShape();
      popMatrix();
    }
  }
}

//---------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------//

public class SeqDrawColor {
  float h;
  float x;
  float y;
  float pixLength;
  color c;

  public SeqDrawColor(float x, float y, float pixLength) {
    this.x = x;
    this.y = y;
    this.pixLength = pixLength;
    this.h = pixLength * 16;
  }

  public void render() {
    drawColor();
  }

  private void drawColor() {
    color textC = color(0, 0, 100);
    float hue = hue(this.c);
    float sat = saturation(this.c);
    float bri = brightness(this.c);

    String hueStr = "hue: ";
    plainText(hueStr, this.x, this.y, textC, 12);

    float w = textWidth(hueStr);
    noStroke();
    fill(color(hue, 100, 100));
    rect(x + w, y, h, h);

    w += h + 10;
    String satStr = "sat: ";
    plainText(satStr, this.x + w, this.y, textC, 12);

    w += textWidth(satStr);
    noStroke();
    fill(color(hue, sat, 100));
    rect(x + w, y, h, h);

    w += h + 10;
    String briStr = "bri: ";
    plainText(briStr, this.x + w, this.y, textC, 12);

    w += textWidth(briStr);
    noStroke();
    fill(color(0, 0, bri));
    rect(x + w, y, h, h);
  }

  public void update(SeqImg seqimg) {
    this.c = seqimg.currentRGB;
  }
}

//---------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------//

public class SeqDrawNotes {

  LinkedList<NoteVisual> notelist = new LinkedList<NoteVisual>();
  float currentH;
  float maxH;
  float x;
  float y;
  float pixLength;
  int length = 4;

  public SeqDrawNotes(float x, float y, float pixLength) {
    this.x = x;
    this.y = y;
    this.pixLength = pixLength;
    maxH = pixLength * 16 * length;
  }

  public void render() {
    drawNotes();
    grid();
    drawCurrentNote();
  }

  public void backgroundRender() {
    backgroundLayer();
    grid();
    backgroundCurrentNote();
  }

  private void drawNotes() {
    float incrW = x;
    for (int i = 0; i < notelist.size(); i++) {
      NoteVisual note = notelist.get(i);
      float rectLength = note.offset * pixLength;
      fill(note.currentColor);
      noStroke();
      rect(incrW, y, rectLength, rectLength);
      incrW += rectLength;
    }
  }

  private void backgroundLayer() {
    fill(100);
    noStroke();
    rect(x, y, maxH, pixLength * 16);
  }

  private void grid() {
    for (int i = 0; i < length; i++) {
      stroke(255);
      strokeWeight(2);
      line(x + pixLength * 16 * (i + 1), y, x + pixLength * 16 * (i + 1), y + pixLength * 16 );
    }
  }

  private void backgroundCurrentNote() {
    fill(100);
    stroke(255);
    strokeWeight(2);
    rect(x + maxH + 10, y, pixLength * 16, pixLength * 16);
  }

  private void drawCurrentNote() {
    if (notelist.isEmpty()) return;
    NoteVisual note = notelist.getLast();
    fill(note.currentColor);
    noStroke();
    rect(x + maxH + 10, y, pixLength * 16, pixLength * 16);
  }

  public void update(NoteVisual note) {
    enque(note);
    currentH += pixLength * note.offset;
    while (currentH > maxH) {
      NoteVisual tempNote = notelist.get(0);
      currentH -= pixLength * tempNote.offset;
      deque();
    }
  }

  public void clearList() {
    notelist.removeAll(notelist);
  }

  private void enque(NoteVisual note) {
    notelist.addLast(note);
  }

  private void deque() {
    notelist.removeFirst();
  }
}

//---------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------//

public class SeqDrawStatus {
  float x;
  float y;
  Behaviour behaviour;
  States state;
  float offset;
  int id;
  String deviceName;
  public SeqDrawStatus(float x, float y, Seq2 seq) {
    this.x = x;
    this.y = y;
    this.behaviour = seq.behaviour;
    this.state = seq.state;
    this.offset = seq.getOffset();
    this.id = seq.id;
    this.deviceName = seq.deviceName;
  }

  public void render() {
    drawStatus();
  }

  public void drawStatus() {
    float xMarg = 150;
    float h = 150;
    String time = "";

    switch(round(offset)) {
      //1 bar
    case 16:
      time = "1";
      break;
      //1/2
    case 8:
      time = "1/2";
      break;
      //1/4
    case 4:
      time = "1/4";
      break;
      //1/8
    case 2:
      time = "1/8";
      break;
      //1/16
    case 1:
      time = "1/16";
      break;
    };

    String note1 = (
      "id: " + id + "\n" +
      "midi: " + deviceName + "\n" +
      "isMoving: " + behaviour.isMoving + "\n" +
      "isMatrix: " + behaviour.isMatrix + "\n"
      );

    String note2 = (
      "time: " + time + "\n" +
      "oct: " + behaviour.oct + "\n" +
      "isShortTrig: " + state.isShortTrig + "\n" +
      "isMute: "  + state.isMute + "\n"
      );
    fill(0, 0, 0);
    noStroke();
    rect(x, y, xMarg, h);

    highlightBooleanText(note1, x, y, 14, color(0, 0, 100));

    fill(0, 0, 0);
    noStroke();
    rect(x + xMarg - 10, y, xMarg, h);

    fill(0, 0, 100);
    textSize(14);
    highlightBooleanText(note2, x + xMarg, y, 14, color(0, 0, 100));
  };
}

//---------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------//

public class SeqMapVis {
  SeqImg seqimg;
  MappingData mapdata;
  float x;
  float y;
  float offset = 1.7;
  float y2 = 10;

  public SeqMapVis(float x, float y, SeqImg seqimg, MappingData mapdata) {
    this.x = x;
    this.y = y;
    this.seqimg = seqimg;
    this.mapdata = mapdata;
    if(width < 1400) this.offset = 1.8;
  }

  public void update(SeqImg seqimg, MappingData mapdata) {
    this.seqimg = seqimg;
    this.mapdata = mapdata;
  }

  public void render() {
    mapVisual();
  }

  private void mapVisual() {
    color textC = color(0, 0, 100);
    String hueToNote = "[hue > note]";
    plainText(hueToNote, x, y - 5, 14, textC);

    float plotX = x + textWidth(hueToNote) + 10;

    // hue map
    for (int i = 0; i < 360; i++) {
      float tempX = plotX + i/offset;
      strokeWeight(1);
      stroke(i, 100, 100);
      line(tempX, y, tempX, y + y2);
    }

    for (int i = 0; i < mapdata.scaleRange.length; i++) {
      float tempX = plotX + mapdata.scaleRange[i] / offset;
      stroke(255);
      strokeWeight(2);
      line(tempX, y, tempX, y + y2);
    }

    float ellipseX = plotX + hue(seqimg.currentRGB) / offset;
    noFill();
    strokeWeight(2);
    stroke(255);
    ellipse(ellipseX, y + y2/2, 10, 10);

    for (int i = 0; i < mapdata.scaleRange.length; i++) {
      float tempX = plotX + mapdata.scaleRange[i] / offset;
      int steps = i;
      String notes = mapdata.getNotes(steps);
      int textSize = 12;
      plainText(notes, tempX, y + y2 + 2, textSize, color(0, 0, 100));
    }

    //brightness map

    float y3 = y2 + 20;

    String briToOct = "[bri > oct]";
    plainText(briToOct, x, y + y3 -5, 14, textC);


    for (int i = 0; i < 100; i++) {
      float tempX = round(plotX + map(i, 0, 100, 0, 360) / offset);
      noStroke();
      fill(color(0, 0, i));
      rect(tempX, y + y3, round(map(1, 0, 100, 0, 360)) / offset, y2);
    }

    for (int i = 0; i < mapdata.octRange.length; i++) {
      float tempX = plotX + map(mapdata.octRange[i], 0, 100, 0, 360) / offset;
      stroke(255);
      strokeWeight(2);
      line(tempX, y + y3, tempX, y + y3 + y2);
    }

    float ellipseX2 = plotX + map(brightness(seqimg.currentRGB), 0, 100, 0, 360) / offset;
    noFill();
    strokeWeight(2);
    stroke(inverseColor(color(0,100,brightness(seqimg.currentRGB))));
    ellipse(ellipseX2, y + y3 + y2/2, 10, 10);
    
    for (int i = 0; i < mapdata.octRange.length; i++) {
      float tempX = plotX + map(mapdata.octRange[i], 0, 100, 0, 360) / offset;
      int octNum = i + Note.NOTE_C2 / 12;
      String oct = "" + octNum;
      int textSize = 12;
      plainText(oct, tempX, y + y3 + y2 + 2, textSize, color(0, 0, 100));
    }
  }
}

//---------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------//

public class SeqDrawResult {
  float x;
  float y;
  MidiMap midimap;
  SeqImg seqimg;

  public SeqDrawResult(float x, float y, SeqImg seqimg, MidiMap midimap) {
    this.x = x;
    this.y = y;
    this.seqimg = seqimg;
    this.midimap = midimap;
  }

  void render() {
    drawText();
  }

  void update(SeqImg seqimg, MidiMap midimap) {
    this.seqimg = seqimg;
    this.midimap = midimap;
  }

  void drawText() {
    int textSize = 22;
    color c = seqimg.currentRGB;
    color normalTextC = color(0, 0, 100);
    float hue = hue(c);
    float bri = brightness(c);
    
    String outputLabel = "[output > midi]  ";
    plainText(outputLabel, this.x, this.y, 14, normalTextC);
    float w = textWidth(outputLabel);

    String noteLabel = "note: ";
    plainText(noteLabel, this.x + w, this.y, 14, normalTextC);
    w += textWidth(noteLabel);

    String note = midimap.getNoteText();
    plainText(note, this.x + w, this.y, textSize, color(hue, 100, 100));
    w += textWidth(note) + 10;

    String octLabel = "oct: ";
    plainText(octLabel, this.x + w, this.y, 14, normalTextC);
    w += textWidth(octLabel);

    String oct = "" + midimap.getCurrentOct();
    color octC = color(0, 0, bri);
    if (bri < 10){
      oct = "noteOff";
      octC = color(0,100,100);
    }
    plainText(oct, this.x + w, this.y, textSize, octC);
  }
}
