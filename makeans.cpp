#include <bits/stdc++.h>
using namespace std;


char la[int(8e6)];

int main() {
	freopen("tmp.ans", "r", stdin);
	char *r = la + fread(la, 1, int(8e6), stdin);
	fclose(stdin);

	char *l = la;
	while (*l != '\n') l++;
	l++;
	while (*r != 'I') r--;
	freopen("tmp.ans", "w", stdout);
	while (l != r) putchar(*l++);
	fclose(stdout);

}
