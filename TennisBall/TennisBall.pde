import processing.serial.*; // 1) Importar librería de Serial

// Declaración de variables
PImage fondo;

int barraX;
int barraAncho = 200;
int barraAlto = 15;
int velocidadBarra = 20;

int bolaX;
int bolaY;
int bolaVelocidadX = 5;
int bolaVelocidadY = 5;
int bolaDiametro = 20;

boolean gameOver = false;
int muertes = 0;

// 2) Variables para Arduino
Serial arduinoPort;          // objeto para el puerto serie
boolean arduinoConnected = false;

void setup() {
  size(800, 600);
  fondo = loadImage("imagen1.jpg");
  
  // Posición inicial de la barra
  barraX = width/2 - barraAncho/2;
  
  // Posición inicial de la pelota
  bolaX = width/2;
  bolaY = 50;
  
  // 3) Inicializar la comunicación serie con Arduino
  String[] ports = Serial.list();
  if (ports.length > 0) {
    // Usamos el primer puerto encontrado (puede ajustarse si fuera necesario)
    arduinoPort = new Serial(this, ports[0], 9600);
    arduinoConnected = true;
  } else {
    println("Arduino no conectado. Verifica el puerto.");
  }
}

void draw() {
  background(fondo);

  // Dibujar barra
  fill(0, 100, 10);
  rect(barraX, height - barraAlto, barraAncho, barraAlto);

  // Dibujar pelota
  fill(255, 0, 0);
  ellipse(bolaX, bolaY, bolaDiametro, bolaDiametro);

  // Mostrar muertes
  textSize(30);
  fill(255);
  text("Muertes: " + muertes, 10, 30);

  // 4) Leer datos del Arduino (si hay algo disponible en el buffer serie)
  if (arduinoConnected && arduinoPort.available() > 0) {
    char input = arduinoPort.readChar();  // Leemos un caracter
    interpretarSenal(input);
  }

  // Lógica de juego
  if (!gameOver) {
    bolaX += bolaVelocidadX;
    bolaY += bolaVelocidadY;

    // Rebote horizontal
    if (bolaX > width - bolaDiametro/2 || bolaX < bolaDiametro/2) {
      bolaVelocidadX *= -1;
    }
    // Rebote en el techo
    if (bolaY < bolaDiametro/2) {
      bolaVelocidadY *= -1;
    }

    // Rebote con la barra
    if (bolaY >= height - barraAlto - bolaDiametro/2) {
      if (bolaX >= barraX && bolaX <= barraX + barraAncho) {
        bolaVelocidadY *= -1; // rebote
      } else {
        muertes++;
         // Enviamos señal al Arduino indicando que hay una "muerte"
          if (arduinoConnected) {
            arduinoPort.write('4');
          }
        reiniciarJuego();
      }
    }


    // Game over si muertes > 2
    if (muertes > 2) {
      gameOver = true;
       // Enviar señal de game over
        if (arduinoConnected) {
          arduinoPort.write('3');
        }
    }
  } else {
    textSize(32);
    fill(255);
    text("Juego Terminado - Presiona 'R' para reiniciar", width/2 - 300, height/2);
  }
}

// 5) Interpretar la señal del Arduino y mover la barra
void interpretarSenal(char senal) {
  switch (senal) {
    case '1':
      // Mover barra a la derecha
      barraX += velocidadBarra;
      break;
    case '2':
      // Mover barra a la izquierda
      barraX -= velocidadBarra;
      break;
  }
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    reiniciarJuego();
    muertes = 0;
    gameOver = false;
  } else if (key == CODED) {
    if (keyCode == LEFT) {
      barraX -= velocidadBarra;
    } else if (keyCode == RIGHT) {
      barraX += velocidadBarra;
    }
  }
}

void reiniciarJuego() {
  bolaX = width/2;
  bolaY = 50;
  bolaVelocidadX = 5;
  bolaVelocidadY = 5;
}
