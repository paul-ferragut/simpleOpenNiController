void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
 
  switch(keyCode)
  {
  case LEFT:
    rotY += 0.1f;
    break;
  case RIGHT:
    // zoom out
    rotY -= 0.1f;
    break;
  case UP:
    if(keyEvent.isShiftDown())
      zoomF += 0.02f;
    else
      rotX += 0.1f;
    break;
  case DOWN:
    if(keyEvent.isShiftDown())
    {
      zoomF -= 0.02f;
      if(zoomF < 0.01)
        zoomF = 0.01;
    }
    else
      rotX -= 0.1f;
    break;
  }
  
      if(key == '+') {
          zoomF+=0.1;
        } 
        else  if(key == '-') {
          zoomF-=0.1;
        }
}

void mouseDragged()
{
    rotX += (mouseY - pmouseY) * 0.01;
    rotY -= (mouseX - pmouseX) * 0.01;
}

