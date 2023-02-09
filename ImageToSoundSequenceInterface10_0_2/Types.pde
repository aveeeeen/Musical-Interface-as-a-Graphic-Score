public class Behaviour {
  boolean isMoving = false;
  boolean isMatrix = true;
  int oct = 1;

  public Behaviour(boolean mode, boolean type, int oct) {
    this.isMoving = mode;
    this.isMatrix = type;
    this.oct = oct;
  };
};

public class SeqImg {
  private final color[] seqRGB;
  private final color currentRGB;

  public SeqImg(color[] seqRGB, color currentRGB) {
    this.seqRGB = seqRGB;
    this.currentRGB = currentRGB;
  };
};

public class States {
  boolean selected;
  boolean isAlive;
  boolean isNoteOn;
  boolean isShortTrig;
  boolean isMute;

  public States() {
    selected = false;
    isAlive = false;
    isNoteOn = false;
    isShortTrig = false;
    isMute = true;
  };
};

public class NoteVisual {
  float offset;
  color currentColor;
  public NoteVisual(float offset, color currentColor ) {
    this.offset = offset;
    this.currentColor = currentColor;
  }
}

public class SeqData {
  private final int seqStart;
  private final int seqLength;
  private final int colLength;

  public SeqData(int seqStart, int seqLength) {
    seqStart = floor(collide(seqStart, 0, imgSource.col*imgSource.row - 1, 0));
    this.seqStart = seqStart;
    this.seqLength = seqLength;
    this.colLength = int(sqrt(seqLength));
  };

  public SeqData setSeqLength(int seqLength) {
    return new SeqData(this.seqStart, seqLength);
  };

  public SeqData shift(int shiftLength) {
    return new SeqData(this.seqStart + shiftLength, this.seqLength);
  };

  public SeqData move(int input, int arrLength) {
    if(input > arrLength) input -= arrLength;
    return new SeqData(input, this.seqLength);
  }

  public SeqData correctToOffset(float offset, int refLength) {
    int row = imgSource.row;
    int pos2d[] = Utils.get2dPos(this.seqStart, refLength);
    int jDiff = int(pos2d[1] % offset);
    int iDiff = int(pos2d[0] % offset);
    int shiftLength = 0;
    if (jDiff != 0) shiftLength -= jDiff;
    if (iDiff != 0) shiftLength -= row * iDiff;
    return new SeqData(this.seqStart + shiftLength, this.seqLength);
  }
};

public class MappingData {
  int[] mScale; // defines scale
  int[] scaleRange;
  int[] octRange;
  int key;
  String[] chromaticNotes = new String[]{"C", "C#", "D", "E#", "E", "F", "F#", "G", "G#", "A", "Bb", "B"};

  public MappingData(int[] mScale, int scaleDiv, int octDiv, String key) {
    this.mScale = mScale;
    
    int[] scaleRange = new int[scaleDiv];
    for (int i = 0; i < scaleDiv; i++) {
      scaleRange[i] = 360 * i / scaleDiv;
    }
    this.scaleRange = scaleRange;
    
    int[] octRange = new int[octDiv];
    for (int i = 0; i < octDiv; i++) {
      octRange[i] = 100 * i/octDiv;
    }
    this.octRange = octRange;
    println(octRange);
    
    int numKey = 0;
    for (int i = 0; i < chromaticNotes.length; i++) {
      if (key == chromaticNotes[i]) {
        numKey = i;
        break;
      }
    }
    this.key = numKey;
  }

  public String getNotes(int step) {
    step %= mScale.length;
    int note = mScale[step] + key;
    note %= chromaticNotes.length;
    String notes = chromaticNotes[note];
    return notes;
  }
  
  public int getBaseNote(){
    int middleC = Note.NOTE_C2;
    return middleC + key;
  }
};

public class ScaleData{
  String name;
  int[] notes;
  
  public ScaleData(String name, int[] notes){
    this.name = name;
    this.notes = notes;
  }
}
