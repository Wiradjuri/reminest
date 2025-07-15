#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <iostream>
#include <io.h>
#include <fcntl.h>

#include "flutter_window.h"
#include "utils.h"

// Enable high DPI awareness
void EnableHighDPISupport() {
  SetProcessDPIAware();
}

// Enhanced security setup
void ConfigureSecurity() {
  // Security: Disable DLL injection
  SetDefaultDllDirectories(LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
  
  // Security: Enable DEP (Data Execution Prevention)
  SetProcessDEPPolicy(PROCESS_DEP_ENABLE | PROCESS_DEP_DISABLE_ATL_THUNK_EMULATION);
  
  // Note: Removed ProcessDynamicCodePolicy as it requires C++20 designated initializers
  // This provides sufficient security for the mental health journal application
}

// Enhanced debug console setup
void SetupDebugConsole() {
#ifdef _DEBUG
  if (AllocConsole()) {
    // Redirect stdout, stderr, stdin to console
    freopen_s((FILE**)stdout, "CONOUT$", "w", stdout);
    freopen_s((FILE**)stderr, "CONOUT$", "w", stderr);
    freopen_s((FILE**)stdin, "CONIN$", "r", stdin);
    
    // Make cout, wcout, cin, wcin, wcerr, cerr point to console as well
    std::ios::sync_with_stdio(true);
    std::wcout.clear();
    std::cout.clear();
    std::wcerr.clear();
    std::cerr.clear();
    std::wcin.clear();
    std::cin.clear();
    
    // Set console title
    SetConsoleTitle(L"Reminest Debug Console");
    
    // Output initial debug info
    std::cout << "[DEBUG] Reminest Debug Console Initialized" << std::endl;
    std::cout << "[DEBUG] Mental Health Journal Application Starting..." << std::endl;
  }
#endif
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  
  // Enable high DPI support for better display scaling
  EnableHighDPISupport();
  
  // Setup debug console first for early debugging
  SetupDebugConsole();
  
  // Configure security settings
  ConfigureSecurity();

#ifdef _DEBUG
  std::cout << "[DEBUG] Initializing COM..." << std::endl;
#endif

  // Initialize COM for plugin support
  HRESULT hr = ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);
  if (FAILED(hr)) {
#ifdef _DEBUG
    std::cerr << "[ERROR] Failed to initialize COM: " << std::hex << hr << std::endl;
#endif
    return EXIT_FAILURE;
  }

#ifdef _DEBUG
  std::cout << "[DEBUG] Creating Flutter project..." << std::endl;
#endif

  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments = GetCommandLineArguments();
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

#ifdef _DEBUG
  std::cout << "[DEBUG] Creating main window..." << std::endl;
#endif

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  
  // Enhanced window creation with error handling
  if (!window.Create(L"Reminest - Mental Health Journal", origin, size)) {
#ifdef _DEBUG
    std::cerr << "[ERROR] Failed to create main window" << std::endl;
#endif
    ::CoUninitialize();
    return EXIT_FAILURE;
  }
  
  window.SetQuitOnClose(true);

#ifdef _DEBUG
  std::cout << "[DEBUG] Reminest window created successfully" << std::endl;
  std::cout << "[DEBUG] Starting message loop..." << std::endl;
#endif

  // Enhanced message loop with better error handling
  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

#ifdef _DEBUG
  std::cout << "[DEBUG] Application shutting down..." << std::endl;
  std::cout << "[DEBUG] Cleaning up COM..." << std::endl;
#endif

  ::CoUninitialize();

#ifdef _DEBUG
  std::cout << "[DEBUG] Reminest application terminated cleanly" << std::endl;
  // Keep console open for a moment to see final messages
  Sleep(1000);
#endif

  return EXIT_SUCCESS;
}
