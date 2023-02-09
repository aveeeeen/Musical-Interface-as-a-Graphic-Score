public class MasterImg {
  PImage imgSource;
  float pixSize;
  float ratio;
  float imgRatio;
  float mosaicRatio;
  float canvasWidth;
  float canvasHeight;
  int col, row;
  float xOffset;
  float yOffset;
  float imgXOffset;
  float imgYOffset;
  color[][] imgC;
  float canvasX;
  float canvasY;

  public MasterImg(float canvasWidth, float canvasHeight, int col, int row, PImage imgSource) {
    this.col = col;
    this.row = row;
    this.canvasWidth = canvasWidth;
    this.canvasHeight = canvasHeight;
    this.imgSource = imgSource;

    this.ratio = canvasWidth/canvasHeight;
    this.imgRatio = imgSource.width/imgSource.height;

    //mosaicRatio = (float)col/(float)row;

    this.xOffset = imgSource.width/col;
    this.yOffset = imgSource.height/row;

    this.imgXOffset = canvasWidth % col;
    this.imgYOffset = canvasHeight % row;

    if (imgXOffset == 0.0) imgXOffset = col;
    float pixOffset = imgXOffset/col;
    this.pixSize = canvasWidth/col;
    //if (canvasWidth%2 == 0) this.pixSize = canvasWidth/col;
    
    this.imgC = new color[col][row];

    println("img size: " + imgSource.width  + " * " + imgSource.height );
    println("canvas ratio: " + ratio);
    println(imgRatio + "image ratio");
    println(imgXOffset + "imgOffset");
    println("pixSize: " + pixSize);

    //img data extraction/transformation
    for (int i = 0; i < row; i ++ ) {
      for (int j = 0; j < col; j ++ ) {
        int x = floor(j*xOffset);
        int y = floor(i*yOffset);
        int w = imgSource.width;
        int h = imgSource.height;
        int index = x + y * (w);

        if (index < 0) index *= -1;
        while (index > imgSource.pixels.length - 1) index = index - (imgSource.pixels.length - 1);
        imgC[i][j] = imgSource.pixels[index];
      }
    }
  }

  public void setPlacement(float x, float y) {
    this.canvasX = x;
    this.canvasY = y;
  }

  public color[][] getColor() {
    return this.imgC;
  }

  public float getPixSize() {
    return this.pixSize;
  }
}
