//CLASSES
PFont fText;

// VARIABLES
int W=706;
int H=530;
int xTrsl=50;
int yTrsl=50;
int xSpan=W-xTrsl*2;
int ySpan=H-yTrsl*2;
int gap=10;
int hBaseLineInt=5;
int eDiffInt=20;
int eGraphSpan=1000;
int ptNum, ptNum2, ele, hBaseLine;
float xMin, xMax, xMed, yMin, yMax, yMed, eMin, eMax, trkLength, eLine, eLineInt, distLine;
float[] xList, yList, eList, dist, segLength, eDiffList, distGraph, eGraph;
double[] xLd, yLd;
boolean once=true;

//COLORS
color bg=color(33);
color txtCol=color(200);
color actCol=color(200, 100, 75);
color fgCol=color(8, 162, 207);
color bgCol=color(5, 100, 130, 100);

////////
////////
void setup() {
  size(706, 530, P3D);
  //fText = createFont("Monaco", 10, true);

  //SETUP GPX
  String[] gpxList=loadStrings("http://a3panda.altervista.org/escursoreBlogger/130616_BalzeDegliSpicchi/13.06.16_Catria.gpx");
  String gpxListTot=join(gpxList, "");
  String[] ptListUntrimmed=split(gpxListTot, "<trkpt lat=");
  int ptNum=ptListUntrimmed.length-1;
  String ptTot="";
  for (int i=1; i<ptListUntrimmed.length; i++) ptTot=ptTot+ptListUntrimmed[i];
  String[] ptLatLonUntrimmed=splitTokens(ptTot, "\"");

  //SETUP LAT LON
  String[] latList=new String[ptNum];
  String[] lonList=new String[ptNum];
  String[] eleListUntrimmed=new String[ptNum];
  int j=0;
  for (int i=0; i<ptLatLonUntrimmed.length; i+=4) {
    latList[j]=ptLatLonUntrimmed[i];
    lonList[j]=ptLatLonUntrimmed[i+2];
    eleListUntrimmed[j]=ptLatLonUntrimmed[i+3];
    j++;
  }

  //SETUP ELE
  String eleListTot=join(eleListUntrimmed, "");
  String[] eleListTrimmed1=split(eleListTot, "</ele>");
  eleListTot=join(eleListTrimmed1, "");
  String[] eleListTrimmed2=split(eleListTot, "><ele>");
  eleListTot="";
  for (int i=1; i<eleListTrimmed2.length; i++) eleListTot=eleListTot+"<t"+eleListTrimmed2[i];
  String[] eleListTrimmed3=split(eleListTot, "<t");

  String[] eleList=new String[ptNum];
  j=0;
  for (int i=1; i<eleListTrimmed3.length; i+=2) {
    eleList[j]=eleListTrimmed3[i];
    j++;
  }

  //TRACK POINTS COORDS
  xLd=new double[ptNum];
  yLd=new double[ptNum];
  xList=new float[ptNum];
  yList=new float[ptNum];
  eList=new float[ptNum];

  for (int i=0; i<ptNum; i++) {
    xList[i]=float(lonList[i]);
    yList[i]=float(latList[i]);
    eList[i]=float(eleList[i]);
  }

  xMin=min(xList);
  xMax=max(xList);
  yMin=min(yList);
  yMax=max(yList);
  xMed=(xMin+xMax)/2;
  yMed=(yMin+yMax)/2;
  eMin=min(eList);
  eMax=max(eList);
  float eSpan=eMax-eMin;

  println(yMed+" "+xMed);

  for (int i=0; i<ptNum; i++) {
    xLd[i]=Double.parseDouble(lonList[i]);
    xLd[i]=(xLd[i]*10-round(xMed*10));
    yLd[i]=Double.parseDouble(latList[i]);
    yLd[i]=(yLd[i]*10-round(yMed*10));
    xList[i]=(float)xLd[i];
    yList[i]=(float)yLd[i];
  }

  //for (int i=0; i<ptNum; i++) println(xList[i]+"\t"+yList[i]+"\t"+eList[i]);

  //VALUTAZIONE PENDENZA PER SCRITTE GRAFICO
  eDiffList=new float[ptNum];
  for (int i=0; i<ptNum/2; i++) eDiffList[i]=eList[i]-eList[i+eDiffInt];
  for (int i=ptNum-1; i>=ptNum/2; i-=1) eDiffList[i]=eList[i-eDiffInt]-eList[i]; 

  //println(xList[0]+" "+xLd[0]);
  //println(xMin+" "+xMax+" "+yMin+" "+yMax+" "+eMin+" "+eMax);
  //println(ptNum+"\t"+xList.length);

  //ELEVATION SETUP
  segLength=new float[ptNum-1];  //segment length
  dist=new float[ptNum-1];       //cumulative distance
  for (int i=1; i<ptNum; i++) segLength[i-1]=sqrt(sq(xList[i]-xList[i-1])+sq(yList[i]-yList[i-1]));//+sq(eList[i]-eList[i-1]));
  dist[0]=segLength[0];
  for (int i=1; i<dist.length; i++) dist[i]=dist[i-1]+segLength[i];
  trkLength=dist[dist.length-1]*10;
  println(trkLength);

  //ELEVATION/DIST GRAPH SETUP
  distGraph=new float[ptNum-1];
  eGraph=new float[ptNum];
  hBaseLine=floor(eMin/hBaseLineInt)*hBaseLineInt;
  for (int i=0; i<ptNum-1; i++) {
    distGraph[i]=dist[i]*xSpan/trkLength*10;
    eGraph[i]=(eList[i]-eMin)*ySpan/eGraphSpan;
    //println(distGraph[i]);
  }
  eLine=(hBaseLine-eMin)*ySpan/eSpan;
  eLineInt=hBaseLineInt*ySpan/eSpan;
  distLine=100*xSpan/trkLength;

  ///////////////////////
  // WHY // WHY // WHY //
  ///////////////////////
  //for (int i=0; i<100; i++) println(distGraph[i]+"\t"+(ySpan-eGraph[i]));
  //println(ptNum);
  ptNum2=ptNum;
}

