import beads.*; //<>// //<>// //<>// //<>//
//import org.jaudiolibs.beads.*;

import peasy.*;
import peasy.org.apache.commons.math.*;
import peasy.org.apache.commons.math.geometry.*;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.json.simple.parser.*;
//import org.tritonus.share.*;
import java.io.FileReader;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.Collections;
import java.util.HashSet;
import java.awt.Color;
import javafx.stage.FileChooser;
import javafx.stage.DirectoryChooser;
import javafx.stage.FileChooser.ExtensionFilter;
import javafx.stage.*;
import javafx.application.Platform;

InfoWindow infoWindow;
PeasyCam cam;
JSONParser p;
AudioContext ac;
SamplePlayer player;
SamplePlayer hitsound;
//AudioDecoder ad;

final int MAX_RENDER_ELEMENTS = 2000;

boolean shftPressed = false;
boolean cameraActive = false;
int state = 0; 
JSONObject map;
//String songPath = "D:\\things\\bsmaps\\Beat Saber_Data\\CustomWIPLevels\\netest";
String songPath = "D:/things/bsmaps/Beat Saber_Data/CustomWIPLevels/New Challenger Approaching";
String difficulty = "ExpertPlus";
String characteristic = "Standard";
String loadedSong = songPath;
float noteSize = 50;
ArrayList<Note> notes;
ArrayList<Obstacle> obstacles;
ArrayList<Event> events;
ArrayList<CustomEvent> customEvents;
float editorScale = 20;
float cursor = 0;
float precision = 1;
int precision_power = 1;
boolean ctlPressed = false; //whether control is being pressed
PImage[] cutDirections;
float bpm;
boolean playing = false;
long timeStartedPlaying;
float cursorStartedPlaying;
color leftColor;
color rightColor;
color obstacleColor;
float noteJumpSpeed;
float startBeatOffset;
float jumpDistance;
float cutoffPoint = 50; //how far notes should be rendered
HashMap<String, Integer> proplen; //how many attributes are in certain properties
color backgroundColor;
float ringRotation = 0;
float ringRotationToAdd = 0;
int ringZoom = 0;
int ringToZoom = 0;
boolean ringZoomed = false;
HashMap<String, Track> tracks;
HashMap<String, JSONArray> pointDefinitions;
int notedispx = 200; //x and y of the note display
int notedispy = 200;
boolean iw_canrender = false;
Selection selection;
color selectionColor;
int propertyImageSize = 32; //size that custom events display at
HashMap<String, PImage> propertyImages;
HashMap<String, String> simplePropertyNames;
boolean displayTracks = false; //toggles a thing where notes display their track ontop of them
ArrayList<RenderElement> renderQueue;
HashMap<String, PImage> UIElementImages;
String versionText = "ALPHA BUILD 1";
JSONObject mapjo;
boolean saveSong = false;
float lightingLerpAmount = 0.01;
boolean enableAssignPlayerToTrack = false;
boolean renderMarkers = true;
String sketchPath;
String codeFontPath = "/data/font/SourceCodePro-Medium.ttf";
String textFontPath = "/data/font/Roboto-Medium.ttf";
PFont codeFont;
PFont textFont;

