#include <iostream>
#include <algorithm>
#include <bitset>
#include <map>
#include <numeric>
#include <queue>
#include <set>
#include <string>
#include <stack>
#include <unordered_map>
#include <unordered_set>
#include <vector>
#include <utility>
#include <tuple>
#include <cmath>
#include <chrono>
#include <fstream>
// #define MOD (998244353l)
#define MOD (1000000007l)
#define ll long long
#define rep(i, n) for (ll i = 0; i < (n); i++)
#define PI (3.1415926535897932)
#define all(x) x.begin(), x.end()
#define Yes  cout << "Yes" << endl;  
#define No  cout << "No" << endl
#define YES cout << "YES" << endl
#define NO cout << "NO" << endl 
using namespace std;
const double pi = 3.141592653589793238;
const ll inf = 1073741823;
const ll infl = 1LL << 60;
const string ABC = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const string abc = "abcdefghijklmnopqrstuvwxyz";
string inputfilename = "input.txt";
string outputfilename = "output.txt";
ifstream in(inputfilename);
ofstream out(outputfilename);

void solve(){
    queue<string> ans;
    string s;
    while(in >> s){
        ans.push(s);
    }
    //出力
    while(!ans.empty()){
        string s = ans.front();
        if(s.substr(0,3) == "【"){
            out << ";" << ans.front() << endl <<endl; //【の前に;を入れコメントアウト
            ans.pop();
        }
        else if(s.substr(0,9) =="知行「"){
            out << "#" << s.substr(0,6) << endl;
            out << s.substr(6, s.size()) << "[n]"<< endl;
            out << "#" << endl;
            ans.pop();
        }
        else if(s.substr(0,9) =="優子「"){
            out << "#" << s.substr(0,6) << endl;
            out << s.substr(6, s.size()) << "[n]"<< endl;
            out << "#" << endl;
            ans.pop();
        }
        else if(s.substr(0,6) =="清水"){
            out << "#" << s.substr(0,6) << endl;
            out << s.substr(6, s.size()) << "[n]"<< endl;
            out << "#" << endl;
            ans.pop();
        }
        else{
            out << ans.front() << "[n]" << endl << endl; //[n]で改行
            ans.pop();
        }
    }
}

int main(void){ 
    cin.tie(0);
    ios::sync_with_stdio(false);
    solve();
    in.close();
    out.close();
    return 0;
}