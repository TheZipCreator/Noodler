public class InfoWindow extends PApplet {
  public ArrayList<HashMap<String, Object>> noteHitboxes;
  public PImage tempImage;
  public ArrayList<UIElement> elements;
  public HashMap<String, PImage> propertyImages;
  public int oldWidth;
  public int oldHeight;
  public boolean isAlwaysOnTop = false;
  public boolean enabled = true;
  public PFont textFont;
  public PFont codeFont;
  public int state = 0;
  public int keyCode_;
  public char key_;
  boolean runkeyPress = false;
  boolean rankeyTyped = false;
  ArrayList<String> console;
  String currentString;
  
  
  public void settings() {
    size(800, 800, FX2D); //renderer is FX2D to avoid a crash when resizing window
    PJOGL.setIcon("data/img/logo.png");
  }
  public void setup() {
    surface.setResizable(true);
    frame.setResizable(true); //I know that I should use surface.setResizable(), but if I use that then it doesn't work correctly for some reason
    surface.setAlwaysOnTop(false);
    surface.setTitle("Info");
    surface.setLocation(-900, 0);
    infoWindow.ellipseMode(CORNER);
    tempImage = new PImage(width, height);
    oldWidth = width;
    oldHeight = height;
    elements = new ArrayList<UIElement>();
    background(0);
    textMode(MODEL);
    initializeUI();
    codeFont = createFont(sketchPath+codeFontPath, 16);
    textFont = createFont(sketchPath+textFontPath, 64);
    currentString = "";
    console = new ArrayList<String>();
    console.add("Test");
  }
  public void draw() {
    try {
      if(iw_canrender && enabled) {
        if(state == 0) {
          textFont(textFont);
          iw_canrender = false;
          if(width != oldWidth || height != oldHeight) {
            oldWidth = width;
            oldHeight = height;
            tempImage = new PImage(width, height);
          }
          background(0);
          fill(255);
          textSize(32);
          text("Precision:"+precision, 0, 32);
          float scaling = 0.5;
          float noteSpacing = noteSize*scaling;
          float x = noteSpacing*2;
          float y = 100;
          noteHitboxes = new ArrayList<HashMap<String, Object>>();
          for(int i = 0; i < notes.size(); i++) {
            HashMap<String, Object> hitbox = notes.get(i).render2d(scaling, x, y);
            if(hitbox != null) {
              hitbox.put("id", i);
              noteHitboxes.add(hitbox);
            }
          }
          strokeWeight(1);
          stroke(255);
          drawGrid(round(x-(2*noteSpacing)), round(y-(2*noteSpacing)), 8, 7, round(noteSpacing));
          stroke(0, 255, 0);
          drawGrid(round(x), round(y), 4, 3, round(noteSpacing));
          updateMenu();
          for(int i = 0; i < elements.size(); i++) {
            UIElement uie = elements.get(i);
            uie.render(this);
            switch(uie.id) {
              //case "note_x":
              //  notes.get(selection.get(0)).x = int(((TextBox)uie).value);
              //break;
              //case "note_y":
              //  notes.get(selection.get(0)).y = int(((TextBox)uie).value);
              //break;
              //case "note_cutDirection":
              //  notes.get(selection.get(0)).cutDirection = int(((TextBox)uie).value);
              //break;
              case "global_displayTracks":
                displayTracks = ((CheckBox)uie).checked;
              break;
              case "global_songPath":
                String path = ((FileSelector)uie).path;
                if(!(path.equals(songPath))) {
                  //loadSong(songPath, "Standard", "ExpertPlus");
                  songPath = path;
                }
              break;
              case "global_alwaysOnTop":
                boolean aot = ((CheckBox)uie).checked;
                if(isAlwaysOnTop != aot) {
                  surface.setAlwaysOnTop(aot);
                  isAlwaysOnTop = aot;
                }
              break;
              case "global_enableAssignPlayerToTrack":
                enableAssignPlayerToTrack = (((CheckBox)uie).checked);
              break;  
              case "global_difficulty":
                difficulty = ((TextBox)uie).value;
              break;
              case "global_characteristic":
                characteristic = ((TextBox)uie).value;
              break;
              case "global_enabled":
                enabled = ((CheckBox)uie).checked;
              break;
              case "global_renderMarkers":
                renderMarkers = ((CheckBox)uie).checked;
                break;
              case "editSelection_editNotes":
                Button b = (Button)uie;
                if(b.clicked) {
                  b.clicked = false;
                  elements = new ArrayList<UIElement>();
                  state = 1;
                  initializeUI();
                }
                break;
              default:
              break;
            }
          }
          for(int i = 0; i < elements.size(); i++) {
            elements.get(i).renderSecond(this);
          }
        } else if(state == 1) {
          updateMenu();
          background(0);
          textSize(64);
          text("Editing "+selection.selectedNotes.size()+" Note"+(selection.selectedNotes.size() > 1 ? "s" : ""), 64, 64);
          for(int i = 0; i < elements.size(); i++) {
            UIElement uie = elements.get(i);
            uie.render(this);
            switch(uie.id) {
              case "global_return":
              if(((Button)uie).clicked) {
                state = 0;
                elements = new ArrayList<UIElement>();
                initializeUI();
              }
              break;
              case "global_json":
              CodeArea ca = (CodeArea)uie;
              if(ca.finishedEditing) {
                ca.finishedEditing = false;
                try {
                  selection.selectedNotes.get(0).fromJSON((JSONObject)p.parse(ca.getValue()));
                } catch(ParseException e) {
                  ca.beingEdited = true;
                }
              } else {
                if(!ca.beingEdited) ca.setValue(formatJSON(selection.selectedNotes.get(0).toJSON().toString()));
              }
              break;
              default:
              break;
            }
          }
        } else if(state == 2) {
          background(0);
          textFont(codeFont);
          textSize(16);
          stroke(255);
          line(0, height-16, width, height-16);
        }
        loadPixels();
        tempImage.pixels = pixels;
        tempImage.updatePixels();
      } else {
        image(tempImage, 0, 0);
      }
    } catch(AssertionError e) {
      println("Assertion Error");
    }
    if(runkeyPress) {
      keyPress();
      runkeyPress = false;
    }
  }
  public void mousePressed() {
    float scaling = 0.5;
    float noteSpacing = noteSize*scaling;
    //find the closest (in time) note that the player clicked
    //this algorithm will fail if a song is longer than 99999999 beats, but that will never happen, right? right???
    int winner = -1;
    float winnerTime = 9999999;
    for(int i = 0; i < noteHitboxes.size(); i++) {
      PVector position = (PVector)noteHitboxes.get(i).get("position");
      PVector scale = (PVector)noteHitboxes.get(i).get("scale");
      int id = (int)noteHitboxes.get(i).get("id");
      position.x -= noteSpacing*0.5;
      position.y -= noteSpacing*0.5;
      //println(mouseX, mouseY, position.x, position.y, position.x+scale.x, position.y+scale.y);
      if(mouseX > position.x && mouseY > position.y && mouseX < position.x+scale.x && mouseY < position.y+scale.y) {
        if(notes.get(id).time < winnerTime) {
          winner = id;
          winnerTime = notes.get(id).time;
        }
      }
    }
    if(winner != -1) { //if a note was clicked
      Note n = notes.get(winner);
      if(shftPressed) {
        if(!selection.containsNote(n)) { //if the note is not selected
          selection.selectNote(winner); //select the note
        } else { //otherwise
          selection.deselectNote(winner);
        }
      }
    }
    for(int i = 0; i < elements.size(); i++) { //<>// //<>// //<>//
      if(elements.get(i).mousePressed(mouseX, mouseY)) return;
    }
  }
  void keyPress() {
    if(keyCode_ == SHIFT) shftPressed = true;
    for(int i = 0; i < elements.size(); i++) {
      UIElement uie = elements.get(i);
      uie.keyPressed(rankeyTyped ? key_ : 0, keyCode_);
    }
    rankeyTyped = false;
  }
  void keyTyped() {
    key_ = key;
    rankeyTyped = true;
  }
  void keyPressed() {
    keyCode_ = keyCode;
    runkeyPress = true;
  }
  public void keyReleased() {
    if(keyCode == SHIFT) shftPressed = false;
  }
  public void updateMenu() {
    if(state == 0) {
      elements = removeElementStart(elements, "customEvent");
      ArrayList<CustomEvent> ce = getCustomEventsAtTime(cursor);
      int apa_y = 250;
      int at_y = 350;
      int apa_x = 0;
      int at_x = 0;
      textSize(16);
      fill(255);
      noStroke();
      text("AssignPathAnimation:", 0, apa_y);
      text("AnimateTrack:", 0, at_y);
      for(int i = 0; i < ce.size(); i++) {
        CustomEvent event = ce.get(i);
        if(event.type.equals("AssignPathAnimation") || event.type.equals("AnimateTrack")) {
          Set<String> temp = event.data.keySet();
          Set<String> properties = new HashSet<String>(temp);
          Object track_obj = event.data.get("_track");
          String[] track = new String[0];
          if(track_obj instanceof String) {
            track = new String[1];
            track[0] = (String)event.data.get("_track");
          } else if(track_obj instanceof JSONArray) {
            JSONArray arr = (JSONArray)track_obj;
            track = new String[arr.size()];
            for(int j = 0; j < track.length; j++) {
              track[j] = (String)arr.get(j);
            }
          }
          int tempy = 0;
          int x = at_x;
          if(event.type.equals("AssignPathAnimation")) x = apa_x;
          int y = at_y;
          if(event.type.equals("AssignPathAnimation")) y = apa_y;
          //remove things that aren't properties
          if(properties.contains("_duration")) properties.remove("_duration");
          if(properties.contains("_track")) properties.remove("_track");
          if(properties.contains("_easing")) properties.remove("_easing");
          if(tracks.containsKey(track[0])) {
            color c = tracks.get(track[0]).col;
            fill(red(c), green(c), blue(c));
            rect(x, y, propertyImageSize, propertyImageSize*properties.size());
          }
          for(String j: properties) {
            if(propertyImages.containsKey(j) && simplePropertyNames.containsKey(j)) {
              elements.add(new UImage(x, tempy+y, "customEvent_"+track, propertyImages.get(j), simplePropertyNames.get(j)+" Animation on Track "+track));
            } else {
              println(j);
            }
            tempy += propertyImageSize;
          }
          if(event.type.equals("AssignPathAnimation")) apa_x += propertyImageSize;
          else at_x += propertyImageSize;
        }
      }
      //if(selection.size() == 1) {
      //  if(!UIContains(elements, "note_x")) {
      //    Note n = notes.get(selection.get(0));
      //    elements.add(new TextBox(50, 500, 150, 25, "note_x", str(n.x), "Line Layer"));
      //    elements.add(new TextBox(50, 550, 150, 25, "note_y", str(n.y), "Line Index"));
      //    elements.add(new TextBox(50, 600, 150, 25, "note_cutDirection", str(n.cutDirection), "Cut Direction"));
      //  }
      //} else {
      //  if(UIContains(elements, "note_x")) {
      //    elements = removeElement(elements, "note_x");
      //    elements = removeElement(elements, "note_y");
      //    elements = removeElement(elements, "note_cutDirection");
      //  }
      //}
      if(selection.selectedNotes.size() > 0 && !UIContains(elements, "editSelection_editNotes")) {
        elements.add(new Button(100, 500, 200, 25, "editSelection_editNotes", "Edit Notes"));
      }
      if(selection.selectedNotes.size() < 1) removeElement(elements, "editSelection_editNotes");
    } else if(state == 1) {
      
    }
  }
  
  public void initializeUI() {
    if(state == 0) {
      elements.add(new CheckBox(300, 130, 25, 25, "global_displayTracks", false, "Display Tracks"));
      elements.add(new CheckBox(300, 160, 25, 25, "global_alwaysOnTop", false, "Always On Top"));
      elements.add(new CheckBox(300, 190, 25, 25, "global_enableAssignPlayerToTrack", false, "Enable AssignPlayerToTrack Events"));
      elements.add(new CheckBox(300, 220, 25, 25, "global_renderMarkers", renderMarkers, "Render Markers"));
      elements.add(new TextBox(300, 100, 200, 25, "global_difficulty", difficulty, "Difficulty"));
      elements.add(new TextBox(510, 100, 200, 25, "global_characteristic", characteristic, "Characteristic"));
      elements.add(new FileSelector(300, 0, "global_songPath", songPath, true, sketchPath+"/data/levels", "Pick Map"));
    } else if(state == 1) {
      elements.add(new Button(1, 8, 64, 64, "global_return", "<"));
      Note n = selection.selectedNotes.get(0);
      elements.add(new CodeArea(50, 100, width-100, 400, "global_json", formatJSON(n.toJSON().toString())));
    }
  }
  
  void drawGrid(int x, int y, int xSize, int ySize, int spacing) {
    for(int i = 0; i < xSize+1; i++) {
      line(x+(i*spacing), y, x+(i*spacing), y+(spacing*ySize));
    }
    for(int i = 0; i < ySize+1; i++) {
      line(x, y+(i*spacing), x+(spacing*xSize), y+(i*spacing));
    }
  }
}

boolean UIContains(ArrayList<UIElement> elements, String id) {
  for(int i = 0; i < elements.size(); i++) {
    if(elements.get(i).hasId(id)) return true;
  }
  return false;
}

ArrayList<UIElement> removeElement(ArrayList<UIElement> elements, String id) {
  for(int i = elements.size()-1; i >= 0; i--) {
    if(elements.get(i).hasId(id)) {
      elements.remove(i);
    }
  }
  return elements;
}

ArrayList<UIElement> removeElementStart(ArrayList<UIElement> elements, String id) {
  for(int i = elements.size()-1; i >= 0; i--) {
    if(elements.get(i).id.startsWith(id)) {
      elements.remove(i);
    }
  }
  return elements;
}
