Grid grid;
ArrayList<Biome> biomes;

int GRID_SIZE = 10;

boolean drawGrid = false;
boolean drawPerlin = false;
boolean drawBiome = true;
boolean drawHumidity = false;
float heat = 0.0;
float precipitation = 0.5;
float seasonalIncrement = 0.005;


void setup() 
{
  size(800, 600);
  colorMode(RGB, 255);  
  noStroke();
  background(255,255, 255);
  noiseDetail(10);
  noiseSeed(4);
  
  //biomes = generateBiomes();
  
  //grid = new Grid(GRID_SIZE, new AStar<GridPoint>(new Manhattan()), biomes);

  //noLoop();
}

void draw() 
{
  
  heat = heat+seasonalIncrement;
  seasonalIncrement = (heat > 1 || heat < 0) ? seasonalIncrement*-1 : seasonalIncrement;
  heat = Math.max(heat+seasonalIncrement, 0);
  
  biomes = generateBiomes();
  grid = new Grid(GRID_SIZE, new AStar<GridPoint>(new Manhattan()), biomes);
  
  background(255, 255, 255);
  
  if(drawPerlin){ //<>//
    grid.drawAltitude();
  }
  if(drawBiome){
    grid.drawBiome();
  }
  if(drawGrid){
    grid.drawGrid();
  }
  if(drawHumidity){
    grid.drawHumidity();
  }
  //grid.drawOutEdges();
}
