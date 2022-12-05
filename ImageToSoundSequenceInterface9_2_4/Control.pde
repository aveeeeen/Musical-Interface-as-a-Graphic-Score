import java.util.List;
import java.lang.Object;

public class UI {
  PVector vector;
  ControlP5 cp5;
  Knob min, max, brightness2, brightness, hue, saturation;
  Textfield setBPMtext, saveAs;

  float x = width/2-imgSource.canvasWidth/2+imgSource.canvasWidth;
  float y = height/2;
  float firstH = 40;
  float knobH = 60; // ui marg
  float knobW = 50; // ui marg
  float textFieldH = 30;
  float textFieldW = 60;
  color strC = color(0, 0, 255);
  String ctrls = "-------------------- Controls --------------------";
  String status = "-------------------- Status --------------------";
  float titleX = (width - x)/2 + x - textWidth(ctrls)/2;
  float statusX = (width - x)/2 + x - textWidth(status)/2;

  Boolean isCorrectBPM = true;

  UI(PApplet thePApplet, float canvasWidth, float canvasHeight) {
    cp5 = new ControlP5(thePApplet);

    final float r = 15; // this is for the radius
    final float ui1spacing = 80;
    final float ui2spacing = 280;
    final float knobRes = 50;
    /*
    min = cp5.addKnob("min")
     .setRange(0, 100)
     .setValue(0)
     .setPosition((10*1)+ui2spacing, 10)
     .setRadius(r)
     .setDragDirection(Knob.HORIZONTAL)
     .setResolution(knobRes)
     .setColorBackground(colour)
     .setDecimalPrecision(0)
     ;
     max = cp5.addKnob("max")
     .setRange(0, 100)
     .setValue(100)
     .setPosition((10*2)+(r*2)+ui2spacing, 10)
     .setRadius(r)
     .setDragDirection(Knob.HORIZONTAL)
     .setResolution(knobRes)
     .setColorBackground(colour)
     .setDecimalPrecision(0)
     ;
     brightness2 = cp5.addKnob("brightness")
     .setRange(-100, 100)
     .setValue(0)
     .setPosition((10*3)+(r*4)+ui2spacing, 10)
     .setRadius(r)
     .setDragDirection(Knob.HORIZONTAL)
     .setResolution(knobRes)
     .setColorBackground(colour)
     .setDecimalPrecision(0)
     ;
     */


    float h = y;


    plainText(ctrls, titleX, y, 14, strC);

    h += firstH;
    x += 10;

    String strHue = "Color Mod:";
    float xMarg = textWidth(strHue) ;
    float uiX = x + xMarg + knobW;

    plainText(strHue, x, h, 14, strC);

    hue = cp5.addKnob("hue")
      .setRange(-180, 180)
      .setValue(0)
      .setPosition(uiX, h)
      .setRadius(r)
      .setDragDirection(Knob.HORIZONTAL)
      .setResolution(knobRes)
      .setColorBackground(colour)
      .setDecimalPrecision(0)
      ;

    uiX += knobW;

    saturation = cp5.addKnob("sat")
      .setRange(-100, 100)
      .setValue(0)
      .setPosition(uiX, h)
      .setRadius(r)
      .setDragDirection(Knob.HORIZONTAL)
      .setResolution(knobRes)
      .setColorBackground(colour)
      .setDecimalPrecision(0)
      ;

    uiX += knobW;

    brightness = cp5.addKnob("bri")
      .setRange(-100, 100)
      .setValue(0)
      .setPosition(uiX, h)
      .setRadius(r)
      .setDragDirection(Knob.HORIZONTAL)
      .setResolution(knobRes)
      .setColorBackground(colour)
      .setDecimalPrecision(0)
      ;

    h += knobH;
    String strBPM = "set BPM: ";
    uiX = x + xMarg + knobW;

    plainText(strBPM, x, h, 14, strC);

    //textField

    setBPMtext = cp5.addTextfield("set bpm")
      .setPosition(uiX, h)
      .setSize(50, 20)
      .setFocus(false)
      .setColor(color(0, 0, 255))
      ;

    uiX += this.textFieldW;

    cp5.addBang("set_bpm")
      .setPosition(uiX, h)
      .setSize(50, 20)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      ;
    /*
    h += knobH;
    String strConnect = "Connect: ";
    uiX = x + xMarg + knobW;

    plainText(strConnect, x, h, 14, strC);

    cp5.addBang("midiSync")
      .setPosition(uiX, h)
      .setSize(60, 20)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      ;

    h += textFieldH;
    cp5.addBang("controller")
      .setPosition(uiX, h)
      .setSize(60, 20)
      .getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER)
      ;
    */
  };

