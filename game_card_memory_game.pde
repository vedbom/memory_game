// start date: 21/10/2021
// finish data: 15/01/2022

import java.util.*;

CardManager game;
PImage cardFaces[];
PImage cardBack;
void setup(){
  size(1000, 600, P3D);
  game = new CardManager();
  game.setupGame();
  
  //cardTexture = loadImage("Playing Cards/PNG-cards-1.3/red_joker.png");
  String fileNames[] = {"ace_of_clubs", "2_of_clubs", "3_of_clubs", "4_of_clubs", "5_of_clubs", "6_of_clubs", "7_of_clubs", "8_of_clubs", "9_of_clubs", "10_of_clubs", "jack_of_clubs", "queen_of_clubs2", "king_of_clubs2",
                        "ace_of_spades", "2_of_spades", "3_of_spades", "4_of_spades", "5_of_spades", "6_of_spades", "7_of_spades", "8_of_spades", "9_of_spades", "10_of_spades", "jack_of_spades", "queen_of_spades2", "king_of_spades2",
                        "ace_of_diamonds", "2_of_diamonds", "3_of_diamonds", "4_of_diamonds", "5_of_diamonds", "6_of_diamonds", "7_of_diamonds", "8_of_diamonds", "9_of_diamonds", "10_of_diamonds", "jack_of_diamonds", "queen_of_diamonds2", "king_of_diamonds2",
                        "ace_of_hearts", "2_of_hearts", "3_of_hearts", "4_of_hearts", "5_of_hearts", "6_of_hearts", "7_of_hearts", "8_of_hearts", "9_of_hearts", "10_of_hearts", "jack_of_hearts", "queen_of_hearts2", "king_of_hearts2"};
  // convert the array to a List so that the shuffle() function can be used
  List<String> list = Arrays.asList(fileNames);
  Collections.shuffle(list);
  // convert the list back to an array so it can be used
  list.toArray(fileNames);
  
  cardFaces = new PImage[fileNames.length];
  cardBack = loadImage("card_back.png");
  for(int i = 0; i < fileNames.length; i++){
    cardFaces[i] = loadImage("Playing Cards/PNG-cards-1.3/" + fileNames[i] + ".png");
  }
}

void draw(){
  background(17, 118, 22);
  game.display();
  game.update();
}

class Card{
  PVector pos;
  int id;
  float w, h;
  float angleY;
  float animLimit;
  boolean faceDown;
  boolean playTurnoverAnim;
  boolean playRemoveAnim;
  color cardColor;
  Card(float x, float y, float z, float w_, float h_){
    pos = new PVector(x, y, z);
    w = w_;
    h = h_;
    angleY = 0;
    animLimit = 0;
    faceDown = true;
    playTurnoverAnim = false;
    playRemoveAnim = false;
  }
  void update(){
    if(playTurnoverAnim){
      turnoverCard();
    }
    if(playRemoveAnim){
      removeCard();
    }
  }
  void display(){
    // display the cards with colors only
    pushMatrix();
    translate(pos.x + w/2, pos.y, pos.z - 0.5);
    rotateY(angleY);
    pushMatrix();
    translate(0, 0, 0.5);
    stroke(0);
    fill(0, 255, 0);
    rect(-w/2, 0, w, h);
    popMatrix();
    pushMatrix();
    translate(0, 0, -0.5);
    stroke(0);
    fill(cardColor);
    rect(-w/2, 0, w, h);
    popMatrix();
    popMatrix();
  }
  void displayWithCardTextures(){
    // display the cards with textures
    pushMatrix();
    translate(pos.x + w/2, pos.y, pos.z - 0.5);
    rotateY(angleY);
    pushMatrix();
    translate(0, 0, 0.5);
    stroke(0);
    stroke(0);
    textureMode(NORMAL);
    beginShape();
    texture(cardBack);
    vertex(-w/2, 0, 0, 0, 0);
    vertex(w/2, 0, 0, 1, 0);
    vertex(w/2, h, 0, 1, 1);
    vertex(-w/2, h, 0, 0, 1);
    endShape();
    popMatrix();
    pushMatrix();
    translate(0, 0, -0.5);
    stroke(0);
    textureMode(NORMAL);
    beginShape();
    texture(cardFaces[id]);
    // the texture coordinates have to be mirrored because the card turnsover
    vertex(-w/2, 0, 0, 1, 0);
    vertex(w/2, 0, 0, 0, 0);
    vertex(w/2, h, 0, 0, 1);
    vertex(-w/2, h, 0, 1, 1);
    endShape();
    popMatrix();
    popMatrix();
  }
  void playTurnoverAnim(){
    playTurnoverAnim = true;
    animLimit = angleY + PI;
  }
  void playRemoveAnim(){
    playRemoveAnim = true;
    // increase the z-component of the card being removed so that it does not go through the other cards
    pos.z += 1;
  }
  void setId(int id_){
    id = id_;
  }
  void setCardcolor(color cardColor_){
    cardColor = cardColor_;
  }
  boolean isClicked(){
    if(mouseX >= pos.x && mouseX < pos.x + w && mouseY >= pos.y && mouseY < pos.y + h){
      return true;
    }
    else{
      return false;
    }
  }
  void turnoverCard(){
    if(angleY < animLimit){
      angleY += 0.1;
    }
    else{
      angleY = animLimit;
      playTurnoverAnim = false;
      faceDown = !faceDown;
    }
  }
  void removeCard(){
    if(pos.y > -height){
      pos.y -= 10;
    }
    else{
      playRemoveAnim = false;
    }
  }
}

