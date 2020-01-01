#include "io.h"

int f(int x, int y);
int g(int x, int y);
int f(int x, int y) {
	if (y == 0) return 1;
	if (y == 1) return x;
	return g(x, y / 2) * g(x, (y + 1) / 2);
}

int g(int x, int y) {
	if (y == 0) return 1;
	if (y == 1) return x;
	return f(x, y / 2) * f(x, (y + 1) / 2);
}

int h(int x) {return x % 2 == 0 ? h(x - 1) + 1 : 0;}

int main() {

	for (int i = 1; i <= 6; i++) {
		if (i % 3 == 0) {
			outl(i); print(" ");
		}
		else {
			print("# ");
		}
	}
	outl(h(1)); outl(h(2));
	outl(23456); print(" ");
	outl(f(2, 15));
	print("\nclock = "); outl(clock());
}
