//  gcc -mwindows -o acrord32.exe acrord32.c
#include <windows.h>
#include <shellapi.h>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    // lpCmdLine enthält alle Argumente als einen String
    ShellExecute(NULL, "open", "SumatraPDF.exe", lpCmdLine, NULL, SW_SHOWNORMAL);
    return 0;
}