void settings() {
  size(1200, 800, P3D);
  PJOGL.setIcon("data/img/logo.png");
}
void setup() {
  ellipseMode(CORNER);
  proplen = new HashMap<String, Integer>();
  simplePropertyNames = new HashMap<String, String>();
  selection = new Selection();
  proplen.put("_position",3);
  proplen.put("_rotation",3);
  proplen.put("_localRotation",3);
  proplen.put("_scale",3);
  proplen.put("_dissolve",1);
  proplen.put("_dissolveArrow",1);
  proplen.put("_arrowDissolve",1);
  proplen.put("_cuttable",1);
  proplen.put("_interactable",1);
  proplen.put("_definitePosition",3);
  proplen.put("_localPosition",3); //I don't know what this is or what it does
  proplen.put("_time",1);
  proplen.put("_color", 4);
  proplen.put("_attenuation",1); //fog
  proplen.put("_offset",1);
  proplen.put("_startY",1);
  proplen.put("_height",1);
  
  simplePropertyNames.put("_position","Position");
  simplePropertyNames.put("_rotation","Rotation");
  simplePropertyNames.put("_localRotation","Local Rotation");
  simplePropertyNames.put("_scale","Scale");
  simplePropertyNames.put("_dissolve","Dissolve");
  simplePropertyNames.put("_dissolveArrow","Dissolve Arrow");
  simplePropertyNames.put("_arrowDissolve","Dissolve Arrow");
  simplePropertyNames.put("_cuttable","Cuttable");
  simplePropertyNames.put("_interactable","Interactable");
  simplePropertyNames.put("_definitePosition","Definite Position");
  simplePropertyNames.put("_localPosition","Local Position"); //I don't know what this is or what it does
  simplePropertyNames.put("_time","Time");
  simplePropertyNames.put("_color", "Color");
  simplePropertyNames.put("_attenuation","Fog Attenuation"); //fog
  simplePropertyNames.put("_offset","Fog Offset");
  simplePropertyNames.put("_startY","Fog Start Y");
  simplePropertyNames.put("_height","Fog Height");
  ac = new AudioContext();
  surface.setResizable(true);
  //surface.setLocation(225, 50);
  cam = new PeasyCam(this, 0, 0, 0, 500);
  cam.lookAt(0, 0, 0);
  //cam.rotateY(PI);
  cam.pan(0, -500);
  cam.setSuppressRollRotationMode();
  cam.setActive(cameraActive);
  p = new JSONParser();
  notes = new ArrayList<Note>();
  obstacles = new ArrayList<Obstacle>();
  events = new ArrayList<Event>();
  sketchPath = sketchPath(); //sketchPath variable exists because for some reason child PApplets can't access sketchPath
  player = new SamplePlayer(ac, SampleManager.sample(sketchPath()+"/data/audio/hitsound.wav"));
  loadSong(songPath, characteristic, difficulty);
  if(customEvents == null) throw new NullPointerException(); //this is just here to prevent the exception from being thrown somewhere else
  player.setKillOnEnd(false);
  hitsound = new SamplePlayer(ac, SampleManager.sample(sketchPath()+"/data/audio/hitsound.wav"));
  hitsound.setKillOnEnd(false);
  Gain g = new Gain(ac, 2, 0.2);
  g.addInput(player);
  Gain g2 = new Gain(ac, 2, 0.05);
  g2.addInput(hitsound);
  ac.out.addInput(g);
  ac.out.addInput(g2);
  cutDirections = new PImage[9];
  cutDirections[0] = loadImage("data/img/cutDirection/0.png");
  cutDirections[1] = loadImage("data/img/cutDirection/1.png");
  cutDirections[2] = loadImage("data/img/cutDirection/2.png");
  cutDirections[3] = loadImage("data/img/cutDirection/3.png");
  cutDirections[4] = loadImage("data/img/cutDirection/2.png");
  cutDirections[5] = loadImage("data/img/cutDirection/3.png");
  cutDirections[6] = loadImage("data/img/cutDirection/2.png");
  cutDirections[7] = loadImage("data/img/cutDirection/3.png");
  cutDirections[8] = loadImage("data/img/cutDirection/8.png");
  backgroundColor = color(0,0,0);
  selectionColor = color(0, 255, 255);
  HashMap<String, PImage> propertyImages = new HashMap<String, PImage>();
  UIElementImages = new HashMap<String, PImage>();
  File f = new File(sketchPath()+"/data/img/animation/");
  String[] files = f.list();
  for(int i = 0; i < files.length; i++) {
    println(files[i], files[i].split("\\.")[0]);
    propertyImages.put(files[i].split("\\.")[0], loadImage(sketchPath()+"/data/img/animation/"+files[i]));
  }
  f = new File(sketchPath()+"/data/img/UIElement/");
  files = f.list();
  for(int i = 0; i < files.length; i++) {
    println(files[i], files[i].split("\\.")[0]);
    UIElementImages.put(files[i].split("\\.")[0], loadImage(sketchPath()+"/data/img/UIElement/"+files[i]));
  }
  println("Notes: "+notes.size());
  println("Obstacles: "+obstacles.size());
  codeFont = createFont(sketchPath()+codeFontPath, 16);
  textFont = createFont(sketchPath()+textFontPath, 64);
  infoWindow = new InfoWindow();
  String[] args = {"test"};
  PApplet.runSketch(args, infoWindow);
  infoWindow.propertyImages = propertyImages;
}
void draw() {
  try {
  textFont(textFont);
  //camera shit (I have to do this every frame because peasycam)
  float fov = PI/3.0;
  float cameraZ = (height/2.0) / tan(fov/2.0);
  perspective(fov, float(width)/float(height), cameraZ/10.0, cameraZ*200.0);
  background(red(backgroundColor), green(backgroundColor), blue(backgroundColor));
  fill(255);
  //box(100);
  //render markers
  if(renderMarkers) {
    fill(255);
    textSize(32);
    float offset = -(cursor-floor(cursor));
    for(int i = -10; i < 10; i++) { //render beat markers
      pushMatrix();
      translate(0, noteSize*3, (i*editorScale*noteSize)-(offset*editorScale*noteSize));
      box(4*noteSize, noteSize/10, noteSize/10);
      text(floor((cursor+offset)-i), noteSize*2, 0);
      popMatrix();
    }
    pushMatrix(); //render boxes on the side
    translate(noteSize*2, noteSize*1.25, 0);
    box(noteSize/10, 3.5*noteSize, noteSize/10);
    popMatrix();
    pushMatrix();
    translate(-noteSize*2, noteSize*1.25, 0);
    box(noteSize/10, 3.5*noteSize, noteSize/10);
    popMatrix();
  }
    pushMatrix();
    if(enableAssignPlayerToTrack) {
  int playerTrackIndex = getLastCustomEvent("AssignPlayerToTrack");
    if(playerTrackIndex != -1) {
      Track playerTrack = tracks.get((String)(customEvents.get(playerTrackIndex).data.get("_track")));
      JSONObject properties = playerTrack.properties;
      JSONArray position = new JSONArray();
      JSONArray rotation = new JSONArray();
      if(properties.containsKey("_position")) {
        position = (JSONArray)properties.get("_position");
      } else {
        position.add(0);
        position.add(0);
        position.add(0);
      }
      if(properties.containsKey("_rotation")) {
        rotation = (JSONArray)properties.get("_rotation");
      } else {
        rotation.add(0);
        rotation.add(0);
        rotation.add(0);
      }
      translate(-(dapf(position.get(0)))*noteSize, dapf(position.get(1))*noteSize, dapf(position.get(2))*noteSize);
      rotateX(-radians(dapf(rotation.get(0))));
      rotateY(-radians(dapf(rotation.get(1))));
      rotateZ(-radians(dapf(rotation.get(2))));
    }
    }
  //lighting
  rectMode(CENTER);
  float leftLaserRot = 0;
  float rightLaserRot = 0;
  if(getLastEvent(12) != -1) {
    float leftLaserSpeed = events.get(getLastEvent(12)).value*0.25;
    leftLaserRot = ((cursor*leftLaserSpeed)%360);
  }
  if(getLastEvent(13) != -1) {
    float rightLaserSpeed = events.get(getLastEvent(13)).value*0.25;
    rightLaserRot = ((cursor*rightLaserSpeed)%360);
  }
  //println("A", red(backgroundColor), green(backgroundColor), blue(backgroundColor));
  if(state == 0) {
    int backgroundLoc = -5000;
    if(getLastEvent(0) != -1) { 
      color c = events.get(getLastEvent(0)).getColor();
      if(alpha(c) != 0) {
        backgroundColor = lerpColor(backgroundColor, c, lightingLerpAmount);
        stroke(red(c), green(c), blue(c), alpha(c));
        strokeWeight(25);
        pushMatrix();
        translate(0, -2000, 0);
        line(-10000, -10000, backgroundLoc, 10000, 10000, backgroundLoc-1000);
        line(-10000, 10000, backgroundLoc, 10000, -10000, backgroundLoc-1000);
        popMatrix();
      }
    }
    if(getLastEvent(1) != -1) {
      color c = events.get(getLastEvent(1)).getColor();
      if(alpha(c) != 0) {
        backgroundColor = lerpColor(backgroundColor, c, lightingLerpAmount);
        fill(red(c), green(c), blue(c), alpha(c));
        stroke(red(c), green(c), blue(c), alpha(c));
        strokeWeight(0);
        int boxSize = 4000;
        int divisor = 10;
        pushMatrix();
        rotateZ(radians(ringRotation));
        pushMatrix();
        translate(0, -boxSize/2, backgroundLoc+2000);
        rect(0, 0, boxSize+(boxSize/10), boxSize/divisor);
        popMatrix();
        pushMatrix();
        translate(-boxSize/2, 0, backgroundLoc+2000);
        rect(0, 0, boxSize/divisor, boxSize);
        popMatrix();
        pushMatrix();
        translate(boxSize/2, 0, backgroundLoc+2000);
        rect(0, 0, boxSize/divisor, boxSize);
        popMatrix();
        pushMatrix();
        translate(0, boxSize/2, backgroundLoc+2000);
        rect(0, 0, boxSize+(boxSize/10), boxSize/divisor, boxSize/divisor);
        popMatrix();
        popMatrix();
        noStroke();
      }
    }
    if(getLastEvent(2) != -1) {
      color c = events.get(getLastEvent(2)).getColor();
      if(alpha(c) != 0) {
        backgroundColor = lerpColor(backgroundColor, c, lightingLerpAmount);
        stroke(red(c), green(c), blue(c), alpha(c));
        strokeWeight(10);
        pushMatrix();
        translate(0, 2000, 200);
        translate(0, 0, backgroundLoc*1.2);
        rotateX(leftLaserRot);
        line(50000, 25000, 0, -50000, -25000, 0);
        line(50000, 0, 0, -50000, 0, 0);
        line(50000, -25000, 0, -50000, 25000, 0);
        popMatrix();
      }
    }
    if(getLastEvent(3) != -1) {
      color c = events.get(getLastEvent(3)).getColor();
      if(alpha(c) != 0) {
        backgroundColor = lerpColor(backgroundColor, c, lightingLerpAmount);
        stroke(red(c), green(c), blue(c), alpha(c));
        strokeWeight(10);
        pushMatrix();
        translate(0, -2000, 200);
        translate(0, 0, backgroundLoc*1.2);
        rotateX(rightLaserRot);
        line(50000, 25000, 0, -50000, -25000, 0);
        line(50000, 0, 0, -50000, 0, 0);
        line(50000, -25000, 0, -50000, 25000, 0);
        popMatrix();
      }
    }
    if(getLastEvent(4) != -1) {
      color c = events.get(getLastEvent(4)).getColor();
      if(alpha(c) != 0) {
        backgroundColor = lerpColor(backgroundColor, c, lightingLerpAmount);
        fill(red(c), green(c), blue(c), alpha(c));
        stroke(red(c), green(c), blue(c), alpha(c));
        strokeWeight(0);
        int boxSize = 3000;
        int divisor = 10;
        pushMatrix();
        rotateZ(radians(ringRotation));
        pushMatrix();
        translate(0, -boxSize/2, backgroundLoc+ringZoom);
        rect(0, 0, boxSize+(boxSize/divisor), boxSize/divisor);
        popMatrix();
        pushMatrix();
        translate(-boxSize/2, 0, backgroundLoc+ringZoom);
        rect(0, 0, boxSize/divisor, boxSize);
        popMatrix();
        pushMatrix();
        translate(boxSize/2, 0, backgroundLoc+ringZoom);
        rect(0, 0, boxSize/divisor, boxSize);
        popMatrix();
        pushMatrix();
        translate(0, boxSize/2, backgroundLoc+ringZoom);
        rect(0, 0, boxSize+(boxSize/10), boxSize/divisor);
        popMatrix();
        popMatrix();
        noStroke();
      }
    }
    backgroundColor = lerpColor(backgroundColor, color(0), lightingLerpAmount*2.5);
    //println("B", red(backgroundColor), green(backgroundColor), blue(backgroundColor));
    if(playing) {
      for(int i = 0; i < events.size(); i++) {
        if(events.get(i).time < cursor && !events.get(i).activated) {
          events.get(i).activated = true;
          if(events.get(i).type == 8) ringRotationToAdd += 45;
          if(events.get(i).type == 9) { 
            ringZoomed = !ringZoomed;
            if(ringZoomed) ringToZoom += 1000;
            if(!ringZoomed) ringToZoom -= 1000;
          }
        }
      }
    }
    float rr = ringRotationToAdd/10;
    ringRotation += rr;
    ringRotationToAdd -= rr;
    float rz = ringToZoom/10;
    ringZoom += rz;
    ringToZoom -= rz;
    noStroke();
    fill(255);
    float renderLimit = jumpDistance/4;
    //clear the render queue
    renderQueue = new ArrayList<RenderElement>();
    //add objects to the render queue
    for(int i = 0; i < obstacles.size(); i++) {
      obstacles.get(i).render();
    }
    iw_canrender = false;
    for(int i = 0; i < notes.size(); i++) {
      notes.get(i).render();
    }
    //sort the render queue by opacity
    Collections.sort(renderQueue);
    Collections.reverse(renderQueue);
    //actually render the objects
    for(int i = 0; i < renderQueue.size(); i++) {
      renderQueue.get(i).render();
    }
    if(frameCount > 20) iw_canrender = true;
    if(playing) {
      cursor = cursorStartedPlaying+((Math.round(player.getPosition())-timeStartedPlaying)*(((bpm/60f))*0.001));
    }
    popMatrix();
    //update tracks (this is done last so that there's no flickering when the player is being animated)
    Set<String> tracksKeySet = tracks.keySet();
    for(String i : tracksKeySet) {
      //tracks.get(i).update();
      tracks.get(i).updatedThisFrame = false;
    }
  }
  if(!loadedSong.equals(songPath)) {
    loadedSong = songPath;
    loadSong(songPath, characteristic, difficulty);
  }
  textMode(SHAPE);
  textSize(16);
  fill(255, 64);
  text(versionText, -(width/4), -(height/4));
  textMode(MODEL);
  } catch(Exception e) {
    //e.printStackTrace();
    println("Error");
    throw e;
  } catch(AssertionError e) {
    e.printStackTrace();
  }
  if(saveSong) {
    saveSong = false;
    Platform.runLater(new Runnable() {
      @Override
      public void run() {
        saveSong();
      }
    });
  }
}

