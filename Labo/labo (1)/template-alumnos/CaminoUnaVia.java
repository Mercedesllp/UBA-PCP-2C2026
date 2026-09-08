// Zorros grises de Saldungaray, parte 1 (ghostbusters).
import java.util.concurrent.Semaphore;
import java.util.concurrent.ThreadLocalRandom;

public class CaminoUnaVia {
    static int NUM_CARS = 12;

    int autosEnCamino = 0;
    Semaphore mutex = Semaphore(0);
    Semaphore izq = Semaphore(0);
    Semaphore der = Semaphore(0);

    public void entrar(int direction) throws InterruptedException {

        if(direction == 0){
            izq.acquire();
            mutex.acquire();
            autosEnCamino ++;
            mutex.release();
            izq.release();
        } else{
            der.acquire();
            mutex.acquire();
            autosEnCamino ++;
            mutex.release();
            der.release();
        }

    }

    public void salir(int direction) throws InterruptedException {

    }

    // Simula el tiempo que tarda un auto en cruzar el desvio.
    private void cruzarPuente() throws InterruptedException {
        Thread.sleep(ThreadLocalRandom.current().nextInt(2));
    }

    public static void main(String[] args) throws InterruptedException {
        CaminoUnaVia route = new CaminoUnaVia();

        for (int i = 0; i < NUM_CARS; i++) {
            int car = i;
            int direction = ThreadLocalRandom.current().nextInt(2);
            System.out.println("Auto " + car + " cruzando en sentido " + direction);


        }
    }
}
