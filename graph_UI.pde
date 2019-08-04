import processing.serial.*;
import processing.opengl.*;

static final char GYRO=1;
static final char ACCEL=2;
static final char MAG=3;
static final char XYZ_rotations=4;
static final int graph_width=500, graph_depth=150;
static final int axis_color[][]={{200,50,50},{60,120,200},{200,200,80}};//x_axis(1)is RED,y_axis(2)is BLUE,z_axis(3)is YELLOW
static final int x_color=0,y_color=1,z_color=2; //1is red 2is blue 3is yellow
static final int text_size=30;
static final int box_width=100,box_height=50,box_depth=160;
static final int box_Xpotision=1600,box_Ypotision=850;
static final int box_textpotision=-180;
static final int circle_R=270;
static final int Diamond=100;
static final int Rectangle_width=160,Rectangle_height=35;
char data;//data 
Serial myPort;
float gx, gy, gz;
float ax, ay, az;
float mx, my, mz;
float roll=0,pitch=0,yaw=0;
int a=1;//回転方向
graphMonitor x_GyroGraph;
graphMonitor y_GyroGraph;
graphMonitor z_GyroGraph;
graphMonitor x_AccelGraph;
graphMonitor y_AccelGraph;
graphMonitor z_AccelGraph;
graphMonitor x_MagGraph;
graphMonitor y_MagGraph;
graphMonitor z_MagGraph;
graphMonitor x_rotations;
graphMonitor y_rotations;
graphMonitor z_rotations;

circleMonitor roll_circle;
circleMonitor pitch_circle;
circleMonitor yaw_circle;//未実装

void setup(){
  size(2800,1000,P3D);//3D space specific
 myPort = new Serial(this,"COM4",115200);//COM4 serial 115200
  frameRate(50);
  smooth();
  myPort.bufferUntil('\n');//\nでデータ分割
  
  x_GyroGraph = new graphMonitor("x_gyro", 100,  40, graph_width, graph_depth,x_color);//String _TITLE,_X_POSITION,_Y_POSITION,_,_Y_LENGTH
  y_GyroGraph = new graphMonitor("y_gyro", 100, 240, graph_width, graph_depth,y_color);
  z_GyroGraph = new graphMonitor("z_gyro", 100, 440, graph_width, graph_depth,z_color);
  x_AccelGraph= new graphMonitor("x_accel",720,  40, graph_width, graph_depth,x_color);
  y_AccelGraph= new graphMonitor("y_accel",720, 240, graph_width, graph_depth,y_color);
  z_AccelGraph= new graphMonitor("z_accel",720, 440, graph_width, graph_depth,z_color);
  x_MagGraph  = new graphMonitor("x_mag", 1340,  40, graph_width, graph_depth,x_color);
  y_MagGraph  = new graphMonitor("y_mag", 1340, 240, graph_width, graph_depth,y_color);
  z_MagGraph  = new graphMonitor("z_mag", 1340, 440, graph_width, graph_depth,z_color);
  x_rotations = new graphMonitor("roll",  1960,  40, graph_width, graph_depth,x_color);
  y_rotations = new graphMonitor("pitch", 1960, 240, graph_width, graph_depth,y_color);
  z_rotations = new graphMonitor("yaw",   1960, 440, graph_width, graph_depth,z_color);

  roll_circle = new circleMonitor("roll",350,800,x_color);
  pitch_circle= new circleMonitor("pitch",700,800,y_color);
}

void draw(){
  background(25);

  x_GyroGraph.graphDraw(gx);
  y_GyroGraph.graphDraw(gy);
  z_GyroGraph.graphDraw(gz);
  x_AccelGraph.graphDraw(ax);
  y_AccelGraph.graphDraw(ay);
  z_AccelGraph.graphDraw(az);
  x_MagGraph.graphDraw(mx);
  y_MagGraph.graphDraw(my);
  z_MagGraph.graphDraw(mz);
  x_rotations.graphDraw(roll);
  y_rotations.graphDraw(pitch);
  z_rotations.graphDraw(yaw);
 
  roll_circle.graphDraw(roll);
  pitch_circle.graphDraw(pitch);
  yaw_circle(yaw);
 
  ypr_box(roll,pitch,yaw);
  ryp_box(roll,pitch,yaw);
}