void keyPressed() {
  if(keyCode == CONTROL) {
    ctlPressed = true;
  }
  if(keyCode == SHIFT) {
    shftPressed = true;
  }
  if(state == 0) {
    if(key == 'c') {
      cameraActive = !cameraActive;
      cam.setActive(cameraActive);
    }
    if(key == 'r') {
      if(!cameraActive) {
        cam.lookAt(0, 0, 0);
        cam.rotateY(PI);
        cam.pan(0, -500);
      }
    }
    if(keyCode == 'S') {
      if(ctlPressed) {
        saveSong = true;
      }
    }
    if(key == ' ') {
      if(!playing) {
        double position = (cursor*(1f/(bpm/60f)))*1000;
        player.setPosition(position);
        ac.start();
        timeStartedPlaying = Math.round(position);
        cursorStartedPlaying = cursor;
        for(int i = 0; i < events.size(); i++) {
          if(events.get(i).time < cursor) events.get(i).activated = true;
        }
      } else {
        ac.stop();
        cursor = roundToNearest(cursor, precision_power);
        for(int i = 0; i < notes.size(); i++) {
          notes.get(i).playedClickSound = false;
        }
        for(int i = 0; i < events.size(); i++) {
          events.get(i).activated = false;
        }
      }
      playing = !playing;
    }
  }
}
void keyReleased() {
  if(keyCode == CONTROL) {
    ctlPressed = false;
  }
  if(keyCode == SHIFT) {
    shftPressed = false;
  }
}
void mouseWheel(MouseEvent event) {
  if(state == 0) {
    if(!cameraActive) {
      if(ctlPressed) {
        precision_power += event.getCount();
        precision = pow(2, precision_power);
      } else {
        cursor -= event.getCount()*precision;
      }
    }
  }
}
void loadSong(String path, String characteristic, String difficulty) {
  noLoop();
  cursor = 0;
  leftColor = color(217, 22, 22);
  rightColor = color(50, 172, 255);
  obstacleColor = leftColor;
  String audioPath = songPath+"\\song.mp3";
  player.setSample(SampleManager.sample(audioPath));
  songPath = path;
  JSONObject jo = new JSONObject();
  try {
    jo = (JSONObject)p.parse(new FileReader(songPath+"/Info.dat")); //load map
  } catch(Exception e) {
    e.printStackTrace();
  }
  try {
    bpm = dapf(jo.get("_beatsPerMinute"));
    //audioPath = songPath+"/"+((String)jo.get("_songFilename"));
    JSONArray dbms = (JSONArray)jo.get("_difficultyBeatmapSets"); //get difficulties
    for(int i = 0; i < dbms.size(); i++) { //loop through all difficulty sets
      Map a = (Map)dbms.get(i);
      if(a.get("_beatmapCharacteristicName").equals(characteristic)) { //If it's standard
        JSONArray b = (JSONArray)a.get("_difficultyBeatmaps");
        for(int j = 0; j < b.size(); j++) { //loop through all difficulties
          Map c = (Map)b.get(j); //get this difficulty
          if(c.get("_difficulty").equals(difficulty)) { //If it's ex+
            loadMap(songPath+"/"+c.get("_beatmapFilename"));
            noteJumpSpeed = dapf(c.get("_noteJumpMovementSpeed"));
            startBeatOffset = dapf(c.get("_noteJumpStartBeatOffset"));
            jumpDistance = getJumpDistance(noteJumpSpeed, startBeatOffset);
            editorScale = noteJumpSpeed;
            if(c.containsKey("_customData")) {
              JSONObject customData = (JSONObject)c.get("_customData");
              if(customData.containsKey("_colorLeft")) {
                JSONObject col = (JSONObject)customData.get("_colorLeft");
                leftColor = color(dapf(col.get("r"))*255, dapf(col.get("g"))*255, dapf(col.get("b"))*255);
              }
              if(customData.containsKey("_colorRight")) {
                JSONObject col = (JSONObject)customData.get("_colorRight");
                rightColor = color(dapf(col.get("r"))*255, dapf(col.get("g"))*255, dapf(col.get("b"))*255);
              }
            }
          }
        }
      }
    }
  } catch(Exception e) {
    throw e;
  }
  loop();
}
void saveSong() {
  if(!mapjo.containsKey("_customData")) mapjo.put("_customData", new JSONObject()); //add _customData if it doesn't already exist
  JSONArray _notes = new JSONArray();
  for(int i = 0; i < notes.size(); i++) {
    _notes.add(notes.get(i).toJSON());
  }
  JSONArray _obstacles = new JSONArray();
  for(int i = 0; i < obstacles.size(); i++) {
    _obstacles.add(obstacles.get(i).toJSON());
  }
  JSONArray _events = new JSONArray();
  for(int i = 0; i < events.size(); i++) {
    _events.add(events.get(i).toJSON());
  }
  JSONArray _customEvents = new JSONArray();
  for(int i = 0; i < customEvents.size(); i++) {
    _customEvents.add(customEvents.get(i).toJSON());
  }
  JSONArray _pointDefinitions = new JSONArray();
  for(String i: pointDefinitions.keySet()) {
    JSONObject pd = new JSONObject();
    pd.put("_name", i);
    pd.put("_points", pointDefinitions.get(i));
    _pointDefinitions.add(pd);
  }
  mapjo.put("_notes", _notes);
  mapjo.put("_obstacles", _obstacles);
  mapjo.put("_events", _events);
  ((JSONObject)mapjo.get("_customData")).put("_customEvents", _customEvents);
  ((JSONObject)mapjo.get("_customData")).put("_pointDefinitions", _pointDefinitions);
  FileChooser chooser = new FileChooser();
  File directory = new File(sketchPath());
  chooser.setTitle("Choose an output file");
  chooser.setInitialFileName(difficulty+characteristic);
  chooser.setInitialDirectory(directory);
  chooser.getExtensionFilters().addAll(new ExtensionFilter("Beat Saber Map Data Files", "*.dat"));
  File f = chooser.showSaveDialog(null);
  String[] toSave = {mapjo.toString()};
  saveStrings(f.getAbsolutePath(), toSave);
  println("Saving complete!");
}
void loadMap(String path) {
  noLoop();
  notes = new ArrayList<Note>();
  obstacles = new ArrayList<Obstacle>();
  events = new ArrayList<Event>();
  customEvents = new ArrayList<CustomEvent>();
  tracks = new HashMap<String, Track>();
  pointDefinitions = new HashMap<String, JSONArray>();
  JSONObject jo = new JSONObject();
  try {
    jo = (JSONObject)p.parse(new FileReader(path)); //load map
    mapjo = (JSONObject)p.parse(new FileReader(path));
  } catch(Exception e) {
    println(e.getMessage());
  }
    JSONArray mapNotes = (JSONArray)jo.get("_notes"); //get notes
    JSONArray mapObstacles = (JSONArray)jo.get("_obstacles"); //get obstacles
    JSONArray mapEvents = (JSONArray)jo.get("_events"); //get events
    if(jo.containsKey("_customData")) {
      println("custom data detected");
      JSONObject mapCustomData = (JSONObject)jo.get("_customData");
      if(mapCustomData.containsKey("_customEvents")) {
        JSONArray mapCustomEvents = (JSONArray)(mapCustomData.get("_customEvents"));
        for(int i = 0; i < mapCustomEvents.size(); i++) { //loop through custom events
          Map e = (Map)mapCustomEvents.get(i); //get note
          if(e.containsKey("_data")) { //please if you make a map fucking put some data in your custom events god
            JSONObject data = (JSONObject)e.get("_data");
            if(data.containsKey("_track")) { //this is here because for some fucking reason some maps just have custom events without any tracks assigned. WHY
              customEvents.add(new CustomEvent(dapf(e.get("_time")), (String)e.get("_type"), (JSONObject)e.get("_data"))); //parse note and add it to notes array
            }
          }
        }
        println("loaded custom events");
        for(int i = 0; i < customEvents.size(); i++) {
          customEvents.get(i).findTracks();
        }
        println("loaded custom events' tracks");
      }
      if(mapCustomData.containsKey("_pointDefinitions")) {
        JSONArray mapPointDefinitions = (JSONArray)(mapCustomData.get("_pointDefinitions"));
        for(int i = 0; i < mapPointDefinitions.size(); i++) { //loop through custom events
          Map e = (Map)mapPointDefinitions.get(i); //get note
          pointDefinitions.put((String)e.get("_name"), (JSONArray)e.get("_points"));
        }
        println("loaded point definitions");
      }
    }
    for(int i = 0; i < mapNotes.size(); i++) { //loop through notes
      Map n = (Map)mapNotes.get(i); //get note
      notes.add(new Note(dapf(n.get("_time")), dapi(n.get("_lineIndex")), dapi(n.get("_lineLayer")), dapi(n.get("_type")), dapi(n.get("_cutDirection")))); //parse note and add it to notes array
      if(n.containsKey("_customData")) notes.get(notes.size()-1).addCustomData((JSONObject)(n.get("_customData")));
    }
    println("loaded notes");
    for(int i = 0; i < mapObstacles.size(); i++) { //loop through obstacles
      Map o = (Map)mapObstacles.get(i); //get note
      obstacles.add(new Obstacle(dapf(o.get("_time")), dapi(o.get("_lineIndex")), dapi(o.get("_width")), dapf(o.get("_duration")), dapi(o.get("_type")))); //parse note and add it to notes array
      if(o.containsKey("_customData")) obstacles.get(obstacles.size()-1).addCustomData((JSONObject)(o.get("_customData")));
    }
    println("loaded obstacles");
    for(int i = 0; i < mapEvents.size(); i++) { //loop through events
      Map e = (Map)mapEvents.get(i); //get note
      events.add(new Event(dapf(e.get("_time")), dapi(e.get("_type")), dapi(e.get("_value")))); //parse note and add it to notes array
      if(e.containsKey("_customData")) events.get(events.size()-1).addCustomData((JSONObject)(e.get("_customData")));
    }
    println("loaded events");
  println("map parsed!");
  loop();
}
int dapi(Object o) throws DetectAndParseException { //detect and parse
  if(o instanceof Integer) {
    return (int)o;
  } else if(o instanceof Long) {
    return int((Long)o);
  } else if(o instanceof Double) {
    return int(((Double)o).floatValue());
  } else if(o instanceof Float) {
    return int((Float)o);
  } else if(o instanceof Boolean) {
    return int((boolean)o);
  }
  //throw new DetectAndParseException();
  return -1;
}
float dapf(Object o) throws DetectAndParseException { //detect and parse
  if(o instanceof Integer) {
    return (int)o;
  } else if(o instanceof Long) {
    return float(int((Long)o));
  } else if(o instanceof Double) {
    return ((Double)o).floatValue();
  } else if(o instanceof Float) {
    return (Float)o;
  } else if(o instanceof Boolean) {
    return int((boolean)o);
  }
  //throw new DetectAndParseException();
  return -1;
}
boolean isNumber(Object o) {
  if(o instanceof Integer) {
    return true;
  } else if(o instanceof Long) {
    return true;
  } else if(o instanceof Double) {
    return true;
  } else if(o instanceof Float) {
    return true;
  }
  return false;
}

