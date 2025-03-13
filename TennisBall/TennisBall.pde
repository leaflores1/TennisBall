PImage fondo;

// Variables de la barra
int barraX;
int barraAncho = 200;
int barraAlto = 15;
int velocidadBarra = 20;

// Setup
void setup() {
  size(800, 600);
  fondo = loadImage("imagen1.jpg");
  // Barra al centro
  barraX = width/2 - barraAncho/2;
}

// Draw
void draw() {
  background(fondo);

  // Dibujar barra
  fill(0, 100, 10);
  rect(barraX, height - barraAlto, barraAncho, barraAlto);
}

// Mover barra con flechas
void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      barraX -= velocidadBarra;
    } else if (keyCode == RIGHT) {
      barraX += velocidadBarra;
    }
  }
}
