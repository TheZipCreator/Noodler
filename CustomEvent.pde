class CustomEvent implements Comparable {
  float time;
  String type;
  JSONObject data;
  
  CustomEvent(float time, String type, JSONObject data) {
    this.time = time;
    this.type = type;
    this.data = data;
  }
  
  void findTracks() {
    if(data.containsKey("_track")) {
      String t = (String)data.get("_track");
      if(!tracks.containsKey(t)) tracks.put(t, new Track(t));
    }
  }
  
  @Override
  int compareTo(Object o) {
    return round(time*1000)-round(((CustomEvent)o).time*1000);
  }
  
  @Override
  String toString() {
    return time+" ";
  }
}
