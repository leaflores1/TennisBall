PImage fondo;

// Barra
int barraX;
int barraAncho = 200;
int barraAlto = 15;
int velocidadBarra = 20;

// Pelota
int bolaX;
int bolaY;
int bolaVelocidadX = 5;
int bolaVelocidadY = 5;
int bolaDiametro = 20;

// Variables de estado
boolean gameOver = false;
int muertes = 0;

void setup() {
  size(800, 600);
  fondo = loadImage("imagen1.jpg");
  barraX = width/2 - barraAncho/2;
  bolaX = width/2;
  bolaY = 50;
}

void draw() {
  background(fondo);

  fill(0, 100, 10);
  rect(barraX, height - barraAlto, barraAncho, barraAlto);

  fill(255, 0, 0);
  ellipse(bolaX, bolaY, bolaDiametro, bolaDiametro);

  // Mostrar muertes
  textSize(30);
  fill(255);
  text("Muertes: " + muertes, 10, 30);

  // Lógica de rebote
  if (!gameOver) {
    bolaX += bolaVelocidadX;
    bolaY += bolaVelocidadY;

    // Rebote horizontal
    if (bolaX > width - bolaDiametro/2 || bolaX < bolaDiametro/2) {
      bolaVelocidadX *= -1;
    }
    // Rebote techo
    if (bolaY < bolaDiametro/2) {
      bolaVelocidadY *= -1;
    }

    // Rebote con la barra
    if (bolaY >= height - barraAlto - bolaDiametro/2) {
      // Verifica si está encima de la barra
      if (bolaX >= barraX && bolaX <= barraX + barraAncho) {
        bolaVelocidadY *= -1; // rebote
      } else {
        // Se cayó
        muertes++;
        reiniciarJuego();
      }
    }

    // Verificar un "game over" simple (ejemplo: más de 2 muertes)
    if (muertes > 2) {
      gameOver = true;
    }
  } else {
    textSize(32);
    fill(255);
    text("Juego Terminado - Presiona 'R' para reiniciar", width/2 - 300, height/2);
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
