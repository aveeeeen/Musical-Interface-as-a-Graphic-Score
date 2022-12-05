
public static class Utils {
  //  transforms 2d array to 1d array
  // array[][] -> array[]

  public static color[] arr2dToArr1d(color[][] input) {
    int arr_length = floor(sqrt(input.length*input.length));
    color[] arr1d = new color[input.length*input.length];

    for (int i = 0; i < arr_length; i++) {
      for (int j = 0; j < arr_length; j++) {
        arr1d[j + i * arr_length] = input[i][j];
      }
    }
    return arr1d;
  }

  // transforms 1d array to 2d array
  // array[] -> array[][]


  public static color[][] arr1dToArr2d(color[] input) {
    int arr_length = floor(sqrt(input.length));
    color[][] arr2d = new color[arr_length][arr_length];

    for (int i = 0; i < arr_length; i++) {
      for (int j = 0; j < arr_length; j++) {
        arr2d[i][j] = input[j + i * arr_length] ;
      }
    }
    return arr2d;
  }

  // get coordinates from 1d position
  // int, columnLength -> int[]

  public static int[] get2dPos(int pos1d, int columnLength) {
    int[] returnPos = new int[2];
    returnPos[1] = pos1d % columnLength;
    returnPos[0] = floor(pos1d / columnLength);
    return returnPos;
  }

  //  This gets the image data from the refered data and extract values starting from a specific index of the refered data
  //  refered_data[] index -> return_data[specific length]

  public static color[] extractImgData1d(color[] refered_data, SeqData seq, float offset) {
    int start = seq.seqStart;
    color[] return_data = new color[seq.seqLength];
    color[][] data2d = arr1dToArr2d(refered_data);
    int reflen = refered_data.length;
    int refcol = floor(sqrt(reflen));
    while (start > reflen - 1) start -= reflen;
    int pos2d[] = get2dPos(start, refcol);
    for (int i = 0; i < seq.seqLength; i++) {
      int indexI = floor(pos2d[1] + i * offset);
      int indexJ = floor(pos2d[0] + offset - 1);
      while (indexI > refcol -1) {
        indexI -= refcol;
        indexJ += offset;
      };
      while (indexJ > refcol - 1) indexJ -= refcol;
      return_data[i] = data2d[indexJ][indexI];
    };
    return return_data;
  };


  public static color[] extractImgData2d(color[] refered_data, SeqData seq, float offset) {
    int columnLength = floor(sqrt(seq.seqLength));
    int start = seq.seqStart;
    color[][] data2d = arr1dToArr2d(refered_data);
    color[] return_data = new color[seq.seqLength];
    int reflen = refered_data.length;
    int refcol = floor(sqrt(refered_data.length));
    while (start > reflen - 1) start -= reflen;
    int[] pos2d = get2dPos(start, refcol);

    for (int i = 0; i < columnLength; i++) {
      for (int j = 0; j < columnLength; j++) {
        int indexI = floor(pos2d[0] + i * offset);
        int indexJ = floor(pos2d[1] + j * offset);
        while (indexJ > refcol - 1) {
          indexI += 1;
          indexJ -= refcol;
        }
        while (indexI > refcol - 1) indexI -= refcol;
        return_data[j+i*columnLength] = data2d[indexI][indexJ];
      };
    };
    return return_data;
  };


  public static float foldPointX(float edgeOfX, float x) {
    if (x > edgeOfX) x -= edgeOfX;
    if (x < 0) edgeOfX -= x;
    return x;
  };

  public static float foldPointY(float edgeOfY, float y) {
    if (y > edgeOfY) y -= edgeOfY;
    if (y < 0) edgeOfY -= y;
    return y;
  };
};



public void printMatrix(color[] arr, color[] markers) {
  int colLength = int(sqrt(arr.length));
  println("colLength: " + colLength);
  color[][] arr2d = Utils.arr1dToArr2d(arr);

  for (int i = 0; i < colLength; i++) {
    for (int j = 0; j < colLength; j++) {
      boolean match = false;
      for (int k = 0; k < markers.length; k++) {
        if (arr2d[i][j] == markers[k]) match = true;
      };
      if (match) {
        print("[" + numPrint(arr2d[i][j]) + "]");
      } else {
        print(" " + numPrint(arr2d[i][j]) + " ");
      };
    };
    print("\n");
  };
}

public String numPrint(color input) {
  String retStr = "0000";
  char[] str = retStr.toCharArray();
  int brightness = round(brightness(input));
  String numStr = String.valueOf(brightness);
  for (int i = 0; i < numStr.length(); i++) {
    int index = numStr.length() - 1 - i;
    str[retStr.length() - 1 - i] = numStr.charAt(index);
  };
  return retStr = String.valueOf(str);
};

public void consoleOut() {
  String spacer = "\n==========================================================\n";
  color[] arr1d = Utils.arr2dToArr1d(tempC);
  color[] seqColor = seq[0].seqimg.seqRGB;
  println(spacer);

  println("tempC width: " + tempC.length);
  println("arr1d lenght: " + arr1d.length);
  println("seqColor width: " + seqColor.length);
  println("seqStart: " + seq[0].seqdata.seqStart);

  printMatrix(arr1d, seqColor);
  println(spacer);
}

public color inverseColor(color c) {
  float hue = hue(c);
  float sat = saturation(c);
  float bri = brightness(c);

  hue = hue - 180;
  if (hue < 0) hue = 360 - hue;
  sat = 100 - sat;
  bri = 100 - bri;
  c = color(0, 0, bri);
  return c;
}

void highlightText(String text, float x, float y, int size, color c, color hc) {
  String[] eachString = extractLines(text);
  float scalar = 6.0;
  for (int i = 0; i < eachString.length; i++) {
    float w = textWidth(eachString[i]);
    float h = textDescent() * scalar;
    noStroke();
    fill(hc);
    rect(x, y + h * i, w, h);
    textSize(size);
    textAlign(LEFT, TOP);
    fill(c);
    text(eachString[i], x, y + h * i);
  }
}

void plainText(String text, float x, float y, int size, color c) {
  String[] eachString = extractLines(text);
  float scalar = 6.0;
  for (int i = 0; i < eachString.length; i++) {
    float h = textDescent() * scalar;
    textSize(size);
    textAlign(LEFT, TOP);
    fill(c);
    text(eachString[i], x, y + h * i);
  }
}

void highlightBooleanText(String text, float x, float y, int size, color c) {
  String[] eachString = extractLines(text);
  float scalar = 6.0;
  //println(eachString.length);
  for (int i = 0; i < eachString.length; i++) {
    color hc = color(0, 100, 50);
    float w = textWidth(eachString[i]);
    float h = textDescent() * scalar;
    if (eachString[i].contains("true")) hc = color(100, 100, 50);
    if (eachString[i].contains("false")) {
      float strW = textWidth("false");
      noStroke();
      fill(hc);
      rect(x + w - strW, y + h * i, strW, h);
    }
    if (eachString[i].contains("true")) {
      float strW = textWidth("true");
      noStroke();
      fill(hc);
      rect(x + w - strW, y + h * i, strW, h);
    }
    textSize(size);
    textAlign(LEFT, TOP);
    fill(c);
    text(eachString[i], x, y + h * i);
  }
}

public String[] extractLines(String text) {
  String[] eachString = text.split("\n|\r");
  return eachString;
}

public float collide(float input, float min, float max, float collideOffset) {
  while (input < min - collideOffset) input = input + max;
  while (input > max + collideOffset) input -= max;
  return input;
}
