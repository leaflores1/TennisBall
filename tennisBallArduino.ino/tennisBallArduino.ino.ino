const int botonDerechaPin = 2;
const int botonIzquierdaPin = 3;
const int replayPin = 6; // Botón para replay

const int ledRojoPin = 8;
const int ledVerdePin = 9;

void setup() {
  Serial.begin(9600);
  pinMode(botonDerechaPin, INPUT_PULLUP);
  pinMode(botonIzquierdaPin, INPUT_PULLUP);
  pinMode(replayPin, INPUT_PULLUP);

  pinMode(ledRojoPin, OUTPUT);
  pinMode(ledVerdePin, OUTPUT);
}

void loop() {
  // Botón mover barra
  if (digitalRead(botonDerechaPin) == LOW) {
    Serial.write('1');
    delay(50);
  } else if (digitalRead(botonIzquierdaPin) == LOW) {
    Serial.write('2');
    delay(50);
  }

  // Botón replay
  if (digitalRead(replayPin) == LOW) {
    Serial.write('6');  // señal de replay
    delay(50);
  }

  // Leer señales de Processing
  if (Serial.available() > 0) {
    char c = Serial.read();
    switch(c) {
      case '3': // Game Over
        digitalWrite(ledRojoPin, HIGH);
        digitalWrite(ledVerdePin, LOW);
        break;
      case '4': // Muerte
        digitalWrite(ledRojoPin, HIGH);
        delay(500);
        digitalWrite(ledRojoPin, LOW);
        break;
    }
  }
}
