const int botonDerechaPin = 2;
const int botonIzquierdaPin = 3;

void setup() {
  Serial.begin(9600);
  pinMode(botonDerechaPin, INPUT_PULLUP);
  pinMode(botonIzquierdaPin, INPUT_PULLUP);
}

void loop() {
  if (digitalRead(botonDerechaPin) == LOW) {
    Serial.write('1'); // mover barra a la derecha
    delay(200); // pequeña pausa para evitar rebotes
  } 
  else if (digitalRead(botonIzquierdaPin) == LOW) {
    Serial.write('2'); // mover barra a la izquierda
    delay(200);
  }
}
