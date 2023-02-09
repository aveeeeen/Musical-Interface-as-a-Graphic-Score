Seq2[] seq = new Seq2[4];
DrawFeedback[] drawFeedback = new DrawFeedback[4];
boolean hasRan = false;

public void instantiate() {
  if (!hasRan) runInstances();
};

public void runInstances() {

  midiOutSource = MidiOut.availableOutputs();
  midiInSource = MidiIn.availableInputs();

  int midiOutputSelect = 0;
  for (int i = 0; i < seq.length; i++) {
    if (i > midiOutSource.length-1) midiOutputSelect = 0;
    seq[i] = new Seq2((int)random(0, 500), midiOutSource[midiOutputSelect], i, imgSource.canvasX, imgSource.canvasY);
    seq[i].updateData(imgSource.imgC);
    midiOutputSelect++;
  };

  for (int i = 0; i < drawFeedback.length; i++) {
    int index = i;
    boolean isLeft = true;
    float feedbackX = 10;
    if (i > 3 - 1) {
      index %= 3;
      feedbackX += width/2-imgSource.canvasWidth/2+imgSource.canvasWidth;
      isLeft = !isLeft;
    }
    float feedbackY = height/3 * index + 10;
    drawFeedback[i] = new DrawFeedback(feedbackX, feedbackY, seq[i], isLeft);
  };

  println("=========================================-------------------");

  printArray(midiInSource);

  for (int i = 0; i < midiInSource.length; i++) {
    if (targetMidiIn.equals(midiInSource[i])) {
      midiSyncIs = true;
      break;
    };
  };

  for (int i = 0; i < midiInSource.length; i++) {
    if (targetMidiCC.equals(midiInSource[i])) {
      midiCCIs = true;
      EventReceiverMIDI.start(this, targetMidiCC);
      break;
    }
  };

  if (midiSyncIs) {
    BeatMIDI.start(this, targetMidiIn);
  } else {
    beat = new Beat(this, 120 * 4);
    bpm = "120";
    int bpm_int = Integer.parseInt(bpm);
    println(bpm_int);
    beat.set_bpm(bpm_int * 4);
  }



  println("midiSyncIs:" + midiSyncIs);
  println("midiCCIs:" + midiCCIs);

  //ui element
  ui = new UI(this, imgSource.canvasWidth, imgSource.canvasWidth);
  hasRan = true;
};
