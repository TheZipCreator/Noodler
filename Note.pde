class Note {
  float time;
  int x;
  int y;
  int type;
  /*
  0=left
  1=right
  2=?????????
  3=bomb
  */
  int cutDirection;
  /*
  0=up
  1=down
  2=left
  3=right
  4=upleft
  5=upright
  6=downleft
  7=downright
  8=dot
  */
  boolean playedClickSound;
  JSONObject customData;
  boolean dead;
  HashMap<String, Object> storedData;
  
  Note(float time, int x, int y, int type, int cutDirection) {
    this.time = time;
    //this code exists to fix a bug because SOMEBODY (looking at you, reaxt) decided to make notes out of bounds in order to make a song unplayable on quest before it had NE
    if(x > 4 || x < 0) x = 2;
    if(y > 3 || y < 0) y = 0;
    this.x = x;
    this.y = y;
    this.type = type;
    this.cutDirection = cutDirection;
    customData = new JSONObject();
    playedClickSound = false;
    dead = false;
    storedData = new HashMap<String, Object>();
  }
  Note addCustomData(JSONObject cd) {
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
        dead = true;
        return this;
      }
    }
    return this;
  }
  void render() {
    if(dead) return;
    JSONObject trackCD = new JSONObject();
    JSONObject tempCD = copyJSONObject(customData);
    HashSet<String> sharedProperties = new HashSet<String>();
    try {
    if(customData.containsKey("_track")) {
      trackCD = tracks.get((String)customData.get("_track")).properties;
      Set<String> keys = trackCD.keySet();
      for(String i : keys) {
        tempCD.put(i, (JSONArray)trackCD.get(i));
        sharedProperties.add(i);
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
      storedData.put("_noteJumpMovementSpeed", njs);
      changed = true;
    }
    if(customData.containsKey("_noteJumpStartBeatOffset")) {
      sbo = dapf(customData.get("_noteJumpStartBeatOffset"));
      storedData.put("_noteJumpStartBeatOffset", sbo);
      changed = true;
    }
    boolean changedTime = false;
    float tempTime = time;
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
    if(!(time > cursor-cutoffPoint && time < cursor+cutoffPoint)) return; //make sure the note is reasonably close to the cursor
    float localjd = jumpDistance;
    if(!changed) {
      if(!decideToRender_t(tempTime-cursor, time-cursor, jumpDistance)) return;
    }
    else if(!decideToRender_t(tempTime-cursor, time-cursor, getJumpDistance(njs, sbo))) { 
      return;
    } else {
      localjd = getJumpDistance(njs, sbo);
    }
    //
    //infoWindow.
    //infoWindow.translate(notedispx, notedispy);
    noStroke();
    //infoWindow.noStroke();
    boolean interactable = true;
    PVector position = BeatwallsToPosition(new PVector(x-2, y, tempTime), njs);
    PVector scale = new PVector(1,1,1);
    PVector localRotation = new PVector(0, 0, 0);
    PVector rotation = new PVector(0, 0, 0);
    //noodle
    float animPosition = getAnimPosition(time-cursor, localjd);
    //println(animPosition);
    float dissolve = 1;
    float dissolveArrow = 1;
    JSONObject animations = new JSONObject();
    if(customData.containsKey("_animation")) animations = (JSONObject)customData.get("_animation");
    if(customData.containsKey("_track")){
      Track track = tracks.get((String)customData.get("_track"));
      if(!track.updatedThisFrame) track.update();
      JSONObject temp = track.getMostRecentPathAnimation(cursor);
      Set<String> keys = temp.keySet();
      for(String i: keys) {
        sharedProperties.add(i);
        animations.put(i, temp.get(i));
      }
    }
      Set<String> keys = animations.keySet();
      for(String i : keys) {
        try {
          Animation a;
          if(animations.get(i) instanceof JSONArray) a = new Animation((JSONArray)animations.get(i), i);
          else if(animations.get(i) instanceof String) a = new Animation(pointDefinitions.get((String)animations.get(i)), i);
          else {
            dead = true; //kill the note
            println("Expected a point definition or animation object, got "+animations.get(i));
            return;
          }
          JSONArray arr = a.getPropertyAtPosition(animPosition);
          //add together path and track animation
          if(trackCD.containsKey(i)) {
            JSONArray temp = (JSONArray)trackCD.get(i);
            switch(i) {
              case "_position":
              case "_localRotation":
              case "_rotation":
              case "_definitePosition":
              tempCD.put(i, addArrays(arr, temp));
              break;
              case "_scale":
              case "_dissolve":
              case "_dissolveArrow":
              case "_color":
              case "_interactable":
              tempCD.put(i, multArrays(arr, temp));
              break;
              default:
              tempCD.put(i, addArrays(arr, temp));
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
      //lp = local property
    float[] lp_position = new float[2];
    lp_position[0] = x-2;
    lp_position[1] = y;
    if(customData.containsKey("_position") && sharedProperties.contains("_position")) {
      JSONArray pos = (JSONArray)customData.get("_position");
      lp_position[0] = dapf(pos.get(0));
      lp_position[1] = dapf(pos.get(1));
    }
    float[] lp_rotation = new float[3];
    if(customData.containsKey("_rotation") && sharedProperties.contains("_rotation")) {
      Object o = customData.get("_rotation");
      if(isNumber(o)) {
        float rot = dapf(customData.get("_rotation"));
        lp_rotation[1] = dapf(rot);
      } else {
        JSONArray rot = (JSONArray)customData.get("_rotation");
        lp_rotation[0] = dapf(rot.get(0));
        lp_rotation[1] = dapf(rot.get(1));
        lp_rotation[2] = dapf(rot.get(2));
      }
    }
    float[] lp_localRotation = new float[3];
    if(customData.containsKey("_localRotation") && sharedProperties.contains("_localRotation")) {
      Object o = customData.get("_localRotation");
      if(isNumber(o)) {
        float rot = dapf(customData.get("_localRotation"));
        lp_localRotation[1] = dapf(rot);
      } else {
        JSONArray rot = (JSONArray)customData.get("_localRotation");
        lp_localRotation[0] = dapf(rot.get(0));
        lp_localRotation[1] = dapf(rot.get(1));
        lp_localRotation[2] = dapf(rot.get(2));
      }
    }
    float[] lp_scale = new float[3];
    lp_scale[0] = 1;
    lp_scale[1] = 1;
    lp_scale[2] = 1;
    if(customData.containsKey("_scale") && sharedProperties.contains("_scale")) {
      JSONArray sca = (JSONArray)customData.get("_scale");
      lp_scale[0] = dapf(sca.get(0));
      lp_scale[1] = dapf(sca.get(1));
      if(sca.size() > 2) lp_scale[2] = dapf(sca.get(2));
    }
    PVector _position = new PVector(x-2, y, 0);
    if(tempCD.containsKey("_position")) { //position
      JSONArray pos = (JSONArray)tempCD.get("_position");
      if(pos.size() < 3) {
        println(pos, lp_position.length);
        position = BeatwallsToPosition(new PVector(dapf(pos.get(0))+lp_position[0], dapf(pos.get(1))+lp_position[1], tempTime), njs);
        _position.x = dapf(pos.get(0));
        _position.y = dapf(pos.get(1));
      } else {
        position = BeatwallsToPosition(new PVector(dapf(pos.get(0))+lp_position[0], dapf(pos.get(1))+lp_position[1], tempTime), njs);
        position.z += noteSize*dapf(pos.get(1));
        _position.x = dapf(pos.get(0));
        _position.y = dapf(pos.get(1));
        _position.z = dapf(pos.get(2));
      }
    }
    if(tempCD.containsKey("_definitePosition")) { //definitie position
      JSONArray pos = (JSONArray)tempCD.get("_definitePosition");
      PVector temp = BeatwallsToPosition(new PVector(_position.x+dapf(pos.get(0)), _position.y+dapf(pos.get(1)), tempTime), njs);
      float z = -dapf(pos.get(2));
      //temp.z = -(((z*noteSize)-(cursor*noteSize)));
      temp.z = z*noteSize;
      position = temp;
    }
    if(tempCD.containsKey("_scale")) { //scale
      JSONArray sca = (JSONArray)tempCD.get("_scale");
      sca = multArrays(sca, createJSONArray(lp_scale[0], lp_scale[1], lp_scale[2]));
      scale = new PVector(dapf(sca.get(0)), dapf(sca.get(1)), dapf(sca.get(2)));
    }
    if(tempCD.containsKey("_interactable")) { //interactable
      interactable = (dapf(tempCD.get("_interactable")) > 0.99);
    }
    if(tempCD.containsKey("_rotation")) { //rotation
      Object o = tempCD.get("_rotation");
      if(isNumber(o)) {
        float rot = dapf(o);
        rotation = new PVector(lp_rotation[0], rot+lp_rotation[1], lp_rotation[2]);
      } else {
        JSONArray rot = (JSONArray)o;
        rotation = new PVector(dapf(rot.get(0))+lp_rotation[0], dapf(rot.get(1))+lp_rotation[1], dapf(rot.get(2))+lp_rotation[2]);
      }
    }
    if(tempCD.containsKey("_localRotation")) { //local rotation
      JSONArray lr = (JSONArray)tempCD.get("_localRotation");
      localRotation = new PVector(dapf(lr.get(0))+lp_localRotation[0], dapf(lr.get(1))+lp_localRotation[1], -dapf(lr.get(2))+lp_localRotation[2]);
    }
    if(tempCD.containsKey("_dissolve")) {
      dissolve = dapf(((JSONArray)tempCD.get("_dissolve")).get(0));
    }
    if(tempCD.containsKey("_dissolveArrow")) {
      dissolveArrow = dapf(((JSONArray)tempCD.get("_dissolveArrow")).get(0));
    }
    color colr;
    colr = color(0);
    switch(type) {
      case 0:
        if(time > cursor || changedTime) colr = color(red(leftColor), green(leftColor), blue(leftColor), dissolve*255);
        else  colr = color(red(leftColor), green(leftColor), blue(leftColor), dissolve*64);
        break;
      case 1:
        if(time > cursor || changedTime)  colr = color(red(rightColor), green(rightColor), blue(rightColor), dissolve*255);
        else fill(red(rightColor),  colr = color(rightColor), blue(rightColor), dissolve*64);
        break;
      case 3:
        if(time > cursor || changedTime)  colr = color(128, 128, 128, dissolve*255);
        else  colr = color(128, 128, 128, dissolve*64);
        break;
      default:
        if(time > cursor || changedTime)  colr = color(0, 0, 0, dissolve*255);
        else  colr = color(0, 0, 0, dissolve*64);
        break;
    }
    if(tempCD.containsKey("_color")) { //chroma custom color
      JSONArray col = (JSONArray)tempCD.get("_color");
      if(tempTime > cursor) colr = color(dapf(col.get(0))*255, dapf(col.get(1))*255, dapf(col.get(2))*255, dissolve*255);
      else colr = color(dapf(col.get(0))*255, dapf(col.get(1))*255, dapf(col.get(2))*255, dissolve*64);
    }
    switch(cutDirection) {
      case 0:
      break;
      case 1:
      localRotation.z += 180;
      break;
      case 2:
      localRotation.z -= 90;
      break;
      case 3:
      localRotation.z += 90;
      break;
      case 4:
      localRotation.z -= 45;
      break;
      case 5:
      localRotation.z += 45;
      break;
      case 6:
      localRotation.z -= 135;
      break;
      case 7:
      localRotation.z += 135;
      break;
      default:
      break;
    }
    color arrowColor;
    float[] hsb = Color.RGBtoHSB(round(red(colr)), round(green(colr)), round(blue(colr)), null);
    arrowColor = color(Color.HSBtoRGB(hsb[0], ((1-dissolve)/2), hsb[2]));
    if(dissolve > 0.99) arrowColor = color(255);
    storedData.put("position", copyPVector(position));
    storedData.put("scale", copyPVector(scale));
    storedData.put("localRotation", copyPVector(localRotation));
    storedData.put("dissolve", dissolve);
    storedData.put("dissolveArrow", dissolveArrow);
    storedData.put("color", colr);
    storedData.put("time", tempTime);
    storedData.put("rotation", rotation);
    storedData.put("arrowColor", arrowColor);
    
      //infoWindow.fill(prs[6].x, prs[6].y, prs[6].z, dissolve*255);
      //infoWindow.translate(position.x, position.y);
      //infoWindow.rotate(radians(localRotation.z));
      //if(dissolve > 0.01) {
      //  if(type != 3) //infoWindow.rect(0, 0, noteSize*0.8*scale.x, noteSize*0.8*scale.y);
      //  else //infoWindow.ellipse(0, 0, noteSize*0.5, noteSize*0.5);
      //}
      //translate((x*noteSize)-(1.5*noteSize), (2-y)*noteSize, -(((time*editorScale*noteSize)-(cursor*editorScale*noteSize))));
      //rotateX(radians(rotation.x));
      //rotateY(radians(rotation.y));
      //rotateZ(-radians(rotation.z));
      //translate(position.x, position.y, position.z);
      //rotateX(radians(localRotation.x));
      //rotateY(radians(localRotation.y));
      //rotateZ(radians(localRotation.z));
      ////if(cutDirection == 4 || cutDirection == 7) localRotation.z += 45;
      ////if(cutDirection == 5 || cutDirection == 6) localRotation.z -= 45;
      if(time < cursor && !changedTime) {
        dissolve *= 0.25;
        dissolveArrow *= 0.25;
      }
      if(dissolve > 0.01) addRenderElement(new RenderNote(position, rotation, localRotation, scale, dissolve, colr, type == 3));
      //fill(red(colr), green(colr), blue(colr), alpha(colr));
      //box(scale.x*noteSize*0.8, scale.y*noteSize*0.8, scale.z*noteSize*0.8);
      if(dissolveArrow > 0.01) {
        if(type != 3) addRenderElement(new RenderArrow(position, rotation, localRotation, scale, dissolveArrow, colr, cutDirection == 8));
      }
      if(selection.containsNote(this)) {
        PVector tempScale = scale.copy();
        tempScale.mult(1.4);
        addRenderElement(new RenderNote(position, rotation, localRotation, tempScale, 0.25, selectionColor, false));
      }
      //
      //textMode(SHAPE);
      if(displayTracks) {
        if(customData.containsKey("_track")) {
          String t = (String)customData.get("_track");
          color col = tracks.get(t).col;
          fill(red(col), green(col), blue(col));
          textSize(16);
          rect(-textWidth(t)/2, -48, textWidth(t), 16);
          fill(255);
          text(t, -textWidth(t)/2, -32, 10);
        }
      }
      //textMode(MODEL);
    fill(255);
    
    //infoWindow.
    //click sound stuff
    if(playing && type != 3 && interactable) {
      if(cursorStartedPlaying < time && cursor >= time && !playedClickSound) {
        playedClickSound = true;
        hitsound.setPosition(0);
        //println(animPosition);
      }
    }
  }
  HashMap<String, Object> render2d(float scaling, float x, float y) {
    try {
      if(storedData.containsKey("position")) {
        infoWindow.noStroke();
        float njs = noteJumpSpeed;
        float sbo = startBeatOffset;
        boolean changed = false;
        if(storedData.containsKey("_noteJumpMovementSpeed")) {
          njs = dapf(customData.get("_noteJumpMovementSpeed"));
          changed = true;
        }
        if(storedData.containsKey("_noteJumpStartBeatOffset")) {
          sbo = dapf(customData.get("_noteJumpStartBeatOffset"));
          changed = true;
        }
        float time = (float)storedData.get("time");
        if(!(time > cursor-cutoffPoint && time < cursor+cutoffPoint)) return null; //make sure the note is reasonably close to the cursor
        float localjd = jumpDistance;
        float jumpDistanceScale = 0.1;
        if(!changed) {
          if(!decideToRender(time-cursor, jumpDistance*jumpDistanceScale)) return null;
        }
        else if(!decideToRender(time-cursor, getJumpDistance(njs, sbo)*jumpDistanceScale)) { 
          return null;
        } else {
          localjd = getJumpDistance(njs, sbo);
        }
        if(time < cursor-0.1) return null;
        PVector position = (PVector)storedData.get("position");
        position.x += noteSize*2;
        position.y += noteSize*0.5;
        position.mult(scaling);
        position.x += x;
        position.y += y;
        PVector scale = (PVector)storedData.get("scale");
        scale.mult(scaling);
        PVector localRotation = (PVector)storedData.get("localRotation");
        PVector rotation = (PVector)storedData.get("rotation");
        color c = (color)storedData.get("color");
        float dissolve = (float)storedData.get("dissolve");
        float dissolveArrow = (float)storedData.get("dissolveArrow");
        color arrowColor = (color)storedData.get("arrowColor");
        infoWindow.fill(red(c), green(c), blue(c), dissolve*255);
        infoWindow.pushMatrix();
        infoWindow.rotate(radians(rotation.z));
        infoWindow.translate(position.x, position.y);
        infoWindow.rotate(radians(localRotation.z));
        infoWindow.translate(-(noteSize*scale.x)/2, -(noteSize*scale.y)/2);
        if(type != 3) {
          if(cutDirection == 8) {
            ellipse(noteSize*scale.x*0.2, noteSize*scale.x*0.2, noteSize*scale.x*0.4, noteSize*scale.y*0.4);
          } else {
            infoWindow.rect(0, 0, noteSize*scale.x, noteSize*scale.y);
            infoWindow.fill(red(arrowColor), green(arrowColor), blue(arrowColor), dissolveArrow*255);
            infoWindow.translate(noteSize*scale.x*0.05, noteSize*scale.y*0.05);
            infoWindow.beginShape();
            infoWindow.vertex(0, noteSize*scale.y*0.7);
            infoWindow.vertex(noteSize*scale.x*0.7, noteSize*scale.y*0.7);
            infoWindow.vertex((noteSize*scale.x*0.7)/2, (noteSize*scale.y*0.7)/2);
            infoWindow.endShape();
          }
        } else {
          infoWindow.fill(128);
          infoWindow.ellipse(0, 0, noteSize*scale.x, noteSize*scale.y);
        }
        infoWindow.popMatrix();
        HashMap<String, Object> rv = new HashMap<String, Object>();
        scale.mult(noteSize);
        rv.put("position", position);
        rv.put("scale", scale);
        return rv;
      }
      return null;
    } catch(Exception e) {
      println(storedData);
      throw e;
      
    }
  }
  JSONObject toJSON() {
    JSONObject obj = new JSONObject();
    obj.put("_time", time);
    obj.put("_lineIndex", x);
    obj.put("_lineLayer", y);
    obj.put("_type", type);
    obj.put("_cutDirection", cutDirection);
    if(customData.size() > 0) obj.put("_customData", customData);
    return obj;
  }
  void fromJSON(JSONObject obj) {
    if(obj.containsKey("_time")) time = dapf(obj.get("_time"));
    if(obj.containsKey("_type")) type = dapi(obj.get("_type"));
    if(obj.containsKey("_lineIndex")) x = dapi(obj.get("_lineIndex"));
    if(obj.containsKey("_lineLayer")) y = dapi(obj.get("_lineLayer"));
    if(obj.containsKey("_cutDirection")) cutDirection = dapi(obj.get("_cutDirection"));
    if(obj.containsKey("_customData")) customData = (JSONObject)obj.get("_customData");
  }
}
