int tableHeight = 10; // Hauteur du table //<>// //<>// //<>// //<>// //<>// //<>//
int tableWidth = 10; // Largeur du table
int numberOfMines = 10; // Nombre de Mines
int cellSize = 40; // Taille d'affichage d'une cellule

PImage img_mine;


final color COLOR_BACKGROUND = color (255);            // couleur du fond
final color COLOR_TEXT = color (0);            // couleur du texte

final color COLOR_CLOSE = color (0, 0, 255);     // couleur pour une case fermée
final color COLOR_TAG = color (0, 255, 0);    // couleur pour une case marquée

final color COLOR_MINE = color (255, 0, 0);       // couleur pour une case mine ouverte
final color COLOR_EMPTY = color (190, 190, 190);            // couleur pour une case vide


//                            [étage 2] nombre de mines dans les cellules voisines = 0 à 8
// table [Coord x][Coord y] [étage 1] statut = CLOSE, TAG ou OPEN
//                            [étage 0] contenu = MINE ou EMPTY
int table[][][] = new int[tableWidth][tableHeight][3];



int numberOfCells = tableHeight*tableWidth;
int timeStart = 0;
int timeLastClic = 0;
int numberOfCloseCells = numberOfCells;

final int TYPE = 0;
final int STATUS = 1;
final int AROUND = 2;

final int MINE = 1;
final int EMPTY = 0;

final int CLOSE = 2;
final int TAG = 1;
final int OPEN = 0;


final int INIT = 0;
final int WAITING = 1;
final int RUNNING = 2;
final int SUCCESS = 3;
final int DEFEAT = 4;
final int AFK = 42;


int gameStep = INIT;
final int AFK_PERIOD = 20;



void setup() {
  size(10, 10);
  img_mine = loadImage("mine(2).png");
}

void draw () {
  switch (gameStep) {

  case INIT :
    initGame();
    displayBoard();
    gameStep = RUNNING;
    break;

  case WAITING:
    displayWaitingScreen();
    break ;

  case RUNNING :
    displayBoard();
    displayTimer();
    break ;

  case SUCCESS :
  case DEFEAT :
  case AFK :
    displayBoard();
    endGame();
    gameStep = WAITING;
    break ;
  }
}



void initGame () {
  background(COLOR_BACKGROUND);
  windowResize(tableWidth*cellSize, (tableHeight+4)*cellSize);
  fill(COLOR_BACKGROUND);
  rect(0, 0, tableWidth*cellSize, (tableHeight+4)*cellSize);
  textSize(cellSize);
  initBoard();
  timeStart=millis();
  timeLastClic=timeStart;
}


// fonction qui remplit le table avec le nombre de mines demandées.

void initBoard() {
  println("initBoard");
  if (numberOfMines>numberOfCells) {      // Vérifie que le nombre de Mines n'est pas trop grand
    numberOfMines=numberOfCells;
  }
  for (int i=0; i<tableWidth; i++) {
    for (int j=0; j<tableHeight; j++) {
      table[i][j][TYPE] = EMPTY;
      table[i][j][STATUS] = CLOSE;
    }
  }

  int counter = 0;
  numberOfCloseCells = numberOfCells;
  while (numberOfMines > counter) {       // Place les mines aléatoirement.
    int x = int(random(tableWidth));
    int y = int(random(tableHeight));
    if (table[x][y][TYPE]!=MINE) {         // Vérifie qu'il n'y a pas déjà une mine à cet emplacement
      table[x][y][TYPE]= MINE;
      counter++;
    }
  }

  for (int i=0; i<tableWidth; i++) {
    for (int j=0; j<tableHeight; j++) {
      table[i][j][AROUND] = countMinesAround(i, j);   // [étage 2] : Enregistre le nombre de mines voisines
    }
  }
}


// compte le nombre de Mines voisines
int countMinesAround (int x, int y) {
  println("countMinesAround", x, y);
  int compteur=0;
  for (int i=x-1; i<x+2; i++) {
    for (int j=y-1; j<y+2; j++) {
      if (i>=0 && j>=0 && i<tableWidth && j<tableHeight) {
        if (table[i][j][TYPE] == MINE) {
          compteur++;
        }
      }
    }
  }
  return compteur;
}



void displayBoard () {
  for (int i=0; i<tableWidth; i++) {
    for (int j=0; j<tableHeight; j++) {
      switch(gameStep) {
      case INIT :
        displayCell_RUNNING(i, j);
      case RUNNING :
        displayCell_RUNNING(i, j);
        break ;
      case SUCCESS :
        displayCell_SUCCESS(i, j);
        break ;
      case DEFEAT :
        displayCell_DEFEAT(i, j);
        break ;
      case AFK :
        displayCell_AFK(i, j);
        break ;
      }
      displayCellText(i, j);
    }
  }
}

void displayCell_RUNNING (int x, int y) {
  color cellColor = color (0);
  switch (table[x][y][STATUS]) {

  case OPEN :
    if (table[x][y][TYPE]==MINE) {
      cellColor = COLOR_MINE;
    } else {
      cellColor = COLOR_EMPTY;
    }
    break;

  case CLOSE :
    cellColor = COLOR_CLOSE;
    break;

  case TAG :
    cellColor = COLOR_TAG;
    break;
  }
  fill(cellColor);
  rect(x*cellSize+1, y*cellSize+1, cellSize-2, cellSize-2, 5);
  if (table[x][y][TYPE]==MINE && table[x][y][STATUS]==OPEN) {
    image(img_mine, x*cellSize+1, y*cellSize+1, cellSize-2, cellSize-2);
  }
}

