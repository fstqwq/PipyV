#include <bits/stdc++.h>
using namespace std;


int main() {
	ifstream a("tmp/a.log"), b("oktmp/a.log");
	string la, lb;
	int cnt = 0;
	while (true) {
		cnt++;
		string aa, bb;
		while (true) {
			if (getline(a, aa)) {
				if (aa != la) break;
			}
			else {
				aa = "EOF";
				break;
			}
		}
		while (true) {
			if (getline(b, bb)) {
				if (bb != lb) break;
			}
			else {
				bb = "EOF";
				break;
			}
		}
		if (aa != bb) {
			cout << cnt - 1 << " : " << endl << la << endl << lb << endl;
			cout << cnt     << " : " << endl << aa << endl << bb << endl;
			return 0;
		}
		la = aa;
		lb = bb;
		if (aa == "EOF") break;
	}
}
