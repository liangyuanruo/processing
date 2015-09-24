//Data
FloatTable data;
int rowCount;
float dataMin, dataMax;
int volumeInterval = 10; //For y axis
int volumeIntervalMinor = 5;

int yearMin, yearMax;
int[] years;
int yearInterval = 10; //For x axis

//Plotting bounds
float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int currentColumn = 0;
int columnCount;

PFont plotFont;

void setup(){
  
  size(720, 405);
  
  /* Code to read data and set variables */
  //Use special FloatTable for faster data access
  data = new FloatTable("milk-tea-coffee.tsv");
  rowCount = data.getRowCount();
  columnCount = data.getColumnCount();
  
  //Get year array, min and max
  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length - 1];
  
  dataMin = 0;
  dataMax = ceil(data.getTableMax() / volumeInterval) * volumeInterval;
  
  /*Corners of plotted time series*/
  plotX1 = 120;
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;
  
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);
  
  smooth();
  
}

void draw(){
  background(224);
  
  //Show plot area as a white box
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);
  
  drawTitle();
  drawAxisLabels();
  drawVolumeLabels();
  drawYearLabels();
  drawDataLine(currentColumn);
  drawDataPoints(currentColumn);
}

void drawTitle(){
  fill(0);
  textSize(20); textAlign(LEFT);
  String title = data.getColumnName(currentColumn);
  text(title, plotX1, plotY1 - 25);
}

void drawAxisLabels(){
  fill(0); textSize(13); textLeading(15);
  
  textAlign(CENTER, CENTER);
  text("Gallons\nconsumed\nper capita", labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
  
}


//Draw the data as a series of points
void drawDataPoints(int col){
  strokeWeight(5);
  stroke(#5679C1);
  for (int row = 0; row < rowCount; row++){
     if (data.isValid(row, col)){
       float value = data.getFloat(row, col);
       float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
       float y = map(value, dataMin, dataMax, plotY2, plotY1);
       point(x,y);
       
     }
  }
}

//Draw the data as a series of lines
void drawDataLine(int col){
  noFill();
  beginShape();
  strokeWeight(2);
  stroke(#5679C1,128); //transparent
  for (int row = 0; row < rowCount; row++){
     if (data.isValid(row, col)){
       float value = data.getFloat(row, col);
       float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
       float y = map(value, dataMin, dataMax, plotY2, plotY1);
       vertex(x,y);
       
     }
  }
  endShape();
}

void drawYearLabels(){
  fill(0);
  textSize(10); textAlign(CENTER, TOP);
  
  //Use thin grey lines to draw a grid
  stroke(224); strokeWeight(1);
  
  for (int row = 0; row < rowCount; row++){
    if(years[row] % yearInterval == 0){
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + 10); //year label
      line(x, plotY1, x, plotY2); //grid
    }
  }
}

void drawVolumeLabels(){
  fill(0); textSize(10);
  stroke(128); strokeWeight(1);
  
  for (float v = dataMin; v <= dataMax; v += volumeIntervalMinor){
    if (v % volumeIntervalMinor == 0){ //If a tick mark
      float y = map(v, dataMin, dataMax, plotY2, plotY1);
      if (v % volumeInterval == 0){ //If major tick mark
        if(v == dataMin){
          textAlign(RIGHT); //Align by bottom
        }else if (v == dataMax){
          textAlign(RIGHT, TOP); //Align by top
        }else {
          textAlign(RIGHT, CENTER); //Centre vertically
        }
        text(floor(v), plotX1 - 10, y);
        line(plotX1 - 5, y, plotX1, y); //Draw major tick
      } else {
        line(plotX1 - 2, y, plotX1, y); //Draw minor tick
      }
    }
  }
}
  
void keyPressed(){
  if (key =='['){
    currentColumn--;
    if (currentColumn < 0) currentColumn = columnCount - 1;
  } else if (key == ']'){
    currentColumn++;
    if (currentColumn == columnCount) currentColumn = 0;
  }
}