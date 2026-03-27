// Game state: 0=Start, 1=Play, 2=GameOver, 3=Win
int state = 0;
int startTime;
int duration = 30;

// Playe
float px = 350;
float py = 280;
float vx = 0;
float vy = 0;
float accel = 0.6;
float friction = 0.9;
float gravity = 0.6;
float jumpForce = -12;
float pR = 20; 
float groundY = 300; 

// Start
int lives = 3;
boolean canHit = true;
int lastHitTime = 0;
int hitCooldownMs = 800;

// Enemy variables 
int n = 8;
float[] ex = new float[n];
float[] ey = new float[n];
float[] evx = new float[n];
float[] evy = new float[n];
float eR = 15; // Enemy radius

void setup() {
  size(700, 350);
  frameRate(60);
  resetGame();
}

// Resets player 
void resetGame() {
  px = 350;
  py = 280;
  vx = 0;
  vy = 0;
  lives = 3;
  
  // Initialize each enemy with random position and speed
  for (int i = 0; i < n; i++) {
    ex[i] = random(eR, width - eR);
    ey[i] = random(eR, height - eR);
    evx[i] = random(-3, 3);
    evy[i] = random(-3, 3);
    // Ensure they aren't moving too slowly
    if (abs(evx[i]) < 1) evx[i] = 2;
    if (abs(evy[i]) < 1) evy[i] = -2;
  }
}

void draw() {
  background(20, 25, 40); // Dark background

  // Start Screen
  if (state == 0) {
    textAlign(CENTER);
    textSize(32);
    fill(255, 220, 0);
    text("DODGE & SURVIVE", width/2, 120);
    textSize(18);
    fill(255);
    text("Press ENTER to Start", width/2, 180);
  }
  
  // Gameplay Screen
  else if (state == 1) {
    updatePlayer();
    updateEnemies();
    checkCollision();
    drawPlayer();
    drawEnemies();
    drawUI();
    
    // Check if time has run out
    int elapsed = (millis() - startTime) / 1000;
    if (elapsed >= duration) {
      state = 3; // Win state
    }
  }
  
  // Game Over Screen
  else if (state == 2) {
    textAlign(CENTER);
    textSize(32);
    fill(255, 50, 50);
    text("GAME OVER", width/2, 150);
    textSize(18);
    fill(255);
    text("Press R to Restart", width/2, 200);
  }
  
  // Win Screen
  else if (state == 3) {
    textAlign(CENTER);
    textSize(32);
    fill(50, 255, 150);
    text("YOU WIN", width/2, 150);
    textSize(18);
    fill(255);
    text("Press R to Restart", width/2, 200);
  }
}

// Handles player movement 
void updatePlayer() {
  if (keyPressed) {
    if (keyCode == RIGHT) vx += accel;
    if (keyCode == LEFT) vx -= accel;
  }
  
  vx *= friction; 
  vy += gravity;  
  
  px += vx;
  py += vy;
  
 
  if (py > groundY) {
    py = groundY;
    vy = 0;
  }
  

  px = constrain(px, pR, width - pR);
}


void drawPlayer() {
  noStroke();
  
  if (!canHit) {
    fill(255, 255, 255, 150); 
  } else {
    fill(0, 240, 255); 
  }
  ellipse(px, py, pR*2, pR*2);
}

// Moves enemies and bounces them off walls
void updateEnemies() {
  for (int i = 0; i < n; i++) {
    ex[i] += evx[i];
    ey[i] += evy[i];
    
    // Wall bounce 
    if (ex[i] > width - eR || ex[i] < eR) evx[i] *= -1;
    if (ey[i] > height - eR || ey[i] < eR) evy[i] *= -1;
  }
}


void drawEnemies() {
  fill(255, 0, 150); 
  for (int i = 0; i < n; i++) {
    ellipse(ex[i], ey[i], eR*2, eR*2);
  }
}

// Checks if player is touching any enemy
void checkCollision() {
 
  if (!canHit && millis() - lastHitTime > hitCooldownMs) {
    canHit = true;
  }
  
  for (int i = 0; i < n; i++) {
    float d = dist(px, py, ex[i], ey[i]);

    if (d < pR + eR && canHit) {
      lives--;
      lastHitTime = millis();
      canHit = false;
      if (lives <= 0) state = 2; // Move to Game Over
    }
  }
}

// Displays Lives and Timer
void drawUI() {
  fill(255, 220, 0);
  textAlign(LEFT);
  textSize(16);
  int elapsed = (millis() - startTime) / 1000;
  text("Lives: " + lives, 20, 25);
  text("Time: " + (30 - elapsed) , 20, 45);
}


void keyPressed() {
  // Start game
  if (state == 0 && keyCode == ENTER) {
    startTime = millis();
    state = 1;
  }
  // Jump 
  if (state == 1 && key == ' ' && py == groundY) {
    vy = jumpForce;
  }
  // Restart game
  if ((state == 2 || state == 3) && (key == 'r' || key == 'R')) {
    resetGame();
    state = 0;
  }
}
