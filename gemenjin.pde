float time = 0;
float timeSlice = 0.0005;

GStates states = new GStates();

/**
 * Objek basis
 */
class GObject {
  GObjects container;
  
  // (x0, y0) adalah koordinat mula-mula
  float x0, y0;
  
  // (x, y) adalah koordinat saat ini
  float x, y;
  
  // catchDistance adalah radius lingkaran dari (x, y)
  // di mana titik lain dianggap sebagai bagian dari
  // objek ini
  float catchDistance = 5;
  
  float t = 0;
  
  // birthTime digunakan untuk mencatat waktu kelahiran
  // objek
  float birthTime = 0;

  // Status objek, apakah masih hidup?
  // Jika diset false, maka pada frame berikutnya
  // objek ini akan dibunuh
  boolean life = true;
  
  // visible untuk menunjukkan bahwa objek ini harus digambar
  boolean visible = true;
  
  boolean interactive = true;
  
  // Status interaksi
  boolean tested = false;
  boolean hovered = false;
  boolean focus = false;
  boolean clicked = false;
  boolean pressed = false;
  boolean released = false;
  boolean dragged = false;
  
  /**
   * Konstruktor
   */
  GObject() {
    reset();
    
    clearStatus();
  }
  
  /**
   * Untuk mengupdate posisi objek
   * Method ini harus dioverride sesuai kebutuhan
   */
  void position() {  
  }
  
  /**
   * Untuk menggambar objek
   * Method ini harus dioverride sesuai kebutuhan
   */
  void draw() {
  }
  
  /**
   * Event handlers
   *
   * Method-method di bawah ini digunakan untuk menangani
   * kejadian-kejadian tertentu terhadap objek ini.
   * Semuanya masih kosong, dan harus diimplementasikan
   * oleh kelas turunannya.
   */
  void clicked() {}              // Objek diklik
  void pressed() {}              // Objek ditekan pakai mouse
  void released() {}             // Objek dilepas
  void dragged() {}              // Objek didrag
  void timer(float time) {}      // Pengalaman pada waktu tertentu
  void collide(GObject obj) {}   // Objek menabrak obj

  /**
   * Ini untuk menguji apakah sebuah titik termasuk
   * dalam objek ini atau tidak.
   * Silahkan dioverride sesuai kebutuhan.
   */
  boolean inBound(float mx, float my) {
    return dist(mx, my, x, y) < catchDistance;
  }
  
  /**
   * Ini untuk menguji tabrakan dengan sebuah objek lain
   * Boleh dioverride sesuai kebutuhan
   */
  boolean detectCollision(GObject obj) {
    return dist(x, y, obj.x, obj.y) <= (obj.catchDistance + catchDistance);
  }
  
  /*****************************************************/
  
  void reset() {
    birthTime = time;
  }
  
  /**
   * Untuk mereset status jika diperlukan
   */
  void clearStatus() {
    tested = false;
    clicked = false;
    pressed = false;
    released = false;
    hovered = false;
    focus = false;
    dragged = false;
  }
  
  /**
   * Untuk inisialisasi status
   */
  void initStatus() {
    tested = false;
  }

  /**
   * Untuk membunuh objek ini
   */
  void kill() {
    life = false;
  }
  
  /**
   * Untuk menerjemahkan kerangka waktu global
   * ke kerangka waktu objek
   * Sekaligus memanggil event handler timer()
   */  
  float time() {
    t = time - birthTime;
    
    timer(t);
    
    return t;
  }
  
  /**
   * Ini untuk mendeteksi tabrakan dengan semua objek lain
   */
  void detectCollision() {
    for (int i = 0; i < container.size(); i++) {
      GObject o = container.get(i);
      
      if (o != this && o.visible) {
        if (detectCollision(o)) {
          collide(o);
        }
      }
    }
  }
  
  void stateEntered() {
  }
  
  void stateLeft() {
  }
  
  /**
   * Tes interaksi
   */
  void testInteraction() {
    if (! tested) {
      tested = true;
      hovered = inBound(mouseX, mouseY);
      pressed = hovered && (mousePressed == true);
      focus = container.focus == this;
    }
  }
  
  /**
   *
   */
  void mouseClicked() {
    testInteraction();
    
    if (hovered) {
      clicked = true;
      clicked();
    }
  }
  
  /**
   *
   */
  void mousePressed() {
    testInteraction();
    
    if (hovered) {
      pressed = true;
      dragged = true;
      pressed();
      container.setFocus(this);
    }
    
    released = false;
  }
  
  /**
   *
   */
  void mouseReleased() {
    testInteraction();
    
    if (hovered) {
      released = true;
      released();
    }
    
    dragged = false;
    pressed = false;
  }
  
  /**
   *
   */
  void mouseDragged() {
    testInteraction();
    
    if (dragged) {
      dragged();
    }
  }
  
  /**
   *
   */
  void mouseMoved() {
    testInteraction();
  }
  
  /**
   *
   */
  void keyTyped() {
    testInteraction();
    
    if (focus) {
    }
  }
  
  /**
   *
   */
  void keyPressed() {
    testInteraction();
    
    if (focus) {
    }
  }
  
  /**
   *
   */
  void keyReleased() {
    testInteraction();
    
    if (focus) {
    }
  }

}

/**
 * GClear, objek penghapus layar
 */
