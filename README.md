# Procedural_Map_Generation
 [In collaboration with Craig Cravath (sccravat@ncsu.edu) and Yi Li (yli273@ncsu.edu), CSC584, Department of Computer Science, North Carolina State University]

 Procedural content generation (PCG) is to generate game content programmatically through a procedural but random process. Therefore, the generated content is strictly within the game space, but also has unpredictable characteristics. This method not only brings many advantages to game developers: it reduces memory consumption and saves the time of manually producing highly repetitive content. It also brings many benefits to players: the overall content of the game is richer, the playability is improved, and there can be surprises from time to time. However, the PCG technology used in the game development process is mainly limited to certain specific types of game elements, and PCG is rarely deployed to generate the entire game.
 Our goal is to make a map generator using PCG technology. This map generator is based on a multi-layer structure. First, PCG is used to generate the bottom layer, and then following layers can be built on top of that.

 With the increasing complexity of game environments, it becomes expensive and extremely difficult to manually design the different components involved. Several games are based on map environments that the players can navigate. Generating these map environments involves creativity and randomness while maintaining feasibility for navigation and coherence in terms of landscape and terrain. For games with less complexity, human designers could script the map environments with manual specifications. However, for more complicated game environments, such as games with potentially infinite levels of difficulty, it is not feasible to hand-code these environments. Instead, we turn to machines for automated content generation, simulating human understanding and creativity.

 ## Problem Statement
 Our goal is to create a tool that leverages different techniques and takes varying parameters to procedurally generate different map environments. We will provide varying input parameters that will impact the map’s terrain and biome. Once these maps are created they can be used as building blocks for further game development. 

 ## Tasks and Techniques
 The project focuses on automated 2D map generation, utilizing various computer graphic techniques and procedural algorithms. By layering outputs from different techniques, a complex bird’s-eye view landscape is created. The core data structure is a graph, paired with tile visuals. With the map generation being hierarchical, individual graphs temporarily store parameters for each layer. For instance, the base layer holds cell location data, while the second layer, Perlin Noise, contains cell height info. Future work aims to optimize performance and storage, intending to consolidate multi-layered graph expressions into one. Users can view the final map or visualize specific layer parameters, aiding in testing and troubleshooting.

 ### Grid Creation
 Our map starts with an n×n grid base layer, using a scalable tile representation. Unique zoom features enhance both size and detail, with altitude-influenced edges directing from high to low points.

 <p align="center">
   <img width="700" alt="Base Grid" src="https://github.com/atpugs/Procedural_Map_Generation/assets/31329834/223908ac-6d21-4d7d-afae-2cc982ea4ae8">
 </p>

 ### Perlin Noise
 Perlin Noise provides a realistic landscape elevation, avoiding abrupt changes typically seen with random noise. The algorithm starts with a coarse grid, generating noise points, then interpolates for a finer grid. For instance, an initial 10x10 grid becomes a detailed 100x100 elevation map after interpolation. This elevation layer overlays the base grid, creating an altitude map. Altitude influences edge assignments, with visual representation mapping altitudes to shades; darker tiles signify higher altitudes.

 Using Processing's built-in Perlin Noise, we simulate map elevations. The raw Perlin Noise varies too rapidly for realistic terrains. To address this, we refine the sampling rate, using a default of 100 times (10x10) sampling, ensuring smoother terrain transitions and capturing all terrain features.

 <p align="center">
   <img width="700" alt="Perlin Noise - Altitude Map" src="https://github.com/atpugs/Procedural_Map_Generation/assets/31329834/36323e09-3807-473e-bb4c-19ca5e4e1696">
 </p>

 ### Biome Application
 The biome layer assigns landscape types to grid points based on Perlin Noise altitudes. Altitude ranges dictate biomes: snow (white), bare rocks (gray), grass (green), sandy land (yellow), and lakes (blue). Rivers get specific colors based on underlying biomes. Biomes also influence edge creation in the grid, and further iterations aim to refine terrain distinctions for enhanced map complexity.

 <p align="center">
   <img width="700" alt="Screenshot 2023-09-22 at 5 56 11 PM" src="https://github.com/atpugs/Procedural_Map_Generation/assets/31329834/3af1b55d-18d9-4eac-9704-9dbc894feab8">
 </p>

 ### Value Noise
 Value noise, simpler than Perlin Noise, interpolates between randomly generated single values. We use it for attributes like humidity, refining biomes. For instance, grass biomes can now differentiate into jungle variations based on humidity. A separate value noise map simulates rainstorms, visually depicting rain and hail based on altitude. Seasonal shifts cause dynamic rainfall patterns across regions, enhancing realism in the generated map.

 <p align="center">
   <img width="700" alt="Screenshot 2023-09-22 at 5 56 45 PM" src="https://github.com/atpugs/Procedural_Map_Generation/assets/31329834/33a8cbb3-5aed-411a-acb4-2d9f9063c1a0">
 </p>

 ### Water Incorporation
 Instead of complex hydraulic erosion methods, we use key attributes to simulate water feature locations. A humidity map, generated via value noise, dictates air humidity, influencing water biomes. By tracking neighboring biomes and considering altitude-humidity patterns, natural water features like rivers originating from snow biomes are inferred, mimicking real-world formations without fully simulating hydraulic processes.

 ### Alternate Biome Attributes
 We've incorporated additional parameters like water content for nuanced biome representation. New biomes like deep jungle and deep water are introduced, with distinctions made via a Heat system based on altitude, humidity, and heat attributes. Biomes dynamically shift with global heat changes, simulating real-world biome transitions. Seasonal changes, driven by a heat index, simulate events like snow melt and water evaporation, enhancing map interactivity.

 ### A* search on graph
 We've adopted the A* algorithm for fluid pathfinding in the graph, favoring its efficiency for high-vertex, high-connectivity tile-based graphs over classic methods like Dijkstra. Given the real-world terrain simulation aim, A* ensures paths resembling natural river courses, considering obstacles and elevation differences. The heuristic choice for A* prioritizes generating intriguing paths over strictly optimal ones.

 We use the A* algorithm to simulate river creation, drawing paths from the highest to lowest points based on the Perlin Noise height map. However, A*'s global optimization hinders hydraulic erosion simulation, which requires local optimization. To address this, heuristic dispersion is increased to emphasize locality, producing more naturally curving rivers. We also plan to add bridges, visually represented by three cells. Bridge placement is determined by biome type, surrounding non-river area size, and randomness, ensuring integration with the terrain.

 <p align="center">
 <img width="889" alt="Screenshot 2023-09-22 at 5 58 27 PM" src="https://github.com/atpugs/Procedural_Map_Generation/assets/31329834/45e85e4b-bd90-4f0a-9821-74a303b86dbb">
 </p>

 ## Evaluation
 Our map generation uses a layered approach, stacking different algorithms for distinct map layers. Evaluation is modular, assessing each layer's quality and then integrating these evaluations based on their importance. The primary focus is on terrain height, comparing value and Perlin noise. Specific biome areas in a sample map include:
 Rock: 903 cells <br>
 Sand: 416 cells <br>
 Deep jungle: 288 cells <br>
 Snow: 618 cells <br>
 Grass: 1540 cells <br>
 Muddy: 60 cells <br>
 Land: 156 cells <br>
 Deep water: 53 cells <br>
 Shallow Jungle: 639 cells <br>
 Water: 268 cells <br>

 Adjustments, such as increasing heat, lead to observable changes like declining water and snow areas. After finalizing algorithms for each layer, we refine them, designating an evaluation function for each. The ultimate algorithm effectiveness is measured by the quality and speed of generated content, with landscapes differentiated using color codes for varied terrains.

 ## References
 Millington, AI for Games, 3rd ed.Boca Raton, FL: CRC Press, 2019, pp. 687-704. <br>
 K. Perlin, “An image synthesizer,” ACM Siggraph Computer Graphics, vol. 19, pp. 287-296, July, 1985.
