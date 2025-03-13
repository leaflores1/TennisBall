const int botonDerechaPin = 2;
const int botonIzquierdaPin = 3;

// Pines de LEDs
const int ledRojoPin = 8;
const int ledVerdePin = 9;

void setup() {
  Serial.begin(9600);
  pinMode(botonDerechaPin, INPUT_PULLUP);
  pinMode(botonIzquierdaPin, INPUT_PULLUP);

  pinMode(ledRojoPin, OUTPUT);
  pinMode(ledVerdePin, OUTPUT);
}

void loop() {
  // Leer botones para mover la barra
  if (digitalRead(botonDerechaPin) == LOW) {
    Serial.write('1');
    delay(200);
  } else if (digitalRead(botonIzquierdaPin) == LOW) {
    Serial.write('2');
    delay(200);
  }
  
  // Escuchar si Processing envía algo
  if (Serial.available() > 0) {
    char c = Serial.read();
    switch(c) {
      case '3': 
        // '3' => Game Over
        digitalWrite(ledRojoPin, HIGH);   // enciende LED rojo
        digitalWrite(ledVerdePin, LOW);   // apaga LED verde
        break;
      case '4':
        // '4' => Muerte
        digitalWrite(ledRojoPin, HIGH);
        delay(500);
        digitalWrite(ledRojoPin, LOW);
        break;
    }
  }
}
