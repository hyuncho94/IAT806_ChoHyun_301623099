/* Solar system clock
Type in a current time and hit the Enter key to set an alarm time
Type in an alarm time and hit the Enter key to start

The red planet represents hours, it orbits around the sun every 12 hours
Blue planet represents minute, it orbits around the sun every 60 minutes
white planet represents the second, it orbits around the blue planet per 60 seconds

When the timer hits the set alarm time, a big bang effect occurs
*/

String input = ""; // setthe starting time
boolean isInputtingCurrentTime = true; // check if there is a current time input
boolean isInputtingAlarmTime = false; // check if there is a alarm time input
int hours = 0, minutes = 0, seconds = 0; // current time
int alarmHours = -1, alarmMinutes = -1, alarmSeconds = -1; // alarm time (no input yet)
boolean alarmTriggered = false; // alarm trigger state

//drawing solar system
float sunX, sunY; // sun position
float earthAngle, marsAngle, moonAngle; // angle for planets
float earthOrbitRadius = 150; 
float marsOrbitRadius = 250;
float moonOrbitRadius = 40;
float earthSpeed = TWO_PI / 3600; // earth orbits every 3600 frames (3600/60 = 60 == 1hour) 
float marsSpeed = TWO_PI / 43200; // mars orbits every 43200 frames (43200/60/12 = 60 == 12 hours)
float moonSpeed = TWO_PI / 60; // moon orbits every 60 frames (60/60 1==1min)

// alarm effect
int maxCircles = 10; // big bang effect ellipse number
float[] circleSizes; // big bang effect ellipse size
color[] circleColors; // big bang effect colors

void setup() {
  size(800, 800); //set canvas size
  sunX = width / 2; // set sun's position in the center of the screen
  sunY = height / 2;
  textSize(20); // set text size

  // big bang effect
  circleSizes = new float[maxCircles]; //save circle sizes
  circleColors = new color[maxCircles]; // save circle colors
  for (int i = 0; i < maxCircles; i++) {
    circleSizes[i] = i * 50; // create 10 different size circles
    circleColors[i] = color(random(255), random(255), random(255)); // create different color circles
  }
}

void draw() {
  background(0); // background

// Typing starting time
// create setting time scene
  if (isInputtingCurrentTime) {
    fill(255);
    text("Enter current time (HH:MM:SS): " + input, width / 2 - 200, height / 2); 
  } else if (isInputtingAlarmTime) {
    // create alarm setting scene
    fill(255);
    text("Enter alarm time (HH:MM:SS): " + input, width / 2 - 200, height / 2);
  } else {
    // if alarm time is same as the current time and trigger alarm
    if (alarmTriggered) { 
      drawBigBangEffect(); //start big bang effect 
    } else {
      // keep showing the solar system scene
      translate(sunX, sunY); // set center to the sun's center

      // draw orbit
      stroke(150);
      noFill();
      ellipse(0, 0, earthOrbitRadius * 2, earthOrbitRadius * 2); // earth orbit
      ellipse(0, 0, marsOrbitRadius * 2, marsOrbitRadius * 2);   // mars orbit
      ellipse(earthOrbitRadius * cos(earthAngle), earthOrbitRadius * sin(earthAngle), moonOrbitRadius * 2, moonOrbitRadius * 2); // moon orbit

      // draw sun
      fill(255, 204, 0);
      noStroke();
      ellipse(0, 0, 50, 50);

      // draw earth
      float earthX = earthOrbitRadius * cos(earthAngle); // earth X position according to trigonometric
      float earthY = earthOrbitRadius * sin(earthAngle); // earth y position according to trigonometric
      fill(0, 102, 255); //earth color
      ellipse(earthX, earthY, 30, 30); // draw earth

      // draw moon
      float moonX = earthX + moonOrbitRadius * cos(moonAngle); //moon x position
      float moonY = earthY + moonOrbitRadius * sin(moonAngle); //moon y position
      fill(200); // moon color
      ellipse(moonX, moonY, 15, 15); //draw moon

      // draw mars
      float marsX = marsOrbitRadius * cos(marsAngle); //mars x position
      float marsY = marsOrbitRadius * sin(marsAngle); // mars y position
      fill(255, 102, 102); // mars color
      ellipse(marsX, marsY, 40, 40); // draw mars

      // update time
      if (frameCount % 60 == 0) { // every 60 frame update 1 
        updateTime();
      }

      // update angles
      earthAngle += earthSpeed / 60.0; 
      moonAngle += moonSpeed / 60.0;
      marsAngle += marsSpeed / 60.0;
    }

    // show current time and alarm time on the screen
    resetMatrix(); // reset center
    fill(255); 
    textAlign(CENTER);
    text("Time: " + nf(hours, 2) + ":" + nf(minutes, 2) + ":" + nf(seconds, 2), width / 2, 50); // nf is function for number format, nf(intValue, digits) this is why time looks like 00:00:00
    text("Alarm: " + nf(alarmHours, 2) + ":" + nf(alarmMinutes, 2) + ":" + nf(alarmSeconds, 2), width / 2, 80);

    // check if alarm time matches current time and alarm trigger is false
    if (!alarmTriggered && hours == alarmHours && minutes == alarmMinutes && seconds == alarmSeconds) {
      alarmTriggered = true; // trigger alarm
    }
  }
}
// function for alarm trigger effect
void drawBigBangEffect() {
  for (int i = 0; i < maxCircles; i++) { //repeat 10 times
    noFill();
    stroke(circleColors[i]); 
    strokeWeight(2);
    ellipse(sunX, sunY, circleSizes[i], circleSizes[i]);// draw ellipse

    // grow circle size 
    circleSizes[i] += 5;

    // if the circle is bigger than the canvas size reset to 0
    if (circleSizes[i] > width * 1.5) {
      circleSizes[i] = 0;
      circleColors[i] = color(random(255), random(255), random(255)); // 새로운 색상
    }
  }
}

