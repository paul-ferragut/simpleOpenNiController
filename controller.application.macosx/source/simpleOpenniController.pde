import SimpleOpenNI.*;
 
SimpleOpenNI context;
float        zoomF =0.3f;
float        rotX = radians(180);  // by default rotate the hole scene 180deg around the x-axis, 
                                   // the data from openni comes upside down
float        rotY = radians(0);

long      timing=0;

long currentTime=0;

int userN;
color[] userColors = {color(255,0,0),color(0,255,0),color(0,0,255),color(255,255,0),color(255,0,255),color(0,255,255)};


boolean playRecording=false;

ArrayList<PVector> userData = new ArrayList<PVector>();

ArrayList<ArrayList<PVector>> positionsForAllUsers = new ArrayList<ArrayList<PVector>>();
int[] clrs = {color(255,0,0),color(0,255,0),color(0,0,255)};
int user = 0;
int maxUsers = 5;//let's test 3 lists of points for now


void setup(){
  
  //userID = new IntList();
   for(int i = 0 ; i < maxUsers ; i++){ 
   positionsForAllUsers.add(new ArrayList<PVector>());
 
 }//initialize array list of pos. per user
  
  size(1024,768,P3D);
  textFont(createFont("Arial",48));
  context = new SimpleOpenNI(this);
  
  if(playRecording == true){
      
    // playing, this works without the camera
    if ( context.openFileRecording("record.oni") == false)
    {
      println("can't find recording !!!!");
      exit();
    }

    // it's possible to run the sceneAnalyzer over the recorded data strea   
    if ( context.enableScene() == false)
    {
      println("can't setup scene!!!!");
      exit();
      return;
    }
    context.setMirror(false);
    context.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);//enable user events, but no skeleton tracking, needed for the CoM functionality   
    println("This file has " + context.framesPlayer() + " frames.");
  
  }
  else{
  
    context.enableRGB();
    context.alternativeViewPointDepthToImage();//aligns depth with rgb streams
    context.enableDepth();
    context.setMirror(false);
    context.enableScene();
    context.enableUser(SimpleOpenNI.SKEL_PROFILE_NONE);//enable user events, but no skeleton tracking, needed for the CoM functionality    
  }

  stroke(255);
  smooth();
  perspective(radians(45),float(width)/float(height),10,150000);
}
 
void draw()
{
  
  currentTime=millis();
  context.update();//update kinect
  //clear and do scene transformation(translation,rotation,scale)
  background(0,0,0);
  pushMatrix();//3D
  translate(width/2, height/2, 0);
  rotateX(rotX);
  rotateY(rotY);
  scale(zoomF);
 
  int[]   depthMap = context.depthMap();//640*480 long array of ints from 0-2047
  int[]   sceneMap = context.sceneMap();//640*480 long array of ints, 0 is bg, 1 is user 1, 2 is user 2, etc.
  PImage  rgbImage = context.rgbImage();
  PVector[] realWorldMap = context.depthMapRealWorld();//convert raw depth values to real world 3D positions in space 
  PVector realWorldPoint;//we'll reuse this PVector when converting raw depth values to 3D position
  int     steps   = 5; 
  int     index   = 0;
  translate(0,0,-1000);  // set the rotation center of the scene 1000 in front of the camera
 
  userData.clear(); 

  beginShape(POINTS);
  for(int y=0;y < context.depthHeight();y+=steps)
  {
    for(int x=0;x < context.depthWidth();x+=steps)
    {
      index = x + y * context.depthWidth();
      if(depthMap[index] > 0)
      { 
        // draw the projected point
        realWorldPoint = realWorldMap[index];
        stroke(rgbImage.pixels[index]);      
        int userPixel = sceneMap[index]; 
        if(userPixel > 0) {
          stroke(userColors[userPixel%userColors.length]);
          PVector ud;
          if(userData.size() >= userPixel) ud = userData.get(userPixel-1);
          else{
            ud = new PVector(Float.MAX_VALUE,0,-1);//hacky way to store data: x = minY,y = maxY, z = maxY-minY
            userData.add(ud);
        
            
          }
          if(realWorldPoint.y < ud.x) ud.x = realWorldPoint.y;
          if(realWorldPoint.y > ud.y) ud.y = realWorldPoint.y;
          ud.z = ud.y - ud.x;
        }
        vertex(realWorldPoint.x,realWorldPoint.y,realWorldPoint.z);
      }
    } 
  } 
  endShape();
 
   //DRAW CENTER OF MASS AND TRAIL
  int[] users = context.getUsers();
  
  //check validity of user id
 

  
  for(int i = 0 ; i < users.length; i++){
    
    PVector com = new PVector();
    context.getCoM(users[i],com);
    pushMatrix();
    translate(com.x,com.y,com.z);
    box(10);
    popMatrix();
    
    
          user=i;
        if(user > 0 && com.x!=0 && com.y!=0 && com.z!=0){
    //array index is off by 1 compared to openni users
    positionsForAllUsers.get(user-1).add(new PVector(com.x,com.y,com.z));
        }
    
    PVector ud;
    if(userData.size() >= users[i]) {
      ud = userData.get(users[i]-1);
      
      line(com.x,ud.x,com.z,com.x,ud.y,com.z);
      pushMatrix();
      translate(com.x,com.y,com.z);
      rotateX(PI);
      text("height: "+(ud.y-ud.x),0,0,0);
      popMatrix();
    }
    

  }
  
  // draw the kinect cam
  context.drawCamFrustum();
  
 // background(255);
  beginShape(POINTS);
  //println("size"+positionsForAllUsers.size());
  for(int i = 0 ; i < positionsForAllUsers.size(); i++){//for each user's list of points
    ArrayList<PVector> ppu = positionsForAllUsers.get(i);//get the points per user list
   stroke(color(255,0,0));
    
    for(int j = 0 ; j < ppu.size(); j++){//for each point in a user's list
      PVector pos = ppu.get(j);
      vertex(pos.x,pos.y,pos.z);
    }
    
  }
  
  endShape();
  
    popMatrix();
  
  
}

//OpenNI basic user events
void onNewUser(int userId){
  println("detected" + userId);

  userN = userId;

           
}
void onLostUser(int userId){
  println("lost: " + userId);
  
  userN = userId;
}


