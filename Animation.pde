class Animation {
  JSONArray[] keyframes;
  float[] times;
  String property;
  boolean dead = false;
  public static final int INTERPOL_FRAMES = 100; //lowering this will improve performance but also reduce the quality of path animation easing
  
  Animation(JSONArray keyframes, String property) {
    try {
    dead = false;
    ArrayList<JSONArray> kf = new ArrayList<JSONArray>();
    for(int i = 0; i < keyframes.size(); i++) {
      kf.add((JSONArray)keyframes.get(i));
    }
    this.keyframes = new JSONArray[kf.size()];
    for(int i = 0; i < kf.size(); i++) {
      this.keyframes[i] = kf.get(i);
    }
    times = new float[this.keyframes.length];
    int proplength = proplen.get(property);
    if(this.keyframes.length > 1) {
      for(int i = 0; i < times.length; i++) {
        times[i] = dapf(this.keyframes[i].get(proplength));
      }
    }
    this.property = property;
    } catch(Exception e) {
      println(keyframes, property);
      dead = true;
    }
    if(property.equals("_rotation") || property.equals("_localRotation")) {
      //fix rotation
      int proplength = proplen.get(property);
      for(int i = 1; i < this.keyframes.length; i++) {
        JSONArray a = this.keyframes[i];
        JSONArray b = this.keyframes[i-1];
        for(int j = 0; j < proplength; j++) {
          
        }
      }
    }
  }
  
  JSONArray getPropertyAtPosition(float pos) {
    if(dead) return new JSONArray();
    if(keyframes.length == 1) return keyframes[0];
    JSONArray result = new JSONArray();
    int proplength = proplen.get(property);
    int firstFrame = 0;
    int secondFrame = 0;
    //find first frame
    for(int i = 0; i < times.length; i++) {
      if(pos > times[i]) firstFrame = i;
    }
    //get second frame
    secondFrame = firstFrame+1;
    if(secondFrame > keyframes.length-1) secondFrame = keyframes.length-1;
    //get how far we're into the animation (progress)
    //println(pos, firstFrame, secondFrame, times.length, keyframes.length);
    float progress = map(pos, times[firstFrame], times[secondFrame]+0.001, 0, 1);
    if(keyframes[secondFrame].size() > proplength+1) { //if there's an easing
      progress = ease(progress, (String)keyframes[secondFrame].get(proplength+1)); //apply the easing
    }
    //calculate the values
    for(int i = 0; i < proplength; i++) {
      float firstValue = dapf(keyframes[firstFrame].get(i));
      float secondValue = dapf(keyframes[secondFrame].get(i));
      result.add(lerp(firstValue, secondValue, progress));
    }
    return result;
  }
  
  ArrayList<JSONArray> getExpandedAnimation() {
    ArrayList<JSONArray> out = new ArrayList<JSONArray>();
    for(int i = 0; i < INTERPOL_FRAMES; i++) {
      out.add(getPropertyAtPosition(float(i)/float(INTERPOL_FRAMES)));
    }
    return out;
  }
  
  JSONArray interpolate(Animation anim, float aWeight, float bWeight) {
    ArrayList<JSONArray> a = getExpandedAnimation();
    ArrayList<JSONArray> b = anim.getExpandedAnimation();
    int proplength = proplen.get(property);
    JSONArray c = new JSONArray();
    for(int i = 0; i < INTERPOL_FRAMES; i++) {
      JSONArray ia = a.get(i);
      JSONArray ib = b.get(i);
      JSONArray ic = new JSONArray();
      for(int j = 0; j < proplength; j++) {
        float firstValue = dapf(ia.get(j));
        float secondValue = dapf(ib.get(j));
        ic.add(average(firstValue*aWeight, secondValue*bWeight));
      }
      ic.add(float(i)/float(INTERPOL_FRAMES));
      c.add(ic);
    }
    return c;
  }
}
