import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 125; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

int screenWidth = 800;
int screenHeight = 800;

float keyWidth = 12;
float keyHeight = 15;
float keyScale = 1.3;
float keyWSpacing = 12.5;
float keyHSpacing = keyHeight + 2;
float spaceW = 80;
float delW = 20;

float leftEdge;
float topEdge;
float yOffset;

String[] common;
String mostCommon = "";

private class Key 
{
  float x = 0;
  float y = 0;
  float w = keyWidth;
  float h = keyHeight;
  char label = 'a';
}

ArrayList<Key> keys = new ArrayList<Key>();
char[] letters = {'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ' ', '<'};

boolean isMouseHover(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x - w/2 && mouseX< x + w/2 && mouseY > y - h/2 && mouseY< y + h/2); //check to see if it is in button bounds
}


//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
  
  leftEdge = width / 2 - sizeOfInputArea / 2 + 1;
  topEdge = height / 2 - sizeOfInputArea / 2;
  yOffset = height/2;

  
  // Set-up keyboard keys
  for (int i = 0; i < letters.length; i++) 
  {
    Key k = new Key();
    if (i < 10) {
      k.x = leftEdge + ((sizeOfInputArea - keyWSpacing * 9) / 2) + i * keyWSpacing;
      k.y = yOffset + 0 * keyHSpacing;
    }
    else if (i < 19) {
      k.x = leftEdge + ((sizeOfInputArea - keyWSpacing * 8) / 2) + (i-10) * keyWSpacing;
      k.y = yOffset + 1 * keyHSpacing;
    }
    else if (i < 26) {
      k.x = leftEdge + ((sizeOfInputArea - keyWSpacing * 6) / 2) + (i-19) * keyWSpacing;
      k.y = yOffset + 2 * keyHSpacing;
    }
    else if (i == 26) {
      k.x = leftEdge + (sizeOfInputArea / 2);
      k.y = yOffset + 3 * keyHSpacing;
      k.w = spaceW;
    }
    else {
      k.x = leftEdge + (sizeOfInputArea / 2) + spaceW / 2 + delW / 2;
      k.y = yOffset + 3 * keyHSpacing;
      k.w = delW;
    }
    k.label = letters[i];
    keys.add(k);
    println("Added letter " + k.label + " at " + k.x + ", " + k.y + " to keys");
  }
  
  //common = loadStrings("count_2l.txt"); //load the common letter combos into memory
  //println(((common[0]).split("  "))[0]);
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  rectMode(CENTER);
  background(255); //clear background
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2, height/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
  
  textSize(36);
  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", width/2, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(CENTER); //align the text center
    fill(255);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, width/2, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, width/2, 100); //draw the target string
    fill(0);
    text("Entered:  " + currentTyped +"|", width/2, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(width - 100, height - 100, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", width - 100, height - 100); //draw next label
  }
  
  fill(255);
  textSize(10);
  mostCommon = currentTyped + "|";
  text(mostCommon, width / 2, height / 2 - sizeOfInputArea / 4);
  
  // Drawing the keyboard
  for (int i = 0; i < 28; i++) 
  {
    Key k = keys.get(i);
    float scale = 1;
    stroke(0);
    fill(255);
    if (isMouseHover(k.x, k.y, k.w, k.h)) {
      fill(200);
      scale = keyScale;
    }
    rect(k.x, k.y, k.w, k.h * scale);
    textAlign(CENTER, CENTER);
    noStroke();
    fill(0);
    textSize(k.w * scale);
    text(k.label, k.x, k.y - 3); //draw current letter
  }
  
    //fill(0);
    //ellipse(leftEdge + (sizeOfInputArea - keyWSpacing * 9) / 2, yOffset, 10, 10);
}

//String searchCommon() {
//  String maxString = ""; 
//  int max = 0;
//  for (int i = 0; i < common.length; i++) {
//    if ((common[i].contains(currentTyped)) && common[i].freq > max) {
//      maxString = common[i];
//      max = common[i].freq;
//    }
//  }
//  return maxString;
//}


void mousePressed()
{
  for (int i = 0; i < letters.length; i++) {
    Key k = keys.get(i);
    if (isMouseHover(k.x, k.y, k.w, k.h)) {
      char currLetter = k.label;
      if (currLetter == '<') {
        if (currentTyped.length() > 0) {
          currentTyped = currentTyped.substring(0, currentTyped.length()-1);
        }
        break;
      }
      currentTyped += k.label;
      break;
    }
  }
  
  //mostCommon = searchCommon();
  //if (didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in left button
  //{
  //  currentLetter --;
  //  if (currentLetter<'_') //wrap around to z
  //    currentLetter = 'z';
  //}

  //if (didMouseClick(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2)) //check if click in right button
  //{
  //  currentLetter ++;
  //  if (currentLetter>'z') //wrap back to space (aka underscore)
  //    currentLetter = '_';
  //}

  //if (didMouseClick(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea/2)) //check if click occured in letter area
  //{
  //  if (currentLetter=='_') //if underscore, consider that a space bar
  //    currentTyped+=" ";
  //  else if (currentLetter=='`' & currentTyped.length()>0) //if `, treat that as a delete command
  //    currentTyped = currentTyped.substring(0, currentTyped.length()-1);
  //  else if (currentLetter!='`') //if not any of the above cases, add the current letter to the typed string
  //    currentTyped+=currentLetter;
  //}

  //You are allowed to have a next button outside the 1" area
  if (isMouseHover(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}





//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