  public void render() {
    float h = y;
    float textX = x + 10;

    plainText(ctrls, titleX, y, 14, strC);

    h += firstH;

    String strHue = "Color Mod:";

    plainText(strHue, textX, h, 14, strC);

    h += knobH;
    String strBPM = "Set BPM: ";

    plainText(strBPM, textX, h, 14, strC);
    /*
    h += knobH;
    String strConnect = "Connect: ";
    plainText(strConnect, textX, h, 14, strC);
    */

    renderStatus(x+10, y + y/2);

    if (!isCorrectBPM) {
      float xMarg = textWidth(strBPM);
      float alertX = x + xMarg + knobW;
      alertX += textFieldW * 2 + 10;
      plainText("BPM must be \n20...200", alertX, h, 14, color(0, 100, 100));
    }

    //isKeyInputOn = false;
    ui.cp5.show();
    if (ui.cp5.get(Textfield.class, "set bpm").isMouseOver()) {
      ui.cp5.get(Textfield.class, "set bpm").setFocus(true);
      isKeyInputOn = false;
    } else {
      ui.cp5.get(Textfield.class, "set bpm").setFocus(false);
      isKeyInputOn = true;
    }
  }

  private void renderStatus(float xx, float yy) {
    float h = yy;

    plainText(status, statusX, h, 14, color(0, 0, 100));

    h += firstH;

    float xMarg = (width - x) / 2;
    String note1 = (
      "Current BPM: " + bpm
      );

    String note2 = (
      "MidiSyncIs: " + midiSyncIs + "\n" +
      "ControllerIs: " + midiCCIs
      );

    highlightBooleanText(note1, xx, h, 14, color(0, 0, 100));
    highlightBooleanText(note2, xx + xMarg, h, 14, color(0, 0, 100));
  }


  public PVector get_elem_pos(String elem_name) {
    PVector v = new PVector(0, 0);
    Boolean isElem = false;
    List <ControllerInterface<?>> elem_list = ui.cp5.getList();

    for (int i = 0; i < elem_list.size(); i++) {
      if (elem_list.get(i).getName() == elem_name) {
        float[] pos_data = elem_list.get(i).getPosition();
        v.set(pos_data[0], pos_data[1]);
        isElem = true;
        break;
      }
    }

    if (!isElem) println("no such element named " + "'" + elem_name + "'" + " found, returned vector(0,0)");
    return v;
  }
}

boolean isShift = false;


void event_receive(int command, float[] data) {
  //commnad 0 = noteOn, command 1 = noteOff, command 2 = CC
  if (!midiCCIs) return;
  if (command == 2) {
    midiControl((int)data[1], data[2]);
  }
  //noteOn
  if (command == 0) {
    midiNoteTrig((int)data[1], command);
  }
  //noteOff
  if (command == 1) {
    midiNoteTrig((int)data[1], command);
  }
}

void midiControl(int number, float val) {
  switch(number) {
    case 16:
      ui.hue.setValue(map(val, 0, 127, ui.hue.getMin(), ui.hue.getMax()));
    break;
  case 20:
    ui.saturation.setValue(map(val, 0, 127, ui.saturation.getMin(), ui.saturation.getMax()));
    break;
  case 24:
    ui.brightness.setValue(map(val, 0, 127, ui.brightness.getMin(), ui.brightness.getMax()));
    break;
  }
}

