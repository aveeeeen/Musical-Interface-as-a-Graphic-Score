/*
  I've cited most of the processes and ideas from Daniel Shiffmans "Learning Processing" tutorials.
 Thanks, Prof.Shiffman!
 
 Learning Processing
 Daniel Shiffman
 http://www.learningprocessing.com
 Example 15-7: Displaying the pixels of an image
 */
import wellen.*;
import controlP5.*;
import java.util.regex.*;

PFont font;
MasterImg imgSource;
color[][] tempC;
//fileselection
String path;
boolean fileSelect = false;
int fileOperation = 0;

color colour = (100);
boolean isKeyInputOn = false;

MidiOut midiSetupOut;
MidiIn midiSetupIn;
String[] midiOutSource;
String[] midiInSource;
String targetMidiIn = "USB MIDI Interface";
String targetMidiCC = "MIDI Mix";
boolean midiCCIs = false;
boolean midiSyncIs = false;

String bpm = "";
Beat beat;
BeatMIDI midiSync;

UI ui;
JSONObject scale;


void setup() {
  fullScreen(P2D);
  //size(800, 800);
  //size(1600, 900, P2D);

  //String[] fontList = PFont.list();
  //printArray(fontList);
  textFont(createFont("Arial", 14));
  frameRate(20);

  selectInput("Select file, Image JPG or PNG", "fileSelected");
  colorMode(HSB, 360, 100, 100);
}

void fileSelected(File selection) {
  if (fileOperation == 0) {
    if (selection == null) {
      println("no file selected");
      path = null;
    } else {
      path = selection.getAbsolutePath();
      println("file selected");
      println(path);
      if (path == null || !path.endsWith(".png") && !path.endsWith(".jpg")) println("not correct file type");
      
      int canvasW = height - 100;
      if(width > 1400);
      
      PImage img = loadImage(path);
      imgSource = new MasterImg(canvasW, canvasW, 128*2, 128*2, img);
      imgSource.setPlacement(width/2-imgSource.canvasWidth/2, 50);
      tempC = new color[imgSource.col][imgSource.row];

      fileSelect = true;
      fileOperation++;
    }
  } else {
    if (selection == null) {
      println("no file selected");
      path = null;
    } else {
      path = selection.getAbsolutePath();
      println("file selected");
      println(path);
      loadFile();
    }
  }
}

float prevFrame = 0;
float ellapsed = 0;
float interval = 1000;
void draw() {
  background(0, 0, 0);
  /*
  if(millis() - ellapsed > interval){
   float calcFrame = frameCount - prevFrame;
   prevFrame = frameCount;
   ellapsed = millis();
   println(
   "-----------------------" +
   "\n FPS:" + calcFrame
   );
   }
   */
  if (fileSelect) {
    instantiate();
    if (hasRan) run();
  }
}

void beat(int pBeat) {

  for (int i = 0; i < seq.length; i++) {
    // the program should update the img data from reference no matter any states
    seq[i].updateData(tempC);
    float beatTrigDivider = seq[i].getSeqTime();
    if (midiSyncIs) beatTrigDivider *= 6;
    if (pBeat % beatTrigDivider == 0) {
      seq[i].tickAction();
    }
  }
}

void updateFeedback() {
  for (int i = 0; i < drawFeedback.length; i++) {
    int index = i;
    if (i > 3 - 1) index %= 3;
    float feedbackY = height/3 * index + 10;
    float feedbackX = 10;
    if (i > 3 - 1) feedbackX += width/2-imgSource.canvasWidth/2+imgSource.canvasWidth;

    drawFeedback[i].update(feedbackX, feedbackY, seq[i]);
  }
}

void run() {
  float pixSize = imgSource.getPixSize();
  int row = imgSource.row;
  int col = imgSource.col;
  for (int i = 0; i< row; i++) {
    for (int j = 0; j < col; j++) {

      float[] hsb = new float[3];
      hsb[0] = hue(imgSource.getColor()[i][j]);
      hsb[1] = saturation(imgSource.getColor()[i][j]);
      hsb[2] = brightness(imgSource.getColor()[i][j]);

      hsb[0] += ui.hue.getValue();
      hsb[1] += ui.saturation.getValue();
      hsb[2] += ui.brightness.getValue();

      tempC[i][j] = color(hsb[0], hsb[1], hsb[2]);

      fill(tempC[i][j]);
      noStroke();
      rect(j*pixSize+imgSource.canvasX, i*pixSize+imgSource.canvasY, pixSize, pixSize);
    };
  };

  int aliveCount = 0;

  for (int i = 0; i < seq.length; i++) {
    if (seq[i].state.isAlive) aliveCount++;
    if (seq[i] == seq[seqIndex] && seq[i].state.isAlive) {
      seq[i].state.selected = true;
    } else {
      seq[i].state.selected = false;
    };
    if (!seq[i].state.isAlive) seq[i].state.selected = false;
    //first render only unselected seq
    if (!seq[i].state.selected) seq[i].render();
    drawFeedback[i].updateSeqPos(seq[i].draw.pos);
    drawFeedback[i].render();
  };

  if (aliveCount == 1) {
    for (int i = 0; i < seq.length; i++) {
      if (seq[i].state.isAlive) seqIndex = i;
    };
  };

  //render selected seq individualy to display it to the foreground

  seq[seqIndex].render();
  
  //render feeedbacks
  updateFeedback();

  //ui

  ui.render();

  //textInput
  //cp5.get(Textfield.class, "save as").get
}

