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
  boolean mousePressed(int mouseX, int mouseY) {
    return false;
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
    app.text(tempValue, x, y+textSize-2);
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
    if(shftPressed) key = Character.toUpperCase(key);
    else key = Character.toLowerCase(key);
    if(isPrintableChar(key)) {
      tempValue += key;
    } else {
      if(keyCode == BACKSPACE && tempValue.length() > 0) tempValue = tempValue.substring(0, tempValue.length()-1);
      if(keyCode == ENTER) stopEditing();
    }
  }
  @Override
  boolean mousePressed(int mouseX, int mouseY) {
    if(mouseX > x && mouseX < x+xSize && mouseY > y && mouseY < y+ySize) {
      println(value);
      beingEdited = true;
      return true;
    } else {
      stopEditing();
      return false;
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
  boolean mousePressed(int mouseX, int mouseY) {
    if(mouseX > x && mouseX < x+xSize && mouseY > y && mouseY < y+ySize) {
      checked = !checked;
      return true;
    }
    return false;
  }
}

class FileSelector extends UIElement {
  String path;
  String title;
  String defaultPath;
  boolean directoryOrFile;
  
  FileSelector(int x, int y, String id, String path, boolean directoryOrFile /*true = directory, false = file*/, String defaultPath, String title) {
    super(x, y, 32, 32, id);
    this.path = path;
    this.directoryOrFile = directoryOrFile;
    this.title = title;
    this.defaultPath = defaultPath;
  }
  
  @Override
  void render(PApplet app) {
    app.image(UIElementImages.get("FileSelector"), x, y);
    app.textSize(16);
    app.fill(255);
    app.text(path, x+xSize+2, y+(ySize/2)+8);
  }
  @Override
  boolean mousePressed(int mouseX, int mouseY) {
    if(mouseX > x && mouseX < x+xSize && mouseY > y && mouseY < ySize) {
      try {
        File f = new File("c:\\");
        if(directoryOrFile) {
          DirectoryChooser chooser = new DirectoryChooser();
          File directory = new File(defaultPath);
          chooser.setInitialDirectory(directory);
          chooser.setTitle(title);
          f = chooser.showDialog(null);
        } else {
          FileChooser chooser = new FileChooser();
          File directory = new File(defaultPath);
          chooser.setTitle(title);
          chooser.setInitialDirectory(directory);
          f = chooser.showOpenDialog(null);
        }
        path = f.getAbsolutePath();
      } catch(NullPointerException e) {
        //no folder was selected
      } catch(IllegalArgumentException e) {
        println(defaultPath, path);
        throw e;
      }
      return true;
    } else {
      return false;
    }
  }
}

class CodeArea extends UIElement {
  public final static int TEXT_SIZE = 16;
  public final static float TEXT_WIDTH = 9.6;
  ArrayList<String> value;
  ArrayList<String> tempValue;
  boolean beingEdited;
  boolean finishedEditing;
  int cursorX;
  int cursorY;
  int cursorTimer = 0;
  
  CodeArea(int x, int y, int xSize, int ySize, String id,  ArrayList<String> value) {
    super(x, y, xSize, ySize, id);
    this.value = value;
    tempValue = new ArrayList<String>(value);
    cursorX = 1;
    cursorY = 1;
    finishedEditing = false;
  }
  @Override
  void render(PApplet app) {
    cursorTimer++;
    app.fill(32, 0, 32);
    app.strokeWeight(3);
    if(beingEdited) app.stroke(0, 0, 255);
    else app.stroke(255);
    app.rect(x, y, xSize, ySize);
    app.textSize(TEXT_SIZE);
    app.textFont(codeFont);
    app.fill(255);
    ArrayList<String> disp = beingEdited ? tempValue : value;
    for(int i = 0; i < disp.size(); i++) {
      app.text(disp.get(i), x, y+(TEXT_SIZE*(i+1)));
    }
    app.strokeWeight(1);
    if(beingEdited && cursorTimer%60 < 30) {
      app.stroke(255);
      app.line(x+(cursorX*TEXT_WIDTH), y+(cursorY*TEXT_SIZE), x+(cursorX*TEXT_WIDTH), y+((cursorY+1)*TEXT_SIZE));
    }
    app.textFont(textFont);
  }
  void keyPressed(char key, int keyCode) {
    cursorTimer = 0;
    if(isPrintableChar(key)) {
      tempValue.set(cursorY, insertChar(key, tempValue.get(cursorY), cursorX));
      cursorX++;
    } else {
      if(keyCode == RIGHT) {
        cursorX++;
        if(cursorX > tempValue.get(cursorY).length()) {
          cursorX = 0;
          cursorY++;
          if(cursorY > tempValue.size()-1) cursorY--;
        }
      }
      if(keyCode == LEFT) {
        cursorX--;
        if(cursorX < 0) {
          cursorY--;
          if(cursorY < 0) {
            cursorX = 0;
            cursorY++;
          } else {
            cursorX = tempValue.get(cursorY).length();
          }
        }
      }
      if(keyCode == UP) {
        cursorY--;
        if(cursorY < 0) cursorY = 0;
        if(cursorX > tempValue.get(cursorY).length()) cursorX = tempValue.get(cursorY).length();
      }
      if(keyCode == DOWN) {
        cursorY++;
        if(cursorY > tempValue.size()-1) cursorY = tempValue.size()-1;
        if(cursorX > tempValue.get(cursorY).length()) cursorX = tempValue.get(cursorY).length();
      }
      if(keyCode == ENTER) {
        String s = tempValue.get(cursorY);
        tempValue.set(cursorY, s.substring(0, cursorX));
        int numSpaces = 0;
        for(int i = 0; i < s.length(); i++) {
          if(s.charAt(i) == ' ') numSpaces++;
          else break;
        }
        s = s.substring(cursorX, s.length());
        for(int i = 0; i < numSpaces; i++) {
          s = ' '+s;
        }
        cursorX = numSpaces;
        cursorY++;
        tempValue.add(cursorY, s);
      }
      if(keyCode == TAB) {
        keyPressed(' ', ' ');
        keyPressed(' ', ' '); 
      }
      if(keyCode == BACKSPACE) {
        if(cursorX > 0) {
          tempValue.set(cursorY, removeChar(tempValue.get(cursorY), cursorX));
          cursorX--;
        } else {
          if(cursorY > 0) {
            String s = tempValue.get(cursorY);
            tempValue.remove(cursorY);
            cursorY--;
            cursorX = tempValue.get(cursorY).length();
            tempValue.set(cursorY, tempValue.get(cursorY)+s);
          }
        }
      }
    }
  }
  @Override
  boolean mousePressed(int mouseX, int mouseY) {
    cursorTimer = 0;
    if(mouseX > x && mouseX < x+xSize && mouseY > y && mouseY < y+ySize) {
      beingEdited = true;
      cursorX = floor((mouseX-x)/TEXT_WIDTH);
      cursorY = (mouseY-y)/TEXT_SIZE;
      if(cursorY > tempValue.size()-1) {
        cursorY = tempValue.size()-1;
        cursorX = tempValue.get(tempValue.size()-1).length();
      }
      if(cursorX > tempValue.get(cursorY).length()) {
        cursorX = tempValue.get(cursorY).length();
      }
      return true;
    } else {
      stopEditing();
      return false;
    }
  }
  void stopEditing() {
    value = new ArrayList<String>(tempValue);
    beingEdited = false;
    finishedEditing = true;
  }
  String getValue() {
    String out = "";
    for(int i = 0; i < value.size(); i++) {
      out += value.get(i)+"\n";
    }
    return out;
  }
  void setValue(ArrayList<String> val) {
    value = new ArrayList<String>(val);
    tempValue = new ArrayList<String>(val);
  }
}

class Button extends UIElement {
  String label;
  float textSize;
  boolean clicked = false;
  
  Button(int x, int y, int xSize, int ySize, String id, String label) {
    super(x, y, xSize, ySize, id);
    this.textSize = ySize;
    this.label = label;
  }
  @Override
  void render(PApplet app) {
    if(clicked) app.fill(128);
    else app.fill(0);
    app.stroke(255);
    app.strokeWeight(2);
    app.rect(x, y, xSize, ySize);
    app.textSize(textSize);
    app.textAlign(CENTER);
    app.fill(255);
    app.text(label, x+(xSize/2), y+textSize-2);
    app.textAlign(LEFT);
  }
  @Override
  boolean mousePressed(int mouseX, int mouseY) {
    if(mouseX > x && mouseX < x+xSize && mouseY > y && mouseY < y+ySize) {
      clicked = true;
      return true;
    }
    return false;
  }
}

boolean isPrintableChar( char c ) { //stolen from stackoverflow
    Character.UnicodeBlock block = Character.UnicodeBlock.of( c );
    return (!Character.isISOControl(c)) &&
            block != null &&
            block != Character.UnicodeBlock.SPECIALS;
}

String insertChar(char c, String s, int index) {
  return s.substring(0, index)+c+s.substring(index, s.length());
}
String removeChar(String s, int index) {
  return s.substring(0, index-1)+s.substring(index, s.length());
}
