import processing.serial.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import processing.core.PImage;;  // Para manejar listas

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

// Arduino
Serial arduinoPort;
boolean arduinoConnected = false;

// Estadísticas
ArrayList<Estadisticas> estadisticasList = new ArrayList<Estadisticas>();
int tiempoInicial;

void setup() {
  size(800, 600);
  fondo = loadImage("imagen1.jpg");

  // Inicializar posiciones
  barraX = width/2 - barraAncho/2;
  bolaX = width/2;
  bolaY = 50;

  // Iniciar conteo de tiempo
  tiempoInicial = millis();

  // Conexión con Arduino
  String[] ports = Serial.list();
  if (ports.length > 0) {
    arduinoPort = new Serial(this, ports[0], 9600);
    arduinoConnected = true;
  } else {
    println("Arduino no conectado.");
  }

  // Cargar estadísticas previas
  cargarEstadisticas();
}

void draw() {
  background(fondo);

  // Barra
  fill(0, 100, 10);
  rect(barraX, height - barraAlto, barraAncho, barraAlto);

  // Pelota
  fill(255, 0, 0);
  ellipse(bolaX, bolaY, bolaDiametro, bolaDiametro);

  // Muertes
  textSize(30);
  fill(255);
  text("Muertes: " + muertes, 10, 30);

  // Leer señales de Arduino
  if (arduinoConnected && arduinoPort.available() > 0) {
    char input = arduinoPort.readChar();
    interpretarSenal(input);
  }

  // Lógica de juego
  if (!gameOver) {
    bolaX += bolaVelocidadX;
    bolaY += bolaVelocidadY;

    if (bolaX > width - bolaDiametro/2 || bolaX < bolaDiametro/2) {
      bolaVelocidadX *= -1;
    }
    if (bolaY < bolaDiametro/2) {
      bolaVelocidadY *= -1;
    }

    // Rebote con barra o caída
    if (bolaY >= height - barraAlto - bolaDiametro/2) {
      if (bolaX >= barraX && bolaX <= barraX + barraAncho) {
        bolaVelocidadY *= -1;
      } else {
        muertes++;
        // Enviamos señal de muerte
        if (arduinoPort != null) {
          arduinoPort.write('4');
        }
        // Guardar estadística
        guardarEstadisticas();

        reiniciarJuego();
      }
    }

    // Verificar game over
    if (muertes > 2) {
      gameOver = true;
      if (arduinoPort != null) {
        arduinoPort.write('3');
      }
    }
  } else {
    textSize(32);
    fill(255);
    text("Juego Terminado - Presiona 'R' para reiniciar", width/2 - 300, height/2);
  }
}

void interpretarSenal(char senal) {
  switch (senal) {
    case '1':
      barraX += velocidadBarra;
      break;
    case '2':
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

// ------------------------------------------------------
// Manejo de estadísticas

class Estadisticas {
  int muertes;
  int tiempoJuego; // en ms
  Estadisticas(int m, int t) {
    muertes = m;
    tiempoJuego = t;
  }
}

void cargarEstadisticas() {
  try {
    BufferedReader br = new BufferedReader(new FileReader("estadisticas.txt"));
    String line;
    while ((line = br.readLine()) != null) {
      // Ejemplo de línea: "Muertes: 5, Tiempo total: 12345 milisegundos"
      String[] partes = line.split(": ");
      if (partes.length == 2) {
        // partes[0] = "Muertes"
        // partes[1] = "5, Tiempo total: 12345 milisegundos"
        String[] sub = partes[1].split(", Tiempo total: ");
        int m = Integer.parseInt(sub[0]);
        int t = Integer.parseInt(sub[1].replace(" milisegundos", ""));
        estadisticasList.add(new Estadisticas(m, t));
      }
    }
    br.close();
  } catch (IOException e) {
    println("No se pudo leer estadisticas.txt");
  }
}

void guardarEstadisticas() {
  int tiempoJuego = millis() - tiempoInicial;
  try {
    PrintWriter writer = new PrintWriter(new FileWriter("estadisticas.txt", true));
    writer.println("Muertes: " + muertes + ", Tiempo total: " + tiempoJuego + " milisegundos");
    writer.close();
  } catch (IOException e) {
    println("No se pudo escribir en estadisticas.txt");
  }
}
