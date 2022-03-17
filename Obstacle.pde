class Obstacle {
  float time;
  int x;
  int type;
  float duration;
  int width;
  JSONObject customData;
  
  Obstacle(float time, int x, int widt, float duration, int type) {
    this.time = time;
    this.x = x;
    this.width = widt;
    this.type = type;
    this.duration = duration;
    customData = new JSONObject();
  }
  Obstacle addCustomData(JSONObject cd) {
    if(cd == null) return this;
    customData = (JSONObject)cd;
    if(customData.containsKey("_track")) {
      try {
        Object obj = (String)customData.get("_track");
        String t = "";
        if(obj instanceof String ) t = (String)customData.get("_track");
        else t = (String)((JSONArray)customData.get("_track")).get(0); //for some reason, some maps have their notes' _track set to a jsonarray. This assumingly has the bahavior of assigning it to 2 tracks simultaneously. This is not documented anywhere in the Heck docs, and crashes on Quest. I just take the first track from there and call it a day
        if(!tracks.containsKey(t)) tracks.put(t, new Track(t));
      } catch(Exception e) {
        println(customData.get("_track"));
        return this;
      }
    }
    return this;
  }
  
  void render() {
    JSONObject trackCD = new JSONObject();
    JSONObject tempCD = (JSONObject)customData;
    try {
    if(customData.containsKey("_track")) {
      trackCD = tracks.get((String)customData.get("_track")).properties;
      Set<String> keys = trackCD.keySet();
      for(String i : keys) {
        tempCD.put(i, (JSONArray)trackCD.get(i));
      }
    }
    } catch(Exception e) {
      println(tracks.get((String)customData.get("_track")));
      throw e;
    }
    float njs = noteJumpSpeed;
    float sbo = startBeatOffset;
    boolean changed = false;
    if(customData.containsKey("_noteJumpMovementSpeed")) {
      njs = dapf(customData.get("_noteJumpMovementSpeed"));
      changed = true;
    }
    if(customData.containsKey("_noteJumpStartBeatOffset")) {
      sbo = dapf(customData.get("_noteJumpStartBeatOffset"));
      changed = true;
    }
    float tempTime = time;
    boolean changedTime = false;
    if(tempCD.containsKey("_time")) {
      float newTime = (dapf(((JSONArray)tempCD.get("_time")).get(0)));
      newTime = map(newTime, 0, 1, 1, -1);
      float jd = getJumpDistance(njs, sbo);
      float offset = ((jd/2)*newTime)*(editorScale/noteSize);
      tempTime = cursor+offset;
      changedTime = true;
      //tempTime = time+getTimeFromAnimPosition(dapf(tempCD.get("_time")), getJumpDistance(njs, sbo));
      /*println(getTimeFromAnimPosition(dapf(tempCD.get("_time")), getJumpDistance(njs, sbo)))*/;
    }
    if(!(tempTime > cursor-cutoffPoint && tempTime < cursor+cutoffPoint)) return; //make sure the note is reasonably close to the cursor
    if(!changed) if(!decideToRender(time-cursor, jumpDistance)) return;
    else if(!decideToRender(time-cursor, getJumpDistance(njs, sbo))) return;
    fill(red(obstacleColor), green(obstacleColor), blue(obstacleColor), 128);
    PVector position = BeatwallsToPosition(new PVector(x-1.5, 3, time), njs);
    PVector scale = new PVector(this.width*noteSize, ((1-type)+1)*1.5*noteSize, duration*editorScale*noteSize);
    PVector rotation = new PVector(0, 0, 0);
    boolean interactable = true;
    PVector localRotation = new PVector(0, 0, 0);
    float h = 3;
    if(type == 1) h = 1.5;
    float localjd = jumpDistance;
    if(decideToRender(time-cursor, getJumpDistance(njs, sbo))) { 
      localjd = getJumpDistance(njs, sbo);
    }
    //noodle
    float animPosition = getAnimPosition(time-cursor, localjd);
    //println(animPosition);
    float dissolve = 1;
    JSONObject animations = new JSONObject();
    if(customData.containsKey("_animation")) {
      animations = (JSONObject)customData.get("_animation");
    } else if(customData.containsKey("_track")){
      animations = tracks.get((String)customData.get("_track")).getMostRecentPathAnimation(cursor);
    }
      Set<String> keys = animations.keySet();
      for(String i : keys) {
        try {
          Animation a;
          if(animations.get(i) instanceof JSONArray) a = new Animation((JSONArray)animations.get(i), i);
          else a = new Animation(pointDefinitions.get((String)animations.get(i)), i);
          JSONArray arr = a.getPropertyAtPosition(animPosition);
          if(trackCD.containsKey(a.property)) {
            JSONArray temp = (JSONArray)trackCD.get(a.property);
            switch(a.property) {
              case "_position":
              case "_localRotation":
              case "_rotation":
              case "_definitePosition":
              tempCD.put(a.property, addArrays(arr, temp));
              break;
              case "_scale":
              case "_dissolve":
              case "_dissolveArrow":
              case "_color":
              case "_interactable":
              tempCD.put(a.property, multArrays(arr, temp));
              break;
              default:
              tempCD.put(a.property, addArrays(arr, temp));
              break;
            }
          }
          else tempCD.put(a.property, arr);
          //println(arr.get(0), arr.get(1), arr.get(2));
        } catch(Exception e) {
          throw e;
        }
      }
    Set<String> keys2 = trackCD.keySet();
    for(String i : keys2) {
      if(!tempCD.containsKey(i)) tempCD.put(i, (JSONArray)trackCD.get(i));
    }
    if(tempCD.containsKey("_scale")) { //scale
      JSONArray sca = (JSONArray)tempCD.get("_scale");
      if(sca.size() > 2) scale = new PVector(dapf(sca.get(0))*noteSize, dapf(sca.get(1))*noteSize, dapf(sca.get(2))*noteSize);
      else scale = new PVector(dapf(sca.get(0))*noteSize, dapf(sca.get(1))*noteSize, scale.z);
      h = scale.y/noteSize;
    }
    PVector _position = new PVector(0, h, 0);
    if(tempCD.containsKey("_position")) { //position
      JSONArray pos = (JSONArray)tempCD.get("_position");
      _position = new PVector(_position.x+dapf(pos.get(0)), _position.y+dapf(pos.get(1)));
      position = BeatwallsToPosition(new PVector(dapf(pos.get(0))-0.5, dapf(pos.get(1))+h-0.5, tempTime), njs);
    }
    if(tempCD.containsKey("_definitePosition")) { //definite position
      JSONArray pos = (JSONArray)tempCD.get("_definitePosition");
      PVector temp = BeatwallsToPosition(new PVector(_position.x+dapf(pos.get(0))-0.5, _position.y+dapf(pos.get(1))+h-0.5, tempTime), njs);
      float z = -dapf(pos.get(2));
      //temp.z = -(((z*noteSize)-(cursor*noteSize)));
      temp.z = z*noteSize;
      position = temp;
    }
    if(tempCD.containsKey("_interactable")) { //interactable
      interactable = (boolean)tempCD.get("_interactable");
    }
    if(tempCD.containsKey("_rotation")) { //rotation
      Object o = tempCD.get("_rotation");
      if(isNumber(o)) {
        float rot = dapf(o);
        rotation = new PVector(0, rot, 0);
      } else {
        JSONArray rot = (JSONArray)o;
        rotation.x = dapf(rot.get(0));
        rotation.y = dapf(rot.get(1));
        rotation.z = dapf(rot.get(2));
      }
    }
    if(tempCD.containsKey("_localRotation")) { //local rotation
      JSONArray lr = (JSONArray)tempCD.get("_localRotation");
      localRotation = new PVector(dapf(lr.get(0)), dapf(lr.get(1)), dapf(lr.get(2)));
    }
    if(tempCD.containsKey("_dissolve")) {
      dissolve = dapf(((JSONArray)tempCD.get("_dissolve")).get(0));
    }
    color colr = obstacleColor;
    if(tempCD.containsKey("_color")) { //chroma custom color
      JSONArray col = (JSONArray)tempCD.get("_color");
      colr = color(dapf(col.get(0))*255, dapf(col.get(1))*255, dapf(col.get(2))*255, dissolve*128);
    }
    if(dissolve < 0) dissolve = -dissolve*2;
    if(dissolve > 0.01) {
      renderQueue.add(new RenderObstacle(position, rotation, localRotation, scale, dissolve*0.5, colr));
    }
  }
}
