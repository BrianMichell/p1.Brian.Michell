int col1Start, col2Start, col3Start, col4Start;
final int COL_1_ROWS = 7;
final int COL_2_ROWS = 9;
final int COL_3_ROWS = 7;
final int COL_4_ROWS = 5;
final int LABEL_DIAMETER = 50;
final int PADDING = 25; 

byte currentFloor = 5;
byte assistRecovery = 0;
boolean directionUp = true;
ArrayList<Byte> floors = new ArrayList<Byte>();

// Assuming 60Hz draw clock
final byte MOVE_FRAMES = 120; // 2 seconds
final int AWAIT_FRAMES = 420; // 7 seconds

byte elevatorMoveFrames = MOVE_FRAMES;
int awaitFrames = AWAIT_FRAMES; 

final color BUTTON_PRESSED = color(0,255,0);

// It was incapable of displaying extended ASCII characters
final String[] labels = {
    "Open",
    "Close",
    "10",
    "8",
    "6",
    "4",
    "2",
    "G",
    "Assist",
    "11",
    "9",
    "7",
    "5",
    "3"
};

void setup() {
    size(350,750);
    col1Start = 0;
    col2Start = 75;
    col3Start = 150;
    col4Start = 225;
}

void draw() {
    background(128,128,128);
    addCircles();

    fill(0);
    rect(175, 50, 150, 125);
    fill(255,0,0);
    textAlign(CENTER);
    textSize(50);
    if(currentFloor == 0) {
        textSize(20);
        text("Assistance called", 175+75, 50+75);
    } else {
        text(str(currentFloor), 175+75, 50+75);
    }

    determineButton(mouseX, mouseY);

    if(!floors.isEmpty() && awaitFrames >= 0) {
        awaitFrames--;
    } else if(floors.isEmpty()) {
        // Do nothing
    } else {
        moveElevator();
    }
}

// Draws the circles on the screen
void addCircles() {
    //Column 1 setup
    int l = 0;
    textAlign(CENTER);
    textSize(20);
    for(int i=1; i<= COL_1_ROWS; i++) {
        fill(0);
        ellipse(LABEL_DIAMETER, PADDING*i+LABEL_DIAMETER*i, LABEL_DIAMETER, LABEL_DIAMETER);
        fill(255);
        text(labels[l], LABEL_DIAMETER, PADDING*i+LABEL_DIAMETER*i+5);
        l++;
    }
    //Column 2 setup
    fill(100,100,100);
    for(int i=1; i<= COL_2_ROWS; i++) {
        if(i>7) {
            fill(0);
            ellipse(LABEL_DIAMETER+col2Start, PADDING*i+LABEL_DIAMETER*i, LABEL_DIAMETER, LABEL_DIAMETER);
            fill(255);
            text(labels[l],LABEL_DIAMETER+col2Start, PADDING*i+LABEL_DIAMETER*i+5);
            l++;
        } else {
            fill(100,100,100);
            for(byte f : floors) {
                if(f==10 && i==3 || f==8 && i==4 || f==6 && i==5 || f==4 && i==6 || f==2 && i==7){ // This is gross and bad but I'm lazy and don't want to spend the time to do it correctly
                    fill(BUTTON_PRESSED);
                }
            }
            ellipse(LABEL_DIAMETER+col2Start, PADDING*i+LABEL_DIAMETER*i, LABEL_DIAMETER, LABEL_DIAMETER);
        }
    }
    //Column 3 setup
    fill(0);
    for(int i=3; i<=COL_3_ROWS+2; i++) { // Needed to offset by 2 rows
        
        if(l<14) {
            fill(0);
            ellipse(LABEL_DIAMETER+col3Start, PADDING*i+LABEL_DIAMETER*i, LABEL_DIAMETER, LABEL_DIAMETER);
            fill(255);
            text(labels[l], LABEL_DIAMETER+col3Start, PADDING*i+LABEL_DIAMETER*i+5);
            l++;
        } else {
            fill(100,100,100);
            for(byte f : floors) {
                if(f==1 && i==8) {
                    fill(BUTTON_PRESSED);
                }
            }
            ellipse(LABEL_DIAMETER+col3Start, PADDING*i+LABEL_DIAMETER*i, LABEL_DIAMETER, LABEL_DIAMETER);
        }
    }
    //Column 4 setup
    for(int i=3; i<=COL_4_ROWS+2; i++) { // Needed to offset by 2 rows
        fill(100,100,100);
        for(byte f : floors) {
            if(f==11 && i==3 || f==9 && i==4 || f==7 && i==5 || f==5 && i==6 || f==3 && i==7){
                fill(BUTTON_PRESSED);
            }
        }
        ellipse(LABEL_DIAMETER+col4Start, PADDING*i+LABEL_DIAMETER*i, LABEL_DIAMETER, LABEL_DIAMETER);
    }
}

