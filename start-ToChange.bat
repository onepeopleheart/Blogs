@echo off
cd /d "%~dp0"
echo Starting Hugo Server...
echo Press Ctrl+C to stop
echo.
hugo server -D --navigateToChanged
pause
