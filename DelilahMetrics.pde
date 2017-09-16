// grab aws metrics and display them / save as a pdf
// acd 2017

static final int BORDER = 100;

import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

Dataset dataset1;
Dataset dataset2;
Dataset dataset3;
float x_size;
float l_max, r_max;
PFont labelFont;

void setup() {
  size(1000, 800);
  dataset1 = new Dataset("input1.json");
  dataset2 = new Dataset("input2.json");
  dataset3 = new Dataset("input3.json", dataset2);  // additive
  x_size = dataset1.size();
  l_max = 100; //dataset.max;
  r_max = 1000;
  labelFont = createFont("Courier", 15);
  noLoop();
}

void draw() {
  background(255);
  
  // axes
  stroke(0);
  strokeWeight(3);
  line2(0, 0, x_size, 0, x_size, l_max);
  line2(0, 0, 0, l_max, x_size, l_max);
  strokeWeight(1);
  dataset1.drawXAxis(x_size);

  // data
  dataset1.draw(#ff8000, r_max);
  dataset2.draw(#00ff00, l_max);
  dataset3.draw(#0000ff, l_max);
  
  String filename = "delilah_metrics_" + year() + nf(month(), 2) + nf(day(), 2) + ".png";
  println(filename);
  save(filename);
}

float mapX(float x, float max) {
  return map(x, 0, max, BORDER, width - BORDER);
}

float mapY(float y, float max) {
  return map(y, 0, max, height - BORDER, BORDER);
}

float dataMax;
int dataSize;

class Dataset {
  
  TreeMap<String, Float> points = new TreeMap<String, Float>();
  float max = 0;;

  // load data from file
  Dataset(String filename) {
    this(filename, null);
  }
  
  // load data from file and add on the other dataset
  Dataset(String filename, Dataset dataset) {
    JSONObject json = loadJSONObject(filename);
    // data is an array called datapoints
    JSONArray data = json.getJSONArray("Datapoints");
    for (int i = 0 ; i < data.size() ; i++) {
      JSONObject obj = (data.getJSONObject(i));
      float a = obj.getFloat("Average");
      String t = obj.getString("Timestamp");
      if (a > max) {
        max = a;
      }
      if (dataset == null) {
        points.put(t, a);
      } else {
        // add on the value from the passed in dataset
        points.put(t, a + dataset.points.get(t));
      }
    }
  }
  
  int size() {
    return points.size();
  }

  float max() {
    return max;
  }

  void draw(color colour, float max) {
    stroke(colour);
    strokeWeight(5);
    Float[] list = points.values().toArray(new Float[0]);
    for (int i = 0 ; i < size() - 1 ; i++) {
      line2(i, list[i], i + 1, list[i + 1], size(), max);
    }
  }
  
  // draws the labels on the x axis
  void drawXAxis(float max) {
    String[] list = points.keySet().toArray(new String[0]);
    stroke(0);
    fill(0);
    textFont(labelFont);
    for (int i = 0 ; i < size() ; i++) {
      float x = mapX(i, max);
      float y = height - BORDER + 10;
      String time = list[i].substring(11, 16);
      if (time.endsWith(":00")) {
        line(x, y - 10, x, BORDER);
        pushMatrix();
        translate(x, y);
        rotate(radians(90));
        text(time, 0, 0);
        popMatrix();
      }
    }
  }
}  

void line2(float x0, float y0, float x1, float y1, float size, float max) {
  float x00 = mapX(x0, size);
  float y00 = mapY(y0, max);
  float x10 = mapX(x1, size);
  float y10 = mapY(y1, max);
  line(x00, y00, x10, y10);
}