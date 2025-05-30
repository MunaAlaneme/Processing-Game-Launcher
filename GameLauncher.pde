import processing.javafx.*;
import ch.bildspur.postfx.builder.*;
import ch.bildspur.postfx.pass.*;
import ch.bildspur.postfx.*;
import org.multiply.processing.*;
import processing.javafx.*;
import processing.svg.*;
import processing.sound.*;
import org.guilhermesilveira.*;
import java.util.*;
import java.math.*;
import java.lang.*;
import java.io.*;
import java.math.BigDecimal;

// Processing 4.4.3 beta
/**
 * Nebula. 
 * 
 * From CoffeeBreakStudios.com (CBS)
 * Ported from the webGL version in GLSL Sandbox:
 * http://glsl.heroku.com/e#3265.2
 */

double currentScreen = 0; // 0 = Menu, 1 = Game 1, 2 = Game 2
double frames = 0;
double Game1Time = 0;
SoundFile Music1Game1, Music1Game0, clickSound;
float Music1Game1playbackSpeed = 1;
float WindowXscale, WindowYscale, WindowScale, WindowScale2 = 1;
PShader nebula;
PFont font1;
void setup() {
  size(1280, 720, P2D); // Default size
  font1 = loadFont("Helvetica-255.vlw");
  surface.setResizable(true); // Allow resizing
  clickSound = new SoundFile(this, "data/audio/sfx/Click mouse - Fugitive Simulator - The-Nick-of-Time.wav");
  if (round(random(0,1)) == 1) {
    Music1Game1 = new SoundFile(this, "data/audio/music/coal bones - readme.txt (TPOT OST).wav");
  } else {
    Music1Game1 = new SoundFile(this, "data/audio/music/(Pegbox Studios) geg dier - clickercore.wav");
  }
  if (round(random(0,1)) == 1) {
    Music1Game0 = new SoundFile(this, "data/audio/music/YOYLECAKE Michael - Streetlight.wav");
    Music1Game0.loop();
  } else {
    Music1Game0 = new SoundFile(this, "data/audio/music/YOYLECAKE Michael (Verlis) - Motorway Glorped (Streetlight).wav");
    Music1Game0.loop();
  }
  nebula = loadShader("data/shaders/nebula.glsl");
  nebula.set("resolution", float(width), float(height));
  //frameRate(24);
}

double currentTime, deltaTime, previousTime;
void draw() {
  textFont(font1);
  WindowXscale = width / 1280.0;
  WindowYscale = height / 720.0;
  if ((WindowXscale < 0) && (WindowYscale < 0)) {
    WindowScale = max(WindowXscale, WindowYscale);
  } else if ((WindowXscale > 0) && (WindowYscale > 0)) {
    WindowScale = min(WindowXscale, WindowYscale);
  } else {WindowScale = 0;}
  if ((WindowXscale > 0) && (WindowYscale > 0)) {
    WindowScale2 = min(WindowXscale, WindowYscale);
  } else if ((WindowXscale < 0) && (WindowYscale < 0)) {
    WindowScale2 = max(WindowXscale, WindowYscale);
  } else {WindowScale2 = 0;}
  currentTime = millis();              // Get the current time in milliseconds
  deltaTime = (currentTime - previousTime) / 1000.0; // Convert to seconds
  previousTime = currentTime;              // Update the previous time
  
  if (currentScreen == 0) {
    nebula.set("time", millis() / 500.0);
    nebula.set("resolution", float(width), float(height));   
    //shader(nebula); 
    // This kind of raymarching effects are entirely implemented in the
    // fragment shader, they only need a quad covering the entire view 
    // area so every pixel is pushed through the shader.
    fill(200, 200, 200);
    rect(0, 0, width, height);
    drawMenu();
  } else if (currentScreen == 1) {
    playGame1();
  } else if (currentScreen == 2) {
    playGame2();
  }
  frames ++;
}

