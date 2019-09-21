import processing.video.*;
import oscP5.*;
import netP5.*;

int numPixels;

float result;

int squareWidth = 640 / 10;
int squareHeight = 480 / 10;

int numHoriz = 640/squareWidth;
int numVert = 480/squareHeight;

color[] squares = new color[numHoriz * numVert];

Capture video;

OscP5 oscP5;
NetAddress dest;

void setup() {
  size(640, 480);
  
  String[] cameras = Capture.list();

  if (cameras == null) { 
    println("Failed to retrieve the list of available cameras, will try the default...");
    video = new Capture(this, 640, 480);
  } 

  video = new Capture(this, 640, 480);
  video.start();

  oscP5 = new OscP5(this, 12000);
  dest = new NetAddress("127.0.0.1", 6448);
}

void draw() {

  if (video.available() == true) {
    video.read();

    video.loadPixels(); // Read the pixels of video

    int squareNum = 0;
    int pixelsInASquare = squareWidth*squareHeight;
    for (int x = 0; x < 640; x += squareWidth) {

      for (int y = 0; y < 480; y += squareHeight) {
        float red = 0, green = 0, blue = 0;

        // Calculate the rgb values for each entire square 
        for (int i = 0; i < squareWidth; i++) {
          for (int j = 0; j < squareHeight; j++) {
            int index = (x + i) + (y + j) * 640;
            red += red(video.pixels[index]);
            green += green(video.pixels[index]);
            blue += blue(video.pixels[index]);
          }
        }

        squares[squareNum] =  color(red/pixelsInASquare, green/pixelsInASquare, blue/pixelsInASquare);

        fill(squares[squareNum]);

        int index = x + 640*y;
        red += red(video.pixels[index]);
        green += green(video.pixels[index]);
        blue += blue(video.pixels[index]);

        rect(x, y, squareWidth, squareHeight);
        squareNum++;
      }
    }

    sendOsc(squares);
  }

  fill(0, 33, 222); // The curtains are blue

  result = (abs(result));

  rect(0, 0, 640 / 2 * result, 480); // <-- Left curtain
  rect(640 - (640 / 2 * result), 0, 640, 480); // <-- Right curtain
}

void sendOsc(int[] squares) {
  OscMessage msg = new OscMessage("/wek/inputs");
  for (int i = 0; i < squares.length; i++) {
    msg.add(abs(float(squares[i])) / 1000);
  }
  oscP5.send(msg, dest);
}

void oscEvent(OscMessage message) {
  result = message.get(0).floatValue();
}