class DetectAndParseException extends RuntimeException {
  public DetectAndParseException() {
      super();
  }
  public DetectAndParseException(String errorMessage) {
      super(errorMessage);
  }
}

long getTime() {
  return System.currentTimeMillis();
}

float roundToNearest(float num, float nearest) {
  return float(floor(num/nearest))*nearest;
}

PVector BeatwallsToPosition(PVector pos, float njs) { //convert beatwalls position to world position
  return new PVector((pos.x*noteSize)+(0.5*noteSize), (2-pos.y)*noteSize, -(((pos.z*njs*noteSize)-(cursor*njs*noteSize))));
}
PVector BeatwallsToPosition2D(PVector pos) { //convert beatwalls position to world position
  return new PVector((pos.x*noteSize)+(0.5*noteSize), (2-pos.y)*noteSize);
}

int getLastEvent(int type) { //gets last event of a type before cursor
  float winner = -1;
  int winnerIndex = -1;
  for(int i = 0; i < events.size(); i++) {
    if(events.get(i).time <= cursor && events.get(i).type == type) {
      if(events.get(i).time > winner) {
        winnerIndex = i;
        winner = events.get(i).time;
      }
    }
  }
  return winnerIndex;
}

int getLastCustomEvent(String type) { //gets last custom event of a type before cursor
  float winner = -1;
  int winnerIndex = -1;
  for(int i = 0; i < customEvents.size(); i++) {
    if(customEvents.get(i).time <= cursor && customEvents.get(i).type.equals(type)) {
      if(customEvents.get(i).time > winner) {
        winnerIndex = i;
        winner = customEvents.get(i).time;
      }
    }
  }
  return winnerIndex;
}