int seqIndex = 0;

void keyPressed() {
  if (!isKeyInputOn) return;

  int row = imgSource.row;
  int col = imgSource.col;
  switch(key) {
  case' ':
    seqIndex++;
    if (seqIndex > seq.length - 1) seqIndex = 0;
    int aliveCount = 0;
    while (!seq[seqIndex].state.isAlive) {
      if (aliveCount > seq.length) break;
      aliveCount++;
      seqIndex++;
      if (seqIndex > seq.length - 1) seqIndex = 0;
    };
    println(seqIndex);
    break;
  };

  switch(key) {
  case 'd':
    seq[seqIndex].seqdata = seq[seqIndex].seqdata.shift(floor(1*seq[seqIndex].getOffset()));
    //seq[seqIndex].current--;
    break;
  case 'a':
    seq[seqIndex].seqdata = seq[seqIndex].seqdata.shift(floor(-1*seq[seqIndex].getOffset()));
    //seq[seqIndex].current--;
    break;
  case 'w':
    seq[seqIndex].seqdata = seq[seqIndex].seqdata.shift(floor(-row*seq[seqIndex].getOffset()));
    if (seq[seqIndex].seqdata.seqStart < 0) seq[seqIndex].seqdata = seq[seqIndex].seqdata.shift(floor(row*col*seq[seqIndex].getOffset())) ;
    seq[seqIndex].updateData(tempC);
    break;
  case 's':
    seq[seqIndex].seqdata = seq[seqIndex].seqdata.shift(floor(row*seq[seqIndex].getOffset()));
    seq[seqIndex].updateData(tempC);
    break;
  case 'l':
    seq[seqIndex].behaviour.isMatrix = seq[seqIndex].behaviour.isMatrix ? false : true;
    seq[seqIndex].updateData(tempC);

    break;
  case 'k':
    seq[seqIndex].seqRow *= 2;
    seq[seqIndex].seqCol *= 2;
    if (seq[seqIndex].seqRow > row) {
      seq[seqIndex].seqRow = 16;
      seq[seqIndex].seqCol = 16;
    }
    seq[seqIndex].updateData(tempC);

    break;
  case 'j':
    seq[seqIndex].behaviour.isMoving = seq[seqIndex].behaviour.isMoving ? false : true;
    break;
  case 'i':
    seq[seqIndex].seqRow /= 2;
    seq[seqIndex].seqCol /= 2;
    if (seq[seqIndex].getOffset() > 16) {
      seq[seqIndex].seqRow = row/2;
      seq[seqIndex].seqCol = col/2;
    }
    seq[seqIndex].updateData(tempC);
    break;
  case 'm':
    seq[seqIndex].midimap.pause();
    seq[seqIndex].midiIndex += 1;
    if (seq[seqIndex].midiIndex > midiOutSource.length - 1) seq[seqIndex].midiIndex = 0;
    println(seq[seqIndex].midiIndex);
    String newDeviceName;
    newDeviceName = midiOutSource[seq[seqIndex].midiIndex];
    seq[seqIndex].updateMidi(newDeviceName);
    break;
  case 'M':
    seq[seqIndex].state.isMute = seq[seqIndex].state.isMute ? false : true;
    break;
  case 'o':
    seq[seqIndex].behaviour.oct = (seq[seqIndex].behaviour.oct == 0) ? 1 : 0;
    break;
  case 't':
    // seq[seqIndex].seqTimeState++;
    /// if (seq[seqIndex].seqTimeState > 5) seq[seqIndex].seqTimeState = 0;
    break;
  case 'y':
    // seq[seqIndex].isShortTrig = seq[seqIndex].isShortTrig ? false : true;
    break;
  };

  switch(key) {
  case'1':
    seq[0].state.isAlive = (!seq[0].state.isAlive) ? true : false;
    seqIndex = 0;
    break;
  case'2':
    seq[1].state.isAlive = (!seq[1].state.isAlive) ? true : false;
    seqIndex = 1;
    break;
  case'3':
    seq[2].state.isAlive = (!seq[2].state.isAlive) ? true : false;
    seqIndex = 2;
    break;
  case'4':
    seq[3].state.isAlive = (!seq[3].state.isAlive) ? true : false;
    seqIndex = 3;
    break;
  }

  //consoleOut();
};


