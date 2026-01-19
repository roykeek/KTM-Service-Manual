# KTM 790 Adventure R - Interactive Service Schedule

## Description

An interactive web-based service schedule reference tool for the KTM 790 Adventure R motorcycle. This tool provides a comprehensive maintenance checklist with direct links to the official service manual, featuring a split-screen interface for easy reference.

## Features

- **Comprehensive Service Schedule**: Covers all service intervals from 1,000 km (break-in) to 105,000 km
- **Split-Screen Interface**: Service schedule table on the left, PDF manual viewer on the right
- **Smooth Page Navigation**: Click any page number to instantly navigate to that section in the PDF
- **Organized Categories**: 
  - Engine & Intake
  - Brakes
  - Chassis & Controls
  - Electrical & Cooling
- **Fully Responsive Design**: Optimized layout for both desktop and mobile devices
  - Desktop: Side-by-side layout with full table and PDF viewer
  - Mobile: Stacked layout with optimized spacing and sizing
- **Accessibility Features**: Keyboard navigation support and comprehensive ARIA labels

## Files Required

- `index.html` or `KTM_service_Manual.html` - The main HTML file
- `KTM790_2020_ServiceManual.pdf` - The KTM service manual PDF (stored in the repository)

Note: The PDF is served via jsDelivr CDN and rendered using Mozilla's PDF.js viewer for reliable cross-platform compatibility on desktop and mobile devices.

## How to Use

### Option 1: Python Web Server (Recommended)

1. Open a terminal/command prompt in the folder containing the HTML file
2. Run:
   ```bash
   python -m http.server 8000
   ```
3. Open your browser and go to: `http://localhost:8000/KTM_service_Manual.html`
4. Press `Ctrl+C` in the terminal to stop the server when done

**Requirements**: Python installed on your computer

### Option 2: VS Code Live Server Extension

1. Install the "Live Server" extension in VS Code:
   - Open Extensions panel (`Ctrl+Shift+X`)
   - Search for "Live Server" by Ritwick Dey
   - Click Install
2. Right-click `KTM_service_Manual.html` in VS Code
3. Select "Open with Live Server"

### Option 3: Open Directly (Full Functionality Online)

1. Double-click `KTM_service_Manual.html` to open in your default browser
2. **Local Usage**: PDF will work if files are served through a web server
3. **Online Usage**: Visit the GitHub Pages URL for full functionality with CDN-served PDF

## Browser Compatibility

- ✅ Microsoft Edge
- ✅ Google Chrome
- ✅ Firefox
- ✅ Safari
- ✅ Mobile browsers (Chrome/Firefox on Android/iOS)

## Using on Android/Mobile Devices

### Option 1: Access from PC Web Server (Recommended for Home Use)

1. Start the Python web server on your PC (see Option 1 above)
2. Find your PC's IP address:
   - Windows: Run `ipconfig` in command prompt
   - Look for "IPv4 Address" (e.g., `192.168.1.100`)
3. On your Android device (connected to same WiFi network):
   - Open Chrome or Firefox
   - Navigate to: `http://YOUR_PC_IP:8000/KTM_service_Manual.html`
   - Example: `http://192.168.1.100:8000/KTM_service_Manual.html`

### Option 2: GitHub Pages (For Access Anywhere)

Host the files online for free:
1. Create a free GitHub account at https://github.com
2. Create a new repository and upload both files
3. Enable GitHub Pages in repository Settings
4. Access from any device via the GitHub Pages URL

### Option 3: Android Web Server App

1. Install a web server app from Google Play Store:
   - Simple HTTP Server
   - HTTP Server by Paw
   - Servers Ultimate
2. Copy HTML and PDF files to your phone's storage
3. Configure the app to serve the folder
4. Access via `http://localhost:PORT/KTM_service_Manual.html`

### Option 4: Direct File Access (Limited Functionality)

1. Copy both files to your phone
2. Open HTML file with Chrome/Firefox
3. **Note**: PDF may not display in iframe, but page links will open PDF in new tabs

## Usage Tips

- Click any page number in the "Page" column to navigate to that section in the PDF
- Use the table to track which services are due at each mileage interval
- The checkmark (●) indicates when a service is required
- Break-in service at 1,000 km is mandatory for new motorcycles
- Valve clearance checks are required every 30,000 km
- Annual services (15k intervals) should be performed every 12 months regardless of mileage

## Troubleshooting

**Problem**: PDF doesn't display in the right panel  
**Solution**: The application works best when accessed online or through a web server. For local testing, use a Python web server or VS Code Live Server. The PDF is served via jsDelivr CDN for maximum compatibility.

**Problem**: Layout appears cramped on mobile  
**Solution**: The layout automatically adjusts for mobile devices. Try refreshing the page or rotating your device. The table and PDF viewer are stacked vertically on screens smaller than 768px width.

**Problem**: Clicking page numbers doesn't navigate smoothly  
**Solution**: Ensure you're using an updated version of the application (latest commit). Page navigation is optimized for smooth transitions without flickering.

**Problem**: PDF file not found  
**Solution**: Ensure `KTM790_2020_ServiceManual.pdf` is in the same folder as the HTML file.

## Technical Details

- Pure HTML, CSS, and JavaScript - no external dependencies
- PDF served via jsDelivr CDN and rendered with Mozilla PDF.js viewer
- PDF.js provides reliable cross-platform viewing on desktop, mobile, and all browsers
- JavaScript handles page navigation with optimized direct PDF anchor links
- Responsive flexbox layout with mobile-first approach for all screen sizes
- Sticky table header for easy reference while scrolling
- Fully compatible with Chrome, Firefox, Safari on desktop, Android, and iOS
- **Recent improvements** (January 2026):
  - Enhanced mobile responsiveness with optimized minimum widths
  - Improved mobile CSS with better typography and spacing
  - Fixed PDF navigation for smooth page transitions
  - Better touch-friendly link sizes on mobile devices

---

**Last Updated**: January 19, 2026  
**Motorcycle**: KTM 790 Adventure R (2020)  
**Manual Version**: 2020 Service Manual
