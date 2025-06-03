/* Minimalni ZeroOS kernel */
void main() {
    char* video_memory = (char*)0xB8000;
    const char* message = "ZeroOS Kernel uspjesno pokrenut!";

    // Ispis poruke na ekran
    for(int i = 0; message[i] != '\0'; i++) {
        video_memory[i*2] = message[i];    // Znak
        video_memory[i*2+1] = 0x07;        // Atribut (svijetlo sivo na crnom)
    }

    // Beskonacna petlja
    while(1);
}