void serialEvent(Serial myPort){
  String myString = myPort.readStringUntil('\n');

  if (myString != null) {
    myString = trim(myString);//trimで空白消去
    float sensors[] = float(split(myString, ','));// ,cut output
    if (sensors.length > 2) {
      switch(int(sensors[0])){
        case GYRO:
          gx = sensors[1];
          gy = sensors[2];
          gz = sensors[3];
        break; 
  
        case ACCEL:
          ax = sensors[1];
          ay = sensors[2];
          az = sensors[3];
        break; 
       
       case MAG:
          mx = sensors[1];
          my = sensors[2];
          mz = sensors[3];
        break;    
        
        case XYZ_rotations:
        roll =sensors[1];
        pitch=sensors[2];
        yaw  =sensors[3];
      }
    }   
  }
}
void ypr_box(float r,float p,float y ){//YPR
  ambientLight(200,200,200);
  pointLight(200,200,200,box_Xpotision,box_Ypotision,70);//light potison
  lightFalloff(1,0,0);
  lightSpecular(0,0,0);

  pushMatrix();
  translate(box_Xpotision,box_Ypotision);
  textSize(text_size);// title
  fill(80,200,200);     
  textAlign(LEFT, BOTTOM);
  text("YPR", box_textpotision, box_textpotision);
      
  rotateY(radians(y));//Y_rotations is changed  raw(Z_rotation)
  rotateZ(radians(a*r));
  rotateX(radians(-a*-p));
  fill(70, 180, 230);
  stroke(200,255,230);
  box(box_width,box_height,box_depth);

  stroke(60,120,200);
  line( 0, 0, 0, 200, 0, 0);//X rotation(pitch) blue 
  stroke(200,200,80);
  line(0, 0, 0, 0, -200, 0);//Y rotation(yaw)yellow
  stroke(200,50,50);
  line(0, 0, 0, 0, 0, 200);//Z rotation(roll) red
  popMatrix();
}

void ryp_box(float r ,float p ,float y){//RYP
  ambientLight(100,100,100);
  pointLight(100,100,100,box_Xpotision,box_Ypotision,70);//light potison
  lightFalloff(1,0,0);
  lightSpecular(0,0,0);

  pushMatrix();
  translate(box_Xpotision+400,box_Ypotision);
  textSize(text_size);// title
  fill(80,200,200);
  textAlign(LEFT, BOTTOM);
  text("RYP", box_textpotision, box_textpotision);

  rotateX(radians(a*p));
  rotateY(radians(y));//Y_rotations is changed  raw(Z_rotation)
  rotateZ(radians(-a*-r));
  fill(200, 60, 50);
  stroke(200,130,80);
  box(box_width,box_height,box_depth);

  stroke(60,120,200);
  line( 0, 0, 0, 200, 0, 0);//X rotation(pitch) blue 
  stroke(200,200,80);
  line(0, 0, 0, 0, -200, 0);//Y rotation(yaw)yellow
  stroke(200,50,50);
  line(0, 0, 0, 0, 0, 200);//Z rotation(roll) red
  popMatrix();
}

class circleMonitor{
String TITLE;
int X_POSITION,Y_POSITION;
int X_LENGTH,Y_LENGTH;
int c;
circleMonitor(String _TITLE, int _X_POSITION, int _Y_POSITION,int _COLOR){
TITLE=_TITLE;
X_POSITION=_X_POSITION;
Y_POSITION=_Y_POSITION;
c=_COLOR;
 }
 
void graphDraw(float ang){
pushMatrix();
  translate(X_POSITION,Y_POSITION);
  textSize(text_size);// title
  fill(80,200,200);
  textAlign(LEFT, BOTTOM);
  text(TITLE, -circle_R/2, -circle_R/2);
    
  strokeWeight(1);
  stroke(255,255,255);
  fill(25);
  ellipse(0,0,circle_R,circle_R);

  fill(axis_color[c][0],axis_color[c][1],axis_color[c][2]);
  textSize(18);
  text(ang,-circle_R/2-60,0);

  line(-circle_R/2,0,circle_R/2,0);
  line(0,-circle_R/2,0,circle_R/2);

  strokeWeight(1);
  stroke(220);
  fill(axis_color[c][0],axis_color[c][1],axis_color[c][2]);
  translate(0,0);  
  rotate(radians(ang)); 
  rect(-Rectangle_width/2,-Rectangle_height/2,Rectangle_width,Rectangle_height);
  popMatrix();
 }
}/*
void roll_circle(float r){//roll circle
  pushMatrix();
  translate(circle_Xpotision,circle_Ypotision);
  textSize(text_size);// title
  fill(80,200,200);
  textAlign(LEFT, BOTTOM);
  text("roll", -circle_R/2, -circle_R/2);
    
  strokeWeight(1);
  stroke(255,255,255);
  fill(25);
  ellipse(0,0,circle_R,circle_R);
  line(-circle_R/2,0,circle_R/2,0);
  line(0,-circle_R/2,0,circle_R/2);

  fill(200,50,50);
  textSize(18);
  text(r,-circle_R/2-60,0);

  strokeWeight(2);
  stroke(20,50,50);
  fill(200,50,50);
  translate(0,0);  
  rotate(radians(r)); 
  rect(0,0,Rectangle_width,Rectangle_height);
  popMatrix();
}
void pitch_circle(float p){// pitch circle
  pushMatrix();
  translate(circle_Xpotision+350,circle_Ypotision);
  textSize(text_size);// title
  fill(80,200,200);
  textAlign(LEFT, BOTTOM);
  text("pitch", -circle_R/2, -circle_R/2);
      
  strokeWeight(1);
  stroke(255,255,255);
  fill(25);
  ellipse(0,0,circle_R,circle_R);

  fill(60,120,200);
  textSize(18);
  text(p,-circle_R/2-60,0);
      
  line(-circle_R/2,0,circle_R/2,0);
  line(0,-circle_R/2,0,circle_R/2);
  strokeWeight(1);
  stroke(220);
  fill(60,120,200);
  stroke(60,120,200);
  translate(0,0);  
  rotate(radians(-p)); 
  rect(0,0,Rectangle_width,Rectangle_height);
  popMatrix();
}*/
void yaw_circle(float ang){// yaw circle
  pushMatrix();
  translate(700+350,800);//picthの円の描写位置から(+700,+0)
  textSize(text_size);// title
  fill(80,200,200);
  textAlign(LEFT, BOTTOM);
  text("yaw", -circle_R/2, -circle_R/2);
     
  strokeWeight(1);
  stroke(230,230,230);
  fill(25);
  ellipse(0,0,circle_R,circle_R);

  fill(200,200,80);
  textSize(18);
  text(ang,-circle_R/2-60,0);

  strokeWeight(1);
  stroke(220);
  line(-circle_R/2,0,circle_R/2,0);
  line(0,-circle_R/2,0,circle_R/2);
  fill(200,200,80);
  stroke(200,200,90);
  translate(0,0);  
  rotate(radians(-ang)); 
  beginShape();
for (int i = 0; i < 4; i++) {
  int R;
    if (i % 2 == 0) {
     R =Diamond/3 ;
    } else {
     R =Diamond;
    }
    vertex(R*cos(radians(90*i)), R*sin(radians(90*i)));
  } endShape(CLOSE);
popMatrix();
}

