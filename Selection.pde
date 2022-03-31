class Selection {
  ArrayList<Note> selectedNotes;
  ArrayList<Obstacle> selectedObstacles;
  ArrayList<CustomEvent> selectedCustomEvents;
  ArrayList<Event> selectedEvents;
  
  Selection() {
    selectedNotes = new ArrayList<Note>();
    selectedObstacles = new ArrayList<Obstacle>();
    selectedCustomEvents = new ArrayList<CustomEvent>();
    selectedEvents = new ArrayList<Event>();
  }
  
  void selectNote(int index) {
    selectedNotes.add(notes.get(index));
  }
  void selectObstacle(int index) {
    selectedObstacles.add(obstacles.get(index));
  }
  void selectCustomEvent(int index) {
    selectedCustomEvents.add(customEvents.get(index));
  }
  void selectedEvent(int index) {
    selectedEvents.add(events.get(index));
  }
  
  void deselectNote(int index) {
    for(int i = 0; i < selectedNotes.size(); i++) {
      if(notes.get(index) == selectedNotes.get(i)) {
        selectedNotes.remove(i);
        return;
      }
    }
  }
  void deselectObstacle(int index) {
    for(int i = 0; i < selectedObstacles.size(); i++) {
      if(obstacles.get(index) == selectedObstacles.get(i)) {
        selectedObstacles.remove(i);
        return;
      }
    }
  }
  void deselectCustomEvent(int index) {
    for(int i = 0; i < selectedNotes.size(); i++) {
      if(customEvents.get(index) == selectedCustomEvents.get(i)) {
        selectedCustomEvents.remove(i);
        return;
      }
    }
  }
  void deselectEvent(int index) {
    for(int i = 0; i < selectedNotes.size(); i++) {
      if(events.get(index) == selectedEvents.get(i)) {
        selectedEvents.remove(i);
        return;
      }
    }
  }
  boolean containsNote(Note n) {
    return selectedNotes.contains(n);
  }
  boolean containsObstacle(Obstacle o) {
    return selectedObstacles.contains(o);
  }
  boolean containsCustomEvent(CustomEvent c) {
    return customEvents.contains(c);
  }
  boolean containsEvent(Event e) {
    return events.contains(e);
  }
  
  Selection copy() {
    Selection s = new Selection();
    s.selectedNotes = new ArrayList<Note>(selectedNotes);
    s.selectedObstacles = new ArrayList<Obstacle>(selectedObstacles);
    s.selectedCustomEvents = new ArrayList<CustomEvent>(selectedCustomEvents);
    s.selectedEvents = new ArrayList<Event>(selectedEvents);
    return s;
  }
}
