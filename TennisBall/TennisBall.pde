import processing.serial.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import processing.core.PImage;;  // Para manejar listas


PImage fondo;
int barraX, barraAncho=200, barraAlto=15, velocidadBarra=20;
int bolaX, bolaY, bolaVelocidadX=5, bolaVelocidadY=5, bolaDiametro=20;
boolean gameOver = false;
int muertes = 0;

// Arduino
Serial arduinoPort;
boolean arduinoConnected = false;

// Estadísticas
ArrayList<Estadisticas> estadisticasList = new ArrayList<Estadisticas>();
int tiempoInicial;

// Replay
boolean enReplay = false;
ArrayList<PVector> trayectoriaBola = new ArrayList<PVector>();
int indiceReplay = 0;

void setup() {
  size(800, 600);
  fondo = loadImage("imagen1.jpg");

  barraX = width/2 - barraAncho/2;
  bolaX = width/2;
  bolaY = 50;

  tiempoInicial = millis();

  // Conexión Arduino
  String[] ports = Serial.list();
  if (ports.length > 0) {
    arduinoPort = new Serial(this, ports[0], 9600);
    arduinoConnected = true;
  }

  // Cargar estadísticas
  cargarEstadisticas();
}

void draw() {
  background(fondo);

  // Dibuja barra
  fill(0, 100, 10);
  rect(barraX, height - barraAlto, barraAncho, barraAlto);

  // Dibuja pelota
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

  if (!enReplay && !gameOver) {
    // Juego normal
    logicaJuego();
    // Cada frame guardamos la posición actual de la pelota
    trayectoriaBola.add(new PVector(bolaX, bolaY));
  }
  else if (enReplay) {
    reproducirTrayectoria();
  }
  else {
    // Si gameOver
    textSize(32);
    fill(255);
    text("Juego Terminado - Presiona 'R' para reiniciar", width/2 - 300, height/2);
  }
}

void logicaJuego() {
  bolaX += bolaVelocidadX;
  bolaY += bolaVelocidadY;

  // Rebotes
  if (bolaX > width - bolaDiametro/2 || bolaX < bolaDiametro/2) {
    bolaVelocidadX *= -1;
  }
  if (bolaY < bolaDiametro/2) {
    bolaVelocidadY *= -1;
  }

  // Barra
  if (bolaY >= height - barraAlto - bolaDiametro/2) {
    if (bolaX >= barraX && bolaX <= barraX + barraAncho) {
      bolaVelocidadY *= -1;
    } else {
      muertes++;
      if (arduinoPort != null) {
        arduinoPort.write('4'); 
      }
      guardarEstadisticas();
      reiniciarJuego();
    }
  }

  // Game Over
  if (muertes > 2) {
    gameOver = true;
    if (arduinoPort != null) {
      arduinoPort.write('3');
    }
  }
}

// Modo Replay
void reproducirTrayectoria() {
  if (indiceReplay < trayectoriaBola.size()) {
    // Tomar la posición guardada
    PVector pos = trayectoriaBola.get(indiceReplay);
    bolaX = int(pos.x);
    bolaY = int(pos.y);
    indiceReplay++;
  } else {
    // Terminó el replay
    enReplay = false;
    // Reiniciamos el juego por defecto
    reiniciarJuego();
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
    case '6':  // nueva señal para iniciar replay
      iniciarReplay();
      break;
  }
}

void iniciarReplay() {
  // Solo si hay datos en la trayectoria
  if (trayectoriaBola.size() > 0) {
    enReplay = true;
    indiceReplay = 0;
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
  trayectoriaBola.clear();   // limpiamos la trayectoria anterior
}

// ------------------ Estadísticas ------------------
class Estadisticas {
  int muertes;
  int tiempoJuego;
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
      String[] partes = line.split(": ");
      if (partes.length == 2) {
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