class graphMonitor {
    String TITLE;
    int X_POSITION, Y_POSITION;
    int X_LENGTH, Y_LENGTH;
    float [] y1;
    float maxRange;
    int c;
    graphMonitor(String _TITLE, int _X_POSITION, int _Y_POSITION, int _X_LENGTH, int _Y_LENGTH ,int _COLOR) {
      TITLE = _TITLE;
      X_POSITION = _X_POSITION;
      Y_POSITION = _Y_POSITION;
      X_LENGTH   = _X_LENGTH;
      Y_LENGTH   = _Y_LENGTH;
      c=_COLOR;
      y1 = new float[X_LENGTH];
      for (int i = 0; i < X_LENGTH; i++) {
        y1[i] = 0;//rotations     
      }
    }
 void graphDraw(float _y1) {
      y1[X_LENGTH - 1] = _y1;
      for (int i = 0; i < X_LENGTH - 1; i++) {
        y1[i] = y1[i + 1];
      }
      maxRange = 1.0;
      for (int i = 0; i < X_LENGTH - 1; i++) {// maxRange change
        maxRange = (abs(y1[i]) > maxRange ? abs(y1[i]) : maxRange);//range change
    }
      pushMatrix();
      translate(X_POSITION, Y_POSITION);//graph position 
      fill(25);//in fill
      stroke(160);//out fill
      strokeWeight(1);//line weight
      rect(0,0, X_LENGTH, Y_LENGTH);//rect potison
      line(0, Y_LENGTH / 2, X_LENGTH, Y_LENGTH / 2);//center line

      textSize(25);//graph title
      fill(80,200,200);
      textAlign(LEFT, BOTTOM);
      text(TITLE, 20, -5);

      textSize(22);//origin
      fill(220);//white
      textAlign(RIGHT);
      text(0, -5, Y_LENGTH / 2 + 7);

      textSize(20);
      text(nf(maxRange, 0, 1), -5, 18);//range
      text(nf(-1 * maxRange, 0, 1), -5, Y_LENGTH);
      translate(0, Y_LENGTH / 2);
      text(nf(y1[X_LENGTH - 1],0,2), X_LENGTH+80,-3);//data minute

      scale(1, -1);
      strokeWeight(1);
      for (int i = 0; i < X_LENGTH - 1; i++) {
        stroke(axis_color[c][0],axis_color[c][1],axis_color[c][2]);//color change
        line(i, y1[i] * (Y_LENGTH / 2) / maxRange, i + 1, y1[i + 1] * (Y_LENGTH / 2) / maxRange);// graph data output
      }
      popMatrix();
    }
}
