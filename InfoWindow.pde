public class InfoWindow extends PApplet {
  public ArrayList<HashMap<String, Object>> noteHitboxes;
  public PImage tempImage;
  public ArrayList<UIElement> elements;
  public HashMap<String, PImage> propertyImages;
  public int oldWidth;
  public int oldHeight;
  
  public void settings() {
    size(800, 800, FX2D); //renderer is FX2D to avoid a crash when resizing window
    PJOGL.setIcon("data/img/logo.png");
  }
  public void setup() {
    surface.setResizable(true);
    frame.setResizable(true);
    surface.setTitle("Info");
    surface.setLocation(-900, 0);
    infoWindow.ellipseMode(CORNER);
    tempImage = new PImage(width, height);
    oldWidth = width;
    oldHeight = height;
    elements = new ArrayList<UIElement>();
    background(0);
    textMode(MODEL);
    elements.add(new CheckBox(50, 100, 25, 25, "global_displayTracks", false, "Display Tracks"));
    elements.add(new FileSelector(300, 0, "global_songPath", songPath, true, "Pick Map"));
  }
  public void draw() {
    if(iw_canrender) {
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
      float x = (width/2)-noteSpacing*2;
      float y = 100;
      noteHitboxes = new ArrayList<HashMap<String, Object>>();
      for(int i = 0; i < notes.size(); i++) {
        HashMap<String, Object> hitbox = notes.get(i).render2d(scaling, x, y, selection.contains(i));
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
          case "note_x":
            notes.get(selection.get(0)).x = int(((TextBox)uie).value);
          break;
          case "note_y":
            notes.get(selection.get(0)).y = int(((TextBox)uie).value);
          break;
          case "note_cutDirection":
            notes.get(selection.get(0)).cutDirection = int(((TextBox)uie).value);
          break;
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
          default:
          break;
        }
      }
      for(int i = 0; i < elements.size(); i++) {
        elements.get(i).renderSecond(this);
      }
      loadPixels();
      tempImage.pixels = pixels;
      tempImage.updatePixels();
    } else {
      image(tempImage, 0, 0);
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
        if(!selection.contains(winner)) { //if the note is not selected
          selection.add(winner); //select the note
        } else { //otherwise
          for(int i = selection.size()-1; i >= 0; i--) { //find the note in the selecton and deselect it
            if(selection.get(i) == winner) selection.remove(i);
          }
        }
      }
    }
    for(int i = 0; i < elements.size(); i++) { //<>//
      elements.get(i).mousePressed(mouseX, mouseY);
    }
  }
  public void keyPressed() {
    if(keyCode == SHIFT) shftPressed = true;
    for(int i = 0; i < elements.size(); i++) {
      UIElement uie = elements.get(i);
      uie.keyPressed(key, keyCode);
    }
  }
  public void keyReleased() {
    if(keyCode == SHIFT) shftPressed = false;
  }
  public void updateMenu() {
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
        String track = (String)event.data.get("_track");
        int tempy = 0;
        int x = at_x;
        if(event.type.equals("AssignPathAnimation")) x = apa_x;
        int y = at_y;
        if(event.type.equals("AssignPathAnimation")) y = apa_y;
        //remove things that aren't properties
        if(properties.contains("_duration")) properties.remove("_duration");
        if(properties.contains("_track")) properties.remove("_track");
        if(properties.contains("_easing")) properties.remove("_easing");
        if(tracks.containsKey(track)) {
          color c = tracks.get(track).col;
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
    if(selection.size() == 1) {
      if(!UIContains(elements, "note_x")) {
        Note n = notes.get(selection.get(0));
        elements.add(new TextBox(50, 500, 150, 25, "note_x", str(n.x), "Line Layer"));
        elements.add(new TextBox(50, 550, 150, 25, "note_y", str(n.y), "Line Index"));
        elements.add(new TextBox(50, 600, 150, 25, "note_cutDirection", str(n.cutDirection), "Cut Direction"));
      }
    } else {
      if(UIContains(elements, "note_x")) {
        elements = removeElement(elements, "note_x");
        elements = removeElement(elements, "note_y");
        elements = removeElement(elements, "note_cutDirection");
      }
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
