#!/bin/bash

# School Management System - Quick Setup Script (macOS/Linux)
# This script helps set up the project quickly

echo "==============================================="
echo "  School Management System - Setup Script"
echo "==============================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"
echo ""

ALL_PREREQUISITES_MET=true

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}[✓] Node.js: $NODE_VERSION${NC}"
else
    echo -e "${RED}[✗] Node.js not found. Please install from https://nodejs.org/${NC}"
    ALL_PREREQUISITES_MET=false
fi

# Check npm
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}[✓] npm: v$NPM_VERSION${NC}"
else
    echo -e "${RED}[✗] npm not found${NC}"
    ALL_PREREQUISITES_MET=false
fi

# Check Flutter
if command_exists flutter; then
    echo -e "${GREEN}[✓] Flutter SDK installed${NC}"
else
    echo -e "${RED}[✗] Flutter not found. Please install from https://flutter.dev/${NC}"
    ALL_PREREQUISITES_MET=false
fi

# Check MongoDB
if command_exists mongod; then
    echo -e "${GREEN}[✓] MongoDB installed${NC}"
else
    echo -e "${YELLOW}[!] MongoDB not found. You can:${NC}"
    echo -e "${YELLOW}    - Install locally: https://www.mongodb.com/try/download/community${NC}"
    echo -e "${YELLOW}    - Or use MongoDB Atlas: https://www.mongodb.com/cloud/atlas${NC}"
fi

echo ""

if [ "$ALL_PREREQUISITES_MET" = false ]; then
    echo -e "${RED}Please install missing prerequisites and run this script again.${NC}"
    exit 1
fi

echo -e "${GREEN}All prerequisites met! Proceeding with setup...${NC}"
echo ""

# Setup Backend
echo -e "${CYAN}===============================================${NC}"
echo -e "${CYAN}  Setting up Backend${NC}"
echo -e "${CYAN}===============================================${NC}"
echo ""

cd backend || exit

echo -e "${YELLOW}Installing backend dependencies...${NC}"
npm install

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓] Backend dependencies installed successfully${NC}"
else
    echo -e "${RED}[✗] Failed to install backend dependencies${NC}"
    cd ..
    exit 1
fi

# Create .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Creating .env file...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}[!] Please edit backend/.env with your configuration${NC}"
    echo -e "${YELLOW}    MongoDB URI, JWT secrets, etc.${NC}"
fi

cd ..
echo ""

# Setup Flutter App
echo -e "${CYAN}===============================================${NC}"
echo -e "${CYAN}  Setting up Flutter App${NC}"
echo -e "${CYAN}===============================================${NC}"
echo ""

cd flutter_app || exit

echo -e "${YELLOW}Installing Flutter dependencies...${NC}"
flutter pub get

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓] Flutter dependencies installed successfully${NC}"
else
    echo -e "${RED}[✗] Failed to install Flutter dependencies${NC}"
    cd ..
    exit 1
fi

# Create asset directories
echo -e "${YELLOW}Creating asset directories...${NC}"

DIRECTORIES=(
    "assets"
    "assets/images"
    "assets/icons"
    "assets/animations"
    "assets/fonts"
)

for DIR in "${DIRECTORIES[@]}"; do
    if [ ! -d "$DIR" ]; then
        mkdir -p "$DIR"
        echo "  Created: $DIR"
    fi
done

echo -e "${GREEN}[✓] Asset directories created${NC}"

cd ..
echo ""

# Final instructions
echo -e "${CYAN}===============================================${NC}"
echo -e "${CYAN}  Setup Complete!${NC}"
echo -e "${CYAN}===============================================${NC}"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo -e "${NC}1. Configure Backend:${NC}"
echo "   - Edit backend/.env with your MongoDB URI and JWT secrets"
echo ""
echo -e "${NC}2. Start MongoDB:${NC}"
echo "   - Local: Run 'mongod' or start MongoDB service"
echo "   - Or use MongoDB Atlas cloud database"
echo ""
echo -e "${NC}3. Start Backend Server:${NC}"
echo "   cd backend"
echo "   npm run dev"
echo ""
echo -e "${NC}4. Configure Flutter API URL:${NC}"
echo "   - Edit flutter_app/lib/utils/constants.dart"
echo "   - Set baseUrl to your backend URL"
echo "   - For Android Emulator: http://10.0.2.2:5000/api"
echo "   - For iOS Simulator: http://localhost:5000/api"
echo ""
echo -e "${NC}5. Run Flutter App:${NC}"
echo "   cd flutter_app"
echo "   flutter run"
echo ""
echo -e "${NC}6. Login with demo credentials:${NC}"
echo "   Admin: admin@school.com / admin123"
echo "   (Create this user via API or MongoDB)"
echo ""

echo -e "${CYAN}For detailed instructions, see SETUP_GUIDE.md${NC}"
echo ""
