//This code creates a time series line chart

FloatTable data;
int rowCount;
float dataMin, dataMax;
int volumeInterval = 10; //For y axis
int volumeIntervalMinor = 5;

int yearMin, yearMax;
int[] years;
int yearInterval = 10; //For x axis

Integrator interpolators[];

//Plotting bounds
float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

//Interactivity
int currentColumn = 0;
int columnCount;
float[] tabLeft, tabRight;
float tabTop, tabBottom;
float tabPad = 10;

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
  
  interpolators = new Integrator[rowCount];
  for (int row = 0; row < rowCount; row++){
     float initialValue = data.getFloat(row, 0);
     interpolators[row] = new Integrator(initialValue);
     interpolators[row].attraction = 0.1; //Set lower than default (0.2)
  }
  
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
  
  //drawTitle();
  drawTitleTabs();
  drawAxisLabels();
  drawVolumeLabels();
  drawYearLabels();
  
  //Update the Integrators
  for (int row = 0; row < rowCount; row++)
    interpolators[row].update();
  
  //drawDataLine(currentColumn);
  //drawDataCurve(currentColumn);
  drawDataArea(currentColumn);
  drawDataHighlight(currentColumn);
}

void drawTitle(){
  fill(0);
  textSize(20); textAlign(LEFT);
  String title = data.getColumnName(currentColumn);
  text(title, plotX1, plotY1 - 25);
}

void drawTitleTabs(){
 
  rectMode(CORNERS);
  noStroke();
  textSize(20);
  textAlign(LEFT);
  
  //On first use of this method, allocate space for an array
  //to store the values for the left and right edges of the tabs
  if (tabLeft == null){
    tabLeft = new float[columnCount];
    tabRight = new float[columnCount];
  }
  
  float runningX = plotX1;
  tabTop = plotY1 - textAscent() - 15;
  tabBottom = plotY1;
  
  for (int col = 0; col < columnCount; col++){
     
    String title = data.getColumnName(col);
    tabLeft[col] = runningX;
    float titleWidth = textWidth(title);
    tabRight[col] = tabLeft[col] + tabPad + titleWidth + tabPad;
    
    //If current tab selected, set background white, else use pale grey
    fill(col == currentColumn ? 255 : 224);
    rect(tabLeft[col], tabTop, tabRight[col], tabBottom);
    
    //If current tab selected, use black as text, else use dark grey
    fill(col == currentColumn ? 0 : 64);
    text(title, runningX + tabPad, plotY1 - 10);
    
    runningX = tabRight[col];
  }
  
}

void drawAxisLabels(){
  fill(0); textSize(13); textLeading(15);
  
  textAlign(CENTER, CENTER);
  text("Gallons\nconsumed\nper capita", labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Year", (plotX1+plotX2)/2, labelY);
  
}


//Draw the data as a series of points
void drawDataHighlight(int col){

  for (int row = 0; row < rowCount; row++){
     if (data.isValid(row, col)){
       //float value = data.getFloat(row, col);
       float value = interpolators[row].value;

       float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
       float y = map(value, dataMin, dataMax, plotY2, plotY1);
       strokeWeight(5);
       stroke(#5679C1);
       point(x, y);
       
       //Mouseover highlight + text
       if (dist(mouseX, mouseY, x, y) < 3){
          strokeWeight(10);
          point(x, y);
          fill(0); textSize(10); textAlign(CENTER);
          text(nf(value, 0, 2) + " (" + years[row] + ")", x, y-8);
       }
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

//Draw the data as a series of lines
void drawDataCurve(int col){
  noFill();
  beginShape();
  strokeWeight(2);
  stroke(#5679C1,128); //transparent
  for (int row = 0; row < rowCount; row++){
     if (data.isValid(row, col)){
       float value = data.getFloat(row, col);
       float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
       float y = map(value, dataMin, dataMax, plotY2, plotY1);
       curveVertex(x,y);
       
       //Double curve points for start and stop
       if ( row == 0 || row == row-1 ) curveVertex(x, y);
     }
     
  }
  endShape();
}

//Draw the data as an area chart
void drawDataArea(int col){
 fill(#5679C1,128); //transparent
  beginShape();
  for (int row = 0; row < rowCount; row++){
     if (data.isValid(row, col)){
       //float value = data.getFloat(row, col);
       float value = interpolators[row].value;
       float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
       float y = map(value, dataMin, dataMax, plotY2, plotY1);
       vertex(x,y);
       
       //Double curve points for start and stop
       if ( row == 0 || row == row-1 ) vertex(x, y);
     }
  }
  //Draw lower left & lower right corners
  vertex(plotX2, plotY2);
  vertex(plotX1, plotY2);
  endShape(CLOSE);
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
 
void mousePressed(){
   //User selecting panes
   if (mouseY > tabTop && mouseY < tabBottom){ //If click was between top/bottom of pane
      for (int col = 0; col < columnCount; col++){ //Check each pane in turn
         if (mouseX > tabLeft[col] && mouseX < tabRight[col]){ //If click between left/right of pane
            setColumn(col); 
         }
      }
   }
}

void setColumn(int col){
   if (col != currentColumn) currentColumn = col;
   
   for (int row = 0; row < rowCount; row++){
      interpolators[row].target( data.getFloat(row,col) ); 
   }
}