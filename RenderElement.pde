class RenderElement implements Comparable {
  PVector position;
  PVector rotation;
  PVector localRotation;
  PVector scale;
  float opacity;
  color colr;
  
  RenderElement(PVector position, PVector rotation, PVector localRotation, PVector scale, float opacity, color colr) {
    this.position = position;
    this.rotation = rotation;
    this.localRotation = localRotation;
    this.opacity = opacity;
    this.colr = colr;
    this.scale = scale;
  }
  void render() {
    
  }
  void fillColor() {
    fill(red(colr), green(colr), blue(colr), opacity*255);
  }
  void transformations() {
    translate(0, noteSize*2, 0);
    rotateX(radians(rotation.x));
    rotateY(radians(rotation.y));
    rotateZ(-radians(rotation.z));
    translate(0, -noteSize*2, 0);
    translate(position.x, position.y, position.z);
    rotateX(radians(localRotation.x));
    rotateY(radians(localRotation.y));
    rotateZ(radians(localRotation.z));
  }
  
  int compareTo(Object o) {
    return round(opacity*1000)-round(((RenderElement)o).opacity*1000);
  }
}
class RenderNote extends RenderElement {
  boolean bomb;
  
  RenderNote(PVector position, PVector rotation, PVector localRotation, PVector scale, float opacity, color colr, boolean bomb) {
    super(position, rotation, localRotation, scale, opacity, colr);
    this.bomb = bomb;
  }
  
  @Override
  void render() {
    pushMatrix();
    transformations();
    fillColor();
    if(!bomb) box(scale.x*noteSize*0.8, scale.y*noteSize*0.8, scale.z*noteSize*0.8);
    else {
      scale(scale.x*noteSize, scale.y*noteSize, scale.z*noteSize);
      sphere(0.5);
    }
    popMatrix();
  }
}
class RenderArrow extends RenderElement {
  boolean dot;
  
  RenderArrow(PVector position, PVector rotation, PVector localRotation, PVector scale, float opacity, color colr, boolean dot) {
    super(position, rotation, localRotation, scale, opacity, colr);
    this.dot = dot;
  }
  
  @Override
  void render() {
    pushMatrix();
    transformations();
    fill(255, opacity*255);
    translate(-(noteSize*0.8*scale.x)/2, -(noteSize*0.8*scale.y)/2, scale.z*(noteSize/2));
    if(dot) {
      ellipse(noteSize*scale.x*0.2, noteSize*scale.x*0.2, noteSize*scale.x*0.4, noteSize*scale.y*0.4);
    } else {
      translate(noteSize*scale.x*0.05, noteSize*scale.y*0.05);
      pushMatrix();
      translate(0, 0, -0.01);
      fill(red(colr), green(colr), blue(colr), ease(opacity, "easeInQuint")*255);
      float colSize = noteSize*scale.x*0.04;
      float colSize2 = noteSize*scale.x*0.08; //make sure the multiplier here is always 2x the multiplier in colSize
      beginShape();
      vertex(-colSize2, (noteSize*scale.y*0.7)+colSize);
      vertex((noteSize*scale.x*0.7)+colSize2, (noteSize*scale.y*0.7)+colSize);
      vertex((noteSize*scale.x*0.7)/2, ((noteSize*scale.y*0.7)/2)-colSize);
      endShape();
      popMatrix();
      fill(255, opacity*255);
      beginShape();
      vertex(0, noteSize*scale.y*0.7);
      vertex(noteSize*scale.x*0.7, noteSize*scale.y*0.7);
      vertex((noteSize*scale.x*0.7)/2, (noteSize*scale.y*0.7)/2);
      endShape();
    }
    popMatrix();
  }
}

class RenderObstacle extends RenderElement {
  boolean custom = false;
  
  RenderObstacle(PVector position, PVector rotation, PVector localRotation, PVector scale, float opacity, color colr, boolean custom) {
    super(position, rotation, localRotation, scale, opacity, colr);
    this.custom = custom;
  }
  
  @Override
  void render() {
    pushMatrix();
    translate(0, noteSize*2, 0);
    fillColor();
    translate(0, noteSize*2, 0);
    rotateX(radians(rotation.x));
    rotateY(radians(rotation.y));
    rotateZ(-radians(rotation.z));
    translate(0, -noteSize*2, 0);
    translate(position.x+(scale.x/2)-(noteSize/2), position.y+(scale.y/2)-(noteSize), position.z-(scale.z/2)); 
    //+(scale.x/2) is there to make it so the left face of the wall always aligns in the same spot, and -(noteSize/2) is there in order to correct the left face. +(scale.y/2) is similar. 
    //-(scale.z/2) is to make the z position of the wall correct, since duration usually changes it.
    translate(0, scale.y, -scale.z/2);
    rotateX(radians(localRotation.x));
    rotateY(-radians(localRotation.y));
    rotateZ(-radians(localRotation.z));
    translate(0, -scale.y, scale.z/2);
    box(scale.x, scale.y, scale.z);
    popMatrix();
  }
}
