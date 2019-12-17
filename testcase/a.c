#include "io.h"

int f(int x, int y) {
	//outl(x); print(" ");
	//outl(y); print("\n");
	if (y == 1) return x;
	if (y == 0) return 1;
	return f(x, y / 2) * f(x, (y + 1) / 2);
}

int main() {
	outl(f(2, 15));
}
/*#include "io.h"
int a[2][2];
int main() {
	int n = 2, m = 3;
	for (int i = 1; i <= n + 1; i++)
		for (int j = 1; j <= m + 1; j++) {
			a[i % 2][j % 2] ++;
		}
	long long ans = 0;
	for (int i = 0; i < 2; i++)
		for (int j = 0; j < 2; j++) {
			ans += (long long)a[i][j] * (a[i][j] - 1) / 2;
		}
	outl(ans);
}*/