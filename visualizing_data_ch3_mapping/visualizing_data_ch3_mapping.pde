PImage mapImage; //Background map image
Table locationTable; //Contains location data
int rowCount; //Number of rows in locationTable
Table dataTable; //Contains data that we draw
float dataMin = MAX_FLOAT; //Smallest number in data
float dataMax = MIN_FLOAT; //Largest number in data

void setup(){
  size(640, 400);
  
  //background image of USA
  mapImage = loadImage("map.png");
  
  //location table from file that contains coordinates of each state
  locationTable = loadTable("locations.tsv", "tsv");
  
  //Will use row count a lot, so store it globally
  rowCount = locationTable.getRowCount();
  
  //Read the data table
  dataTable = loadTable("random.tsv", "tsv");
  
  //Find max and min values in data
  for (int row = 0; row < rowCount; row++){
    float value = dataTable.getFloat(row, 1); //column 1
    if (value > dataMax) dataMax = value;
    if (value < dataMin) dataMin = value;
  }
}

void draw(){
  background(255);
  image(mapImage, 0, 0); //background map
  
  //Drawing attributes for ellipses
  smooth();
  fill(192, 0, 0); //Red
  noStroke();
  
  //Loop through rows of locations.tsv and draw the points
  for (int row = 0; row < rowCount; row++){
     String abbrev = dataTable.getString(row, 0); //"Key" in 1st column
     float  value  = dataTable.getInt(row, 1); //Value of data to plot
     
     TableRow currentRow = locationTable.findRow(abbrev, 0); //Find row in other column
     
     float x = currentRow.getFloat(1); //column 1
     float y = currentRow.getFloat(2); //column 2
     drawData(x, y, value);
  } 
}

//Map the size of ellipse to the data value
void drawData(float x, float y, float value){
 //Re-map the value to a number between 2 and 40
 float mapped = map(value, dataMin, dataMax, 2, 40);
 //Draw a circle with this item
 ellipse(x, y, mapped, mapped);
  
}