class CardManager{
  ArrayList<Card> cards;
  int numPairs;
  int firstChoice;
  int secondChoice;
  int state;
  CardManager(){
    cards = new ArrayList();
    numPairs = 4;
    firstChoice = -1;
    secondChoice = -1;
    state = 0;
  }
  void setupGame(){
    // find the two multiples of numCards that are closest to eachother
    int numCards = 2*numPairs;
    int smallest = numCards;
    int numRows = 0;
    int numCols = 0;
    for(int i = 1; i <= numCards; i++){
      // first check if i can divide numCards without a remainder
      if(numCards%i != 0){
        continue;
      }
      if(abs(numCards/i - i) < smallest){
        numRows = i;
        numCols = numCards/i;
        smallest = abs(numCards/i - i);
      }
    }
    // place the cards on the board
    float gapRows = 0.1*(height/numRows);
    float gapCols = 0.1*(width/numCols);
    float cardWidth = 0.8*(width/numCols);
    float cardHeight = 0.8*(height/numRows);
    for(int i = 0; i < numRows; i++){
      for(int j = 0; j < numCols; j++){
        cards.add(new Card((j + 1)*gapCols + j*cardWidth + j*gapCols, (i + 1)*gapRows + i*cardHeight + i*gapRows, 0, cardWidth, cardHeight));
      }
    }
    // shuffle the cards and assign the same ID to each pair of cards
    Collections.shuffle(cards);
    int id = 1;
    for(int i = 0; i < cards.size() - 1; i += 2){
      color rand = color(random(255), random(255), random(255));
      cards.get(i).setId(id);
      cards.get(i).setCardcolor(rand);
      cards.get(i + 1).setId(id);
      cards.get(i + 1).setCardcolor(rand);
      id++;
    }
  }
  void display(){
    // display all the cards on the board
    for(Card c: cards){
      //c.display();
      c.displayWithCardTextures();
      c.update();
    }
  }
  void update(){
    println("state: " + state);
    // update the state of the game
    if(state == 0){
      // wait for the player to click on any of the cards
      if(mousePressed){
        for(Card c: cards){
          if(c.isClicked()){
            c.playTurnoverAnim();
            if(firstChoice == -1){
              // get the index of the first card in the arraylist
              firstChoice = cards.indexOf(c);
              state = 1;
            }
            else{
              // get the index of the second card in the arraylist
              secondChoice = cards.indexOf(c);
              state = 2;
            }
          }
        }
      }
    }
    else if(state == 1){
      // wait for any animation to complete after the user selects the first card
      if(!cards.get(firstChoice).playTurnoverAnim){
        state = 0;
      }
    }
    else if(state == 2){
      // wait for any animation to complete after the user selects the second card
      if(!cards.get(secondChoice).playTurnoverAnim){
        state = 3;
      }
    }
    else if(state == 3){
      // look at the players choices and perform the appropriate actions
      if(cards.get(firstChoice).id != cards.get(secondChoice).id){
        // if the first and second choices are not equal then turnover all faceup cards
        state = 4;
        cards.get(firstChoice).playTurnoverAnim();
        cards.get(secondChoice).playTurnoverAnim();
      }
      else{
        // otherwise remove both cards from play
        state = 5;
        cards.get(firstChoice).playRemoveAnim();
        cards.get(secondChoice).playRemoveAnim();
      }
    }
    else if(state == 4){
      // wait for both cards to turnover
      if(!cards.get(firstChoice).playTurnoverAnim && !cards.get(secondChoice).playTurnoverAnim){
        state = 6;
      }
    }
    else if(state == 5){
      // wait for both cards to be removed from play
      if(!cards.get(firstChoice).playRemoveAnim && !cards.get(secondChoice).playRemoveAnim){
        state = 6;
        // remove both cards from the ArrayList
        // remove the card with the largest index first since the remaining elements are shifted over when one is removed
        if(firstChoice > secondChoice){
          cards.remove(firstChoice);
          cards.remove(secondChoice);
        }
        else{
          cards.remove(secondChoice);
          cards.remove(firstChoice);
        }
      }
      // if the number of cards in the ArrayList is zero then start the next level
      println(cards.size());
      if(cards.size() == 0){
        state = 7;
      }
    }
    else if(state == 6){
      // reset the first and second choice variables
      firstChoice = -1;
      secondChoice = -1;
      state = 0;
    }
    else if(state == 7){
      background(0);
      fill(255);
      textSize(38);
      text("You won", width/2 - 100, height/2);
      text("Tap the screen to continue", width/2 - 100, height/2 + 50);
      
      // check if the player has clicked on the screen
      if(mousePressed){
        // increase the number of card pairs and setup a new game
        numPairs += 1;
        setupGame();
        // reset the first and second choice variables
        firstChoice = -1;
        secondChoice = -1;
        state = 0;
      }
    }
    else{
      // default state
    }
  }
}