float getJumpDistance(float njs, float sbo) {
  float startHalfJumpDurationInBeats = 4;
  float maxHalfJumpDistance = 17.999;
  float startNoteJumpMovementSpeed = njs;
  float noteJumpStartBeatOffset = sbo;
  float startBPM = bpm;
  
  float noteJumpMovementSpeed = (startNoteJumpMovementSpeed * bpm) / startBPM;
  float num = 60/bpm;
  float num2 = startHalfJumpDurationInBeats;
  while(noteJumpMovementSpeed * num * num2 > maxHalfJumpDistance) {
    num2 /= 2;
  }
  num2 += noteJumpStartBeatOffset;
  if(num2 < 0.25) num2 = 0.25;
  return 60f/bpm * noteJumpSpeed * num2;
}

boolean decideToRender(float time, float jd) {
  float renderLimit = jd/4;
  return (time > -renderLimit && time < renderLimit);
}
boolean decideToRender_t(float time, float time2, float jd) {
  float renderLimit = jd/4;
  return (time > -renderLimit && time2 < renderLimit);
}

float getAnimPosition(float time, float jd) {
  float renderLimit = jd/4;
  return min(max(1-((time/renderLimit)+0.5),0),1);
}

float getTimeFromAnimPosition(float animPos, float jd) {
  float renderLimit = jd/4;
  return renderLimit/animPos;
}

