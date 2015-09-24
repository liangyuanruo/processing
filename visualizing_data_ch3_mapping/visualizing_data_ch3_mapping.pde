PImage mapImage; //Background map image

Table locationTable; //Contains state location master data
Table dataTable; //Contains data that we draw
Table nameTable; //State abbrevs and their full names

int rowCount; //Number of rows in dataTable
float dataMin = -10;
float dataMax = 10;

Integrator[] interpolators; //Used for transitions

void setup(){
  size(640, 400);
  
  mapImage = loadImage("map.png");
  locationTable = loadTable("locations.tsv", "tsv");
  dataTable = loadTable("random.tsv", "tsv");
  nameTable = loadTable("names.tsv", "tsv");
  
  rowCount = dataTable.getRowCount();

  initIntegrator();

  PFont font = loadFont("Courier-12.vlw");
  textFont(font); //Set current font
  
  smooth(); noStroke();
  
  frameRate(60);
}

void initIntegrator(){
  interpolators = new Integrator[rowCount];
  for (int row = 0; row < rowCount; row++){
    float initialValue = dataTable.getFloat(row, 1);
    interpolators[row] = new Integrator(initialValue, 0.5, 0.2);
  }
}

//Vars to detect mouse position
float closestDist;
String closestText;
float closestTextX;
float closestTextY;

void draw(){
  background(255);
  image(mapImage, 0, 0); //background map
  
  // Update Integrator w current values, which are
  // either those loaded from setup() or those loaded by
  // target() function issued in updateTable()
  for (int row = 0; row < rowCount; row++){
     interpolators[row].update(); 
  }
  
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
     drawData(x, y, row, abbrev, name);
     
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
void drawData(float x, float y, int row, String abbrev, String name){
  
 //Get current value from Integrator
 float value = interpolators[row].value;
 
 //Calculate relevant radius to draw
 float radius = 0;
 if (value >= 0){
   radius = map(value, 0, dataMax, 1.5, 15);
   //fill(#4422CC); //blue
 } else{
   radius = map(value, 0, dataMin, 1.5, 15);
   //fill(#FF4422); //red
 }

 //Determine color
 float percent = norm(value, dataMin, dataMax); //Normalise between 0 and 1
 //HSB = Hue Saturation Brightness
 color between = lerpColor(#296F34, #61E2F0, percent, HSB); //Interpolate between blue and green
 
 //Draw a circle with calculated size/color
 fill(between, 175); //175: tranparency 0-255
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

void keyPressed(){
 if (key == ' '){ //Spacebar
   updateTable();
 }
}

//Refresh data in dataTable
void updateTable(){
   for (int row = 0; row < rowCount; row++){
    float rand = random(dataMin, dataMax);
    interpolators[row].target(rand);
   }
   
}