/**
Determines if the circle is a button or label
*/
byte determineButton(int mouseX, int mouseY) {
    byte b = 1;
    // Check column 2 buttons
    for(int i=1; i<= COL_2_ROWS-2; i++) {
        float x = LABEL_DIAMETER+col2Start;
        float y = PADDING*i+LABEL_DIAMETER*i;
        if(isOver(x,y,mouseX,mouseY)) {
            fill(255,255,0,100);
            ellipse(LABEL_DIAMETER+col2Start, PADDING*i+LABEL_DIAMETER*i, LABEL_DIAMETER, LABEL_DIAMETER);
            return button(b);
        }
        b++;
    }
    // Check column 3 buttons
    for(int i=COL_3_ROWS+2; i>COL_3_ROWS; i--) {
        float x = LABEL_DIAMETER+col3Start;
        float y = PADDING*i+LABEL_DIAMETER*i;
        if(isOver(x,y,mouseX,mouseY)) {
            fill(255,255,0,100);
            ellipse(LABEL_DIAMETER+col3Start, PADDING*i+LABEL_DIAMETER*i, LABEL_DIAMETER, LABEL_DIAMETER);
            return button(b);
        }
        b++;
    }
    // Check column 4 buttons
    for(int i=3; i<=COL_4_ROWS+2; i++) {
        float x = LABEL_DIAMETER + col4Start;
        float y = PADDING*i+LABEL_DIAMETER*i;
        if(isOver(x,y,mouseX,mouseY)) {
            fill(255,255,0,100);
            ellipse(LABEL_DIAMETER+col4Start, PADDING*i+LABEL_DIAMETER*i, LABEL_DIAMETER, LABEL_DIAMETER);
            return button(b);
        }
        b++;
    }
    return 0;
}

boolean isOver(float x, float y, int mouseX, int mouseY) {
    return sqrt(sq(x-mouseX) + sq(y-mouseY)) < LABEL_DIAMETER/2;
}

// Fixes which floor/button is pressed
byte button(byte b) {
    switch(b){
        case 1: // Door open
            return 12;
        case 2: // Door close
            return 13;
        case 3: // 10
            return 10;
        case 4: // 8
            return 8;
        case 5: // 6
            return 6;
        case 6: // 4
            return 4;
        case 7: // 2
            return 2;
        case 8: // Assist
            return 14;
        case 9: // Ground
            return 1;
        case 10: // 11
            return 11;
        case 11: // 9
            return 9;
        case 12: // 7
            return 7;
        case 13: // 5
            return 5;
        case 14: // 3
            return 3;
        default:
            return 0; // ERROR MODE (Should never enter this anyway)
    }
}

void mousePressed() {
    byte floor = determineButton(mouseX, mouseY);
    if(currentFloor == 0) { // Recovers gracefuly from assist button call
        currentFloor = assistRecovery;
    }
    if(floor != 0 && floor <= 11) {
        // Move logic
        if(floor < currentFloor && (!directionUp || floors.isEmpty()) && !floors.contains(floor)) {
            directionUp = false;
            floors.add(floor);
        } else if(floor > currentFloor && (directionUp || floors.isEmpty()) && !floors.contains(floor)) {
            directionUp = true;
            floors.add(floor);
        } 
    } else if(floor > 11) {
        if(floor == 13) {
            awaitFrames-= 100; // Pushing the button a bunch of times really does help here!
        }
        if(floor == 12) {
            awaitFrames = AWAIT_FRAMES;
        }
        if(floor == 14) {
            assistRecovery = currentFloor;
            currentFloor = 0;
        }
    }
}

void moveElevator() {
    byte multiplier = 1;
    if(!directionUp) {
        multiplier = -1;
    }
    elevatorMoveFrames--;
    if(elevatorMoveFrames <= 0) {
        currentFloor+=multiplier;
        if(floors.contains(currentFloor)) {
            floors.remove((Byte)currentFloor);
            awaitFrames = AWAIT_FRAMES;
        }
        elevatorMoveFrames = MOVE_FRAMES;
    }

}