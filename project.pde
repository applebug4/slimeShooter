int ground = 150;
int x = 200; // Player x position
int y; // Player y position
boolean moveLeft = false; 
boolean moveRight = false;
int numShapes = 3; // Number of inventory slots
int inventoryWidth = 75;
int slimeWidth = 170;
int slimeHeight = 200;
int enemyX = 710; // No enemy y since it's the same as the player y
int enemyHealth = 100;
int playerHealth = 100;
int messageDuration = 5000; // 5 seconds before the game quits after it's over
int messageStartTime; // Gets set to 0 after the game is over so it can count to 5 seconds
boolean gameOverState = false; 
ArrayList<slimeBall> slimeBalls = new ArrayList<slimeBall>(); // Creates an array list of slimeBall objects so I can call methods on them in the class later for ease of use
ArrayList<enemySlimeBall> enemySlimeBalls = new ArrayList<enemySlimeBall>();
float maxWidth = 190; // Maximum width the slimes can reach
float minWidth = 170;  // Original width of the slime
float widthChange = 1.5; // Amount to change the slime's width per frame
boolean expanding = true; // Stage of the slime's animation
boolean healingPotionUsed = false; 
boolean viewingInstructions = true; // Automatically set to true for the convenience of the player
boolean isSpecialAttackActive = false;
boolean shieldActive = false;
int shieldStartTime = 0; // Timer starts at 0 and counts to 5
int shieldDuration = 5000; // Shield is active for 5 seconds each use
int timer = 0; // Timer for the enemy slime
int lastTime = 0; // Stores the last time the enemy slime attacked
int interval = 600; // Enemy slime attacks every .6 seconds

void setup() {
  size(1000, 700);
  y = height - ground; // Slime's y position is where the ground ends and the sky starts
  frameRate(26); 
}