//function for updating current time
void updateTime() {
  seconds++; // add seconds
  if (seconds >= 60) { //if seconds hit 60
    seconds = 0; //reset to 0
    minutes++; // and add 1 minute
  }
  if (minutes >= 60) { //if minutes hit 60
    minutes = 0; // reset to 0
    hours++; // and add hour
  }
  if (hours >= 24) { //if hour hit 24
    hours = 0; // reset clock
  }
}

void keyPressed() {
  if (isInputtingCurrentTime || isInputtingAlarmTime) { // if this is setting time scene or setting alarm scene
    if (key == ENTER || key == RETURN) { // if the input is Enter key or return key
      parseInput(); // parse input
    } else if (key == BACKSPACE) { // if the input is backspace
      if (input.length() > 0) { // if there is something written
        input = input.substring(0, input.length() - 1); // delete the last input
      }
    } else if (key != CODED) { //if the input is not special key
      input += key; // add key to input
    }
  }
}

void parseInput() {
  String[] parts = split(input, ':'); // the input is divided accoring to : and saved seperately
  if (parts.length == 3 && isValidNumber(parts[0]) && isValidNumber(parts[1]) && isValidNumber(parts[2])) { // if hour min sec is are input and all parts are valid numbers
    int h = int(parts[0]); // set hour
    int m = int(parts[1]); // set min
    int s = int(parts[2]); // set sec

    // if hour is same or bigger than 0 and less than 24 and minute is equal or less than 60 and second is equal or bigger than 0 and less than 60
    if (h >= 0 && h < 24 && m >= 0 && m < 60 && s >= 0 && s < 60) { 
      if (isInputtingCurrentTime) { // if it is a setting time scene
        hours = h;
        minutes = m;
        seconds = s;
        isInputtingCurrentTime = false; // set time and change the current state to false
        isInputtingAlarmTime = true; // set alarm scene state true
        resetAngles(); // reset angle
      } else if (isInputtingAlarmTime) { // if it is alarm setting scene
        alarmHours = h;
        alarmMinutes = m;
        alarmSeconds = s;
        isInputtingAlarmTime = false; //set alarm time and change state to false
      }
      input = ""; // reset input
    }
  } else {
    input = ""; // reset input
  }
}

boolean isValidNumber(String str) { // check if the input number is valid 
  for (int i = 0; i < str.length(); i++) { // check all the string
    if (!Character.isDigit(str.charAt(i))) { // Character.isDigit(char) checks if the character is number and str.charAT(i) indicates ith character of the string
      return false; //if it's not number it's false
    }
  }
  return true; // all characters are number
}

void resetAngles() { // converting time to angle of the planets
  int totalSeconds = hours * 3600 + minutes * 60 + seconds;
  earthAngle = map(totalSeconds, 0, 3600, -HALF_PI, TWO_PI - HALF_PI); //  map(value, inputstart, inputend, outputstart, outputend);  // since earth orbit during 0 to 3600 frame, - half pi is 0 degree and 2pi -half pi is 360 degree // map current time in range of 0 to 3600 to 0 to 360 degree
  marsAngle = map(totalSeconds, 0, 43200, -HALF_PI, TWO_PI - HALF_PI);
  moonAngle = map(totalSeconds % 60, 0, 60, -HALF_PI, TWO_PI - HALF_PI); 
}