void drawMenu() {
  fill(50);
  textAlign(CENTER);
  textSize(height * 0.1); // Scales text with window height
  text("Game Launcher", width / 2, height * 0.2);

  textSize(height * 0.05); // Smaller text
  text("1. Play Game 1", width / 2, height * 0.3);
  text("2. Play Game 2", width / 2, height * 0.4);
  text("3. Play Game 3", width / 2, height * 0.5);
  text("4. Play Game 4", width / 2, height * 0.6);
  text("5. Run External Script", width / 2, height * 0.7);
}
float buttonXGame1 = width / 2;
float buttonYGame1 = height / 2;
BigDecimal scoreGame1 = new BigDecimal("0");          // Keeps track of the player's scoreGame1
BigDecimal perClickGame1 = new BigDecimal("1");           // Points earned per click
BigDecimal autoClickRateGame1 = new BigDecimal("0");      // Points automatically added per second
BigDecimal autoClickCostGame1 = new BigDecimal("50");     // Cost for Auto Clicker upgrade
BigDecimal multiplierCostGame1 = new BigDecimal("100");   // Cost for Multiplier upgrade
float buttonSizeGame1 = 100;   // Size of the button
void playGame1() {
  BigDecimal tempvar1 = new BigDecimal(deltaTime);
  scoreGame1 = scoreGame1.add(autoClickRateGame1.multiply(tempvar1));
  Game1Time += deltaTime;
  buttonXGame1 = width / 2;
  buttonYGame1 = height / 2;
  fill(100, 200, 255);
  rect(0, 0, width, height);
  fill(0);
  // Instructions to go back
  textSize(height * 0.03);
  text("Press 'B' to return to menu.", width / 2, height - 50);
  // Display upgrades
  textSize(height * 0.08);
  fill(50, 200, 50);
  text("Upgrades", width / 5, height * 0.4);
  textSize(height * 0.04);
  fill(0);
  text("Auto Clicker (" + autoClickCostGame1 + " points): Press 'A'", width / 5, height * 0.475);
  text("Multiplier (" + multiplierCostGame1 + " points): Press 'S'", width / 5, height * 0.525);
  fill(50, 100, 200);
  textSize(height * 0.07);
  textAlign(CENTER);
  text("Click the button to score points!", width / 2, height * 0.1);
  //text("Time: " + Game1Time, width / 2, height * 0.2);
  //text(stopwatch.hour() + ":" + nf(stopwatch.minute(), 2) + ":" + nf(stopwatch.second(), 2) + ":" + nf(stopwatch.millis(), 3), width / 2, height*.2);
  // Draw the button
  fill(200, 50, 50);
  ellipse(buttonXGame1, buttonYGame1, buttonSizeGame1, buttonSizeGame1);

  // Display the score
  fill(0);
  textSize(height*0.1);
  if (scoreGame1.compareTo(new BigDecimal("0.001")) == -1) {
    text("" +   0, width/2, height*.2);
  } else {
    text("" +   scoreGame1.toBigInteger(), width/2, height*.2);
  }
  if (currentScreen == 1) { // Only register clicks during Game 1
    buttonSizeGame1 += ((200 + int(dist(mouseX, mouseY, buttonXGame1, buttonYGame1) < buttonSizeGame1 / 2)*50)*WindowScale2 - buttonSizeGame1)*deltaTime*4;
    Music1Game1playbackSpeed += (1-Music1Game1playbackSpeed)*deltaTime*4;
    clickSound.rate(Music1Game1playbackSpeed);
    Music1Game1.rate(Music1Game1playbackSpeed);
  }
}

void mousePressed() {
  // Check if mouse is inside the button
  if (currentScreen == 1) { // Only register clicks during Game 1
    if (dist(mouseX, mouseY, buttonXGame1, buttonYGame1) < buttonSizeGame1 / 2) {
      scoreGame1 = scoreGame1.add(perClickGame1); // Increment scoreGame1
      // Randomize button position
      buttonSizeGame1 -= random(5, 25)*WindowScale2;
      buttonXGame1 = int(random(buttonSizeGame1 / 2, width - buttonSizeGame1 / 2));
      buttonYGame1 = int(random(buttonSizeGame1 / 2, height - buttonSizeGame1 / 2));
      clickSound.play();
      Music1Game1playbackSpeed += 0.01;
    }
  }
}

