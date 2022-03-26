class UIElement {
  int x;
  int y;
  int xSize;
  int ySize;
  String id;
  
  UIElement(int x, int y, int xSize, int ySize, String id) {
    this.x = x;
    this.y = y;
    this.xSize = xSize;
    this.ySize = ySize;
    this.id = id;
  }
  void render(PApplet app) {
    
  }
  void renderSecond(PApplet app) {
    
  }
  void keyPressed(char key, int keyCode) {
    
  }
  void mousePressed(int mouseX, int mouseY) {
    
  }
  boolean hasId(String testId) {
    return testId.equals(id);
  }
}

class TextBox extends UIElement {
  int textSize;
  String value;
  String tempValue;
  String label;
  boolean beingEdited;
  
  TextBox(int x, int y, int xSize, int ySize, String id, String value, String label) {
    super(x, y, xSize, ySize, id);
    this.textSize = ySize;
    this.value = value;
    this.label = label;
    tempValue = value;
  }
  @Override
  void render(PApplet app) {
    app.fill(255);
    app.strokeWeight(3);
    if(beingEdited) app.stroke(0, 128, 255);
    else {
      tempValue = value;
      app.stroke(128);
    }
    app.rect(x, y, xSize, ySize);
    app.noStroke();
    app.fill(0);
    app.textSize(textSize);
    app.text(tempValue, x, y+textSize);
    app.textSize(textSize*0.75);
    app.fill(255);
    app.text(label, x, y);
  }
  void stopEditing() {
    value = tempValue;
    beingEdited = false;
  }
  @Override
  void keyPressed(char key, int keyCode) {
    if(isPrintableChar(key)) {
      tempValue += key;
    } else {
      if(keyCode == BACKSPACE && tempValue.length() > 0) tempValue = tempValue.substring(0, tempValue.length()-1);
      if(keyCode == ENTER) stopEditing();
    }
  }
  @Override
  void mousePressed(int mouseX, int mouseY) {
    if(mouseX > x && mouseX < x+xSize && mouseY > y && mouseY < y+ySize) {
      println(value);
      beingEdited = true;
    } else {
      stopEditing();
    }
  }
}
class UImage extends UIElement {
  PImage image;
  String hover;
  
  UImage(int x, int y, String id, PImage image, String hover) {
    super(x, y, image.width, image.height, id);
    this.image = image;
    this.hover = hover;
  }
  @Override
  void render(PApplet app) {
    app.image(image, x, y);
  }
  @Override
  void renderSecond(PApplet app) {
    if(app.mouseX > x && app.mouseX < x+xSize && app.mouseY > y && app.mouseY < y+ySize) {
      app.fill(0, 128);
      app.stroke(255);
      app.textSize(16);
      app.rect(app.mouseX, app.mouseY-20, app.textWidth(hover)+2, 20);
      app.fill(255);
      app.text(hover, app.mouseX+2, app.mouseY-4);
    }
  }
  @Override
  void keyPressed(char key, int keyCode) {
    
  }
  @Override
  void mousePressed(int mouseX, int mouseY) {
    
  }
}

class CheckBox extends UIElement {
  boolean checked;
  String label;
  
  CheckBox(int x, int y, int xSize, int ySize, String id, boolean startChecked, String label) {
    super(x, y, xSize, ySize, id);
    checked = startChecked;
    this.label = label;
  }
  @Override
  void render(PApplet app) {
    app.fill(255);
    app.stroke(0);
    app.rect(x, y, xSize, ySize);
    app.textSize(ySize*0.75);
    app.text(label, x+xSize, y+ySize);
    if(checked) {
      app.fill(0, 128, 0);
      app.rect(x+(xSize/2)-(xSize/4), y+(ySize/2)-(ySize/4), xSize/2, ySize/2);
    }
  }
  @Override
  void mousePressed(int mouseX, int mouseY) {
    if(mouseX > x && mouseX < x+xSize && mouseY > y && mouseY < y+ySize) {
      checked = !checked;
    }
  }
}

class FileSelector extends UIElement {
  String path;
  String title;
  boolean directoryOrFile;
  
  FileSelector(int x, int y, String id, String path, boolean directoryOrFile /*true = directory, false = file*/, String title) {
    super(x, y, 32, 32, id);
    this.path = path;
    this.directoryOrFile = directoryOrFile;
    this.title = title;
  }
  
  @Override
  void render(PApplet app) {
    app.image(UIElementImages.get("FileSelector"), x, y);
    app.textSize(16);
    app.text(path, x+xSize+2, y+(ySize/2)+8);
  }
  @Override
  void mousePressed(int mouseX, int mouseY) {
    if(mouseX > x && mouseX < x+xSize && mouseY > y && mouseY < ySize) {
      File f = new File("c:\\");
      if(directoryOrFile) {
        DirectoryChooser chooser = new DirectoryChooser();
        File directory = new File(sketchPath());
        chooser.setInitialDirectory(directory);
        chooser.setTitle(title);
        f = chooser.showDialog(null);
      } else {
        FileChooser chooser = new FileChooser();
        File directory = new File(sketchPath());
        chooser.setTitle(title);
        chooser.setInitialDirectory(directory);
        f = chooser.showOpenDialog(null);
      }
      path = f.getAbsolutePath();
    }
  }
}

boolean isPrintableChar( char c ) { //stolen from stackoverflow
    Character.UnicodeBlock block = Character.UnicodeBlock.of( c );
    return (!Character.isISOControl(c)) &&
            block != null &&
            block != Character.UnicodeBlock.SPECIALS;
}