void displayCell_SUCCESS (int x, int y) {
  color cellColor = color (0);
  switch (table[x][y][TYPE]) {

  case MINE :
    cellColor = COLOR_TAG;
    break;

  case EMPTY :
    cellColor = COLOR_EMPTY;
    break;
  }
  fill(cellColor);
  rect(x*cellSize+1, y*cellSize+1, cellSize-2, cellSize-2, 5);
}


void displayCell_DEFEAT (int x, int y) {
  color cellColor = color (0);
  if (table[x][y][TYPE] == MINE) {
    cellColor = COLOR_MINE;
  } else {
    switch (table[x][y][STATUS]) {
    case CLOSE :
      cellColor = COLOR_CLOSE;
      break;

    case TAG :
      cellColor = COLOR_TAG;
      break;
    case OPEN :
      cellColor = COLOR_EMPTY;
      break;
    }
  }
  fill(cellColor);
  rect(x*cellSize+1, y*cellSize+1, cellSize-2, cellSize-2, 5);
  if (table[x][y][TYPE]==MINE) {
    image(img_mine, x*cellSize+1, y*cellSize+1, cellSize-2, cellSize-2);
  }
}

void displayCell_AFK (int x, int y) {
  println("displayCell_AFK", x, y);
  color cellColor = color(int(random(255)), int(random(255)), int(random(255)));
  fill(cellColor);
  rect(x*cellSize+1, y*cellSize+1, cellSize-2, cellSize-2, 5);
}

void displayCellText (int x, int y) {
  println("displayCellText", x, y);
  fill(COLOR_TEXT);
  if (table[x][y][STATUS]==OPEN && table[x][y][TYPE]==EMPTY && table[x][y][AROUND]!=0) {
    text(table[x][y][AROUND], (x+0.2)*cellSize+1, (y+0.8)*cellSize+1);
  }
}



void openCell (int x, int y) {
  println("openCell", x, y);
  table[x][y][STATUS]=OPEN;
  numberOfCloseCells--;
  if (numberOfCloseCells==numberOfMines) {
    gameStep = SUCCESS;
  }
  if (table[x][y][TYPE]==MINE) {
    gameStep = DEFEAT;
  }
  if (table[x][y][AROUND]==0) {                                                              // ouvre les cellules voisines si pas de mines autour
    for (int i=x-1; i<=x+1; i++) {
      for (int j=y-1; j<=y+1; j++) {
        if (i>=0 && j>=0 && i<tableWidth && j<tableHeight && (table[i][j][STATUS]!=OPEN)) {                               // vérifie que nous sommes à l'intérieur du table ET que la voisine n'est pas déjà ouverte
          openCell(i, j);
        }
      }
    }
  }
}

void tagCell (int x, int y) {
  println("tagCell", x, y);
  if (table [x][y][STATUS]==TAG) {
    table[x][y][STATUS]=CLOSE;
  } else {
    table[x][y][STATUS]=TAG;
  }
}



void endGame () {
  fill(COLOR_MINE);
  String title="";
  switch(gameStep) {
  case SUCCESS :
    title = "Félicitations !";
    break;
  case DEFEAT :
    title = "Game Over...";
    break;
  case AFK :
    title = "Trop tard !";
    break;
  }
  text(title, 0.5*cellSize, (tableHeight+2)*cellSize);
}



void displayTimer () {
  fill(COLOR_BACKGROUND);
  noStroke();
  rect(4*cellSize, tableHeight*cellSize, width-4*cellSize, 1.1*cellSize);
  fill(COLOR_TEXT);
  text("Timer :", 0.5*cellSize, (tableHeight+1)*cellSize);
  text((millis()-timeStart)/1000, 4*cellSize, (tableHeight+1)*cellSize);

  if ((millis()-timeLastClic)/1000>AFK_PERIOD) {
    gameStep = AFK;
  }
}

void displayWaitingScreen() {
  int waitingStep=((millis()-timeStart)/500)%4;
  String msg="";
  
  switch(waitingStep) {
  case 0 :
    msg = "Press any key";
    break;
  case 1 :
    msg = "Press any key.";
    break;
  case 2 :
    msg = "Press any key..";
    break;
  case 3 :
    msg = "Press any key...";
    break;
  }


  fill (COLOR_BACKGROUND);
  rect(0.5*cellSize, (tableHeight+2.5)*cellSize, width-cellSize, 1.1*cellSize);
  fill (COLOR_TEXT);
  text(msg, 0.5*cellSize, (tableHeight+3.5)*cellSize);
}



void mouseClicked() {
  if (gameStep == RUNNING) {
    timeLastClic = millis();
    int x = (mouseX/cellSize);              // Les coordonnées de la souris sont rapportées aux coordonnées du table
    int y = (mouseY/cellSize);
    if (x<tableWidth && y<tableHeight) {         // On vérifie que la souris n'est pas en dehors du table
      switch(mouseButton) {
      case LEFT:
        if (table[x][y][STATUS]==CLOSE) {
          openCell(x, y);
        }
        break;
      case RIGHT:
        tagCell(x, y);
        break;
      }
    }
  }
}

void keyPressed() {
  if (gameStep==WAITING) {
    timeStart=millis();
    gameStep = INIT;
  }
}