void draw() {
  if (once) {
    println(ptNum);
    println(ptNum2);
    once=false;
  }
  background(bg);
  strokeWeight(1);
  stroke(txtCol);
  noFill();
  pushMatrix();
  translate(xTrsl, yTrsl);
  line(.5, 0, .5, ySpan);
  line(.5, 0, -4.5, 5);
  line(0, ySpan+.5, xSpan, ySpan+.5);
  line(xSpan, ySpan+.5, xSpan-5, ySpan+4.5);

  beginShape();
  for (int i=0; i<ptNum2-1; i++) vertex(distGraph[i], ySpan-eGraph[i]);
  endShape();
  popMatrix();

  //for (int i=1; i<ptNum; i++) line(98.73658, 320.24683, distGraph[i], ySpan-eGraph[i]);

  stroke(fgCol);
  fill(fgCol);
  //textFont(fText);

  int seg=0;
  float diff;
  if (mouseX>xTrsl && mouseX<W-xTrsl) {
    for (int i=0; i<ptNum2; i++) {
      diff=mouseX-xTrsl-distGraph[i];
      if (diff<0) {
        seg=i;
        break;
      }
    }
    line(mouseX, ySpan+yTrsl-eGraph[seg]+10, mouseX, H-yTrsl);
    line(mouseX, ySpan+yTrsl-eGraph[seg]-10, mouseX, ySpan+yTrsl-eGraph[seg]-40);
    if (eDiffList[seg]<0) {
      textAlign(RIGHT, TOP);
      text(round(eList[seg]), mouseX-5, ySpan+yTrsl-eGraph[seg]-40);
    } else {
      textAlign(LEFT, TOP);
      text(round(eList[seg]), mouseX+5, ySpan+yTrsl-eGraph[seg]-40);
    }
    if (mouseX>xSpan) {
      textAlign(RIGHT, TOP);
      text(round(dist[seg]*10000), mouseX-5, H-yTrsl-15);
    } else {
      textAlign(LEFT, TOP);
      text(round(dist[seg]*10000), mouseX+5, H-yTrsl-15);
    }
  }
}