class GClear extends GObject {
  color bgcolor;
  
  GClear() {
    bgcolor = color(#000000, 255);
  }
  
  GClear(color c) {
    bgcolor = c;
  }
 
  void draw() {
    fill(bgcolor);
    noStroke();
    rect(0, 0, width, height);
  }
}

/**
 * Kumpulan Objek
 *
 * Methods dari ArrayList:
 * - boolean remove(Object o)
 * - E remove(int index)
 * - void removeRange(int fromIndex, int toIndex)
 * - 
 */
class GObjects extends ArrayList<GObject> {
  GObject focus = null;
  
  /**
   *
   */
  GObjects() {
    clearFocus();
  }
  
  /**
   * Untuk menambah objek baru
   */
  boolean add(GObject o) {
    o.container = this;
    
    return super.add(o);
  }
  
  /**
   * Untuk menggambar kumpulan objek
   */
  void draw() {    
    for (int i = 0; i < size(); i++) {
      GObject o = (GObject) get(i);
 
      o.time();
      o.position();
  
      if (o.visible) {
        o.initStatus();
        o.detectCollision();
        o.testInteraction();
        
        o.draw();
      }
      
      if (! o.life) {
        remove(o);
        i --;
      }
    }
  }
  
  void reset() {
    for (int i = 0; i < size(); i++) {
      get(i).reset();
    }
  }
  
  /**
   * Untuk menset objek sebagai fokus
   */
  void setFocus(GObject o) {
    clearFocus();
    
    focus = o;
  }
  
  /**
   * Untuk menghilangkan fokus
   */
  void clearFocus() {
    focus = null;
  }
  
  /**
   *
   */
  void mouseClicked() {
    for (int i = 0; i < size(); i++) {
      GObject o = get(i);
      if (o.interactive) o.mouseClicked();
    }
  }

  /**
   *
   */
  void mousePressed() {
    for (int i = 0; i < size(); i++) {
      GObject o = get(i);
      if (o.interactive) o.mousePressed();
    }
  }

  /**
   *
   */
  void mouseReleased() {
    for (int i = 0; i < size(); i++) {
      GObject o = get(i);
      if (o.interactive) o.mouseReleased();
    }
  }
  
  /**
   *
   */
  void mouseMoved() {
    for (int i = 0; i < size(); i++) {
      GObject o = get(i);
      if (o.interactive) o.mouseMoved();
    }
  }

  /**
   *
   */
  void mouseDragged() {
    for (int i = 0; i < size(); i++) {
      GObject o = get(i);
      if (o.interactive) o.mouseDragged();
    }
  }

  /**
   *
   */
  void keyTyped() {
    for (int i = 0; i < size(); i++) {
      GObject o = get(i);
      if (o.interactive) o.keyTyped();
    }
  }

  /**
   *
   */
  void keyPressed() {
    for (int i = 0; i < size(); i++) {
      GObject o = get(i);
      if (o.interactive) o.keyPressed();
    }
  }

  /**
   *
   */
  void keyReleased() {
    for (int i = 0; i < size(); i++) {
      GObject o = get(i);
      if (o.interactive) o.keyReleased();
    }
  }
}

/**
 * GState sebenarnya adalah kumpulan objek juga
 */
class GState extends GObjects {
  /**
   * Event ketika masuk ke state ini
   */
  void stateEntered() {
    for (int i = 0; i < size(); i++) {
      get(i).stateEntered();
    }
  }
  
  /**
   *
   */
  void stateLeft() {
    for (int i = 0; i < size(); i++) {
      get(i).stateLeft();
    }
  }  
}

/**
 * GStates adalah kumpulan state
 */
class GStates extends ArrayList<GState> {
  // current adalah state yang sedang berjalan saat ini
  GState current = null;
  
  /**
   * Membuat state baru
   */
  GState newState() {
    GState state = new GState();
    
    if (add(state))
      return state;
    else
      return null;
  }
  
  /**
   * Membuat state baru
   */
  boolean add(GState state) {
    if (size() == 0) current = state;
    
    return super.add(state);
  }
  
  /**
   * Pindah ke state tertentu
   */
  void gotoState(GState state) {
    if (current != null)
      current.stateLeft();
    
    if (state != null) {
      current = state;
      current.stateEntered();
    }
  }
}

/**
 * Menggambar
 */
void draw() {
  time();

  if (states.current != null)
    states.current.draw();
}

/**
 * Untuk mendapatkan waktu relatif saat ini
 * Dalam satuan milisekon * timeSlice
 */
float time() {
  return time = millis() * timeSlice;
}

/**
 * Untuk pindah ke state lain
 */
void gotoState(GState state) {
  states.gotoState(state);
}

/**
 * Events
 */
void mousePressed() {
  if (states.current != null) states.current.mousePressed();
}

void mouseReleased() {
  if (states.current != null) states.current.mouseReleased();
}

void mouseMoved() {
  if (states.current != null) states.current.mouseMoved();
}

void mouseDragged() {
  if (states.current != null) states.current.mouseDragged();
}

void mouseClicked() {
  if (states.current != null) states.current.mouseClicked();
}

void keyPressed() {
  if (states.current != null) states.current.keyPressed();
}

void keyReleased() {
  if (states.current != null) states.current.keyReleased();
}

void keyTyped() {
  if (states.current != null) states.current.keyTyped();
}