void draw() {
    if (viewingInstructions) {
        drawInstructions();
        return; // Skip the rest of draw() if still viewing instructions
    }
  drawSky();
  drawRainbow();
  drawHills();
  drawGround();
  drawSlime(#ff005d);
  expandSlime();
  moveSlime();
  drawInventory();
  
  if (isSpecialAttackActive) { 
     shootSpecial();
  } else {
      shoot();
  }
  
  int currentTime = millis(); 
  
    if (currentTime - lastTime >= interval) { // Adds a new slime ball for the enemy to shoot every 2 seconds
        lastTime = currentTime; 
        enemySlimeBalls.add(new enemySlimeBall(enemyX + slimeWidth / 2, y - slimeHeight / 3, 10, 20));
    }
    
  enemyShoot(); 
  drawEnemySlime(#0373fc);
  drawSun();
  gameOver(); // Checks if the game is over continuously
  drawHealthBars(); 
  useShield(x, y, slimeWidth, slimeHeight, #ff005d); // Loads in shield instantly whenever the player uses it
}

void keyPressed() {
  if (keyCode == LEFT) {
    moveLeft = true;
  } else if (keyCode == RIGHT) {
    moveRight = true;
  }
  else if (key == 'e' || key == 'E') {
    if (!isSpecialAttackActive) {
      slimeBalls.add(new slimeBall(x + slimeWidth / 2, y - slimeHeight / 3, 10, 20));
    }
  } else if (key == '1') {
    shieldActive = true;
    shieldStartTime = millis();
  } else if (key == '2') {
    if (!isSpecialAttackActive) { // Makes sure a special attack isn't already active so that the player cannot abuse the feature
      slimeBalls.add(new slimeBall(x + slimeWidth / 2, y - slimeHeight / 3, 5, 180));
      isSpecialAttackActive = true;
    }
  } else if (key == '3') {
    if(!healingPotionUsed && playerHealth <= 50) { // Potion can only be used once 
      useHealingPotion();
    } 
  } else if (key == 'i' || key == 'I') { 
    viewingInstructions = false;
  }
}

void keyReleased() {
  if (keyCode == LEFT) { // Need to detect when the player releases the key or the player will move forever
    moveLeft = false;
  } else if (keyCode == RIGHT) {
    moveRight = false;
  }
}

void drawInstructions() {
    for (int i = 0; i <= height; i++) {
    float inter = map(i, 0, height, 0, 1);
    color c = lerpColor(#ff5e89, #5eb9ff, inter);
    stroke(c);
    line(0, i, width, i);
   }
  textSize(20);
  changeColor(#154899, 255);
  text("Welcome to slime shooter! You are a pink slime. Your goal is to eliminate the enemy slime, or the blue slime.", 50, 60);
  changeColor(#000000, 255);
  text("Instructions:", 50, 130);
  text("Press E to shoot slime balls at the enemy.", 50, 180);
  text("Use the left or right arrow keys to move left or right.", 50, 230);
  text("Press 1, 2, or 3 to use an item in your inventory.", 50, 280);
  text("Item 1 is a shield that protects you from the enemy's attacks for a few seconds.", 50, 330);
  text("Item 2 is a special attack that does a lot more damage to the enemy than shooting does.", 50, 380);
  text("There is a cooldown of 10 seconds for it.", 50, 430);
  text("Item 3 is a health potion that gives you 50 health points back.", 50, 480);
  text("It may only be used once per game, and only once you are below 50 health points.", 50, 530);
  changeColor(#991539, 255);
  text("Press i when you are ready to start! Good luck!", 300, 620);
}

void drawSky() {
  for (int i = 0; i <= height; i++) {
    float inter = map(i, 0, height, 0, 1);
    color c = lerpColor(#b8dbff, #57aaff, inter);
    stroke(c);
    line(0, i, width, i);
   }
}

void drawGround() {
  color grassTop = #13d446; 
  color grassBottom = #0b8e2a; 
  for (int i = height - ground; i < height; i++) {
    float inter = map(i, height - ground, height, 0, 1);
    color c = lerpColor(grassTop, grassBottom, inter);
    stroke(c);
    line(0, i, width, i);
  }
}

void drawRainbow() {
  changeColor(#ffffff, 255);
  arc(width/2, 300, 660, 660, PI, TWO_PI);
  changeColor(#ff0000, 185);
  arc(width/2, 300, 660, 660, PI, TWO_PI);
  changeColor(#ff9900, 185);
  arc(width/2, 300, 580, 580, PI, TWO_PI);
  changeColor(#fff200, 185);
  arc(width/2, 300, 500, 500, PI, TWO_PI);
  changeColor(#00ff22, 185);
  arc(width/2, 300, 420, 420, PI, TWO_PI);
  changeColor(#0015ff, 185);
  arc(width/2, 300, 340, 340, PI, TWO_PI);
  changeColor(#9900ff, 185);
  arc(width/2, 300, 260, 260, PI, TWO_PI);
  changeColor(#ffffff, 185);
}

void drawHills() {
  changeColor(#289c3a, 255);
  arc(0 + (width/3)/2, height - ground, 550, 650, PI, TWO_PI); // Draws the 2 side hills
  arc(width - (width/3)/2, height - ground, 550, 650, PI, TWO_PI);
  changeColor(#118a0f, 255);
  arc(width/2, height - ground, 550, 680, PI, TWO_PI); // Draws the middle hill
}

void drawSun() {
  for (int r = 300; r > 0; r -= 2) {
    float inter = map(r, 0, 300, 0, 1);
    color c = lerpColor(#fcf803, #ffb908, inter); 
    changeColor(c, 255);
    ellipse(0, 0, r, r);
  }
}

void drawSlime(int col) {
  changeColor(col, (int)(255*0.8));
  arc(x, y,slimeWidth, slimeHeight, PI, TWO_PI); // Draws the slime body
  changeColor(col, (int)(255*0.4));
  arc(x, y, slimeWidth * 0.85, slimeHeight * 0.8, PI, TWO_PI);
  changeColor(col, 255);
  arc(x, y, slimeWidth * 0.5, slimeHeight * 0.45, PI, TWO_PI);
  changeColor(#ffffff, 150);
  ellipse(x - 45, y-70, 10, 15); // Draws the body highlight
  changeColor(#000000, 255);
  ellipse(x + 40, y-55, 10, 20); // Draws the eyes
  ellipse(x - 10, y-55, 10, 20);
  changeColor(#ffffff, 200);
  ellipse(x + 42, y-58, 3, 6); // Draws the eye highlights
  ellipse(x - 8, y-58, 3, 6);
}

void drawEnemySlime(int col) {
  changeColor(col, (int)(255*0.8));
  arc(enemyX, height-ground, slimeWidth, slimeHeight, PI, TWO_PI); // Draws the slime body
  changeColor(col, (int)(255*0.4));
  arc(enemyX, height-ground, slimeWidth * 0.85, slimeHeight * 0.8, PI, TWO_PI);
  changeColor(col, 255);
  arc(enemyX, height-ground, slimeWidth * 0.5, slimeHeight * 0.45, PI, TWO_PI);
  changeColor(#ffffff, 150);
  ellipse(enemyX + 45, height - ground - 70, 10, 15); // Draws the body highlight
  changeColor(#000000, 255);
  ellipse(enemyX + 10, height-ground-55, 10, 20); // Draws the eyes
  ellipse(enemyX - 40, height-ground-55, 10, 20);
  changeColor(#ffffff, 200);
  ellipse(enemyX + 8, height-ground-58, 3, 6);  // Draws the eye highlights
  ellipse(enemyX - 42, height-ground-58, 3, 6);
}

void drawInventory() {
  for(int i = 0; i < numShapes; i++) {
    strokeWeight(3);
    stroke(#000000);
    if(healingPotionUsed && i == 0) {
      fill(#ff0000, 127); // Makes the healing potion slot red once used
    } else {
      fill(#9c9c9c, 127); 
    }
    rect(width/2 - i*inventoryWidth, height-100, inventoryWidth, inventoryWidth); // Draw the inventory square
    fill(#ffffff);
    if(i == 0) { // slot 3 - potion // Set the inventory numbers to correspond correctly with the correct slots (inventory is drawn from right to left, but the numbers are generated/read from left to right)
    // ALSO this helps me draw each specific item in its slot soo yes 
    text(i + 3, (width/2 - i*inventoryWidth) + 10, (height-100) + 25); // Write the inventory slot number
    changeColor(#ffffff, 185);
    ellipse((width/2 - i*inventoryWidth) + 40, (height - 50), 35, 35); // Draws the bottom of potion bottle
    rect((width/2 - i*inventoryWidth) + 35, (height - 77), 10, 10); // Draws the top of potion bottle
    changeColor(#d9493f, 185);
    ellipse((width/2 - i*inventoryWidth) + 40, (height - 50), 25, 25); // Draws the potion liquid
    changeColor(#9c7438, 255);
    rect((width/2 - i*inventoryWidth) + 35, (height - 85), 10, 5); // Draws the potion bottle cap
    } else if(i == 2) { // slot 1 - special attack
      text(i - 1, (width/2 - i*inventoryWidth) + 10, (height-100) + 25);
          changeColor(#ff005d, (int)(255 * 0.8));
          ellipse((width/2 - i*inventoryWidth) + 115, y + 95, 40, 40); // Draw the big slime ball in layers, just like the slimes
          changeColor(#ff005d, (int)(255 * 0.4));
          ellipse((width/2 - i*inventoryWidth) + 115, y + 95, 40 * 0.85, 40 * 0.85);
          changeColor(#ff005d, 255);
          ellipse((width/2 - i*inventoryWidth) + 115, y + 95, 40 * 0.5, 40 * 0.5);
          changeColor(#ffffff, 200);
          ellipse((width/2 - i*inventoryWidth) + 119, y + 90, 7, 7);
    } else { // slot 2 - shield
    text(i + 1, (width/2 - i*inventoryWidth) + 10, (height-100) + 25);
    stroke(#940031);
    fill(#ff0055);
    arc((width/2 - i*inventoryWidth) - 35, (height-110) + 30, 50, 45, 0, PI); // Draw different shapes and blend them together to make a shield
    rect((width/2 - i*inventoryWidth) - 55, height - 70, 40, 30);
    int middle = (((width/2 - i*inventoryWidth) - 50) + ((width/2 - i*inventoryWidth) - 15))/ 2;
    triangle((width/2 - i*inventoryWidth) - 52, height - 40, (width/2 - i*inventoryWidth) - 17, height - 40, middle, height - 30);
    stroke(#0091ff);
    rect((width/2 - i*inventoryWidth) - 45, height - 65, 21, 21);
    }
  }
  strokeWeight(1); // Reset stroke weight to 1
}

void drawHealthBars() {
  fill(#ff0048);
  textSize(25);
  text("Player Health", 130, 310);
  fill(#00b3ff);
  text("Enemy Health", 690, 310);
  fill(#676767);
  stroke(#000000);
  strokeWeight(3);
  rect(130, 325, 150, 30); // Player health bar background
  rect(690, 325, 150, 30); // Enemy health bar background
 
  fill(#fffb26);
  if(playerHealth > 0) {
     rect(130, 325, 150 * (playerHealth / 100.0), 30); // Player health
  } 
  if(enemyHealth > 0) {
     rect(690, 325, 150 * (enemyHealth / 100.0), 30); // Enemy health
  }
  strokeWeight(1);
}

void shoot() { // Player shoot
  for(int i = slimeBalls.size() - 1; i >= 0; i--) { // Goes through array list of slimeBalls, which are created each time the player presses e
    slimeBall s = slimeBalls.get(i); // Gets the current slime ball object
    s.shootEnemy();  // Shoots the slime ball at the enemy
    s.drawSlimeBall(#ff005d);   // Draws the slime ball on the screen  
  if (s.x > width || (s.x >= enemyX - s.size && s.x <= enemyX + s.size)) { // Detects when the slime ball collides with the enemy
      enemyDamage("shoot"); // Inputs an attack of type shoot to damage the enemy
      slimeBalls.remove(i);  // Remove the slime ball from the array list once it's collided with the enemy
    }
  }
 }

void enemyShoot() {
  if(!gameOverState) { // Make the slime stop shooting when the game is over
    for(int i = enemySlimeBalls.size() - 1; i >= 0; i--) {
        enemySlimeBall s = enemySlimeBalls.get(i);
        s.shootPlayer();       
        s.drawSlimeBall(#0373fc);    
        if (s.x - s.size <= x + (slimeWidth / 2)) {
            playerDamage("shoot");
            enemySlimeBalls.remove(i); 
        }
    }
  }
}

void shootSpecial() {
  slimeBall s = slimeBalls.get(slimeBalls.size()-1);
  s.shootEnemy();
  s.drawSpecialAttack(#ff005d);
    if (s.x > width || (s.x >= enemyX - s.size && s.x <= enemyX + s.size)) {
      enemyDamage("specialAttack"); // Different attack type than the regular slime balls, does more damage
      slimeBalls.remove(slimeBalls.size()-1); // No iteration in this function so we assume this is the newest addition to the slimeBall array list. 
      // This works because normal slime balls can't be shot when the special attack is active, so the array size stays the same
      isSpecialAttackActive = false; // Reset flag so that a new special attack can be dealt
    }
}

void enemyDamage(String type) {
  drawEnemySlime(#fc0303); // The enemy slime will flash red when it's hit to indicate that it took damage
  if(type == "shoot") {
    enemyHealth -= 5;
  } else if (type == "specialAttack") {
    enemyHealth -= 15;
  }
}

void playerDamage(String type) {
  drawSlime(#fc0303);
  if(type == "shoot" && !shieldActive) { // Only does damage to the player if they aren't using a shield
    playerHealth -= 5;
  } else if (type == "specialAttack" && !shieldActive) {
    playerHealth -= 15;
  }
}

void useShield(int x, int y, int shieldWidth, int shieldHeight, int col) {
    if (shieldActive) {
      changeColor(col, (int)(255 * 0.2));
      arc(x, y, shieldWidth + 50, shieldHeight + 50, PI, TWO_PI);
        if (millis() - shieldStartTime > shieldDuration) { // 5 second timer for the shield before it disappears
          shieldActive = false; 
        }
     }
}

void useHealingPotion() {
  playerHealth += 50;
  healingPotionUsed = true; // Can only be used once, flags it as true
}

void expandSlime() {
if (expanding) {
    slimeWidth += widthChange; // Increase width
    if (slimeWidth >= maxWidth) {
      expanding = false;       // Start contracting
    }
  } else {
    slimeWidth -= widthChange; // Decrease width
    if (slimeWidth <= minWidth) {
      expanding = true;        // Start expanding again
    }
  }
} 

void gameOver() {
  if (playerHealth <= 0) {
    fill(#000000);
    textSize(30);
    text("You lose! Restart to try again.", (width / 2) - 180, (height / 2) - 40);
    gameOverState = true; 
  } else if (enemyHealth <= 0) {
     fill(#000000);
    textSize(40);
    text("You win!", (width / 2) - 80, (height / 2) - 50);
    gameOverState = true; 
  }
  
  if (gameOverState) {
    gameOverTimer(); // Call the timer only if the game is over
  }
}

void gameOverTimer() {
  if (messageStartTime == 0) { // Set messageStartTime only once
    messageStartTime = millis(); // Start the timer
  }
  
  if (millis() - messageStartTime > messageDuration) {
    exit(); // Close the program after the message duration
  }
}

void moveSlime() {
  if (moveLeft) {
    x -= 10;
  } else if (moveRight) {
    x+= 10;
  }
  if (x > width) { // Resets x position of slime to the ends of the screen if it goes past so that it can never go past
    x = width;
  }
  if (x < 0) {
    x = 0;
  }
}

void changeColor(int col, int alpha) { // Easier way to change the color (saves lines) since I mostly went for a lineless style in this game
  stroke(col, alpha);
  fill(col, alpha);
}

class enemySlimeBall {
  int x;
  int y;
  int shootingSpeed;
  int size;

  enemySlimeBall(int startX, int startY, int speed, int slimeBallSize) {
    x = startX;
    y = startY;
    shootingSpeed = speed;
    size = slimeBallSize;
  }
  
  void shootPlayer() {
    x -= shootingSpeed; // Goes towards the player, which is to the left of the enemy
  }

  void drawSlimeBall(int col) { // Can change the slimes colors later if I want
    changeColor(col, (int)(255 * 0.8)); // Uses the same shading as the bigger slime does
    ellipse(x, y, size, size);
    changeColor(col, (int)(255 * 0.4));
    ellipse(x, y, size * 0.85, size * 0.8);
    changeColor(col, 255);
    ellipse(x, y, size * 0.5, size * 0.45);
    changeColor(#ffffff, 200);
    ellipse(x + 2, y - 2, 7, 7);
  }
} 

class slimeBall {
  int x;
  int y;
  int shootingSpeed;
  int size;

  slimeBall(int startX, int startY, int speed, int slimeBallSize) {
    x = startX;
    y = startY;
    shootingSpeed = speed;
    size = slimeBallSize;
  }

  void shootEnemy() {
    x += shootingSpeed;  // Goes towards the enemy, which is to the right of the player
  }
 
  void drawSlimeBall(int col) {
    changeColor(col, (int)(255 * 0.8));
    ellipse(x, y, size, size);
    changeColor(col, (int)(255 * 0.4));
    ellipse(x, y, size * 0.85, size * 0.8);
    changeColor(col, 255);
    ellipse(x, y, size * 0.5, size * 0.45);
    changeColor(#ffffff, 200);
    ellipse(x + 2, y - 2, 7, 7);
  }
  
  void drawSpecialAttack(int col) {
    changeColor(col, (int)(255 * 0.8));
    ellipse(x, y, size, size);
    changeColor(col, (int)(255 * 0.4));
    ellipse(x, y, size * 0.85, size * 0.85);
    changeColor(col, 255);
    ellipse(x, y, size * 0.5, size * 0.5);
    changeColor(#ffffff, 200);
    ellipse(x + 2, y - 2, 7, 7);
  }
} 
