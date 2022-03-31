class Action {
  
  Action() {
    
  }
  
  void commit() {
    
  }
  
  void undo() {
    
  }
}

class ChangeSelectionAction extends Action {
  Selection s; //the selection that was changed
  Selection before;
  Selection after;
  
  ChangeSelectionAction(Selection s, Selection before, Selection after) {
    super();
    this.before = before;
    this.after = after;
  }
  
  @Override
  void commit() {
    s = after.copy();
  }
  
  void undo() {
    s = before.copy();
  }
}

class ChangeNotesAction extends Action {
  Note[] pointers; //the notes in the notes array.
  ArrayList<Note> before;
  ArrayList<Note> after;
  
  ChangeNotesAction(ArrayList<Note> notePointers, ArrayList<Note> before, ArrayList<Note> after) {
    super();
    this.before = before;
    this.after = after;
    this.pointers = new Note[notePointers.size()];
    for(int i = 0; i < notePointers.size(); i++) {
      this.pointers[i] = notePointers.get(i);
    }
  }
  
  @Override
  void commit() {
    for(int i = 0; i < pointers.length; i++) {
      pointers[i] = after.get(i).copy();
    }
  }
  
  void undo() {
    for(int i = 0; i < pointers.length; i++) {
      pointers[i] = before.get(i).copy();
    }
  }
}

class ChangeObstaclesAction extends Action {
  Obstacle[] pointers; //the notes in the notes array.
  ArrayList<Obstacle> before;
  ArrayList<Obstacle> after;
  
  ChangeObstaclesAction(ArrayList<Obstacle> pointers, ArrayList<Obstacle> before, ArrayList<Obstacle> after) {
    super();
    this.before = before;
    this.after = after;
    this.pointers = new Obstacle[pointers.size()];
    for(int i = 0; i < pointers.size(); i++) {
      this.pointers[i] = pointers.get(i);
    }
  }
  
  @Override
  void commit() {
    for(int i = 0; i < pointers.length; i++) {
      pointers[i] = after.get(i).copy();
    }
  }
  
  void undo() {
    for(int i = 0; i < pointers.length; i++) {
      pointers[i] = before.get(i).copy();
    }
  }
}

class ChangeEventsAction extends Action {
  Event[] pointers; //the notes in the notes array.
  ArrayList<Event> before;
  ArrayList<Event> after;
  
  ChangeEventsAction(ArrayList<Event> pointers, ArrayList<Event> before, ArrayList<Event> after) {
    super();
    this.before = before;
    this.after = after;
    this.pointers = new Event[pointers.size()];
    for(int i = 0; i < pointers.size(); i++) {
      this.pointers[i] = pointers.get(i);
    }
  }
  
  @Override
  void commit() {
    for(int i = 0; i < pointers.length; i++) {
      pointers[i] = after.get(i).copy();
    }
  }
  
  void undo() {
    for(int i = 0; i < pointers.length; i++) {
      pointers[i] = before.get(i).copy();
    }
  }
}

class ChangeCustomEventsAction extends Action {
  CustomEvent[] pointers; //the notes in the notes array.
  ArrayList<CustomEvent> before;
  ArrayList<CustomEvent> after;
  
  ChangeCustomEventsAction(ArrayList<CustomEvent> pointers, ArrayList<CustomEvent> before, ArrayList<CustomEvent> after) {
    super();
    this.before = before;
    this.after = after;
    this.pointers = new CustomEvent[pointers.size()];
    for(int i = 0; i < pointers.size(); i++) {
      this.pointers[i] = pointers.get(i);
    }
  }
  
  @Override
  void commit() {
    for(int i = 0; i < pointers.length; i++) {
      pointers[i] = after.get(i).copy();
    }
  }
  
  void undo() {
    for(int i = 0; i < pointers.length; i++) {
      pointers[i] = before.get(i).copy();
    }
  }
}
