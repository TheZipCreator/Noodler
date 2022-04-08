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

class AddNotesAction extends Action {
  Note[] obj;
  
  AddNotesAction(Note[] obj) {
    super();
    this.obj = obj;
  }
  
  AddNotesAction(ArrayList<Note> obj) {
    super();
    this.obj = new Note[obj.size()];
    for(int i = 0; i < obj.size(); i++) {
      this.obj[i] = obj.get(i);
    }
  }
  
  @Override
  void commit() {
    for(int i = 0; i < obj.length; i++) {
      notes.add(obj[i]);
    }
  }
  
  @Override
  void undo() {
    for(int i = 0; i < obj.length; i++) {
      notes.remove(obj[i]);
    }
  }
}

class AddObstaclesAction extends Action {
  Obstacle[] obj;
  
  AddObstaclesAction(Obstacle[] obj) {
    super();
    this.obj = obj;
  }
  
  AddObstaclesAction(ArrayList<Obstacle> obj) {
    super();
    this.obj = new Obstacle[obj.size()];
    for(int i = 0; i < obj.size(); i++) {
      this.obj[i] = obj.get(i);
    }
  }
  
  @Override
  void commit() {
    for(int i = 0; i < obj.length; i++) {
      obstacles.add(obj[i]);
    }
  }
  
  @Override
  void undo() {
    for(int i = 0; i < obj.length; i++) {
      obstacles.remove(obj[i]);
    }
  }
}

class AddEventsAction extends Action {
  Event[] obj;
  
  AddEventsAction(Event[] obj) {
    super();
    this.obj = obj;
  }
  
  AddEventsAction(ArrayList<Event> obj) {
    super();
    this.obj = new Event[obj.size()];
    for(int i = 0; i < obj.size(); i++) {
      this.obj[i] = obj.get(i);
    }
  }
  
  @Override
  void commit() {
    for(int i = 0; i < obj.length; i++) {
      events.add(obj[i]);
    }
  }
  
  @Override
  void undo() {
    for(int i = 0; i < obj.length; i++) {
      events.remove(obj[i]);
    }
  }
}

class AddCustomEventsAction extends Action {
  CustomEvent[] obj;
  
  AddCustomEventsAction(CustomEvent[] obj) {
    super();
    this.obj = obj;
  }
  
  AddCustomEventsAction(ArrayList<CustomEvent> obj) {
    super();
    this.obj = new CustomEvent[obj.size()];
    for(int i = 0; i < obj.size(); i++) {
      this.obj[i] = obj.get(i);
    }
  }
  
  @Override
  void commit() {
    for(int i = 0; i < obj.length; i++) {
      customEvents.add(obj[i]);
    }
  }
  
  @Override
  void undo() {
    for(int i = 0; i < obj.length; i++) {
      customEvents.remove(obj[i]);
    }
  }
}