color averageColors(color a, color b) {
  return color(((red(a)*(alpha(a)/255))+((red(b)*(alpha(b)/255))))/2, (((green(a)*(alpha(a)/255)))+((green(b)*(alpha(b)/255))))/2, (((blue(a)*(alpha(a)/255)))+((blue(b)*(alpha(b)/255))))/2);
}

JSONArray addArrays(JSONArray a, JSONArray b) {
  JSONArray c = new JSONArray();
  if(a.size() > b.size()) {
    for(int i = 0; i < a.size(); i++) {
      float val = 0;
      if(i < b.size()) val = dapf(b.get(i));
      c.add(dapf(a.get(i))+val);
    }
  } else {
    for(int i = 0; i < b.size(); i++) {
      float val = 0;
      if(i < a.size()) val = dapf(a.get(i));
      c.add(dapf(b.get(i))+val);
    }
  }
  return c;
}
JSONArray multArrays(JSONArray a, JSONArray b) {
  JSONArray c = new JSONArray();
  if(a.size() > b.size()) {
    for(int i = 0; i < b.size(); i++) {
      float val = 1;
      if(i < b.size()) val = dapf(b.get(i));
      c.add(dapf(a.get(i))*val);
    }
  } else {
    for(int i = 0; i < a.size(); i++) {
      float val = 1;
      if(i < a.size()) val = dapf(a.get(i));
      c.add(dapf(b.get(i))*val);
    }
  }
  return c;
}