void midiNoteTrig(int number, int command) {
  if (!isKeyInputOn) return;

  int row = imgSource.row;
  int col = imgSource.col;
  switch(number) {
  case 3:
    if (command == 0) isShift = true;
    if (command == 1) isShift = false;
    break;
  };

  if (command == 1) return;

  switch(number) {
  case 1:
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
  case 24:
    if (!isShift) {
      seq[seqIndex].seqdata = seq[seqIndex].seqdata.shift(floor(1*seq[seqIndex].getOffset()));
    } else {
      seq[seqIndex].behaviour.isMatrix = seq[seqIndex].behaviour.isMatrix ? false : true;
      seq[seqIndex].updateData(tempC);
    }
    //seq[seqIndex].current--;
    break;
  case 18:
    if (!isShift) {
      seq[seqIndex].seqdata = seq[seqIndex].seqdata.shift(floor(-1*seq[seqIndex].getOffset()));
    } else {
      seq[seqIndex].behaviour.isMoving = seq[seqIndex].behaviour.isMoving ? false : true;
    }
    //seq[seqIndex].current--;
    break;
  case 19:
    if (!isShift) {
      seq[seqIndex].seqdata = seq[seqIndex].seqdata.shift(floor(-row*seq[seqIndex].getOffset()));
      if (seq[seqIndex].seqdata.seqStart < 0) seq[seqIndex].seqdata = seq[seqIndex].seqdata.shift(floor(row*col*seq[seqIndex].getOffset())) ;
      seq[seqIndex].updateData(tempC);
    } else {
      seq[seqIndex].seqRow /= 2;
      seq[seqIndex].seqCol /= 2;
      if (seq[seqIndex].getOffset() > 16) {
        seq[seqIndex].seqRow = row/2;
        seq[seqIndex].seqCol = col/2;
      }
      seq[seqIndex].updateData(tempC);
    }
    break;
  case 21:
    if (!isShift) {
      seq[seqIndex].seqdata = seq[seqIndex].seqdata.shift(floor(row*seq[seqIndex].getOffset()));
      seq[seqIndex].updateData(tempC);
    } else {
      seq[seqIndex].seqRow *= 2;
      seq[seqIndex].seqCol *= 2;
      if (seq[seqIndex].seqRow > row) {
        seq[seqIndex].seqRow = 16;
        seq[seqIndex].seqCol = 16;
      }
      seq[seqIndex].updateData(tempC);
    }
    break;
  case 16:
    if (!isShift) {
      seq[seqIndex].midimap.pause();
      seq[seqIndex].midiIndex += 1;
      if (seq[seqIndex].midiIndex > midiOutSource.length - 1) seq[seqIndex].midiIndex = 0;
      //println(seq[seqIndex].midiIndex);
      String newDeviceName;
      newDeviceName = midiOutSource[seq[seqIndex].midiIndex];
      seq[seqIndex].updateMidi(newDeviceName);
    } else {
      seq[seqIndex].state.isMute = seq[seqIndex].state.isMute ? false : true;
    }
    break;
  case 22:
    seq[seqIndex].behaviour.oct = (seq[seqIndex].behaviour.oct == 0) ? 1 : 0;
    break;
  };

  switch(number) {
  case 4:
    seq[0].state.isAlive = (!seq[0].state.isAlive) ? true : false;
    seqIndex = 0;
    break;
  case 7:
    seq[1].state.isAlive = (!seq[1].state.isAlive) ? true : false;
    seqIndex = 1;
    break;
  case 10:
    seq[2].state.isAlive = (!seq[2].state.isAlive) ? true : false;
    seqIndex = 2;
    break;
  case 6:
    seq[3].state.isAlive = (!seq[3].state.isAlive) ? true : false;
    seqIndex = 3;
    break;
  }
}
