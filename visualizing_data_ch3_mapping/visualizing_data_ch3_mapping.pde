PImage mapImage; //Background map image

Table locationTable; //Contains state location master data
Table dataTable; //Contains data that we draw
Table nameTable; //State abbrevs and their full names

int rowCount; //Number of rows in dataTable
float dataMin = MAX_FLOAT; //Smallest number in data
float dataMax = MIN_FLOAT; //Largest number in data

float closestDist;
String closestText;
float closestTextX;
float closestTextY;

void setup(){
  size(640, 400);
  
  //background image of USA
  mapImage = loadImage("map.png");
  
  //location table from file that contains coordinates of each state
  locationTable = loadTable("locations.tsv", "tsv");
  
  //Read the data table
  dataTable = loadTable("random.tsv", "tsv");
  
  //Will use row count a lot, so store it globally
  rowCount = dataTable.getRowCount();
  
  //Find max and min values in data
  for (int row = 0; row < rowCount; row++){
    float value = dataTable.getFloat(row, 1); //column 1
    if (value > dataMax) dataMax = value;
    if (value < dataMin) dataMin = value;
  }
  
  //Load font for tooltips from file
  PFont font = loadFont("Courier-Bold-12.vlw");
  textFont(font); //Set current font
  
  nameTable = loadTable("names.tsv", "tsv");
}

void draw(){
  background(255);
  image(mapImage, 0, 0); //background map
  
  closestDist = MAX_FLOAT; //Used for drawing tooltips
  
  //Drawing attributes for ellipses
  smooth();
  //fill(192, 0, 0); //Red
  noStroke();
  
  //For every data point in dataTable
  for (int row = 0; row < rowCount; row++){
     //Grab key, value for every data point... and
     String abbrev = dataTable.getString(row, 0); //"Key" in 1st column
     float  value  = dataTable.getInt(row, 1); //Value of data to plot
     
     //Look up their position
     TableRow locationRow = locationTable.findRow(abbrev, 0); //Find row in other column
     float x = locationRow.getFloat(1); //column 1
     float y = locationRow.getFloat(2); //column 2
     
     //Look up their names
     TableRow nameRow = nameTable.findRow(abbrev, 0);
     String name = nameRow.getString(1);
     
     //Draw the data point & set tooltip draw settings
     drawData(x, y, value, abbrev, name);
     
     //Use global vars set in drawData()
     //to draw text related to closest circle
     if (closestDist != MAX_FLOAT){
        fill(128);
        textAlign(CENTER);
        text(closestText, closestTextX, closestTextY);
     }
     
  } 
}

//Logic to draw each point & evaluate tooltip
void drawData(float x, float y, float value, String abbrev, String name){
 //Re-scale the value to a number between 1 and 20, for sizing
 float radius = map(value, dataMin, dataMax, 1, 20);
 
 //Interpolate between two colors
 float percent = norm(value, dataMin, dataMax); //Normalise between 0 and 1
 //HSB = Hue Saturation Brightness
 color between = lerpColor(#296F34, #61E2F0, percent, HSB); //Interpolate between blue and green
 
 //Draw a colored circle with this item
 fill(between);
 ellipseMode(RADIUS);
 ellipse(x, y, radius, radius);
 
 //Evaluate whether tooltip should be drawn
 float d = dist(x, y, mouseX, mouseY);
 
 if ((d < radius + 2) && (d < closestDist)){
   closestDist = d;
   closestText = name + " (" + value + ")";
   closestTextX = x;
   closestTextY = y - radius - 4;
 }  
  
}