void playGame2() {
  background(255, 100, 150);
  fill(0);
  textSize(height * 0.03);
  text("Game 2 Running. Press 'M' to return to menu.", width / 2, height / 2);
}
//BigDecimal a = new BigDecimal("10.5");
//BigDecimal b = new BigDecimal("10.5");
//if (a.compareTo(b) >= 0) {
//    System.out.println("a is greater than or equal to b");
//} else {
//    System.out.println("a is less than b");
//}
void keyPressed() {
  if (currentScreen == 0) {
    if (key == '1') {
      currentScreen = 1;
      if (round(random(0,1)) == 1) {
        Music1Game1 = new SoundFile(this, "data/audio/music/coal bones - readme.txt (TPOT OST).wav");
      } else {
        Music1Game1 = new SoundFile(this, "data/audio/music/(Pegbox Studios) geg dier - clickercore.wav");
      }
      Music1Game1.loop();
      Music1Game0.stop();
    }
    if (key == '2'){ currentScreen = 2; Music1Game0.stop();}
    if (key == '3') runPDE("ProcessingClicker.pde");
    if (key == '4') runPDE("ProcessingClicker.pde");
    if (key == '5') runScript();
  } else if ((key == 'm' || key == 'M') && currentScreen != 1) {
    currentScreen = 0;
    if (round(random(0,1)) == 1) {
      Music1Game0 = new SoundFile(this, "data/audio/music/YOYLECAKE Michael - Streetlight.wav");
    } else {
      Music1Game0 = new SoundFile(this, "data/audio/music/YOYLECAKE Michael (Verlis) - Motorway Glorped (Streetlight).wav");
    }
    Music1Game1.stop();
    Music1Game0.loop();
  }
  if (currentScreen == 1) {
    // Handle upgrades
    if (key == 'A' || key == 'a') {
      if (scoreGame1.compareTo(autoClickCostGame1) >= 0) {
        scoreGame1 = scoreGame1.subtract(autoClickCostGame1); // Deduct cost
        autoClickRateGame1 = autoClickRateGame1.add(new BigDecimal("1"));        // Increase auto-click rate
        autoClickCostGame1 = autoClickCostGame1.add(new BigDecimal("50"));    // Increment cost for the next upgrade
      }
    }
    if (key == 'S' || key == 's') {
      if (scoreGame1.compareTo(multiplierCostGame1) >= 0) {
        scoreGame1 = scoreGame1.subtract(multiplierCostGame1); // Deduct cost
        perClickGame1 = perClickGame1.multiply(new BigDecimal("2"));           // Double the points per click
        multiplierCostGame1 = multiplierCostGame1.add(new BigDecimal("100"));   // Increment cost for the next upgrade
      }
    }
    // Return to menu
    if (key == 'B' || key == 'b') {
      currentScreen = 0;
      Music1Game1.stop();
      Music1Game0.loop();
    }
  }
}

void runScript() {
  // Example of running a script
  String[] command;
  
  if (System.getProperty("os.name").toLowerCase().contains("win")) { //<>// //<>// //<>//
    // Windows: Run a batch file
    command = new String[] { "cmd.exe", "/c", "path\\to\\your_script.bat" };
  } else {
    // macOS/Linux: Run a shell script
    command = new String[] { "sh", "-c", "bash path/to/your_script.sh" };
  }
  
  try {
    println("Running script...");
    Process process = exec(command);
    process.waitFor(); // Wait for the script to finish
    println("Script finished with exit code " + process.exitValue());
  } catch (Exception e) {
    println("Error running script: " + e.getMessage());
  }
}

void runPDE(String sketchPath) {
  // Command to run a .pde file using processing-java
  String[] command;
  
  if (System.getProperty("os.name").toLowerCase().contains("win")) {
    // Windows
    command = new String[] { 
      "cmd.exe", "/c", 
      "processing-java", 
      "--sketch=" + sketchPath, 
      "--run"
    };
  } else {
    // macOS/Linux
    command = new String[] { 
      "processing-java", 
      "--sketch=" + sketchPath, 
      "--run"
    };
  }
  
  try {
    println("Running .pde sketch: " + sketchPath);
    Process process = exec(command);
    process.waitFor(); // Wait for the sketch to finish
    println("Sketch finished with exit code " + process.exitValue());
  } catch (Exception e) {
    println("Error running .pde file: " + e.getMessage());
  }
}
