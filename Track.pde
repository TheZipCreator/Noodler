class Track {
  JSONObject properties;
  String name;
  ArrayList<CustomEvent> events;
  color col;
  boolean updatedThisFrame;
  
  Track(String name) {
    properties = new JSONObject();
    this.name = name;
    events = new ArrayList<CustomEvent>();
    //find all custom events related to this track
    for(int i = 0; i < customEvents.size(); i++) {
      CustomEvent e = customEvents.get(i);
      //if(((String)e.type).equals("AnimateTrack")) {
        Object o = e.data.get("_track");
        if(o instanceof String) {
          if(((String)e.data.get("_track")).equals(name)) {
            events.add(e);
          }
        } else if(o instanceof JSONArray) {
          JSONArray arr = (JSONArray)o;
          if(arr.contains(name)) events.add(e);
        }
      //}
    }
    col = color(random(64, 192), random(64, 192), random(64, 192));
    Collections.sort(this.events);
    updatedThisFrame = false;
  }
  
  void update() {
    updatedThisFrame = true;
    properties = new JSONObject();
    for(int i = 0; i < events.size(); i++) {
      CustomEvent e = events.get(i);
      if(cursor > e.time && e.type.equals("AnimateTrack")) {
        JSONObject data = e.data;
        Set<String> keys = data.keySet();
        float duration = dapf(data.get("_duration"));
        float time = e.time;
        for(String j : keys) {
          if(!j.equals("_track") && !j.equals("_duration") && !j.equals("_easing")) {
            Animation a;
            if(data.get(j) instanceof JSONArray) a = new Animation((JSONArray)data.get(j), j);
            else if(data.get(j) instanceof String) a = new Animation(pointDefinitions.get(((String)data.get(j))), j);
            else a = new Animation(createJSONArray(0, 0, 0, 0, 0, 0), j);
            float animPosition = (cursor-time)/duration;
            if(animPosition > 1) animPosition = 1;
            properties.put(j, a.getPropertyAtPosition(animPosition));
          }
        }
      }
    }
  }
  JSONObject getMostRecentPathAnimation(float time) {
    JSONObject temp = new JSONObject();
    HashMap<String, Object[]> lastDurations = new HashMap<String, Object[]>();
    for(int i = 0; i < events.size(); i++) {
      if(time > events.get(i).time && events.get(i).type.equals("AssignPathAnimation")) {
        CustomEvent e = events.get(i);
        JSONObject data = e.data;
        Set<String> keySet = data.keySet();
        for(String j : keySet) {
          if(!j.equals("_easing") && !j.equals("_track") && !j.equals("_duration")) {
            if(temp.containsKey(j)) {
              float duration = dapf(lastDurations.get(j)[0]);
              String easing = "easeLinear";
              if(data.containsKey("_easing")) easing = (String)data.get("_easing");
              JSONArray otherAnim = new JSONArray();
              if(temp.get(j) instanceof JSONArray) otherAnim = (JSONArray)temp.get(j);
              else otherAnim = pointDefinitions.get((String)temp.get(j));
              JSONArray thisAnim = new JSONArray();
              if(data.get(j) instanceof JSONArray) thisAnim = (JSONArray)data.get(j);
              else thisAnim = pointDefinitions.get((String)data.get(j));
              if(time > duration+e.time) temp.put(j, data.get(j));
              else {
                //Interpolate between animations
                Animation a = new Animation(thisAnim, j);
                Animation b = new Animation(otherAnim, j);
                float aWeight = (time-e.time)/duration;
                aWeight = ease(aWeight, easing);
                float bWeight = 1-aWeight;
                temp.put(j, a.interpolate(b, aWeight, bWeight));
              }
            } else temp.put(j, data.get(j));
          }
        }
        float duration = 0;
        String easing = "easeLinear";
        if(data.containsKey("_duration")) {
          duration = dapf(data.get("_duration"));
        }
        if(data.containsKey("_easing")) {
          easing = (String)data.get("_easing");
        }
        for(String j : keySet) {
          if(!j.equals("_easing") && !j.equals("_track") && !j.equals("_duration")) {
            Object[] arr = {duration, easing, new JSONArray()};
            if(data.get(j) instanceof JSONArray) arr[2] = (JSONArray)data.get(j);
            else arr[2] = pointDefinitions.get((String)data.get(j));
            lastDurations.put(j, arr);
          }
        }
      }
    }
    return temp;
  }
}