JSONArray seqFile;
JSONArray file;
String saveFileName = "";

void saveSeq() {
  if (saveFileName == "") return;

  seqFile = new JSONArray();
  for (int i = 0; i < seq.length; i++) {

    JSONObject seqData = new JSONObject();
    /*
    seqData.setInt("id", seq[i].id);
     seqData.setInt("seqStart", seq[i].seqStart);
     seqData.setInt("seqLength", seq[i].seqLength);
     seqData.setInt("current", seq[i].current);
     seqData.setInt("mode", seq[i].mode);
     seqData.setInt("type", seq[i].type);
     seqData.setInt("seqRow", seq[i].seqRow);
     seqData.setInt("seqCol", seq[i].seqCol);
     seqData.setInt("currentCounter", seq[i].currentCounter);
     seqData.setInt("seqTimeState", seq[i].seqTimeState);
     seqData.setBoolean("selected", seq[i].selected);
     seqData.setBoolean("isAlive", seq[i].isAlive);
     seqData.setBoolean("noteIsOn", seq[i].noteIsOn);
     seqData.setBoolean("isShortTrig", seq[i].isShortTrig);
     seqFile.setJSONObject(i, seqData);
     */
  }

  saveJSONArray(seqFile, "data/"+ saveFileName + ".json");
  return;
}

void save() {
  saveSeq();
  return;
}

void loadFile() {
  file = loadJSONArray(path);

  for (int i = 0; i < seq.length; i++) {

    JSONObject seqObj = file.getJSONObject(i);
    /*
    seq[i].seqStart = seqObj.getInt("seqStart");
     
     seq[i].id = seqObj.getInt("id");
     
     seq[i].seqLength = seqObj.getInt("seqLength");
     seq[i].current = seqObj.getInt("current");
     seq[i].mode = seqObj.getInt("mode");
     seq[i].type = seqObj.getInt("type");
     seq[i].seqRow = seqObj.getInt("seqRow");
     seq[i].seqCol = seqObj.getInt("seqCol");
     seq[i].currentCounter = seqObj.getInt("currentCounter");
     seq[i].seqTimeState = seqObj.getInt("seqTimeState");
     seq[i].selected = seqObj.getBoolean("selected");
     seq[i].isAlive = seqObj.getBoolean("isAlive");
     seq[i].noteIsOn = seqObj.getBoolean("noteIsOn");
     seq[i].isShortTrig = seqObj.getBoolean("isShortTrig");
     */
  }
  println("fileloaded");
  return;
}

void load_JSON() {
  fileOperation = 1;
  selectInput("Select file, JSON", "fileSelected");
}

void load_IMG() {
  fileOperation = 0;
  selectInput("Select file, Image JPG or PNG", "fileSelected");
}

void set_bpm() {
  String tempBpm = ui.cp5.get(Textfield.class, "set bpm").getText();
  ui.isCorrectBPM = true;
  if (tempBpm.isEmpty() || !Pattern.matches("[\\d]+", tempBpm)) {
    ui.isCorrectBPM = false;
    return;
  };
  int bpm_int = Integer.parseInt(tempBpm);
  if (bpm_int < 20 || 200 < bpm_int) {
    ui.isCorrectBPM = false;
    return;
  };
  bpm = tempBpm;
  beat.set_bpm(bpm_int * 4);
};

void controller() {
  midiOutSource = MidiOut.availableOutputs();
  midiInSource = MidiIn.availableInputs();
  printArray(midiInSource);
  for (int i = 0; i < midiInSource.length; i++) {
    if (targetMidiCC.equals(midiInSource[i])) {
      midiCCIs = true;
      EventReceiverMIDI.start(this, targetMidiCC);
      return;
    };
  };
  midiCCIs = false;
}

void midiSync() {
  Beat.stop();
  beat.clean_up();
  midiOutSource = MidiOut.availableOutputs();
  midiInSource = MidiIn.availableInputs();
  for (int i = 0; i < midiInSource.length; i++) {
    if (targetMidiIn.equals(midiInSource[i])) {
      midiSyncIs = true;
      break;
    };
  };
  if (midiSyncIs) {
    midiSync = BeatMIDI.start(this, targetMidiIn);
  } else {
    beat = new Beat(this, 120 * 4);
  }
}