float ease(float x, String easing) { //I wrote basically none of this code, I just stole it from easings.net. Typescript is very similar to java so it wasn't too hard
  float c1 = 1.70158;
  float c2 = c1 * 1.525;
  float c3 = c1 + 1;
  float c4 = (2 * PI) / 3;
  float c5 = (2 * PI) / 4.5;
  float n1 = 7.5625;
  float d1 = 2.75;
  switch(easing) {
    case "easeLinear":
    return x;
    case "easeInSine":
    return 1 - cos((x * PI) / 2);
    case "easeOutSine":
    return sin((x * PI) / 2);
    case "easeInOutSine":
    return -(cos(PI * x) - 1) / 2;
    case "easeInCubic":
    return x * x * x;
    case "easeOutCubic":
    return 1 - pow(1 - x, 3);
    case "easeInOutCubic":
    return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2;
    case "easeInQuint":
    return x * x * x * x * x;
    case "easeOutQuint":
    return 1 - pow(1 - x, 5);
    case "easeInOutQuint":
    return x < 0.5 ? 16 * x * x * x * x * x : 1 - pow(-2 * x + 2, 5) / 2;
    case "easeInCirc":
    return 1 - sqrt(1 - pow(x, 2));
    case "easeOutCirc":
    return sqrt(1 - pow(x - 1, 2));
    case "easeInOutCirc":
    return x < 0.5
    ? (1 - sqrt(1 - pow(2 * x, 2))) / 2
    : (sqrt(1 - pow(-2 * x + 2, 2)) + 1) / 2;
    case "easeInElastic":
    
    return x == 0
      ? 0
      : x == 1
      ? 1
      : -pow(2, 10 * x - 10) * sin((x * 10 - 10.75) * c4);
    case "easeOutElastic":

    return x == 0
      ? 0
      : x == 1
      ? 1
      : pow(2, -10 * x) * sin((x * 10 - 0.75) * c4) + 1;
    case "easeInOutElastic":
    return x == 0
    ? 0
    : x == 1
    ? 1
    : x < 0.5
    ? -(pow(2, 20 * x - 10) * sin((20 * x - 11.125) * c5)) / 2
    : (pow(2, -20 * x + 10) * sin((20 * x - 11.125) * c5)) / 2 + 1;
    case "easeInQuad":
    return x * x;
    case "easeOutQuad":
    return 1 - (1 - x) * (1 - x);
    case "easeInOutQuad":
    return x < 0.5 ? 2 * x * x : 1 - pow(-2 * x + 2, 2) / 2;
    case "easeInQuart":
    return x * x * x * x;
    case "easeOutQuart":
    return 1 - pow(1 - x, 4);
    case "easeInOutQuart":
    return x < 0.5 ? 8 * x * x * x * x : 1 - pow(-2 * x + 2, 4) / 2;
    case "easeInExpo":
    return x == 0 ? 0 : pow(2, 10 * x - 10);
    case "easeOutExpo":
    return x == 1 ? 1 : 1 - pow(2, -10 * x);
    case "easeInOutExpo":
     return x == 0
      ? 0
      : x == 1
      ? 1
      : x < 0.5 ? pow(2, 20 * x - 10) / 2
      : (2 - pow(2, -20 * x + 10)) / 2;
    case "easeInBack":
    return c3 * x * x * x - c1 * x * x;
    case "easeOutBack":
    return 1 + c3 * pow(x - 1, 3) + c1 * pow(x - 1, 2);
    case "easeInOutBack":
    return x < 0.5
  ? (pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
  : (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2;
    case "easeInBounce":
    return 1-ease(1-x, "easeOutBounce");
    case "easeOutBounce":
    if (x < 1 / d1) {
        return n1 * x * x;
    } else if (x < 2 / d1) {
        return n1 * (x -= 1.5 / d1) * x + 0.75;
    } else if (x < 2.5 / d1) {
        return n1 * (x -= 2.25 / d1) * x + 0.9375;
    } else {
        return n1 * (x -= 2.625 / d1) * x + 0.984375;
    }
    case "easeInOutBounce":
    return x < 0.5
  ? (1 - ease(1 - 2 * x, "easeOutBounce")) / 2
  : (1 + ease(2 * x - 1, "easeOutBounce")) / 2;
    case "easeStep":
    if(x > 0.99) return 1; //0.99 because x never technically reaches 1, it just gets very close
    else return 0;
    default:
    return x;
  }
}
PVector copyPVector(PVector v) {
  return new PVector(v.x, v.y, v.z);
}
ArrayList<CustomEvent> getCustomEventsAtTime(float t) {
  ArrayList<CustomEvent> temp = new ArrayList<CustomEvent>();
  for(int i = 0; i < customEvents.size(); i++) {
    CustomEvent e = customEvents.get(i);
    float duration = 0.4;
    if(e.data.containsKey("_duration")) duration = dapf(e.data.get("_duration"));
    if(t > e.time && t < e.time+duration) temp.add(customEvents.get(i));
  }
  return temp;
}
float bringCloser(float a, float b, int amount) {
  a += b*amount;
  return a/float(amount+1);
}
float average(float... vals) {
  float result = 0;
  for(int i = 0; i < vals.length; i++) {
    result += vals[i];
  }
  return result/float(vals.length-1);
}
boolean nearValue(float val1, float val2, float amount) {
  return (val1 > val2-amount) && (val1 < val2+amount);
}
JSONObject copyJSONObject(JSONObject obj) { //makes a deep copy of a JSONObject (only use with JSONObjects read from a file)
  JSONObject out = new JSONObject();
  Set keys = obj.keySet();
  for(Object i: keys) {
    Object o = obj.get(i);
    if(o instanceof JSONObject) out.put(i, copyJSONObject((JSONObject)o));
    else if(o instanceof JSONArray) out.put(i, copyJSONArray((JSONArray)o));
    else out.put(i, obj.get(i));
  }
  return out;
}
JSONArray copyJSONArray(JSONArray obj) { //makes a deep copy of a JSONArray (only use with JSONArrays read from a file)
  JSONArray out = new JSONArray();
  for(int i = 0; i < obj.size(); i++) {
    Object o = obj.get(i);
    if(o instanceof JSONObject) out.add(copyJSONObject((JSONObject)o));
    else if(o instanceof JSONArray) out.add(copyJSONArray((JSONArray)o));
    else out.add(obj.get(i));
  }
  return out;
}
JSONArray createJSONArray(Object... vals) {
  JSONArray out = new JSONArray();
  for(int i = 0; i < vals.length; i++) {
    out.add(vals[i]);
  }
  return out;
}
void addRenderElement(RenderElement e) {
  if(renderQueue.size() < MAX_RENDER_ELEMENTS) renderQueue.add(e);
}

ArrayList<String> formatJSON(String json) {
  ArrayList<String> out = new ArrayList<String>();
  String curr = "";
  int indentation = 0;
  boolean inSquareBrackets = false;
  for(int i = 0; i < json.length(); i++) {
    char c = json.charAt(i);
    switch(c) {
      case '{':
      out.add(multiplyString("  ", indentation)+curr);
      out.add(multiplyString("  ", indentation)+c);
      curr = "";
      indentation++;
      break;
      case '}':
      out.add(multiplyString("  ", indentation)+curr);
      indentation--;
      out.add(multiplyString("  ", indentation)+c);
      curr = "";
      break;
      case ',':
      if(inSquareBrackets) curr += ",";
      else {
        curr += ",";
        if(!curr.equals("")) out.add(multiplyString("  ", indentation)+curr);
        else out.set(out.size()-1, out.get(out.size()-1)+c);
        curr = "";
      }
      break;
      case '[':
      inSquareBrackets = true;
      curr += c;
      break;
      case ']':
      inSquareBrackets = false;
      curr += c;
      break;
      default:
      curr += c;
      break;
    }
  }
  if(!curr.equals("")) out.add(curr);
  return out;
}

String multiplyString(String a, int amount) {
  String out = "";
  for(int i = 0; i < amount; i++) {
    out += a;
  }
  return out;
}
