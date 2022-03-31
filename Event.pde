class Event { //lighting events. CustomEvents are their own thing
  float time;
  int type;
  //1 = back lasers
  //2 = big rings
  //3 = left rotating lasers
  //4 = right rotating lasers
  //5 = center lights
  int value;
  //0 = off
  //1 = right on
  //2 = right flash
  //3 = right fade
  //5 = left on
  //6 = left flash
  //7 = left fade
  JSONObject customData;
  boolean activated = false;
  
  Event(float time, int type, int value) {
    this.time = time;
    this.type = type;
    this.value = value;
    this.customData = new JSONObject();
  }
  
  Event addCustomData(JSONObject cd) {
    if(cd == null) return this;
    customData = (JSONObject)cd;
    return this;
  }
  
  color getColor() {
    color c = color(0, 0, 0, 0);
    float progress = cursor-time;
    progress = constrain(progress, 0, 1);
    if(value == 0) c = color(0, 0, 0, 0);
    else if(customData.containsKey("_color")) {
      JSONArray col = (JSONArray)customData.get("_color");
      c = color(dapf(col.get(0))*255, dapf(col.get(1))*255, dapf(col.get(2))*255);
    } else if(customData.containsKey("_lightGradient")) {
      JSONArray scol = (JSONArray)((JSONObject)customData.get("_lightGradient")).get("_startColor");
      JSONArray ecol = (JSONArray)((JSONObject)customData.get("_lightGradient")).get("_endColor");
      float duration = dapf(((JSONObject)customData.get("_lightGradient")).get("_duration"));
      progress = constrain(cursor-(time+duration), 0, 1);
      progress *= duration;
      float scol_a = 255;
      float ecol_a = 255;
      if(scol.size() > 3) scol_a = dapf(scol.get(3))*255;
      if(ecol.size() > 3) ecol_a = dapf(ecol.get(3))*255;
      color startCol = color(dapf(scol.get(0))*255, dapf(scol.get(1))*255, dapf(scol.get(2))*255, scol_a);
      color endCol = color(dapf(ecol.get(0))*255, dapf(ecol.get(1))*255, dapf(ecol.get(2))*255, ecol_a);
      c = lerpColor(startCol, endCol, progress);
    } else {
      if(value >= 1 && value <= 3) c = rightColor;
      else if(value >= 5 && value <= 7) c = leftColor;
    }
    if(value == 3 || value == 7) { //fade
      progress = constrain(cursor-(time+4), 0, 1);
      color c_transparent = color(red(c), green(c), blue(c), 0);
      c = lerpColor(c, c_transparent, progress);
    }
    return c;
  }
  JSONObject toJSON() {
    JSONObject obj = new JSONObject();
    obj.put("_time", time);
    obj.put("_type", type);
    obj.put("_value", value);
    if(customData.size() > 0) obj.put("_customData", customData);
    return obj;
  }
  void fromJSON(JSONObject obj) {
    if(obj.containsKey("_time")) time = dapf(obj.get("_time"));
    if(obj.containsKey("_type")) type = dapi(obj.get("_type"));
    if(obj.containsKey("_value")) value = dapi(obj.get("_value"));
    if(obj.containsKey("_customData")) customData = (JSONObject)obj.get("_customData");
  }
  
  Event copy() {
    return new Event(time, type, value).addCustomData(copyJSONObject(customData));
  }
}
