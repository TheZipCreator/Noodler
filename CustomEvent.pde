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
  
  JSONObject toJSON() {
    JSONObject obj = new JSONObject();
    obj.put("_time", time);
    obj.put("_type", type);
    if(data.size() > 0) obj.put("_data", data);
    return obj;
  }
  
  void fromJSON(JSONObject obj) {
    if(obj.containsKey("_time")) time = dapf(obj.get("_time"));
    if(obj.containsKey("_type")) type = (String)obj.get("_type");
    if(obj.containsKey("_data")) data = (JSONObject)obj.get("_data");
  }
  
  CustomEvent copy() {
    return new CustomEvent(time, type, copyJSONObject(data));
  }
}
