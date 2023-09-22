import java.util.Map;

class GridPoint{
  PVector normalized;
  int x;
  int y;
  PVector location;
  NoiseValues noiseValues;
  boolean river;
  Biome biome;
  boolean bridge;
  
  int gridSize;
  
  
  GridPoint (int x, int y, int gridSize){
    this.x = x;
    this.y = y;
    this.location = new PVector(x, y);
    this.gridSize = gridSize;
    this.noiseValues = new NoiseValues();
  }

  void renderGrid(){
    //render grid    
    rectMode(CENTER);
    stroke(0,0,0);
    noFill();
    square(x, y, gridSize);
  }
  
  void renderAltitude(){
    rectMode(CENTER);
    noStroke();
    
    fill(noiseValues.altitude * 255);
    square(x, y, gridSize);
  }
  
  void renderHumidity(){
    rectMode(CENTER);
    noStroke();
    
    fill(noiseValues.humidity * 255);
    square(x, y, gridSize);
  }
  
  void renderBiome(){
    rectMode(CENTER);
    noStroke();
    if(biome != null){
      if(river){
        fill(biome.riverR, biome.riverG, biome.riverB);
      }else{
        fill(biome.r, biome.g, biome.b);
      }
      
    }else{
      fill(0);
    }
    
    square(x, y, gridSize);
  }
  
  void projectPerlin(float[][] perlinMap){
    this.noiseValues.altitude = perlinMap[y/gridSize][x/gridSize];
  }
  
  void projectValueNoise(float[][] valueNoiseMap){
    this.noiseValues.humidity = valueNoiseMap[y/gridSize][x/gridSize];
  }
}

class NoiseValues{
  //perlin
  float altitude;
  float humidity;
  
  public void generateAltitude(float x, float y){
    this.altitude = noise(x, y);
    this.humidity = 0.0f;
  }
}

ArrayList<GridPoint> createGrid(int interval){
  ArrayList<GridPoint> grid = new ArrayList();
  for(int x = 0; x <= width; x++){
    for(int y = 0; y <= height; y++){
      if(x % interval == 0 && y % interval == 0){
        grid.add(new GridPoint(x, y, interval));
      }
    }
  }
  return grid;
}

class Grid{
  List<Node<GridPoint>> nodes;
  ArrayList<Biome> biomes;
  
  //used as start and goal for river
  Node<GridPoint> high;
  Node<GridPoint> low;
  
  Map<PVector, Node<GridPoint>> nodeMap;
  
  int gridSize;
  
  GraphSearch<GridPoint> search;
  
  Grid(int gridSize, GraphSearch search, ArrayList<Biome> biomes){
    this.gridSize = gridSize;
    this.search = search;
    this.biomes = biomes;
    nodeMap = new HashMap();
    generateNodes();
    createAltitude();
    createHumidity();
    matchBiomesToNodes();
    createEdges();
    createRiver();
  }
  
  void generateNodes(){
    nodes = new ArrayList();
    for(int x = 0; x <= width; x++){
      for(int y = 0; y <= height; y++){
        if(x % gridSize == 0 && y % gridSize == 0){
          Node<GridPoint> node = new Node(new GridPoint(x, y, gridSize));
          nodes.add(node);
          nodeMap.put(node.value.location, node);
        }
      }
    }
  }
  
  void createAltitude(){
    float[][] altMap = perlinMap();
    for(Node<GridPoint> node : nodes){
      node.value.projectPerlin(altMap);
    }
  }
  
  void createHumidity(){
    float[][] humidityMap = valueNoiseMap();
    for(Node<GridPoint> node : nodes){
      node.value.projectValueNoise(humidityMap);
    }
  }
  
  void createEdges(){
    //conect nodes - will first need to call perlin.
    PVector x = new PVector(gridSize, 0);
    PVector y = new PVector(0, gridSize);
    
    for(Node<GridPoint> node : nodes){
      //only create edge if moving down in biome type, create heirarchy.
      //+/- x
      if(nodeMap.get(PVector.add(node.value.location, x))!= null){
        Node<GridPoint> toNode = nodeMap.get(PVector.add(node.value.location, x));
        if(node.value.biome.flow(toNode.value.biome)){
          node.edgeTo(toNode, toNode.value.noiseValues.altitude);
        }
      }
      if(nodeMap.get(PVector.sub(node.value.location, x))!= null){
        Node<GridPoint> toNode = nodeMap.get(PVector.sub(node.value.location, x));
        if(node.value.biome.flow(toNode.value.biome)){
          node.edgeTo(toNode, toNode.value.noiseValues.altitude);
        }
      }
      //+/- y
      if(nodeMap.get(PVector.add(node.value.location, y))!= null){
        Node<GridPoint> toNode = nodeMap.get(PVector.add(node.value.location, y));
        if(node.value.biome.flow(toNode.value.biome)){
          node.edgeTo(toNode, toNode.value.noiseValues.altitude);
        }     
      }
      if(nodeMap.get(PVector.sub(node.value.location, y))!= null){
        Node<GridPoint> toNode = nodeMap.get(PVector.sub(node.value.location, y));
        if(node.value.biome.flow(toNode.value.biome)){
          node.edgeTo(toNode, toNode.value.noiseValues.altitude);
        }
      }
    }
  }
  
  void matchBiomesToNodes(){
    for(Node<GridPoint> node : nodes){
      for(Biome biome : biomes){
        if(biome.matcheBiome(node.value.noiseValues.altitude, node.value.noiseValues.humidity)){
          node.value.biome = biome;
          break;
        }
      }
    }
  }

  void createRiver(){
    //this will be a find shortest path with search - then set those nodes to true - combine search and shortest path method
    //find high and low
    high = nodes.get(0);
    low = nodes.get(0);
    for(Node<GridPoint> node: nodes){
      if(high.value.noiseValues.altitude < node.value.noiseValues.altitude){
        high = node;
      }
      if(low.value.noiseValues.altitude > node.value.noiseValues.altitude){
        low = node;
      }
    }
    high.value.river = true;
    low.value.river = true;
    
    search.reset(high, low);
    List<Edge<GridPoint>> path = search.findPath();
    if(path != null){
      for(Edge<GridPoint> edge : path){
        edge.end.value.river = true;
        edge.start.value.river = true;
      }
    }
  }
  
  void drawGrid(){
    for(Node<GridPoint> node : nodes){
      node.value.renderGrid();
    }
  }
  
  void drawAltitude(){
    for(Node<GridPoint> node : nodes){
      node.value.renderAltitude();
    }
  }
  
  void drawHumidity(){
    for(Node<GridPoint> node : nodes){
      node.value.renderHumidity();
    }
  }
  
  void drawBiome(){
    for(Node<GridPoint> node : nodes){
      node.value.renderBiome();
    }
  }
  
  void drawOutEdges(){
    stroke(1);
    stroke(222, 58, 33);
    for(Node<GridPoint> node : nodes){
      for(Edge<GridPoint> edge : node.out){
        line(edge.start.value.x, edge.start.value.y, edge.end.value.x, edge.end.value.y);
      }
    }
  }
  

}
  
