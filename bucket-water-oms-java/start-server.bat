@echo off
cd /d "%~dp0"
echo Starting Java Backend...
mvn spring-boot:run -DskipTests
