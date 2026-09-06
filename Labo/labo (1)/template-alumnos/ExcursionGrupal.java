// Volcan Lanin, parte 2.

public class MainExcursionGrupal {
    static int PORTENIOS = 6;
    static int STAGES = 4;

    // TODO: variables/objetos de sincronizacion.

    public void esperarPirca() throws InterruptedException {
        // TODO
    }

    public static void main(String[] args) throws InterruptedException {
        MainExcursionGrupal excursion = new MainExcursionGrupal();

        Thread[] group = new Thread[PORTENIOS];
        for (int i = 0; i < PORTENIOS; i++) {
            int id = i;
            group[i] = new Thread(() -> {
                try {
                    for (int stage = 1; stage <= STAGES; stage++) {
                        Thread.sleep((long) (Math.random() * 300));
                        System.out.println("porteno " + id + " llega a la pirca del tramo " + stage);
                        excursion.esperarPirca();
                        System.out.println("porteno " + id + " arranca el tramo " + (stage + 1));
                    }
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            });
        }

        for (Thread t : group) t.start();
        for (Thread t : group) t.join();
    }
}
