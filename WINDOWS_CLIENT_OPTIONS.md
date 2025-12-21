# Windows OTClient Options for The Violet Project

Since you need OTClient for Windows to connect to your VPS server, here are your best options:

## Option 1: Download Pre-Built OTClient for Windows (RECOMMENDED)

### OTLand Community Builds
Pre-compiled Windows builds are available at:
- **OTLand Forum**: http://otland.net/threads/otclient-builds-windows.217977/
- These are regularly updated and ready to use

### Steps:
1. Download the latest Windows build from OTLand
2. Extract the archive
3. Get Tibia 7.72 data files (Tibia.spr, Tibia.dat)
4. Place them in `data/things/772/`
5. Run `otclient.exe`
6. Add your VPS server:
   - Host: Your VPS public IP
   - Port: 7171
   - Protocol: 7.72

## Option 2: Use Official Tibia 7.72 Client with IP Changer (EASIEST)

### What You Need:
- Official Tibia 7.72 client
- IP Changer tool (e.g., TibiaAuto, OldTibia IP Changer)

### Steps:
1. Install Tibia 7.72 client
2. Use IP changer to redirect login server to your VPS IP
3. Launch client and login with:
   - Account: 1234570
   - Password: test123

### Popular IP Changers:
- **TibiaAuto IP Changer**
- **OldTibia IP Changer**
- You can create a simple hosts file modification

## Option 3: Build OTClient on Windows

If you want to build it yourself on Windows:

### Requirements:
- Visual Studio 2019 or later with C++ tools
- vcpkg for dependency management
- Git

### Build Steps:
```batch
# Install vcpkg
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
.\bootstrap-vcpkg.bat
.\vcpkg integrate install

# Install OTClient dependencies
.\vcpkg install boost-iostreams:x64-windows boost-asio:x64-windows boost-system:x64-windows ^
    boost-variant:x64-windows boost-lockfree:x64-windows boost-filesystem:x64-windows ^
    boost-uuid:x64-windows glew:x64-windows luajit:x64-windows libogg:x64-windows ^
    libvorbis:x64-windows openal-soft:x64-windows opengl:x64-windows openssl:x64-windows ^
    physfs:x64-windows zlib:x64-windows

# Clone and build OTClient
git clone https://github.com/edubart/otclient.git
cd otclient
mkdir build && cd build

cmake .. -G "Visual Studio 16 2019" -A x64 ^
    -DCMAKE_TOOLCHAIN_FILE=C:/path/to/vcpkg/scripts/buildsystems/vcpkg.cmake ^
    -DCMAKE_BUILD_TYPE=Release -DLUAJIT=ON

cmake --build . --config Release
```

## Option 4: GitHub Actions Artifacts

OTClient builds Windows binaries via GitHub Actions. You can:
1. Fork the repository
2. Trigger a build
3. Download the Windows artifact from the Actions tab

## Recommended Configuration for Your VPS

### Server Details:
- **IP**: Your VPS public IP (get from VPS provider)
- **Port**: 7171 (login), 7172 (game)
- **Protocol**: 7.72

### Test Account:
- **Account**: 1234570
- **Password**: test123
- **Character**: Violet Admin

## What About the Linux Build?

The OTClient we built on your VPS is for Linux and cannot run on Windows. However:
- ✅ It's useful if you want to test locally on the VPS with X11
- ✅ It demonstrates the build process
- ✅ You could copy it to another Linux machine

## My Recommendation

**For fastest setup on Windows**:
1. Use the **Original Tibia 7.72 client** with an **IP changer** (Option 2)
   - This is the simplest and most reliable method
   - Works immediately with no complex setup
   - Most compatible with 7.72 protocol

2. Alternatively, download **pre-built OTClient** from OTLand (Option 1)
   - More modern interface
   - Better features and customization
   - Still compatible with your server

## Need Help?

If you want me to:
- Create an IP changer script for Windows
- Write detailed setup instructions for a specific method
- Help configure your Windows client

Just let me know which option you prefer!

## Summary

❌ Cannot easily cross-compile OTClient for Windows from Linux VPS  
✅ Pre-built Windows OTClient available on OTLand  
✅ Original Tibia 7.72 client + IP changer is easiest  
✅ Your VPS server is ready and waiting for connections  
✅ Test account ready: 1234570/test123  
