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

void setup() {
  size(800, 600);
  fondo = loadImage("imagen1.jpg");

  // Barra
  barraX = width/2 - barraAncho/2;

  // Pelota
  bolaX = width/2;
  bolaY = 50;
}

void draw() {
  background(fondo);

  // Barra
  fill(0, 100, 10);
  rect(barraX, height - barraAlto, barraAncho, barraAlto);

  // Pelota
  fill(255, 0, 0);
  ellipse(bolaX, bolaY, bolaDiametro, bolaDiametro);

  // Lógica de rebote
  bolaX += bolaVelocidadX;
  bolaY += bolaVelocidadY;

  // Rebote en ejes horizontales
  if (bolaX > width - bolaDiametro/2 || bolaX < bolaDiametro/2) {
    bolaVelocidadX *= -1;
  }
  // Rebote en el techo
  if (bolaY < bolaDiametro/2) {
    bolaVelocidadY *= -1;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      barraX -= velocidadBarra;
    } else if (keyCode == RIGHT) {
      barraX += velocidadBarra;
    }
  }
}
